import { HttpModule } from '@nestjs/axios';
import { BullModule } from '@nestjs/bullmq';
import { Module } from '@nestjs/common';
import { SupabaseModule } from 'nestjs-supabase-js';
import {
  GENERATE_REPORT_QUEUE_NAME,
  REPORT_FLOW_PRODUCER,
  UPLOAD_REPORT_QUEUE_NAME,
} from 'src/libs/common/utils';
import { ApplicationsModule } from 'src/modules/applications/applications.module';
import { ApplicationsService } from 'src/modules/applications/applications.service';
import { CompaniesModule } from 'src/modules/companies/companies.module';
import { CompaniesService } from 'src/modules/companies/companies.service';
import { ReportContext } from 'src/modules/dashboards/contexts';
import {
  GenerateReportProcessor,
  UploadReportProcessor,
} from 'src/modules/dashboards/processors';
import { ReportProducer } from 'src/modules/dashboards/producers';
import {
  ExcelReportStrategy,
  PdfReportStrategy,
} from 'src/modules/dashboards/strategies';
import { EmailsModule } from 'src/modules/emails/emails.module';
import { EmailsProducer } from 'src/modules/emails/producers';
import { JobsModule } from 'src/modules/jobs/jobs.module';
import { JobsService } from 'src/modules/jobs/jobs.service';
import { UploadsModule } from 'src/modules/uploads/uploads.module';
import { UploadsService } from 'src/modules/uploads/uploads.service';
import { UsersModule } from 'src/modules/users/users.module';
import { UsersService } from 'src/modules/users/users.service';
import { WebsocketGateway } from 'src/modules/websockets/websockets.gateway';
import { DashboardsController } from './dashboards.controller';
import { DashboardsService } from './dashboards.service';

@Module({
  imports: [
    SupabaseModule.injectClient('adminClient', 'anonClient'),
    JobsModule,
    ApplicationsModule,
    UsersModule,
    UploadsModule,
    EmailsModule,
    CompaniesModule,
    UploadsModule,
    HttpModule,
    BullModule.registerFlowProducer({
      name: REPORT_FLOW_PRODUCER,
    }),
    BullModule.registerQueue(
      {
        name: GENERATE_REPORT_QUEUE_NAME,
      },
      {
        name: UPLOAD_REPORT_QUEUE_NAME,
      },
    ),
  ],
  controllers: [DashboardsController],
  providers: [
    DashboardsService,
    JobsService,
    ApplicationsService,
    UsersService,
    CompaniesService,
    ExcelReportStrategy,
    PdfReportStrategy,
    UploadsService,
    UploadReportProcessor,
    GenerateReportProcessor,
    ReportProducer,
    EmailsProducer,
    ReportContext,
    WebsocketGateway,
  ],
})
export class DashboardsModule {}
