import { Module } from '@nestjs/common';
import { SupabaseModule } from 'nestjs-supabase-js';
import { UploadsModule } from 'src/modules/uploads/uploads.module';
import { UserNotificationsModule } from 'src/modules/user-notifications/user-notifications.module';
import { UserNotificationsService } from 'src/modules/user-notifications/user-notifications.service';
import { UsersModule } from 'src/modules/users/users.module';
import { UsersService } from 'src/modules/users/users.service';
import { JobsController } from './jobs.controller';
import { JobsService } from './jobs.service';

@Module({
  imports: [
    SupabaseModule.injectClient('adminClient', 'anonClient'),
    UsersModule,
    UploadsModule,
    UserNotificationsModule,
  ],
  controllers: [JobsController],
  providers: [JobsService, UsersService, UserNotificationsService],
  exports: [JobsService],
})
export class JobsModule {}
