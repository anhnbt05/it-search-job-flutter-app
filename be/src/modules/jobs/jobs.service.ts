import {
  BadRequestException,
  ForbiddenException,
  Injectable,
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
import {
  CreateJobDto,
  CreateJobFavoritesDto,
  DeleteJobFavoritesDto,
  ProcessJobStatusDto,
  UpdateJobDto,
} from 'src/modules/jobs/dtos';
import { SupabaseService } from 'src/modules/supabase/supabase.service';

@Injectable()
export class JobsService {
  constructor(private readonly supabaseService: SupabaseService) {}

  public handleGetJobs = async (userId: string) => {
    try {
      const supabaseAdmin = this.supabaseService.getAdminClient();

      const { data: user, error } = await supabaseAdmin
        .from('Users')
        .select('*')
        .eq('ID', userId)
        .maybeSingle<Users>();

      if (error) {
        console.error(error);
        return;
      }

      if (!user)
        throw new NotFoundException(
          `Không tìm thấy người dùng có id '${userId}'`,
        );

      const isRecruiter = user.Role === Role.recruiter ? true : false;

      const query = supabaseAdmin
        .from('Jobs')
        .select(
          '*, Recruiters(*, Users(FullName), CompanyLocation(*, Companies(*)))',
        );

      if (isRecruiter) {
        const { data, error } = await supabaseAdmin
          .from('Recruiters')
          .select('*')
          .eq('UserID', userId)
          .maybeSingle<Recruiters>();

        if (error) throw error;

        if (!data)
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

      if (jobsError) throw jobsError;

      return jobs?.map((job) => ({
        ...omit(job, ['RecruiterID', 'Recruiters']),
        Recruiter: {
          ...omit(job.Recruiters, [
            'Users',
            'UserID',
            'CompanyLocationID',
            'CompanyLocation',
          ]),
          FullName: job.Recruiters.Users.FullName,
          Company: job.Recruiters.CompanyLocation.Companies,
        },
      }));
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleGetJob = async (jobId: string, userId: string) => {
    try {
      const supabaseAdmin = this.supabaseService.getAdminClient();

      const { data: user } = await supabaseAdmin
        .from('Users')
        .select('*')
        .eq('ID', userId)
        .maybeSingle<Users>();

      if (!user)
        throw new NotFoundException(
          `Không tìm thấy người dùng có id '${userId}'`,
        );

      const isRecruiter = user.Role === Role.recruiter ? true : false;

      const query = supabaseAdmin
        .from('Jobs')
        .select('*, Recruiters(*, Users(*) ,CompanyLocation(*, Companies(*)))');

      if (isRecruiter) {
        const { data, error } = await supabaseAdmin
          .from('Recruiters')
          .select('*')
          .eq('UserID', userId)
          .maybeSingle<Recruiters>();

        if (error) throw error;

        if (!data)
          throw new NotFoundException(
            `Không tìm thấy nhà tuyển dụng liên kết với người dùng có id '${userId}'`,
          );

        query.match({ RecruiterID: data.ID, ID: jobId });
      } else {
        query.eq('ID', jobId);
      }

      const { data: job, error: jobError } = await query.maybeSingle<any>();

      if (jobError) throw jobError;

      if (!job) {
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
        ...(await this.handleFormattedJob(jobId, supabaseAdmin)),
        Recruiter: {
          ...omit(job.Recruiters, [
            'CompanyLocation',
            'CompanyLocationID',
            'UserID',
            'Users',
          ]),
          FullName: job.Recruiters.Users.FullName,
          Company: job.Recruiters.CompanyLocation.Companies,
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
      const supabaseAdmin = this.supabaseService.getAdminClient();

      const { data: user } = await supabaseAdmin
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

      const { data: job, error: findJobError } = await supabaseAdmin
        .from('Jobs')
        .select('*')
        .match({ Title, RecruiterID: user.ID })
        .maybeSingle<Jobs>();

      if (findJobError) throw findJobError;

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

      const { data, error } = await supabaseAdmin
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

      if (error) throw error;

      const { error: insertDescriptionError } = await supabaseAdmin
        .from('JobDescription')
        .insert(
          Descriptions.map((description) => ({
            Description: description,
            JobID: data.ID,
          })),
        );

      if (insertDescriptionError) throw insertDescriptionError;

      const { error: insertBenefitsError } = await supabaseAdmin
        .from('JobBenefits')
        .insert(
          Benefits.map((benefit) => ({
            Benefit: benefit,
            JobID: data.ID,
          })),
        );

      if (insertBenefitsError) throw insertBenefitsError;

      const { error: errorCreateRequirements } = await supabaseAdmin
        .from('JobRequirements')
        .insert(
          Requirements.map((requirement) => ({
            Requirement: requirement,
            JobID: data.ID,
          })),
        );

      if (errorCreateRequirements) throw errorCreateRequirements;

      const categoryIds: string[] = [];

      for (const categoryName of Categories) {
        const { data, error } = await supabaseAdmin
          .from('Categories')
          .select('ID')
          .eq('CategoryName', categoryName)
          .single<Categories>();

        if (error) throw error;

        categoryIds.push(data.ID);
      }

      const { error: errorCategoriesInsert } = await supabaseAdmin
        .from('JobCategories')
        .insert(
          categoryIds.map((categoryId) => ({
            CategoryID: categoryId,
            JobID: data.ID,
          })),
        );

      if (errorCategoriesInsert) throw errorCategoriesInsert;

      return (
        await supabaseAdmin
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
    const supabaseAdmin = this.supabaseService.getAdminClient();

    return (
      (await supabaseAdmin.from('Categories').select('ID,CategoryName'))
        ?.data ?? []
    );
  };

  public handleUpdateJob = async (
    jobId: string,
    updateJobDto: UpdateJobDto,
  ) => {
    try {
      const supabaseAdmin = this.supabaseService.getAdminClient();

      const { data } = await supabaseAdmin
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

      const { error } = await supabaseAdmin
        .from('Jobs')
        .update(res)
        .eq('ID', jobId);

      if (error) {
        console.error('Upsert Error:', error);
      }

      if (Descriptions && Descriptions.length) {
        await this.handleSyncJobDetails(
          'JobDescription',
          'Description',
          Descriptions,
          jobId,
          supabaseAdmin,
        );
      }

      if (Benefits && Benefits.length) {
        await this.handleSyncJobDetails(
          'JobBenefits',
          'Benefit',
          Benefits,
          jobId,
          supabaseAdmin,
        );
      }

      if (Requirements && Requirements.length) {
        await this.handleSyncJobDetails(
          'JobRequirements',
          'Requirement',
          Requirements,
          jobId,
          supabaseAdmin,
        );
      }

      return this.handleFormattedJob(jobId, supabaseAdmin);
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
    supabaseAdmin: SupabaseClient,
  ) => {
    try {
      if (!newValues || !newValues.length) return;

      const existingValues: string[] =
        (
          await supabaseAdmin
            .from(tableName)
            .select(fieldName)
            .eq('JobID', jobId)
        )?.data?.map((item) => item[fieldName]) || [];

      const newSet = new Set(newValues);

      const existingSet = new Set(existingValues);

      const toAdd = newValues.filter((val) => !existingSet.has(val));

      const toRemove = existingValues.filter((val) => !newSet.has(val));

      if (toRemove.length) {
        await supabaseAdmin.from(tableName).delete().in(fieldName, toRemove);
      }

      if (toAdd.length) {
        await supabaseAdmin.from(tableName).insert(
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
      const supabaseAdmin = this.supabaseService.getAdminClient();

      const { data: user, error } = await supabaseAdmin
        .from('Users')
        .select('*')
        .eq('ID', userId)
        .maybeSingle<Users>();

      if (error) throw error;

      if (!user)
        throw new NotFoundException(
          `Không tìm thấy người dùng có id '${userId}'`,
        );

      const { data: job, error: jobError } = await supabaseAdmin
        .from('Jobs')
        .select('*')
        .eq('ID', jobId)
        .maybeSingle<Jobs>();

      if (jobError) throw jobError;

      if (!job)
        throw new NotFoundException(
          `Không tìm thấy công việc có id '${jobId}'.`,
        );

      const isRecruiter = user.Role === Role.recruiter ? true : false;

      if (isRecruiter) {
        const { data: recruiter, error } = await supabaseAdmin
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

      await supabaseAdmin
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
      const supabaseAdmin = this.supabaseService.getAdminClient();

      if (!processJobStatusDto || !Object.keys(processJobStatusDto).length)
        throw new BadRequestException(
          `Bạn phải cung cấp các thông tin của các công việc cần cập nhật trạng thái.`,
        );

      const { openJobIds, rejectedJobIds } = processJobStatusDto;

      if (openJobIds && openJobIds.length) {
        await this.generateProcessJobStatus('open', openJobIds, supabaseAdmin);
      }

      if (rejectedJobIds && rejectedJobIds.length) {
        await this.generateProcessJobStatus(
          'rejected',
          rejectedJobIds,
          supabaseAdmin,
        );
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
    supabaseAdmin: SupabaseClient,
  ) => {
    const status = method === 'open' ? JobStatus.open : JobStatus.rejected;

    const { error } = await supabaseAdmin
      .from('Jobs')
      .update({ Status: status })
      .in('ID', items);

    if (error) {
      console.error('Failed to update jobs:', error);
    }
  };

  public handleCreateJobFavorites = async (
    userId: string,
    createJobFavoritesDto: CreateJobFavoritesDto,
  ) => {
    try {
      const supabaseAdmin = this.supabaseService.getAdminClient();

      const { data, error } = await supabaseAdmin
        .from('Candidates')
        .select('*')
        .eq('UserID', userId)
        .maybeSingle<Candidates>();

      if (error) throw error;

      if (!data)
        throw new NotFoundException(
          `Không tìm thấy ứng cử viên có id '${userId}'`,
        );

      const { jobIds } = createJobFavoritesDto;

      const { error: insertJobFavortiesData } = await supabaseAdmin
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

      if (insertJobFavortiesData) throw insertJobFavortiesData;

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
      const supabaseAdmin = this.supabaseService.getAdminClient();

      const { data, error } = await supabaseAdmin
        .from('Candidates')
        .select('*')
        .eq('UserID', userId)
        .maybeSingle<Candidates>();

      if (error) throw error;

      if (!data)
        throw new NotFoundException(
          `Không tìm thấy ứng viên nào mà liên kết với người dùng có id '${userId}'`,
        );

      const { jobIds } = deleteJobFavoritesDto;

      await Promise.all(
        jobIds.map(async (jobId) => {
          const { error } = await supabaseAdmin
            .from('JobFavorites')
            .delete()
            .match({ JobID: jobId, CandidateID: data.ID });

          if (error) throw error;
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
      const supabaseAdmin = this.supabaseService.getAdminClient();

      const { data, error } = await supabaseAdmin
        .from('Categories')
        .select('*')
        .eq('CategoryName', categoryName)
        .maybeSingle<Categories>();

      if (error) throw error;

      if (!data)
        throw new NotFoundException(
          `Danh mục có tên ${categoryName} không tìm thấy.`,
        );

      const response = await supabaseAdmin
        .from('JobCategories')
        .select(
          `
          *,
          Jobs (
            *,
            JobDescription(*),
            JobRequirements(*),
            JobBenefits(*)
          )
        `,
        )
        .eq('CategoryID', data.ID)
        .is('DeletedAt', null);

      if (response?.error) throw response?.error;

      return response?.data?.map((d) => ({
        ...d.Jobs,
        JobBenefits: d.Jobs.JobBenefits.map((jb: any) => jb.Benefit),
        JobDescription: d.Jobs.JobDescription.map((jd: any) => jd.Description),
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
      const supabaseAdmin = this.supabaseService.getAdminClient();

      const { data, error } = await supabaseAdmin
        .from('Candidates')
        .select('*')
        .eq('UserID', userId)
        .maybeSingle<Candidates>();

      if (error) throw error;

      if (!data)
        throw new NotFoundException(
          `Không tìm thấy ứng viên mà liên kết với người dùng có id '${userId}'`,
        );

      const { data: jobs, error: jobsError } = await supabaseAdmin.rpc(
        'get_jobs_sorted_by_level',
        {
          candidate_level: data.Level,
        },
      );

      if (jobsError) throw jobsError;

      return jobs;
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleSearchJobsByLocations = async (locationId: string) => {
    try {
      const supabaseAdmin = this.supabaseService.getAdminClient();

      const { data, error } = await supabaseAdmin
        .from('Locations')
        .select(
          'ID, Name, Country, CompanyLocation(*, Recruiters(*, Jobs(*, Recruiters(*, Users(FullName, Email, PhoneNumber) ,CompanyLocation(*, Companies(*))))))',
        )
        .eq('ID', locationId)
        .maybeSingle<any>();

      if (error) throw error;

      if (!data)
        throw new NotFoundException(
          `Không tìm thấy địa điểm có id '${locationId}'`,
        );

      const jobs =
        data.CompanyLocation?.flatMap(
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
                      'CompanyLocation',
                    ]),
                    FullName: item.Recruiters.Users.FullName,
                    PhoneNumber: item.Recruiters.Users.PhoneNumber,
                    Email: item.Recruiters.Users.Email,
                    Company: {
                      Name: item.Recruiters.CompanyLocation.Companies.Name,
                      LogoUrl:
                        item.Recruiters.CompanyLocation.Companies.LogoUrl,
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

  private handleFormattedJob = async (
    jobId: string,
    supabaseAdmin: SupabaseClient,
  ) => {
    const { data: jobData, error: jobError } = await supabaseAdmin
      .from('Jobs')
      .select(
        '*, JobDescription(ID, Description, DeletedAt), JobBenefits(ID, Benefit, DeletedAt), JobRequirements(ID, Requirement, DeletedAt), JobCategories(CategoryID)',
      )
      .eq('ID', jobId)
      .maybeSingle<any>();

    if (jobError) {
      console.error('Error fetching job:', jobError);
      return;
    }

    const categoryIDs: string[] =
      jobData?.JobCategories.map((category: any) => category.CategoryID) ?? [];

    const { data: categoriesData, error: categoriesError } = await supabaseAdmin
      .from('Categories')
      .select('ID, CategoryName')
      .in('ID', categoryIDs);

    if (categoriesError) {
      console.error('Error fetching categories:', categoriesError);
      return;
    }

    const jobWithCategories = {
      ...omit(jobData, ['JobCategories']),
      JobDescription: jobData?.JobDescription.map((jd: any) => jd.Description),
      JobBenefits: jobData?.JobBenefits.map((jb: any) => jb.Benefit),
      JobRequirements: jobData?.JobRequirements.map(
        (jr: any) => jr.Requirement,
      ),
      Categories: categoriesData.map((c) => c.CategoryName),
    };

    return jobWithCategories;
  };
}
