import { Module } from '@nestjs/common';
import { UploadsService } from './uploads.service';
import { SupabaseModule } from 'nestjs-supabase-js';

@Module({
  imports: [SupabaseModule.injectClient('adminClient')],
  providers: [UploadsService],
  exports: [UploadsService],
})
export class UploadsModule {}
