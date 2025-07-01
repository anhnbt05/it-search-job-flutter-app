import { BullModule } from '@nestjs/bullmq';
import { Global, Module } from '@nestjs/common';
import { SupabaseModule } from 'nestjs-supabase-js';
import { OneSignalProvider } from 'src/libs/common/providers';
import { PUSH_NOTIFICATION_QUEUE_NAME } from 'src/libs/common/utils';
import { PushNotificationProcessor } from 'src/modules/user-notifications/processors';
import { PushNotificaitonProducer } from 'src/modules/user-notifications/producers';
import { WebsocketsModule } from 'src/modules/websockets/websockets.module';
import { UserNotificationsService } from './user-notifications.service';
import { HttpModule } from '@nestjs/axios';

@Global()
@Module({
  imports: [
    SupabaseModule.injectClient('adminClient', 'anonClient'),
    BullModule.registerQueue({
      name: PUSH_NOTIFICATION_QUEUE_NAME,
    }),
    WebsocketsModule,
    HttpModule,
  ],
  providers: [
    UserNotificationsService,
    OneSignalProvider,
    PushNotificaitonProducer,
    PushNotificationProcessor,
  ],
  exports: [
    UserNotificationsService,
    PushNotificaitonProducer,
    PushNotificationProcessor,
  ],
})
export class UserNotificationsModule {}
