import { Global, Module } from '@nestjs/common';
import { SupabaseModule } from 'nestjs-supabase-js';
import { UserNotificationsGateway } from 'src/modules/user-notifications/gateways';
import { UserNotificationsService } from './user-notifications.service';

@Global()
@Module({
  imports: [SupabaseModule.injectClient('adminClient', 'anonClient')],
  providers: [UserNotificationsService, UserNotificationsGateway],
  exports: [UserNotificationsService, UserNotificationsGateway],
})
export class UserNotificationsModule {}
