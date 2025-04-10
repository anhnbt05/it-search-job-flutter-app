import { OnWorkerEvent, Processor, WorkerHost } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import { GENERATE_REPORT_QUEUE_NAME } from 'src/libs/common/utils';
import { DashboardsService } from 'src/modules/dashboards/dashboards.service';
import { CreateReportDto } from 'src/modules/dashboards/dtos';

@Processor(GENERATE_REPORT_QUEUE_NAME)
export class GenerateReportProcessor extends WorkerHost {
  constructor(private readonly dashboardsService: DashboardsService) {
    super();
  }

  async process(
    job: Job<{ createReportDto: CreateReportDto }>,
    token?: string,
  ): Promise<any> {
    console.log(`Processing job '${job.name}'...`);

    return this.dashboardsService.handleGenerateReport(
      job.data.createReportDto,
    );
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
