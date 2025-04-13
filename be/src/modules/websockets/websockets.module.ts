import { Module } from '@nestjs/common';
import { SupabaseModule } from 'nestjs-supabase-js';
import { WebsocketGateway } from 'src/modules/websockets/websockets.gateway';

@Module({
  imports: [SupabaseModule.injectClient('adminClient', 'anonClient')],
  providers: [WebsocketGateway],
  exports: [WebsocketGateway],
})
export class WebsocketsModule {}
