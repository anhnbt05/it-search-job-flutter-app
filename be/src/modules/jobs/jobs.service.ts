import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  InternalServerErrorException,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Cron } from '@nestjs/schedule';
import {
  Applications,
  ApplicationStatus,
  Candidates,
  Categories,
  Jobs,
  JobStatus,
  Level,
  NotificationType,
  Prisma,
  Recruiters,
  Role,
  Users,
} from '@prisma/client';
import { SupabaseClient } from '@supabase/supabase-js';
import { differenceInCalendarDays } from 'date-fns';
import { omit } from 'lodash';
import { InjectSupabaseClient } from 'nestjs-supabase-js';
import {
  AdminNewJobPostMetadata,
  handleFormatUserNotificationContent,
  RecruiterJobApprovedMetadata,
  RecruiterJobRejectedMetadata,
} from 'src/libs/common/utils';
import {
  CreateJobDto,
  CreateJobFavoritesDto,
  DeleteJobFavoritesDto,
  ProcessJobStatusDto,
  RejectedJobStatusDto,
  SearchJobQueryDto,
  UpdateJobDto,
} from 'src/modules/jobs/dtos';
import { PrismaService } from 'src/modules/prisma/prisma.service';
import { UserNotificationsService } from 'src/modules/user-notifications/user-notifications.service';
import { UsersService } from 'src/modules/users/users.service';

@Injectable()
export class JobsService {
  private readonly logger = new Logger(JobsService.name);

  constructor(
    @InjectSupabaseClient('adminClient')
    private readonly adminSupabaseClient: SupabaseClient,
    @InjectSupabaseClient('anonClient')
    private readonly anonSupabaseClient: SupabaseClient,
    private readonly usersService: UsersService,
    private readonly userNotificationsService: UserNotificationsService,
    private readonly configService: ConfigService,
    private readonly prismaService: PrismaService,
  ) {}

  @Cron('0 0 * * *')
  async handleCheckJobsExpired() {
    this.logger.log(
      'Đang kiểm tra các công việc đã hết hạn hoặc sắp hết hạn...',
    );

    const { data: jobs } = await this.anonSupabaseClient
      .from('Jobs')
      .select('*, Recruiters(*)')
      .overrideTypes<any[], { merge: false }>();

    if (!jobs) {
      this.logger.log('Không tìm thấy công việc nào cần kiểm tra, bỏ qua...');
      return;
    }

    this.logger.log(`Tìm thấy ${jobs.length} công việc cần kiểm tra.`);

    const { recruiter_job_expiring_soon, recruiter_job_expired } =
      NotificationType;

    for (const job of jobs) {
      const now = new Date();

      const expiredDay = new Date(job.ExpiredAt as string);

      const diffDays = differenceInCalendarDays(expiredDay, now);

      const recruiterId = job.Recruiters?.UserID as string;

      const jobTitle = job.Title;

      const jobId = job.ID;

      let metadata = {};

      if (diffDays === 2) {
        metadata = { jobExpiredAt: job.ExpiredAt, jobId, jobTitle };

        this.logger.log(
          `Công việc sắp hết hạn: "${jobTitle}" (ID: ${jobId}), còn ${diffDays} ngày.`,
        );

        await this.userNotificationsService.handleCreateUserNotification(
          {
            Content: handleFormatUserNotificationContent(
              recruiter_job_expiring_soon,
              metadata,
            ),
            Type: recruiter_job_expiring_soon,
            metadata,
          },
          recruiterId,
        );

        this.logger.log(
          `Đã gửi thông báo sắp hết hạn cho nhà tuyển dụng có id '${recruiterId}'`,
        );
      } else if (diffDays <= 0) {
        metadata = {
          jobTitle,
          jobId,
        };

        this.logger.log(
          `Công việc đã hết hạn: "${jobTitle}" (ID: ${jobId}), cập nhật trạng thái...`,
        );

        const { error } = await this.adminSupabaseClient
          .from('Jobs')
          .update([
            {
              status: JobStatus.closed,
            },
          ])
          .eq('ID', job.ID);

        if (error) {
          this.logger.error(
            `Lỗi khi cập nhật trạng thái công việc có id '${jobId}'`,
            error,
          );

          throw new InternalServerErrorException(
            'Đã xảy ra lỗi khi cập nhật trạng thái của công việc.',
          );
        }

        this.logger.log(
          `Đã đóng công việc "${jobTitle}" (ID: ${jobId}) thành công.`,
        );

        await this.userNotificationsService.handleCreateUserNotification(
          {
            Content: handleFormatUserNotificationContent(
              recruiter_job_expired,
              metadata,
            ),
            Type: recruiter_job_expired,
            metadata,
          },
          recruiterId,
        );

        this.logger.log(
          `Đã gửi thông báo hết hạn cho nhà tuyển dụng có id '${recruiterId}'`,
        );
      }
    }
  }

