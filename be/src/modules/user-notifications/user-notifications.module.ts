import { Global, Module } from '@nestjs/common';
import { SupabaseModule } from 'nestjs-supabase-js';
import { UserNotificationsService } from './user-notifications.service';

@Global()
@Module({
  imports: [SupabaseModule.injectClient('adminClient', 'anonClient')],
  providers: [UserNotificationsService],
  exports: [UserNotificationsService],
})
export class UserNotificationsModule {}
