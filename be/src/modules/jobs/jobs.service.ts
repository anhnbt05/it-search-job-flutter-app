import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  Candidates,
  Categories,
  Jobs,
  JobStatus,
  NotificationType,
  Recruiters,
  Role,
  Users,
} from '@prisma/client';
import { SupabaseClient } from '@supabase/supabase-js';
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
  UpdateJobDto,
} from 'src/modules/jobs/dtos';
import { UserNotificationsService } from 'src/modules/user-notifications/user-notifications.service';
import { UsersService } from 'src/modules/users/users.service';

@Injectable()
export class JobsService {
  constructor(
    @InjectSupabaseClient('adminClient')
    private readonly adminSupabaseClient: SupabaseClient,
    @InjectSupabaseClient('anonClient')
    private readonly anonSupabaseClient: SupabaseClient,
    private readonly usersService: UsersService,
    private readonly userNotificationsService: UserNotificationsService,
    private readonly configService: ConfigService,
  ) {}

  public handleGetJobs = async (userId: string) => {
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

      const query = this.anonSupabaseClient
        .from('Jobs')
        .select(
          '*, Recruiters(*, Users(FullName), CompanyLocations(*, Companies(*)))',
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

        query
          .match({
            RecruiterID: data.ID,
            Status: JobStatus.open,
          })
          .is('DeletedAt', null);
      }

      const { data: jobs, error: jobsError } = await query
        .match({ Status: JobStatus.open })
        .is('DeletedAt', null)
        .overrideTypes<any[], { merge: false }>();

      if (jobsError)
        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi lấy danh sách các công việc.',
        );

      return jobs?.map((job) => ({
        ...omit(job, ['RecruiterID', 'Recruiters']),
        Recruiter: {
          ...omit(job.Recruiters, [
            'Users',
            'UserID',
            'CompanyLocationID',
            'CompanyLocations',
          ]),
          FullName: job.Recruiters.Users.FullName,
          Company: job.Recruiters.CompanyLocations.Companies,
        },
      }));
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
        .eq('Email', this.configService.get<string>('ADMIN_EMAIL', ''))
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

      return (
        await this.anonSupabaseClient
          .from('Jobs')
          .select('*')
          .eq('ID', data.ID)
          .maybeSingle<Jobs>()
      ).data;
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
        .select('*')
        .eq('ID', jobId)
        .maybeSingle<Jobs>();

      if (!data)
        throw new NotFoundException(
          `Không tìm thấy công việc có id '${jobId}'.`,
        );

      if (data.Status === JobStatus.pending)
        throw new BadRequestException(
          `Bạn chỉ có thể cập nhật công việc khi công việc đang đợi quản trị viên duyệt.`,
        );

      if (data.Status === JobStatus.rejected)
        throw new BadRequestException(
          `Bạn không thể cập nhật công việc mà đã bị quản trị viên từ chối.`,
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

      const { Descriptions, Benefits, Requirements, ExpiredDate, ...res } =
        updateJobDto;

      const { error } = await this.anonSupabaseClient
        .from('Jobs')
        .update({
          ...res,
          ...(ExpiredDate && {
            ExpiredAt: new Date(ExpiredDate),
          }),
        })
        .eq('ID', jobId);

      if (error)
        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi cập nhật công việc.',
        );

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

        if (error) throw error;

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

    if (error)
      throw new InternalServerErrorException(
        'Đã xảy ra lỗi khi cập nhật trạng thái của công việc.',
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

      if (insertJobFavortiesData)
        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi thêm mới công việc ưa thích của ứng viên.',
        );

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

          if (error)
            throw new InternalServerErrorException(
              'Đã xảy ra lỗi khi xoá công việc đã lưu.',
            );
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

  public handleGetJobsByCategoryName = async (categoryName: string) => {
    try {
      const { data, error } = await this.anonSupabaseClient
        .from('Categories')
        .select('*')
        .eq('CategoryName', categoryName)
        .maybeSingle<Categories>();

      if (!data || error)
        throw new NotFoundException(
          `Danh mục có tên ${categoryName} không tìm thấy.`,
        );

      const response = await this.anonSupabaseClient
        .from('JobCategories')
        .select(
          `
          *,
          Jobs (
            *,
            JobDescriptions(*),
            JobRequirements(*),
            JobBenefits(*)
          )
        `,
        )
        .eq('CategoryID', data.ID);

      if (response?.error) {
        console.error(response.error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi lấy danh sách các danh mục của công việc.',
        );
      }

      return response?.data?.map((d) => ({
        ...d.Jobs,
        JobBenefits: d.Jobs.JobBenefits.map((jb: any) => jb.Benefit),
        JobDescriptions: d.Jobs.JobDescriptions.map(
          (jd: any) => jd.Description,
        ),
        JobRequirements: d.Jobs.JobRequirements.map(
          (jr: any) => jr.Requirement,
        ),
      }));
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

      if (data.ID !== candidateId)
        throw new ForbiddenException(
          'Bạn chỉ có thể lấy các công việc phù hợp với trình độ của chính bạn.',
        );

      const { data: jobs, error: jobsError } =
        await this.anonSupabaseClient.rpc('get_jobs_sorted_by_level', {
          candidate_level: data.Level,
        });

      if (jobsError) {
        console.error(jobsError);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi lấy ra các công việc gợi ý cho ứng viên.',
        );
      }

      return jobs?.filter((job: any) => job.Status === JobStatus.open) ?? [];
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleSearchJobsByLocations = async (locationId: string) => {
    try {
      const { data, error } = await this.anonSupabaseClient
        .from('Locations')
        .select(
          'ID, Name, Country, CompanyLocations(*, Recruiters(*, Jobs(*, Recruiters(*, Users(FullName, Email, PhoneNumber) ,CompanyLocations(*, Companies(*))))))',
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
              recruiter.Jobs.filter((job: any) => job.Status === JobStatus.open)
                .map((item: any) => ({
                  ...omit(item, ['Recruiters', 'RecruiterID']),
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
}
