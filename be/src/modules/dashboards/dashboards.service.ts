import { Injectable } from '@nestjs/common';
import { ApplicationsService } from 'src/modules/applications/applications.service';
import { CompaniesService } from 'src/modules/companies/companies.service';
import { ReportContext } from 'src/modules/dashboards/contexts/report.context';
import { CreateReportDto, FilterSummaryDto } from 'src/modules/dashboards/dtos';
import { JobsService } from 'src/modules/jobs/jobs.service';
import { UploadsService } from 'src/modules/uploads/uploads.service';
import { UsersService } from 'src/modules/users/users.service';

@Injectable()
export class DashboardsService {
  constructor(
    private readonly jobsService: JobsService,
    private readonly applicationsService: ApplicationsService,
    private readonly usersService: UsersService,
    private readonly companiesService: CompaniesService,
    private readonly uploadsService: UploadsService,
    private readonly reportsContext: ReportContext,
  ) {}

  public handleCalculateSummary = async (
    filterSummaryDto?: FilterSummaryDto,
  ) => {
    try {
      let startDate: Date | null = null;

      let endDate: Date | null = null;

      if (filterSummaryDto?.EndDate)
        endDate = new Date(filterSummaryDto.EndDate);

      if (filterSummaryDto?.StartDate)
        startDate = new Date(filterSummaryDto.StartDate);

      return {
        jobStats: await this.jobsService.handleCalculateJobSummary(
          startDate || undefined,
          endDate || undefined,
        ),
        applicationStats:
          await this.applicationsService.handleCalculateApplicationSummary(
            startDate || undefined,
            endDate || undefined,
          ),
        userStats: await this.usersService.handleCalculateUserSummary(
          startDate || undefined,
          endDate || undefined,
        ),
      };
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleCalculateCompaniesSummary = async (
    filterSummaryDto?: FilterSummaryDto,
  ) => {
    try {
      return this.companiesService.handleCalculateCompaniesSummary(
        filterSummaryDto?.StartDate
          ? new Date(filterSummaryDto.StartDate)
          : undefined,
        filterSummaryDto?.EndDate
          ? new Date(filterSummaryDto.EndDate)
          : undefined,
      );
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleGenerateReport = async (createReportDto: CreateReportDto) => {
    try {
      const { StartDate, EndDate, Type } = createReportDto;

      const data = await this.handleCalculateCompaniesSummary({
        StartDate: StartDate ? StartDate : undefined,
        EndDate: EndDate ? EndDate : undefined,
      });

      if (!data.length || !data) {
        console.warn(
          'Dữ liệu cho các công ty đang trống. Dừng quá trình tạo báo cáo',
        );
        return;
      }

      const strategy = this.reportsContext.getStrategy(Type);

      return strategy.generate(
        data,
        Type,
        StartDate ? new Date(StartDate) : undefined,
        EndDate ? new Date(EndDate) : undefined,
      );
    } catch (err) {
      console.error(err);
      throw err;
    }
  };

  public handleUploadReport = async (reportFilePath: string) => {
    try {
      console.log(reportFilePath);

      return this.uploadsService.handleUploadFilePath(reportFilePath, 'files');
    } catch (err) {
      console.error(err);
      throw err;
    }
  };
}
