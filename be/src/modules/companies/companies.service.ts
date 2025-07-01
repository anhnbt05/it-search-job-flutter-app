import {
  ForbiddenException,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { ApplicationStatus, Companies, Recruiters } from '@prisma/client';
import { SupabaseClient } from '@supabase/supabase-js';
import { InjectSupabaseClient } from 'nestjs-supabase-js';
import { UpdateCompanyDto } from 'src/modules/companies/dtos';
import { UploadsService } from 'src/modules/uploads/uploads.service';

@Injectable()
export class CompaniesService {
  constructor(
    @InjectSupabaseClient('adminClient')
    private readonly adminSupabaseClient: SupabaseClient,
    @InjectSupabaseClient('anonClient')
    private readonly anonSupabaseClient: SupabaseClient,
    private readonly uploadsService: UploadsService,
  ) {}

  public handleUpdateCompany = async (
    companyId: string,
    updateCompanyDto: UpdateCompanyDto,
    userId: string,
    logoFile?: Express.Multer.File,
  ) => {
    try {
      const { data: recruiter } = await this.anonSupabaseClient
        .from('Recruiters')
        .select('*')
        .eq('UserID', userId)
        .maybeSingle<Recruiters>();

      if (!recruiter)
        throw new NotFoundException(
          `Không tìm thấy thông tin về hồ sơ nhà ứng tuyển của bạn. Vui lòng liên hệ với quản trị viên.`,
        );

      const { data: company } = await this.anonSupabaseClient
        .from('Companies')
        .select('*, CompanyLocations(*, Recruiters(*))')
        .eq('ID', companyId)
        .maybeSingle<any>();

      if (!company)
        throw new NotFoundException(
          `Không tìm thấy công ty có id '${companyId}' trong hệ thống.`,
        );

      const recruiterIds = company.CompanyLocations.flatMap(
        (cl: any) => cl.Recruiters,
      ).map((r: any) => r.ID);

      if (!recruiterIds.includes(recruiter.ID))
        throw new ForbiddenException(
          'Bạn chỉ có thể chỉnh sửa công ty của chính mình.',
        );

      let logoFileUrl: string = '';

      if (logoFile) {
        const { url } = await this.uploadsService.uploadFile(logoFile, 'files');

        if (url) logoFileUrl = url;
      }

      const { data, error } = await this.adminSupabaseClient
        .from('Companies')
        .update([
          {
            ...updateCompanyDto,
            ...(logoFileUrl && { LogoUrl: logoFileUrl }),
          },
        ])
        .eq('ID', companyId)
        .select('*')
        .maybeSingle<Companies>();

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi cập nhật thông tin cho công ty của bạn. Vui lòng thử lại sau.',
        );
      }

      return data;
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleCalculateCompaniesSummary = async (
    startDate?: Date,
    endDate?: Date,
  ) => {
    try {
      const { data: companies, error: companyError } =
        await this.anonSupabaseClient
          .from('Companies')
          .select(
            'ID, Name, LogoUrl, CompanyLocations(*, Recruiters(*, Jobs(*)))',
          );

      if (companyError) {
        console.error(companyError);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi lấy danh sách công ty trong hệ thống.',
        );
      }

      if (!companies.length) return [];

      const result: any[] = [];

      for (const company of companies) {
        const jobIds: string[] =
          company.CompanyLocations.flatMap((c) => c.Recruiters)
            .flatMap((d) => d.Jobs)
            .filter((j) => {
              if (!j.PostedAt) return false;
              const postedAt = new Date(j.PostedAt as string);
              if (startDate && postedAt < startDate) return false;
              if (endDate && postedAt > endDate) return false;
              return true;
            })
            .map((j) => j.ID) ?? [];

        const totalJobs = jobIds.length;

        if (!totalJobs) {
          result.push({
            companyId: company.ID,
            companyName: company.Name,
            companyLogoUrl: company.LogoUrl,
            totalJobs: 0,
            totalApplications: 0,
            totalPendingApplications: 0,
            totalAcceptedApplications: 0,
            totalRejectedApplications: 0,
            acceptanceRate: 0,
            mostAppliedJobTitle: 'Không có dữ liệu',
            applicationTrendMonthly: [],
          });

          continue;
        }

        const { data: applications } = await this.anonSupabaseClient
          .from('Applications')
          .select('Status, AppliedAt, JobID')
          .in('JobID', jobIds);

        const filteredApplications =
          applications?.filter((app) => {
            const appliedDate = new Date(app.AppliedAt as string);
            if (startDate && appliedDate < startDate) return false;
            if (endDate && appliedDate > endDate) return false;
            return true;
          }) ?? [];

        const totalApplications = filteredApplications.length ?? [];

        const totalAcceptedApplications =
          filteredApplications?.filter(
            (a) => a.Status === ApplicationStatus.accepted,
          ).length ?? 0;

        const totalRejectedApplications =
          filteredApplications?.filter(
            (a) => a.Status === ApplicationStatus.rejected,
          ).length ?? 0;

        const totalPendingApplications =
          filteredApplications?.filter(
            (a) => a.Status === ApplicationStatus.pending,
          ).length ?? 0;

        const jobMap = company.CompanyLocations.flatMap((c) => c.Recruiters)
          .flatMap((r) => r.Jobs)
          .reduce((acc, job) => {
            acc.set(job.ID, job.Title);
            return acc;
          }, new Map<string, string>());

        const jobCountMap = new Map<string, number>();

        filteredApplications?.forEach((app) => {
          const title = jobMap.get(app.JobID) ?? 'Unknown';

          jobCountMap.set(
            title as string,
            (jobCountMap.get(title as string) ?? 0) + 1,
          );
        });

        const trendMap = new Map<string, number>();

        filteredApplications?.forEach((item) => {
          const appliedAt = new Date(item.AppliedAt as string);

          const monthKey = `${appliedAt.getFullYear()}-${String(appliedAt.getMonth() + 1).padStart(2, '0')}`;

          trendMap.set(monthKey, (trendMap.get(monthKey) ?? 0) + 1);
        });

        const applicationTrendMonthly = [...trendMap.entries()]
          .sort(([a], [b]) => a.localeCompare(b))
          .map(([month, count]) => ({ month, totalApplications: count }));

        const mostAppliedJobTitle =
          [...jobCountMap.entries()].sort((a, b) => b[1] - a[1])[0]?.[0] ??
          'Không có dữ liệu';

        result.push({
          companyId: company.ID,
          companyName: company.Name,
          companyLogoUrl: company.LogoUrl,
          totalJobs,
          totalApplications,
          totalPendingApplications,
          totalAcceptedApplications,
          totalRejectedApplications,
          acceptanceRate:
            totalApplications > 0
              ? +(totalAcceptedApplications / totalApplications).toFixed(4)
              : 0,
          mostAppliedJobTitle,
          applicationTrendMonthly,
        });
      }

      return result;
    } catch (err) {
      console.error(err);
      throw err;
    }
  };
}
