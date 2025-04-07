import { Module } from '@nestjs/common';
import { JobsService } from './jobs.service';
import { JobsController } from './jobs.controller';
import { SupabaseModule } from 'nestjs-supabase-js';

@Module({
  imports: [SupabaseModule.injectClient('adminClient', 'anonClient')],
  controllers: [JobsController],
  providers: [JobsService],
})
export class JobsModule {}