  public handleGetJobs = async (
    userId: string,
    searchJobQueryDto?: SearchJobQueryDto,
  ) => {
    try {
      const { data: user, error } = await this.anonSupabaseClient
        .from('Users')
        .select('*')
        .eq('ID', userId)
        .maybeSingle<Users>();

      if (!user || error)
        throw new NotFoundException(
          `Không tìm thấy người dùng có id '${userId}'`,
        );

      const isRecruiter = user.Role === Role.recruiter ? true : false;

      const isAdmin = user.Role === Role.admin ? true : false;

      const query = this.anonSupabaseClient
        .from('Jobs')
        .select(
          '*, Recruiters(*, Users(FullName, AvatarUrl), CompanyLocations(*, Companies(*))), JobCategories(*, Categories(*))',
        );

      if (isRecruiter) {
        const { data, error } = await this.anonSupabaseClient
          .from('Recruiters')
          .select('*')
          .eq('UserID', userId)
          .maybeSingle<Recruiters>();

        if (!data || error)
          throw new NotFoundException(
            `Không tìm thấy nhà tuyển dụng liên kết với người dùng có id '${userId}'`,
          );

        query.match({
          RecruiterID: data.ID,
        });
      } else if (isAdmin) {
        query.match({ Status: JobStatus.pending }).is('DeletedAt', null);
      } else {
        query.match({ Status: JobStatus.open }).is('DeletedAt', null);
      }

      const { data: jobs, error: jobsError } = await query.overrideTypes<
        any[],
        { merge: false }
      >();

      if (jobsError)
        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi lấy danh sách các công việc.',
        );

      let formattedJobs = jobs?.map((job) => {
        return {
          ...omit(job, ['RecruiterID', 'Recruiters', 'JobCategories']),
          Recruiter: {
            ...omit(job.Recruiters, [
              'Users',
              'UserID',
              'CompanyLocationID',
              'CompanyLocations',
            ]),
            AvatarUrl: job.Recruiters.Users.AvatarUrl,
            FullName: job.Recruiters.Users.FullName,
            Company: job.Recruiters.CompanyLocations.Companies,
          },
          Categories: job.JobCategories.map(
            (jc: any) => jc.Categories.CategoryName,
          ),
        };
      });

      if (searchJobQueryDto?.categoryNames?.length) {
        const { categoryNames } = searchJobQueryDto;

        const filtered = formattedJobs.filter((fj) =>
          fj.Categories.some((jobCategory: string) =>
            categoryNames.includes(jobCategory),
          ),
        );

        formattedJobs = [...filtered];
      }

      if (searchJobQueryDto?.locationId?.trim()) {
        const { locationId } = searchJobQueryDto;

        const jobs = await this.handleSearchJobsByLocations(
          locationId,
          isAdmin
            ? JobStatus.pending
            : !isRecruiter
              ? JobStatus.open
              : undefined,
        );

        const jobIds = jobs.map((job: any) => job.ID);

        const filtered = formattedJobs.filter((fj: any) =>
          jobIds.includes(fj.ID),
        );

        formattedJobs = [...filtered];
      }

      return formattedJobs;
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleGetJob = async (jobId: string, userId: string) => {
    try {
      const { data: user } = await this.anonSupabaseClient
        .from('Users')
        .select('*')
        .eq('ID', userId)
        .maybeSingle<Users>();

      if (!user)
        throw new NotFoundException(
          `Không tìm thấy người dùng có id '${userId}'`,
        );

      const isRecruiter = user.Role === Role.recruiter ? true : false;

      const query = this.anonSupabaseClient
        .from('Jobs')
        .select(
          '*, Recruiters(*, Users(*) ,CompanyLocations(*, Companies(*)))',
        );

      if (isRecruiter) {
        const { data, error } = await this.anonSupabaseClient
          .from('Recruiters')
          .select('*')
          .eq('UserID', userId)
          .maybeSingle<Recruiters>();

        if (!data || error)
          throw new NotFoundException(
            `Không tìm thấy nhà tuyển dụng liên kết với người dùng có id '${userId}'`,
          );

        query.match({ RecruiterID: data.ID, ID: jobId });
      } else {
        query.eq('ID', jobId);
      }

      const { data: job, error: jobError } = await query.maybeSingle<any>();

      if (!job || jobError) {
        if (isRecruiter)
          throw new NotFoundException(
            `Công việc có id '${jobId}' không phải do bạn đăng.`,
          );

        throw new NotFoundException(
          `Không tìm thấy công việc có id '${jobId}'`,
        );
      }

      if (
        (job.Status === JobStatus.closed ||
          job.Status === JobStatus.rejected) &&
        user.Role === Role.candidate
      )
        throw new BadRequestException(
          `Công việc có tiêu đề '${job.Title}' đã được đóng bởi nhà tuyển dụng công việc này rồi.`,
        );

      if (job.Status === JobStatus.pending && user.Role === Role.candidate)
        throw new BadRequestException(
          `Công việc có tiêu đề '${job.Title}' hiện đang trog quá trình chờ quản trị viên duyệt. Vui lòng quay lại sau.`,
        );

      return {
        ...(await this.handleFormattedJob(jobId)),
        Recruiter: {
          ...omit(job.Recruiters, [
            'CompanyLocations',
            'CompanyLocationID',
            'UserID',
            'Users',
          ]),
          FullName: job.Recruiters.Users.FullName,
          Company: job.Recruiters.CompanyLocations.Companies,
        },
      };
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleCreateJob = async (
    createJobDto: CreateJobDto,
    userId: string,
  ) => {
    try {
      const { data: user } = await this.anonSupabaseClient
        .from('Recruiters')
        .select('*, CompanyLocations(*, Companies(*))')
        .eq('UserID', userId)
        .maybeSingle<any>();

      if (!user)
        throw new NotFoundException(
          `Không tìm thấy nhà tuyển dụng có id '${userId}' trong hệ thống.`,
        );

      const {
        Title,
        Descriptions,
        Requirements,
        Benefits,
        Categories,
        ExpiredDate,
        ...res
      } = createJobDto;

      const { data: job, error: findJobError } = await this.anonSupabaseClient
        .from('Jobs')
        .select('*')
        .match({ Title, RecruiterID: user.ID })
        .maybeSingle<Jobs>();

      if (findJobError)
        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi lấy công việc.',
        );

      if (
        job &&
        (job.Status === JobStatus.open || job.Status === JobStatus.pending)
      )
        throw new BadRequestException(
          `Bạn đã đăng công việc có tiêu đề '${Title}' rồi.`,
        );

      if (new Date(ExpiredDate).getTime() < new Date().getTime())
        throw new BadRequestException(
          `Thời gian hết hạn của công việc phải lớn hơn thời gian hiện tại.`,
        );

      const { data, error } = await this.adminSupabaseClient
        .from('Jobs')
        .insert([
          {
            Title,
            ExpiredAt: ExpiredDate,
            RecruiterID: user.ID,
            ...res,
          },
        ])
        .select('*')
        .single<Jobs>();

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi thêm mới công việc.',
        );
      }

      const { error: insertDescriptionError } = await this.adminSupabaseClient
        .from('JobDescriptions')
        .insert(
          Descriptions.map((description) => ({
            Description: description,
            JobID: data.ID,
          })),
        );

      if (insertDescriptionError) {
        console.error(insertDescriptionError);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi thêm các mô tả cho công việc.',
        );
      }

      const { error: insertBenefitsError } = await this.adminSupabaseClient
        .from('JobBenefits')
        .insert(
          Benefits.map((benefit) => ({
            Benefit: benefit,
            JobID: data.ID,
          })),
        );

      if (insertBenefitsError) {
        console.error(insertBenefitsError);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi thêm các lợi ích cho công việc.',
        );
      }

