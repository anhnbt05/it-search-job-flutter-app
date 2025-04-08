import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import {
  Applications,
  ApplicationStatus,
  Candidates,
  Jobs,
  JobStatus,
  Recruiters,
} from '@prisma/client';
import { SupabaseClient } from '@supabase/supabase-js';
import { omit } from 'lodash';
import { InjectSupabaseClient } from 'nestjs-supabase-js';
import {
  CreateApplicationDto,
  ProcessApplicationsDto,
} from 'src/modules/applications/dtos';
import { JobsService } from 'src/modules/jobs/jobs.service';
import { UploadsService } from 'src/modules/uploads/uploads.service';

@Injectable()
export class ApplicationsService {
  constructor(
    @InjectSupabaseClient('adminClient')
    private readonly adminSupabaseClient: SupabaseClient,
    @InjectSupabaseClient('anonClient')
    private readonly anonSupabaseClient: SupabaseClient,
    private readonly uploadsService: UploadsService,
    private readonly jobsService: JobsService,
  ) {}

  public handleGetApplications = async (userId: string) => {
    try {
      const { data: candidate } = await this.anonSupabaseClient
        .from('Candidates')
        .select('*')
        .eq('UserID', userId)
        .maybeSingle<Candidates>();

      if (!candidate)
        throw new NotFoundException(
          `Không tìm thấy ứng viên mà liên kết với người dùng có id '${userId}' trong hệ thống.`,
        );

      return (
        await this.anonSupabaseClient
          .from('Applications')
          .select('*')
          .eq('CandidateID', candidate.ID)
          .is('DeletedAt', null)
      )?.data;
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleGetApplication = async (
    userId: string,
    applicatioId: string,
  ) => {
    try {
      const { data: candidate } = await this.anonSupabaseClient
        .from('Candidates')
        .select('*')
        .eq('UserID', userId)
        .maybeSingle<Candidates>();

      if (!candidate)
        throw new NotFoundException(
          `Không tìm thấy ứng viên mà liên kết với người dùng có id '${userId}'`,
        );

      const { data: application } = await this.anonSupabaseClient
        .from('Applications')
        .select('*, Jobs(*)')
        .eq('ID', applicatioId)
        .is('DeletedAt', null)
        .maybeSingle<Applications>();

      if (!application)
        throw new NotFoundException(
          `Không tìm thấy đơn ứng tuyển có id '${applicatioId}' trong hệ thống.`,
        );

      if (application.CandidateID !== candidate.ID)
        throw new ForbiddenException(
          'Bạn chỉ có thể xem được đơn ứng tuyển của chính mình.',
        );

      return {
        ...omit(application, ['JobID', 'Jobs', 'CandidateID', 'DeletedAt']),
        Job: {
          ...(await this.jobsService.handleFormattedJob(application.JobID)),
        },
      };
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleCreateApplication = async (
    userId: string,
    createApplicationDto: CreateApplicationDto,
    files?: Express.Multer.File[],
  ) => {
    try {
      const { data: candidate } = await this.anonSupabaseClient
        .from('Candidates')
        .select('*')
        .eq('UserID', userId)
        .maybeSingle<Candidates>();

      if (!candidate)
        throw new NotFoundException(
          `Không tìm thấy ứng viên mà liên kết với người dùng có id '${userId}'`,
        );

      const { JobId } = createApplicationDto;

      const { data: job } = await this.anonSupabaseClient
        .from('Jobs')
        .select('*')
        .eq('ID', JobId)
        .maybeSingle<Jobs>();

      if (!job || job?.Status !== JobStatus.open)
        throw new NotFoundException(
          `Không tìm thấy công việc có id '${JobId}' trong hệ thống.`,
        );

      if (new Date(job?.ExpiredAt).getTime() < new Date().getTime())
        throw new BadRequestException(
          `Công việc có id '${JobId}' đã quá thời gian ứng tuyển.`,
        );

      const resumeFile = files?.find((file) => file.fieldname === 'resumeFile');

      if (!resumeFile && !candidate.ResumeUrl)
        throw new BadRequestException(`Bạn vui lòng nộp file CV.`);

      let resumeFileUrl = candidate.ResumeUrl;

      if (resumeFile) {
        const { url } = await this.uploadsService.uploadFile(
          resumeFile,
          'files',
        );

        if (url) {
          resumeFileUrl = url;
        }
      }

      const { error } = await this.adminSupabaseClient
        .from('Applications')
        .upsert(
          [
            {
              CandidateID: candidate.ID,
              ResumeUrl: resumeFileUrl,
              JobID: JobId,
            },
          ],
          { onConflict: 'CandidateID,JobID' },
        );

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi tạo đơn ứng tuyển cho bạn. Vui lòng thử lại.',
        );
      }

      return this.handleGetApplications(userId);
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleDeleteApplication = async (id: string, userId: string) => {
    try {
      const { data: candidate } = await this.anonSupabaseClient
        .from('Candidates')
        .select('*')
        .eq('UserID', userId)
        .maybeSingle<Candidates>();

      if (!candidate)
        throw new NotFoundException(
          `Không tìm thấy ứng viên mà liên kết với người dùng có id '${userId}' trong hệ thống.`,
        );

      const { data: application } = await this.anonSupabaseClient
        .from('Applications')
        .select('*, Jobs(*)')
        .eq('ID', id)
        .is('DeletedAt', null)
        .maybeSingle<Applications>();

      if (!application)
        throw new NotFoundException(
          `Không tìm thấy đơn ứng tuyển có id '${id}' trong hệ thống.`,
        );

      if (application.CandidateID !== candidate.ID)
        throw new ForbiddenException(
          'Bạn chỉ có thể xoá đơn ứng tuyển của chính mình.',
        );

      const { error } = await this.adminSupabaseClient
        .from('Applications')
        .update([
          {
            DeletedAt: new Date(),
            Status: ApplicationStatus.rejected,
          },
        ])
        .eq('ID', id);

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi trong quá trình xoá đơn ứng tuyển của bạn. Vui lòng thử lại.',
        );
      }

      return this.handleGetApplications(userId);
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleProcessApplications = async (
    userId: string,
    processApplicationsDto: ProcessApplicationsDto,
  ) => {
    try {
      const { data: recruiter } = await this.anonSupabaseClient
        .from('Recruiters')
        .select('*')
        .eq('UserID', userId)
        .maybeSingle<Recruiters>();

      if (!recruiter)
        throw new NotFoundException(
          `Không tìm thấy nhà tuyển dùng nào liên kết với người dùng có id '${userId}' trong hệ thống.`,
        );

      if (
        !processApplicationsDto?.acceptedApplicationIds &&
        !processApplicationsDto?.rejectedApplicationIds
      )
        throw new BadRequestException(
          'Bạn phải cung cấp thông tin về các đơn ứng tuyển cần được xử lý.',
        );

      if (processApplicationsDto?.acceptedApplicationIds)
        await this.handleGenerateProcessApplications(
          'accepted',
          processApplicationsDto.acceptedApplicationIds,
          recruiter.ID,
        );

      if (processApplicationsDto?.rejectedApplicationIds)
        await this.handleGenerateProcessApplications(
          'rejected',
          processApplicationsDto.rejectedApplicationIds,
          recruiter.ID,
        );

      return {
        success: true,
        message: 'Xử lý các đơn ứng tuyển thành công.',
      };
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  private handleGenerateProcessApplications = async (
    type: 'accepted' | 'rejected',
    applicationIds: string[],
    recruiterId: string,
  ) => {
    await Promise.all(
      applicationIds.map(async (applicationId) => {
        const { data: application } = await this.anonSupabaseClient
          .from('Applications')
          .select('*, Jobs(*, Recruiters(*))')
          .eq('ID', applicationId)
          .maybeSingle<any>();

        if (!application)
          throw new NotFoundException(
            `Không tìm thấy đơn ứng tuyển có id '${applicationId}' trong hệ thống.`,
          );

        if (application.Jobs.Recruiters.ID !== recruiterId)
          throw new ForbiddenException(
            `Đơn ứng tuyển có id '${applicationId}' không ứng tuyển cho công việc mà bạn đăng, nên bạn không thể xủ lý chúng.`,
          );

        await this.adminSupabaseClient
          .from('Applications')
          .update([
            {
              Status:
                type === 'accepted'
                  ? ApplicationStatus.accepted
                  : ApplicationStatus.rejected,
            },
          ])
          .eq('ID', applicationId);
      }),
    );
  };
}
