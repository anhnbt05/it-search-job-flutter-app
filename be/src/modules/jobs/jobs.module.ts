import { Module } from '@nestjs/common';
import { SupabaseModule } from 'nestjs-supabase-js';
import { OneSignalProvider } from 'src/libs/common/providers';
import { UploadsModule } from 'src/modules/uploads/uploads.module';
import { UserNotificationsModule } from 'src/modules/user-notifications/user-notifications.module';
import { UserNotificationsService } from 'src/modules/user-notifications/user-notifications.service';
import { UsersModule } from 'src/modules/users/users.module';
import { UsersService } from 'src/modules/users/users.service';
import { JobsController } from './jobs.controller';
import { JobsService } from './jobs.service';
import { WebsocketsModule } from 'src/modules/websockets/websockets.module';
import { ScheduleModule } from '@nestjs/schedule';

@Module({
  imports: [
    SupabaseModule.injectClient('adminClient', 'anonClient'),
    UsersModule,
    UploadsModule,
    UserNotificationsModule,
    WebsocketsModule,
    ScheduleModule.forRoot(),
  ],
  controllers: [JobsController],
  providers: [
    JobsService,
    UsersService,
    UserNotificationsService,
    OneSignalProvider,
  ],
  exports: [JobsService],
})
export class JobsModule {}
