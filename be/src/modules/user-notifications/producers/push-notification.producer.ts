import { InjectQueue } from '@nestjs/bullmq';
import { Injectable } from '@nestjs/common';
import { Queue } from 'bullmq';
import {
  BULLMQ_RETRY_DELAY,
  BULLMQ_RETRY_LIMIT,
  PUSH_NOTIFICATION_QUEUE_NAME,
  PushNotificationData,
} from 'src/libs/common/utils';

@Injectable()
export class PushNotificaitonProducer {
  constructor(
    @InjectQueue(PUSH_NOTIFICATION_QUEUE_NAME)
    private readonly pushNotificationQueue: Queue,
  ) {}

  public handleAddPushNotificationToQueue = async (
    pushNotificationData: PushNotificationData,
  ) => {
    await this.pushNotificationQueue.add(
      'push-notification-for-user',
      { pushNotificationData },
      {
        attempts: BULLMQ_RETRY_LIMIT,
        backoff: {
          type: 'exponential',
          delay: BULLMQ_RETRY_DELAY,
        },
        removeOnComplete: true,
        removeOnFail: false,
      },
    );
  };
}
