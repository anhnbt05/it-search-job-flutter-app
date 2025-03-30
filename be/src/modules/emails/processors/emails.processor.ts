import { OnWorkerEvent, Processor, WorkerHost } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import { EmailsService } from 'src/modules/emails/emails.service';

@Processor('emails-queue')
export class EmailsProcessor extends WorkerHost {
  constructor(private readonly emailsService: EmailsService) {
    super();
  }

  async process(
    job: Job<{
      email: string;
      templateName: string;
      context: Record<string, any>;
    }>,
  ): Promise<any> {
    console.log(
      `Processing job '${job.name}': Sending email to '${job.data.email}'...`,
    );

    const { email, templateName, context } = job.data;

    return this.emailsService.sendEmail(email, templateName, context);
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
