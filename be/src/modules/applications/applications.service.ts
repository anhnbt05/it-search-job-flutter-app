import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  Applications,
  ApplicationStatus,
  Candidates,
  JobStatus,
  NotificationType,
  Recruiters,
} from '@prisma/client';
import { SupabaseClient } from '@supabase/supabase-js';
import { omit } from 'lodash';
import { InjectSupabaseClient } from 'nestjs-supabase-js';
import {
  CandidateApplicationApprovedMetadata,
  CandidateApplicationRejectedMetadata,
  EmailTemplateNameEnum,
  handleFormatUserNotificationContent,
  RecruiterNewApplicationMetadata,
} from 'src/libs/common/utils';
import {
  CreateApplicationDto,
  ProcessApplicationsDto,
  RejectedApplications,
} from 'src/modules/applications/dtos';
import { EmailsProducer } from 'src/modules/emails/producers';
import { JobsService } from 'src/modules/jobs/jobs.service';
import { UploadsService } from 'src/modules/uploads/uploads.service';
import { UserNotificationsService } from 'src/modules/user-notifications/user-notifications.service';

@Injectable()
export class ApplicationsService {
  constructor(
    @InjectSupabaseClient('adminClient')
    private readonly adminSupabaseClient: SupabaseClient,
    @InjectSupabaseClient('anonClient')
    private readonly anonSupabaseClient: SupabaseClient,
    private readonly uploadsService: UploadsService,
    private readonly jobsService: JobsService,
    private readonly userNotificationsService: UserNotificationsService,
    private readonly emailsProducer: EmailsProducer,
    private readonly configService: ConfigService,
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
        .select('*, Users(*)')
        .eq('UserID', userId)
        .maybeSingle<any>();

      if (!candidate)
        throw new NotFoundException(
          `Không tìm thấy ứng viên mà liên kết với người dùng có id '${userId}'`,
        );

      const { JobId } = createApplicationDto;

      const { data: job } = await this.anonSupabaseClient
        .from('Jobs')
        .select('*, Recruiters(*, Users(*))')
        .eq('ID', JobId)
        .maybeSingle<any>();

      if (!job || job?.Status !== JobStatus.open)
        throw new NotFoundException(
          `Không tìm thấy công việc có id '${JobId}' trong hệ thống.`,
        );

      if (new Date(job?.ExpiredAt as string).getTime() < new Date().getTime())
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

      const { data, error } = await this.adminSupabaseClient
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
        )
        .select()
        .single();

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi tạo đơn ứng tuyển cho bạn. Vui lòng thử lại.',
        );
      }

      const metadata: RecruiterNewApplicationMetadata = {
        jobId: job.ID,
        jobTitle: job.Title,
        candidateId: candidate.ID,
        candidateName: candidate.Users.FullName,
        applicationId: data.ID,
      };

      const { recruiter_new_application } = NotificationType;

      await this.userNotificationsService.handleCreateUserNotification(
        {
          Content: handleFormatUserNotificationContent(
            recruiter_new_application,
            metadata,
          ),
          Type: recruiter_new_application,
          metadata,
        },
        job.Recruiters.Users.ID as string,
      );

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
        !processApplicationsDto?.rejectedApplications
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

      if (processApplicationsDto?.rejectedApplications)
        await this.handleGenerateProcessApplications(
          'rejected',
          processApplicationsDto.rejectedApplications,
          recruiter.ID,
        );

      return {
        success: true,
        message: 'Xử lý đơn ứng tuyển thành công.',
      };
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  private handleGenerateProcessApplications = async (
    type: 'accepted' | 'rejected',
    items: string[] | RejectedApplications[],
    recruiterId: string,
  ) => {
    if (type === 'accepted') {
      await Promise.all(
        (items as string[]).map(async (item) => {
          const application = await this.handleVerifyApplication(
            item,
            recruiterId,
          );

          const metadata: CandidateApplicationApprovedMetadata = {
            recruiterId,
            companyName:
              application.Jobs.Recruiters.CompanyLocations.Companies.Name,
            applicationId: application.ID,
            jobId: application.JobID,
            jobTitle: application.Jobs.Title,
          };

          const { candidate_application_approved } = NotificationType;

          await this.userNotificationsService.handleCreateUserNotification(
            {
              Content: handleFormatUserNotificationContent(
                candidate_application_approved,
                metadata,
              ),
              Type: candidate_application_approved,
              metadata,
            },
            application.Candidates.Users.ID as string,
          );

          const { EMAIL_APPLICATION_APPROVED } = EmailTemplateNameEnum;

          await this.emailsProducer.sendEmail(
            application.Candidates.Users.Email as string,
            EMAIL_APPLICATION_APPROVED,
            {
              companyLogoUrl:
                application.Jobs.Recruiters.CompanyLocations.Companies.LogoUrl,
              companyName:
                application.Jobs.Recruiters.CompanyLocations.Companies.Name,
              CandidateName: application.Candidates.Users.FullName,
              jobTitle: application.Jobs.Title,
              EmailSupport: this.configService.get<string>('admin.email', ''),
              PhoneSupport: this.configService.get<string>(
                'admin.phone_number',
                '',
              ),
              ApplicationLogoUrl: this.configService.get<string>(
                'application.logo_url',
                '',
              ),
            },
          );
        }),
      );
    } else if (type === 'rejected') {
      await Promise.all(
        (items as RejectedApplications[]).map(async (item) => {
          const { applicationId, reason } = item;

          const application = await this.handleVerifyApplication(
            applicationId,
            recruiterId,
          );

          const { candidate_application_rejected } = NotificationType;

          const metadata: CandidateApplicationRejectedMetadata = {
            jobId: application.jobID,
            jobTitle: application.Jobs.Title,
            recruiterId,
            reason: reason
              ? reason
              : 'Liên hệ với nhà tuyển dụng để biết nguyên nhân.',
            companyName:
              application.Jobs.Recruiters.CompanyLocations.Companies.Name,
            applicationId: application.ID,
          };

          await this.userNotificationsService.handleCreateUserNotification(
            {
              Content: handleFormatUserNotificationContent(
                candidate_application_rejected,
                metadata,
              ),
              Type: candidate_application_rejected,
              metadata,
            },
            application.Candidates.Users.ID as string,
          );

          const { EMAIL_APPLICATION_REJECTED } = EmailTemplateNameEnum;

          await this.emailsProducer.sendEmail(
            application.Candidates.Users.Email as string,
            EMAIL_APPLICATION_REJECTED,
            {
              companyLogoUrl:
                application.Jobs.Recruiters.CompanyLocations.Companies.LogoUrl,
              companyName:
                application.Jobs.Recruiters.CompanyLocations.Companies.Name,
              CandidateName: application.Candidates.Users.FullName,
              jobTitle: application.Jobs.Title,
              reason: reason
                ? reason
                : 'Liên hệ với nhà tuyển dụng để biết lý do.',
              EmailSupport: this.configService.get<string>('admin.email', ''),
              PhoneSupport: this.configService.get<string>(
                'admin.phone_number',
                '',
              ),
              ApplicationLogoUrl: this.configService.get<string>(
                'application.logo_url',
                '',
              ),
            },
          );
        }),
      );
    }

    const { error } = await this.adminSupabaseClient
      .from('Applications')
      .update([
        {
          Status: type,
        },
      ])
      .in(
        'ID',
        type === 'accepted'
          ? (items as string[])
          : (items as RejectedApplications[]).map((i) => i.applicationId),
      );

    if (error) {
      console.error(error);

      throw new InternalServerErrorException(
        'Đã xảy ra lỗi khi xử lý đơn ứng tuyển. Vui lòng thử lại.',
      );
    }
  };

  public handleCalculateApplicationSummary = async (
    StartDate?: Date,
    EndDate?: Date,
  ) => {
    try {
      let query = this.anonSupabaseClient
        .from('Applications')
        .select('Status, ID');

      if (StartDate) {
        query = query.gte('AppliedAt', StartDate.toISOString());
      }

      if (EndDate) {
        query = query.lte('AppliedAt', EndDate.toISOString());
      }

      const { data, error } = await query;

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi lấy thống kê đơn ứng tuyển trong hệ thống.',
        );
      }

      const summary = {
        total: data.length,
        pending: data.filter((app) => app.Status === ApplicationStatus.pending)
          .length,
        accepted: data.filter(
          (app) => app.Status === ApplicationStatus.accepted,
        ).length,
        rejected: data.filter(
          (app) => app.Status === ApplicationStatus.rejected,
        ).length,
      };

      return summary;
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  private handleVerifyApplication = async (
    applicationId: string,
    recruiterId: string,
  ) => {
    const { data } = await this.anonSupabaseClient
      .from('Applications')
      .select(
        '*, Candidates(*, Users(*)), Jobs(*, Recruiters(*, CompanyLocations(*, Companies(*))))',
      )
      .eq('ID', applicationId)
      .maybeSingle<any>();

    if (!data)
      throw new NotFoundException(
        `Đơn ứng tuyển có id '${applicationId}' không tìm thấy trong hệ thống.`,
      );

    if (data.Jobs.Recruiters.ID !== recruiterId)
      throw new ForbiddenException(
        `Đơn ứng tuyển có id '${applicationId}' không ứng tuyển cho công việc mà bạn đăng, nên bạn không thể xủ lý chúng.`,
      );

    return data;
  };
}
