import { CacheInterceptor, CacheTTL } from '@nestjs/cache-manager';
import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Post,
  Query,
  Req,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { User } from '@supabase/supabase-js';
import { Request } from 'express';
import { Roles } from 'src/libs/common/decorators';
import { RoleAuthGuard, SupabaseGuard } from 'src/libs/common/guards';
import {
  API_TAGS,
  DEFAULT_TTL_SUMMARY_CACHED,
  RoleEnum,
} from 'src/libs/common/utils';
import { CreateReportDto, FilterSummaryDto } from 'src/modules/dashboards/dtos';
import { ReportProducer } from 'src/modules/dashboards/producers/report.producer';
import { DashboardsService } from './dashboards.service';

@Controller('dashboards')
@ApiBearerAuth()
@UseGuards(SupabaseGuard, RoleAuthGuard)
@Roles(RoleEnum.ADMIN)
@ApiTags(API_TAGS.DASHBOARD)
export class DashboardsController {
  constructor(
    private readonly dashboardsService: DashboardsService,
    private readonly reportProducer: ReportProducer,
  ) {}

  @Get('summary')
  @UseInterceptors(CacheInterceptor)
  @CacheTTL(DEFAULT_TTL_SUMMARY_CACHED)
  @ApiOperation({
    summary: 'Thống kê dữ liệu tổng quan về ứng dụng',
    description:
      'Đường dẫn này dùng thống kê dữ liệu tổng quan về ứng dụng liên quan đến bài đăng tuyển, đơn ứng tuyển, người dùng.',
  })
  @ApiResponse({
    status: 200,
    schema: {
      example: {
        jobStats: {
          total: 7,
          open: 6,
          pending: 0,
          closed: 0,
          rejected: 1,
          expired: 0,
        },
        applicationStats: {
          total: 3,
          pending: 1,
          accepted: 1,
          rejected: 1,
        },
        userStats: {
          total: 3,
          candidates: 1,
          recruiters: 1,
          activeUsers: 3,
          blockedUsers: 0,
        },
      },
    },
  })
  async handleCalculateSummaryData(
    @Query() filterSummaryDto?: FilterSummaryDto,
  ) {
    if (
      filterSummaryDto?.StartDate &&
      filterSummaryDto?.EndDate &&
      new Date(filterSummaryDto.EndDate).getTime() <
        new Date(filterSummaryDto.StartDate).getTime()
    )
      throw new BadRequestException(
        'Ngày bắt đầu lọc phải nhỏ hơn ngày kết thúc lọc.',
      );

    return this.dashboardsService.handleCalculateSummary(filterSummaryDto);
  }

  @Get('summary/companies')
  @ApiOperation({
    summary: 'Thống kê dữ liệu tổng quan về các công ty có trong hệ thống',
    description:
      'Đường dẫn này dùng để thống kê dữ liệu tổng quan về các công ty có trong hệ thống.',
  })
  @ApiResponse({
    status: 200,
    description: 'Dữ liệu trả về sau khi thống kê xong.',
    examples: {
      example1: {
        summary: 'Trường hợp không dùng bộ lọc.',
        value: [
          {
            companyId: '2180647a-d0e5-4062-a4a1-28de8bdf539e',
            companyName: 'Công ty phần mềm FPT Software',
            totalJobs: 7,
            totalApplications: 3,
            totalPendingApplications: 1,
            totalAcceptedApplications: 1,
            totalRejectedApplications: 1,
            acceptanceRate: 0.3333,
            mostAppliedJobTitle: 'QA Tester (Junior)',
            applicationTrendMonthly: [
              {
                month: '2025-04',
                totalApplications: 3,
              },
            ],
          },
        ],
      },
      example2: {
        summary:
          'Trường hợp dùng bộ lọc /?StartDate=2025-01-10&EndDate=2025-01-11',
        value: [
          {
            companyId: '2180647a-d0e5-4062-a4a1-28de8bdf539e',
            companyName: 'Công ty phần mềm FPT Software',
            totalJobs: 0,
            totalApplications: 0,
            totalAccepted: 0,
            acceptanceRate: 0,
            mostAppliedJobTitle: null,
          },
        ],
      },
    },
  })
  async handleCaculateCompaniesSummary(
    @Query() filterSummaryDto?: FilterSummaryDto,
  ) {
    if (
      filterSummaryDto?.StartDate &&
      filterSummaryDto?.EndDate &&
      new Date(filterSummaryDto.EndDate).getTime() <
        new Date(filterSummaryDto.StartDate).getTime()
    )
      throw new BadRequestException(
        'Ngày bắt đầu lọc phải nhỏ hơn ngày kết thúc lọc.',
      );

    return this.dashboardsService.handleCalculateCompaniesSummary(
      filterSummaryDto,
    );
  }

  @Post('summary/companies/report')
  @ApiOperation({
    summary: 'Tạo và gửi file báo cáo thống kê cho quản trị viên.',
    description:
      'Đường dẫn này dùng để tạo và gửi file (pdf hoặc xlsx) tổng quan về tình hình tuyển dụng của các công ty thông qua email cho quản trị viên.',
  })
  @ApiResponse({
    status: 201,
    schema: {
      example: {
        success: true,
        message: 'Vui lòng kiểm tra email để tải file báo cáo.',
      },
    },
  })
  @ApiBody({
    type: CreateReportDto,
    description: 'Dữ liệu cần gửi đi để nhận file báo cáo qua email',
  })
  async createReport(
    @Body() createReportDto: CreateReportDto,
    @Req() request: Request,
  ) {
    if (
      createReportDto?.StartDate &&
      createReportDto?.EndDate &&
      new Date(createReportDto.StartDate).getTime() >
        new Date(createReportDto.EndDate).getTime()
    )
      throw new BadRequestException(
        `Ngày bắt đầu lọc dữ liệu phải nhỏ hơn ngày kết thúc lọc dữ liệu.`,
      );

    const userId = (request.user as User).id;

    await this.reportProducer.createReportFlow(createReportDto, userId);

    return {
      success: true,
      message: 'Vui lòng kiểm tra email để tải file báo cáo.',
    };
  }
}
