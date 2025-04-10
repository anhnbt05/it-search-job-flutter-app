import { OnWorkerEvent, Processor, WorkerHost } from '@nestjs/bullmq';
import { ConfigService } from '@nestjs/config';
import { Job } from 'bullmq';
import { EMAIL_QUEUE_NAME, EmailTemplateNameEnum } from 'src/libs/common/utils';
import { EmailsService } from 'src/modules/emails/emails.service';

@Processor(EMAIL_QUEUE_NAME)
export class EmailsProcessor extends WorkerHost {
  constructor(
    private readonly emailsService: EmailsService,
    private readonly configService: ConfigService,
  ) {
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

    const { email } = job.data;

    let context = job.data.context || {};

    let templateName = job.data?.templateName;

    const children = await job.getChildrenValues().catch(() => null);

    if (children && Object.keys(children).length > 0) {
      const uploadResultEntry = Object.entries(children).find(([key]) =>
        key.startsWith('bull:upload-report-queue:'),
      );

      if (uploadResultEntry) {
        const [, uploadResult] = uploadResultEntry;

        templateName = EmailTemplateNameEnum.EMAIL_REPORT;

        context = {
          AdminName: this.configService.get<string>('admin.full_name', ''),
          DownloadUrl: uploadResult.url,
          ApplicationLogoUrl: this.configService.get<string>(
            'application.logo_url',
            '',
          ),
        };
      }
    }

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
