import { Module } from '@nestjs/common';
import { CompaniesService } from './companies.service';
import { CompaniesController } from './companies.controller';
import { SupabaseModule } from 'nestjs-supabase-js';
import { UploadsModule } from 'src/modules/uploads/uploads.module';
import { UploadsService } from 'src/modules/uploads/uploads.service';

@Module({
  imports: [
    SupabaseModule.injectClient('adminClient', 'anonClient'),
    UploadsModule,
  ],
  controllers: [CompaniesController],
  providers: [CompaniesService, UploadsService],
})
export class CompaniesModule {}
