import { OnWorkerEvent, Processor, WorkerHost } from '@nestjs/bullmq';
import { InternalServerErrorException } from '@nestjs/common';
import { Job } from 'bullmq';
import {
  EmailTemplateNameEnum,
  UPLOAD_REPORT_QUEUE_NAME,
} from 'src/libs/common/utils';
import { DashboardsService } from 'src/modules/dashboards/dashboards.service';

@Processor(UPLOAD_REPORT_QUEUE_NAME)
export class UploadReportProcessor extends WorkerHost {
  constructor(private readonly dashboardsService: DashboardsService) {
    super();
  }

  async process(job: Job<any>, token?: string): Promise<any> {
    console.log(`Processing job '${job.name}'...`);

    const childrenValues = Object.values<string>(await job.getChildrenValues());

    if (!childrenValues.length)
      throw new InternalServerErrorException(
        'Đã xảy ra lỗi trong quá trình tạo báo cáo.',
      );

    return this.dashboardsService.handleUploadReport(childrenValues[0]);
  }

  @OnWorkerEvent('completed')
  onCompleted(job: Job) {
    console.log(`Job '${job.name}' completed.`);
  }

  @OnWorkerEvent('failed')
  onFailed(job: Job, err: Error) {
    console.error(`Job '${job.name} failed due to: `, err);
  }

  @OnWorkerEvent('active')
  onActive(job: Job) {
    if (job.attemptsMade > 0) {
      console.error(
        `Retrying job '${job.name}', attempt: ${job.attemptsMade + 1}`,
      );
    }
  }
}
