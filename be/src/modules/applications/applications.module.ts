import { Module } from '@nestjs/common';
import { SupabaseModule } from 'nestjs-supabase-js';
import { OneSignalProvider } from 'src/libs/common/providers';
import { EmailsModule } from 'src/modules/emails/emails.module';
import { EmailsProducer } from 'src/modules/emails/producers';
import { JobsModule } from 'src/modules/jobs/jobs.module';
import { JobsService } from 'src/modules/jobs/jobs.service';
import { UploadsModule } from 'src/modules/uploads/uploads.module';
import { UploadsService } from 'src/modules/uploads/uploads.service';
import { UserNotificationsService } from 'src/modules/user-notifications/user-notifications.service';
import { UsersModule } from 'src/modules/users/users.module';
import { WebsocketGateway } from 'src/modules/websockets/websockets.gateway';
import { WebsocketsModule } from 'src/modules/websockets/websockets.module';
import { ApplicationsController } from './applications.controller';
import { ApplicationsService } from './applications.service';
import { HttpModule } from '@nestjs/axios';

@Module({
  imports: [
    SupabaseModule.injectClient('adminClient', 'anonClient'),
    UploadsModule,
    JobsModule,
    UsersModule,
    EmailsModule,
    WebsocketsModule,
    HttpModule,
  ],
  controllers: [ApplicationsController],
  providers: [
    ApplicationsService,
    UploadsService,
    JobsService,
    UserNotificationsService,
    EmailsProducer,
    OneSignalProvider,
    WebsocketGateway,
  ],
})
export class ApplicationsModule {}
