import { OnWorkerEvent, Processor, WorkerHost } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import { OneSignalProvider } from 'src/libs/common/providers';
import {
  PUSH_NOTIFICATION_QUEUE_NAME,
  PushNotificationData,
} from 'src/libs/common/utils';

@Processor(PUSH_NOTIFICATION_QUEUE_NAME)
export class PushNotificationProcessor extends WorkerHost {
  constructor(private readonly oneSignalProvider: OneSignalProvider) {
    super();
  }

  async process(
    job: Job<{ pushNotificationData: PushNotificationData }>,
  ): Promise<any> {
    console.log(`Processing job '${job.name}'...`);

    return this.oneSignalProvider.handleSendPushNotification(
      job.data.pushNotificationData,
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
