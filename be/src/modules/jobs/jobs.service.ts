import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import {
  Candidates,
  Categories,
  Jobs,
  JobStatus,
  Recruiters,
  Role,
  Users,
} from '@prisma/client';
import { SupabaseClient } from '@supabase/supabase-js';
import { omit } from 'lodash';
import { InjectSupabaseClient } from 'nestjs-supabase-js';
import {
  CreateJobDto,
  CreateJobFavoritesDto,
  DeleteJobFavoritesDto,
  ProcessJobStatusDto,
  UpdateJobDto,
} from 'src/modules/jobs/dtos';

@Injectable()
export class JobsService {
  constructor(
    @InjectSupabaseClient('adminClient')
    private readonly adminSupabaseClient: SupabaseClient,
    @InjectSupabaseClient('anonClient')
    private readonly anonSupbaseClient: SupabaseClient,
  ) {}

  public handleGetJobs = async (userId: string) => {
    try {
      const { data: user, error } = await this.anonSupbaseClient
        .from('Users')
        .select('*')
        .eq('ID', userId)
        .maybeSingle<Users>();

      if (!user || error)
        throw new NotFoundException(
          `Không tìm thấy người dùng có id '${userId}'`,
        );

      const isRecruiter = user.Role === Role.recruiter ? true : false;

      const query = this.anonSupbaseClient
        .from('Jobs')
        .select(
          '*, Recruiters(*, Users(FullName), CompanyLocations(*, Companies(*)))',
        );

      if (isRecruiter) {
        const { data, error } = await this.anonSupbaseClient
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
      const { data: user } = await this.anonSupbaseClient
        .from('Users')
        .select('*')
        .eq('ID', userId)
        .maybeSingle<Users>();

      if (!user)
        throw new NotFoundException(
          `Không tìm thấy người dùng có id '${userId}'`,
        );

      const isRecruiter = user.Role === Role.recruiter ? true : false;

      const query = this.anonSupbaseClient
        .from('Jobs')
        .select(
          '*, Recruiters(*, Users(*) ,CompanyLocations(*, Companies(*)))',
        );

      if (isRecruiter) {
        const { data, error } = await this.anonSupbaseClient
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
      const { data: user } = await this.anonSupbaseClient
        .from('Recruiters')
        .select('*')
        .eq('UserID', userId)
        .maybeSingle<Recruiters>();

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

      const { data: job, error: findJobError } = await this.anonSupbaseClient
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

      if (error)
        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi thêm mới công việc.',
        );

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
        const { data, error } = await this.anonSupbaseClient
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

      return (
        await this.anonSupbaseClient
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
        await this.anonSupbaseClient
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
      const { data } = await this.anonSupbaseClient
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

      const { Descriptions, Benefits, Requirements, ...res } = updateJobDto;

      const { error } = await this.anonSupbaseClient
        .from('Jobs')
        .update(res)
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
          await this.anonSupbaseClient
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
      const { data: user, error } = await this.anonSupbaseClient
        .from('Users')
        .select('*')
        .eq('ID', userId)
        .maybeSingle<Users>();

      if (!user || error)
        throw new NotFoundException(
          `Không tìm thấy người dùng có id '${userId}'`,
        );

      const { data: job, error: jobError } = await this.anonSupbaseClient
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
        const { data: recruiter, error } = await this.anonSupbaseClient
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

      const { openJobIds, rejectedJobIds } = processJobStatusDto;

      if (openJobIds && openJobIds.length) {
        await this.generateProcessJobStatus('open', openJobIds);
      }

      if (rejectedJobIds && rejectedJobIds.length) {
        await this.generateProcessJobStatus('rejected', rejectedJobIds);
      }

      return this.handleGetJobs(userId);
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  private generateProcessJobStatus = async (
    method: 'open' | 'rejected',
    items: string[],
  ) => {
    const status = method === 'open' ? JobStatus.open : JobStatus.rejected;

    const { error } = await this.adminSupabaseClient
      .from('Jobs')
      .update({ Status: status })
      .in('ID', items);

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
      const { data, error } = await this.anonSupbaseClient
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
      const { data, error } = await this.anonSupbaseClient
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
      const { data, error } = await this.anonSupbaseClient
        .from('Categories')
        .select('*')
        .eq('CategoryName', categoryName)
        .maybeSingle<Categories>();

      if (!data || error)
        throw new NotFoundException(
          `Danh mục có tên ${categoryName} không tìm thấy.`,
        );

      const response = await this.anonSupbaseClient
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
        .eq('CategoryID', data.ID)
        .is('DeletedAt', null);

      if (response?.error)
        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi lấy danh sách các danh mục của công việc.',
        );

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

  public handleGetRecommendedJobsForCandidate = async (userId: string) => {
    try {
      const { data, error } = await this.anonSupbaseClient
        .from('Candidates')
        .select('*')
        .eq('UserID', userId)
        .maybeSingle<Candidates>();

      if (!data || error)
        throw new NotFoundException(
          `Không tìm thấy ứng viên mà liên kết với người dùng có id '${userId}'`,
        );

      const { data: jobs, error: jobsError } = await this.anonSupbaseClient.rpc(
        'get_jobs_sorted_by_level',
        {
          candidate_level: data.Level,
        },
      );

      if (jobsError)
        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi lấy ra các công việc gợi ý cho ứng viên.',
        );

      return jobs;
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleSearchJobsByLocations = async (locationId: string) => {
    try {
      const { data, error } = await this.anonSupbaseClient
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

  private handleFormattedJob = async (jobId: string) => {
    const { data: jobData, error: jobError } = await this.anonSupbaseClient
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
      await this.anonSupbaseClient
        .from('Categories')
        .select('ID, CategoryName')
        .in('ID', categoryIDs);

    if (categoriesError)
      throw new InternalServerErrorException(
        'Đã xảy ra lỗi khi lấy các danh mục công việc.',
      );

    const jobWithCategories = {
      ...omit(jobData, ['JobCategories']),
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
}
