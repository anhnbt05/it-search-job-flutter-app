import { InjectQueue } from '@nestjs/bullmq';
import { Injectable } from '@nestjs/common';
import { Queue } from 'bullmq';
import {
  BULLMQ_RETRY_DELAY,
  BULLMQ_RETRY_LIMIT,
  EMAIL_QUEUE_NAME,
} from 'src/libs/common/utils';

@Injectable()
export class EmailsProducer {
  constructor(
    @InjectQueue(EMAIL_QUEUE_NAME) private readonly emailsQueue: Queue,
  ) {}

  public sendEmail = async (
    email: string,
    templateName: string,
    context: Record<string, any>,
  ) => {
    await this.emailsQueue.add(
      `send-${templateName}`,
      { email, templateName, context },
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