      const { error: errorCreateRequirements } = await this.adminSupabaseClient
        .from('JobRequirements')
        .insert(
          Requirements.map((requirement) => ({
            Requirement: requirement,
            JobID: data.ID,
          })),
        );

      if (errorCreateRequirements) {
        console.error(errorCreateRequirements);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi thêm các yêu cầu cho công việc.',
        );
      }

      const categoryIds: string[] = [];

      for (const categoryName of Categories) {
        const { data, error } = await this.anonSupabaseClient
          .from('Categories')
          .select('ID')
          .eq('CategoryName', categoryName)
          .single<Categories>();

        if (error) {
          console.error(error);

          throw new InternalServerErrorException(
            'Đã xảy ra lỗi khi tìm tên danh mục của công việc.',
          );
        }

        categoryIds.push(data.ID);
      }

      const { error: errorCategoriesInsert } = await this.adminSupabaseClient
        .from('JobCategories')
        .insert(
          categoryIds.map((categoryId) => ({
            CategoryID: categoryId,
            JobID: data.ID,
          })),
        );

      if (errorCategoriesInsert)
        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi thêm danh mục cho công việc.',
        );

      const { data: admin } = await this.anonSupabaseClient
        .from('Users')
        .select('*')
        .eq('Email', this.configService.get<string>('admin.email', ''))
        .maybeSingle<Users>();

      if (!admin)
        throw new NotFoundException(
          `Không tìm thấy quản trị viên trong hệ thống.`,
        );

      const metadata: AdminNewJobPostMetadata = {
        jobId: data.ID,
        jobTitle: data.Title,
        recruiterId: data.RecruiterID,
        companyName: user?.CompanyLocations?.Companies?.Name,
      };

      const { admin_new_job_post } = NotificationType;

      await this.userNotificationsService.handleCreateUserNotification(
        {
          Content: handleFormatUserNotificationContent(
            admin_new_job_post,
            metadata,
          ),
          Type: admin_new_job_post,
          metadata,
        },
        admin.ID,
      );

      return this.handleGetJobs(userId);
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleGetCategories = async () => {
    return (
      (
        await this.anonSupabaseClient
          .from('Categories')
          .select('ID,CategoryName')
      )?.data ?? []
    );
  };

  public handleUpdateJob = async (
    jobId: string,
    updateJobDto: UpdateJobDto,
  ) => {
    try {
      const { data } = await this.anonSupabaseClient
        .from('Jobs')
        .select('*, Recruiters(*, CompanyLocations(*, Companies(*)))')
        .eq('ID', jobId)
        .maybeSingle<any>();

      if (!data)
        throw new NotFoundException(
          `Không tìm thấy công việc có id '${jobId}'.`,
        );

      if (data.Status === JobStatus.open || data.Status === JobStatus.closed)
        throw new BadRequestException(
          `Bạn không thể cập nhật công việc đang ${data.Status === JobStatus.open ? 'mở' : 'đóng'}.`,
        );

      if (!updateJobDto || !Object.keys(updateJobDto).length)
        throw new BadRequestException(
          `Vui lòng cung cấp thông tin để cập nhật công việc.`,
        );

      if (
        updateJobDto?.ExpiredDate &&
        new Date(updateJobDto.ExpiredDate).getTime() < new Date().getTime()
      )
        throw new BadRequestException(
          'Thời gian hết hạn mới của công việc phải lớn hơn thời gian hiện tại.',
        );

      const {
        Descriptions,
        Benefits,
        Requirements,
        ExpiredDate,
        Categories,
        ...res
      } = updateJobDto;

      const { error } = await this.anonSupabaseClient
        .from('Jobs')
        .update({
          ...res,
          ...(ExpiredDate && {
            ExpiredAt: new Date(ExpiredDate),
          }),
        })
        .eq('ID', jobId);

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi cập nhật công việc.',
        );
      }

      if (Descriptions && Descriptions.length) {
        await this.handleSyncJobDetails(
          'JobDescriptions',
          'Description',
          Descriptions,
          jobId,
        );
      }

      if (Benefits && Benefits.length) {
        await this.handleSyncJobDetails(
          'JobBenefits',
          'Benefit',
          Benefits,
          jobId,
        );
      }

      if (Requirements && Requirements.length) {
        await this.handleSyncJobDetails(
          'JobRequirements',
          'Requirement',
          Requirements,
          jobId,
        );
      }

      if (Categories && Categories.length) {
        const foundCategories = await this.prismaService.categories.findMany({
          where: {
            CategoryName: {
              in: Categories,
            },
          },
        });

        if (foundCategories.length !== Categories.length) {
          const foundNames = new Set(
            foundCategories.map((c) => c.CategoryName),
          );

          const missing = Categories.filter((name) => !foundNames.has(name));

          throw new NotFoundException(
            `Không tìm thấy các danh mục sau: ${missing.join(', ')}.`,
          );
        }

        const existingValues = foundCategories.map((c) => c.ID);

        const existingCategories = (
          await this.prismaService.jobCategories.findMany({
            where: {
              JobID: jobId,
            },
          })
        ).map((jc) => jc.CategoryID);

        const newSet = new Set(existingValues);

        const existingCategoriesSet = new Set(existingCategories);

        const toAdd = existingValues.filter(
          (val) => !existingCategoriesSet.has(val),
        );

        const toRemove = existingCategories.filter((val) => !newSet.has(val));

        if (toRemove.length)
          await this.adminSupabaseClient
            .from('JobCategories')
            .delete()
            .eq('JobID', jobId)
            .in('CategoryID', toRemove);

        if (toAdd.length) {
          await this.adminSupabaseClient.from('JobCategories').insert(
            toAdd.map((val) => ({
              CategoryID: val,
              JobID: jobId,
            })),
          );
        }
      }

      if (data.Status === JobStatus.rejected) {
        await this.prismaService.jobs.update({
          where: {
            ID: data.ID,
          },
          data: {
            Status: JobStatus.pending,
          },
        });

        const { data: admin } = await this.anonSupabaseClient
          .from('Users')
          .select('*')
          .eq('Email', this.configService.get<string>('admin.email', ''))
          .maybeSingle<Users>();

        if (!admin)
          throw new NotFoundException(
            `Không tìm thấy quản trị viên trong hệ thống.`,
          );

        const metadata: AdminNewJobPostMetadata = {
          jobId: data.ID,
          jobTitle: data.Title,
          recruiterId: data.RecruiterID,
          companyName: data?.Recruiters?.CompanyLocations?.Companies?.Name,
        };

        const { admin_new_job_post } = NotificationType;

        await this.userNotificationsService.handleCreateUserNotification(
          {
            Content: handleFormatUserNotificationContent(
              admin_new_job_post,
              metadata,
            ),
            Type: admin_new_job_post,
            metadata,
          },
          admin.ID,
        );
      }

      return this.handleFormattedJob(jobId);
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleSyncJobDetails = async (
    tableName: string,
    fieldName: string,
    newValues: string[],
    jobId: string,
  ) => {
    try {
      if (!newValues || !newValues.length) return;

      const existingValues: string[] =
        (
          await this.anonSupabaseClient
            .from(tableName)
            .select(fieldName)
            .eq('JobID', jobId)
        )?.data?.map((item) => item[fieldName]) || [];

      const newSet = new Set(newValues);

      const existingSet = new Set(existingValues);

      const toAdd = newValues.filter((val) => !existingSet.has(val));

      const toRemove = existingValues.filter((val) => !newSet.has(val));

      if (toRemove.length) {
        await this.adminSupabaseClient
          .from(tableName)
          .delete()
          .in(fieldName, toRemove);
      }

      if (toAdd.length) {
        await this.adminSupabaseClient.from(tableName).insert(
          toAdd.map((val) => ({
            [fieldName]: val,
            JobID: jobId,
          })),
        );
      }
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleDeleteJob = async (jobId: string, userId: string) => {
    try {
      const { data: user, error } = await this.anonSupabaseClient
        .from('Users')
        .select('*')
        .eq('ID', userId)
        .maybeSingle<Users>();

      if (!user || error)
        throw new NotFoundException(
          `Không tìm thấy người dùng có id '${userId}'`,
        );

      const { data: job, error: jobError } = await this.anonSupabaseClient
        .from('Jobs')
        .select('*')
        .eq('ID', jobId)
        .maybeSingle<Jobs>();

      if (!job || jobError)
        throw new NotFoundException(
          `Không tìm thấy công việc có id '${jobId}'.`,
        );

      const isRecruiter = user.Role === Role.recruiter ? true : false;

      if (isRecruiter) {
        const { data: recruiter, error } = await this.anonSupabaseClient
          .from('Recruiters')
          .select('*')
          .eq('UserID', userId)
          .maybeSingle<Recruiters>();

        if (error) {
          console.error(error);

          throw new InternalServerErrorException(
            'Đã xảy ra lỗi khi lấy thông tin nhà tuyển dụng.',
          );
        }

        if (!recruiter)
          throw new NotFoundException(
            `Không tìm thấy nhà tuyển dụng mà liên kết với user có id '${userId}'`,
          );

        if (job.RecruiterID !== recruiter.ID)
          throw new ForbiddenException(
            `Bạn chỉ được phép xoá công việc mà bạn đăng.`,
          );
      }

      await this.adminSupabaseClient
        .from('Jobs')
        .update({
          DeletedAt: new Date().toISOString(),
          Status: JobStatus.closed,
        })
        .eq('ID', jobId);

      return this.handleGetJobs(userId);
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleProcessStatusOfJob = async (
    processJobStatusDto: ProcessJobStatusDto,
    userId: string,
  ) => {
    try {
      if (!processJobStatusDto || !Object.keys(processJobStatusDto).length)
        throw new BadRequestException(
          `Bạn phải cung cấp các thông tin của các công việc cần cập nhật trạng thái.`,
        );

      const { openJobIds, rejectedJobs } = processJobStatusDto;

      if (openJobIds && openJobIds.length) {
        await this.generateProcessJobStatus('open', openJobIds);
      }

      if (rejectedJobs && rejectedJobs.length) {
        await this.generateProcessJobStatus('rejected', rejectedJobs);
      }

      return this.handleGetJobs(userId);
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  private generateProcessJobStatus = async (
    method: 'open' | 'rejected',
    items: string[] | RejectedJobStatusDto[],
  ) => {
    const status = method === 'open' ? JobStatus.open : JobStatus.rejected;

    if (status === 'open') {
      await Promise.all(
        (items as string[]).map(async (item) => {
          const job = await this.handleVerifyJob(item);

          const metadata: RecruiterJobApprovedMetadata = {
            jobId: job.ID,
            jobTitle: job.Title,
          };

          const { recruiter_job_approved } = NotificationType;

          await this.userNotificationsService.handleCreateUserNotification(
            {
              Content: handleFormatUserNotificationContent(
                recruiter_job_approved,
                metadata,
              ),
              Type: recruiter_job_approved,
              metadata,
            },
            job.Recruiters.Users.ID as string,
          );
        }),
      );
    } else if (status === 'rejected') {
      await Promise.all(
        (items as RejectedJobStatusDto[]).map(async (item) => {
          const { jobId, reason } = item;

          const job = await this.handleVerifyJob(jobId);

          const { recruiter_job_rejected } = NotificationType;

          const metadata: RecruiterJobRejectedMetadata = {
            jobId: jobId,
            jobTitle: job.Title,
            reason: reason ? reason : '',
          };

          await this.userNotificationsService.handleCreateUserNotification(
            {
              Content: handleFormatUserNotificationContent(
                recruiter_job_rejected,
                metadata,
              ),
              Type: recruiter_job_rejected,
              metadata,
            },
            job.Recruiters.Users.ID as string,
          );
        }),
      );
    }

    const { error } = await this.adminSupabaseClient
      .from('Jobs')
      .update({ Status: status })
      .in(
        'ID',
        status === 'open'
          ? (items as string[])
          : (items as RejectedJobStatusDto[]).map((j) => j.jobId),
      );

    if (error) {
      console.error(error);

      throw new InternalServerErrorException(
        'Đã xảy ra lỗi khi cập nhật trạng thái của công việc.',
      );
    }
  };

  public handleGetJobFavorites = async (userId: string) => {
    const { data: candidate } = await this.anonSupabaseClient
      .from('Candidates')
      .select('*')
      .eq('UserID', userId)
      .maybeSingle<Candidates>();

    if (!candidate)
      throw new NotFoundException(
        'Không tìm thấy ứng viên này trong hệ thống.',
      );

    const { data: jobFavorites, error } = await this.anonSupabaseClient
      .from('JobFavorites')
      .select(
        '*, Jobs(*, JobBenefits(*), JobRequirements(*), JobDescriptions(*), Recruiters(*, Users(*) ,CompanyLocations(*, Companies(*))) ,JobCategories(*, Categories(CategoryName)))',
      )
      .eq('CandidateID', candidate.ID)
      .overrideTypes<any[], { merge: false }>();

    if (error) {
      console.error(error);

      throw new InternalServerErrorException(
        'Đã xảy ra lỗi trong quá trình lấy danh sách các công việc ưa thích của ứng viên.',
      );
    }

    return (
      jobFavorites.map((jf: any) => ({
        ...omit(jf, ['CandidateID', 'JobID', 'Jobs']),
        Job: {
          ...omit(jf.Jobs, ['JobCategories', 'Recruiters', 'RecruiterID']),
          Categories: jf?.Jobs.JobCategories?.map(
            (jc: any) => jc.Categories.CategoryName,
          ),
          Recruiter: {
            ID: jf.Jobs.Recruiters.ID,
            FullName: jf.Jobs.Recruiters.Users.FullName,
            Position: jf.Jobs.Recruiters.Position,
            Email: jf.Jobs.Recruiters.Users.Email,
            PhoneNumber: jf.Jobs.Recruiters.Users.PhoneNumber,
            AvatarUrl: jf.Jobs.Recruiters.Users.AvatarUrl,
            Company: {
              Name: jf.Jobs.Recruiters.CompanyLocations.Companies.Name,
              LogoUrl: jf.Jobs.Recruiters.CompanyLocations.Companies.LogoUrl,
            },
          },
          JobBenefits: jf.Jobs.JobBenefits.map((jb: any) => jb.Benefit),
          JobDescriptions: jf.Jobs.JobDescriptions.map(
            (jd: any) => jd.Description,
          ),
          JobRequirements: jf.Jobs.JobRequirements.map(
            (jr: any) => jr.Requirement,
          ),
        },
      })) ?? []
    );
  };

  public handleCreateJobFavorites = async (
    userId: string,
    createJobFavoritesDto: CreateJobFavoritesDto,
  ) => {
    try {
      const { data, error } = await this.anonSupabaseClient
        .from('Candidates')
        .select('*')
        .eq('UserID', userId)
        .maybeSingle<Candidates>();

      if (!data || error)
        throw new NotFoundException(
          `Không tìm thấy ứng cử viên có id '${userId}'`,
        );

      const { jobIds } = createJobFavoritesDto;

      const { error: insertJobFavortiesData } = await this.adminSupabaseClient
        .from('JobFavorites')
        .upsert(
          jobIds.map((jobID) => ({
            JobID: jobID,
            CandidateID: data.ID,
          })),
          {
            onConflict: 'JobID, CandidateID',
          },
        )
        .select('*');

      if (insertJobFavortiesData) {
        console.error(insertJobFavortiesData);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi thêm mới công việc ưa thích của ứng viên.',
        );
      }

      return {
        success: true,
        message: 'Danh sách công việc đã được lưu thành công.',
      };
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleDeleteJobFavorites = async (
    userId: string,
    deleteJobFavoritesDto: DeleteJobFavoritesDto,
  ) => {
    try {
      const { data, error } = await this.anonSupabaseClient
        .from('Candidates')
        .select('*')
        .eq('UserID', userId)
        .maybeSingle<Candidates>();

      if (!data || error)
        throw new NotFoundException(
          `Không tìm thấy ứng viên nào mà liên kết với người dùng có id '${userId}'`,
        );

      const { jobIds } = deleteJobFavoritesDto;

      await Promise.all(
        jobIds.map(async (jobId) => {
          const { error } = await this.adminSupabaseClient
            .from('JobFavorites')
            .delete()
            .match({ JobID: jobId, CandidateID: data.ID });

          if (error) {
            console.error(error);

            throw new InternalServerErrorException(
              'Đã xảy ra lỗi khi xoá công việc đã lưu.',
            );
          }
        }),
      );

      return {
        success: true,
        message: 'Các công việc đã lưu đã được xoá.',
      };
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleGetRecommendedJobsForCandidate = async (
    candidateId: string,
    userId: string,
  ) => {
    try {
      const { data, error } = await this.anonSupabaseClient
        .from('Candidates')
        .select('*')
        .eq('UserID', userId)
        .maybeSingle<Candidates>();

      if (!data || error)
        throw new NotFoundException(
          `Không tìm thấy ứng viên mà liên kết với người dùng có id '${userId}'`,
        );

      if (data.ID !== candidateId) return [];

      const candidateLevel = data.Level;

      const jobs = await this.prismaService.$queryRaw<any[]>`
        SELECT 
          j.*, 
          json_agg(DISTINCT r) AS recruiter, 
          json_agg(DISTINCT u) AS user, 
          json_agg(DISTINCT jb) AS job_benefits,
          json_agg(DISTINCT jd) AS job_descriptions,
          json_agg(DISTINCT jr) AS job_requirements,
          json_agg(DISTINCT c) AS company
        FROM "Jobs" j
          LEFT JOIN "Recruiters" r ON r."ID" = j."RecruiterID"
          LEFT JOIN "Users" u ON u."ID" = r."UserID"
          LEFT JOIN "CompanyLocations" cl ON cl."ID" = r."CompanyLocationID"
          LEFT JOIN "Companies" c ON c."ID" = cl."CompanyID"
          LEFT JOIN "JobBenefits" jb ON jb."JobID" = j."ID"
          LEFT JOIN "JobDescriptions" jd ON jd."JobID" = j."ID"
          LEFT JOIN "JobRequirements" jr ON jr."JobID" = j."ID"
        GROUP BY j."ID", r."ID"
        ORDER BY
          CASE 
            WHEN j."Level" = ${Prisma.sql`CAST(${candidateLevel} AS "Level")`} THEN 0
            WHEN ${Prisma.sql`CAST(${candidateLevel} AS "Level")`} = ${Prisma.sql`CAST(${Level.senior} AS "Level")`} AND j."Level" = ${Prisma.sql`CAST(${Level.senior} AS "Level")`} THEN 1
            WHEN ${Prisma.sql`CAST(${candidateLevel} AS "Level")`} = ${Prisma.sql`CAST(${Level.mid} AS "Level")`} AND j."Level" = ${Prisma.sql`CAST(${Level.mid} AS "Level")`} THEN 1
            WHEN ${Prisma.sql`CAST(${candidateLevel} AS "Level")`} = ${Prisma.sql`CAST(${Level.junior} AS "Level")`} AND j."Level" = ${Prisma.sql`CAST(${Level.junior} AS "Level")`} THEN 1
            ELSE 2
          END,
          j."PostedAt" DESC
      `;

      return (
        jobs
          ?.filter((job: any) => job.Status === JobStatus.open)
          .map((job: any) => ({
            ...omit(job, [
              'job_benefits',
              'job_descriptions',
              'job_requirements',
              'CompanyLocationID',
              'UserID',
              'user',
              'recruiter',
              'company',
              'RecruiterID',
            ]),
            JobBenefits: job.job_benefits.map((jb: any) => jb.Benefit),
            JobDescriptions: job.job_descriptions.map(
              (jd: any) => jd.Description,
            ),
            JobRequirements: job.job_requirements.map(
              (jr: any) => jr.Requirement,
            ),
            Recruiter: {
              ID: job.recruiter[0].ID,
              Position: job.recruiter[0].Position,
              FullName: job.user[0].FullName,
              Email: job.user[0].Email,
              PhoneNumber: job.user[0].PhoneNumber,
              AvatarUrl: job.user[0].AvatarUrl,
              Company: {
                Name: job.company[0].Name,
                LogoUrl: job.company[0].LogoUrl,
              },
            },
          })) ?? []
      );
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleSearchJobsByLocations = async (
    locationId: string,
    status?: JobStatus,
  ) => {
    try {
      const { data, error } = await this.anonSupabaseClient
        .from('Locations')
        .select(
          'ID, Name, Country, CompanyLocations(*, Recruiters(*, Jobs(*, JobBenefits(*), JobDescriptions(*), JobRequirements(*) ,JobCategories(*, Categories(*)), Recruiters(*, Users(FullName, Email, PhoneNumber) ,CompanyLocations(*, Companies(*))))))',
        )
        .eq('ID', locationId)
        .maybeSingle<any>();

      if (!data || error)
        throw new NotFoundException(
          `Không tìm thấy địa điểm có id '${locationId}'`,
        );

      const jobs =
        data.CompanyLocations?.flatMap(
          (location: any) =>
            location.Recruiters?.flatMap((recruiter: any) =>
              recruiter.Jobs.filter(
                (job: any) => !status || job.Status === status,
              )
                .map((item: any) => ({
                  ...omit(item, ['Recruiters', 'RecruiterID', 'JobCategories']),
                  Recruiter: {
                    ...omit(item.Recruiters, [
                      'UserID',
                      'CompanyLocationID',
                      'Users',
                      'DeletedAt',
                      'CompanyLocations',
                    ]),
                    FullName: item.Recruiters.Users.FullName,
                    PhoneNumber: item.Recruiters.Users.PhoneNumber,
                    Email: item.Recruiters.Users.Email,
                    Company: {
                      Name: item.Recruiters.CompanyLocations.Companies.Name,
                      LogoUrl:
                        item.Recruiters.CompanyLocations.Companies.LogoUrl,
                    },
                  },
                  JobBenefits: item.JobBenefits.map((jb: any) => jb.Benefit),
                  JobDescriptions: item.JobDescriptions.map(
                    (jd: any) => jd.Description,
                  ),
                  JobRequirements: item.JobRequirements.map(
                    (jr: any) => jr.Requirement,
                  ),
                  Categories: item.JobCategories.map(
                    (jc: any) => jc.Categories.CategoryName,
                  ),
                }))
                .sort(
                  (a: any, b: any) =>
                    new Date(b.PostedAt as string).getTime() -
                    new Date(a.PostedAt as string).getTime(),
                ),
            ) || [],
        ) || [];

      return jobs;
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleFormattedJob = async (jobId: string) => {
    const { data: jobData, error: jobError } = await this.anonSupabaseClient
      .from('Jobs')
      .select(
        '*, JobDescriptions(ID, Description, DeletedAt), JobBenefits(ID, Benefit, DeletedAt), JobRequirements(ID, Requirement, DeletedAt), JobCategories(CategoryID)',
      )
      .eq('ID', jobId)
      .maybeSingle<any>();

    if (jobError)
      throw new InternalServerErrorException(
        'Đã xảy ra lỗi khi lấy thông tin của công việc.',
      );

    const categoryIDs: string[] =
      jobData?.JobCategories.map((category: any) => category.CategoryID) ?? [];

    const { data: categoriesData, error: categoriesError } =
      await this.anonSupabaseClient
        .from('Categories')
        .select('ID, CategoryName')
        .in('ID', categoryIDs);

    if (categoriesError)
      throw new InternalServerErrorException(
        'Đã xảy ra lỗi khi lấy các danh mục công việc.',
      );

    const jobWithCategories = {
      ...omit(jobData, ['JobCategories', 'RecruiterID', 'DeletedAt']),
      JobDescriptions: jobData?.JobDescriptions.map(
        (jd: any) => jd.Description,
      ),
      JobBenefits: jobData?.JobBenefits.map((jb: any) => jb.Benefit),
      JobRequirements: jobData?.JobRequirements.map(
        (jr: any) => jr.Requirement,
      ),
      Categories: categoriesData.map((c) => c.CategoryName),
    };

    return jobWithCategories;
  };

  public handleGetApplicationsOfJob = async (jobId: string, userId: string) => {
    try {
      const { data: recruiter } = await this.anonSupabaseClient
        .from('Recruiters')
        .select('*')
        .eq('UserID', userId)
        .maybeSingle<Recruiters>();

      if (!recruiter)
        throw new NotFoundException(
          `Không tìm thấy thông tin nhà tuyển dụng nào liên kết với người dùng có id '${userId}' trong hệ thống.`,
        );

      const { data: job } = await this.anonSupabaseClient
        .from('Jobs')
        .select(
          '*, Applications(*, Candidates(*, Users(*), WorkExperiences(*)))',
        )
        .eq('ID', jobId)
        .maybeSingle<any>();

      if (!job)
        throw new NotFoundException(
          `Công việc có id '${jobId}' không tìm thấy trong hệ thống.`,
        );

      if (job.RecruiterID !== recruiter.ID)
        throw new ForbiddenException(
          `Công việc '${job.Title}' không phải do bạn đăng.`,
        );

      return (
        job?.Applications.map((application: any) => ({
          ...omit(application, 'CandidateID', 'Candidates'),
          Candidate: this.usersService.handleFormattedProfileCandidateResponse(
            application.Candidates,
          ),
        })) ?? []
      );
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  private handleVerifyJob = async (jobId: string) => {
    try {
      const { data } = await this.anonSupabaseClient
        .from('Jobs')
        .select('*, Recruiters(*, Users(*))')
        .eq('ID', jobId)
        .maybeSingle<any>();

      if (!data)
        throw new NotFoundException(
          `Không tìm thấy công việc có id '${jobId}' trong hệ thống.`,
        );

      return data;
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleCalculateJobSummary = async (
    startDate?: Date,
    endDate?: Date,
  ) => {
    try {
      let query = this.anonSupabaseClient
        .from('Jobs')
        .select('Status, ExpiredAt', { count: 'exact' });

      if (startDate) {
        query = query.gte('PostedAt', startDate.toISOString());
      }

      if (endDate) {
        query = query.lte('PostedAt', endDate.toISOString());
      }

      const { data, error } = await query;

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi lấy thống kê công việc.',
        );
      }

      const summary = {
        total: data.length,
        open: data.filter((job) => job.Status === JobStatus.open).length,
        pending: data.filter((job) => job.Status === JobStatus.pending).length,
        closed: data.filter((job) => job.Status === JobStatus.closed).length,
        rejected: data.filter((job) => job.Status === JobStatus.rejected)
          .length,
        expired: data.filter(
          (job) =>
            new Date(job.ExpiredAt as string).getTime() < new Date().getTime(),
        ).length,
      };

      return summary;
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleCountApplicationsOfJob = async (
    jobId: string,
    status: ApplicationStatus,
  ) => {
    const { data: job } = await this.anonSupabaseClient
      .from('Jobs')
      .select('*, Applications(*)')
      .eq('ID', jobId)
      .maybeSingle<any>();

    if (!job)
      throw new NotFoundException(
        `Không tìm thấy công việc có id '${jobId}' trong hệ thống.`,
      );

    return job.Applications.filter(
      (application: Applications) => application.Status === status,
    )?.length;
  };
}
