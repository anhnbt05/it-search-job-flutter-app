import { Module } from '@nestjs/common';
import { SupabaseModule } from 'nestjs-supabase-js';
import { JobsModule } from 'src/modules/jobs/jobs.module';
import { JobsService } from 'src/modules/jobs/jobs.service';
import { UploadsModule } from 'src/modules/uploads/uploads.module';
import { UploadsService } from 'src/modules/uploads/uploads.service';
import { ApplicationsController } from './applications.controller';
import { ApplicationsService } from './applications.service';
import { UsersModule } from 'src/modules/users/users.module';

@Module({
  imports: [
    SupabaseModule.injectClient('adminClient', 'anonClient'),
    UploadsModule,
    JobsModule,
    UsersModule,
  ],
  controllers: [ApplicationsController],
  providers: [ApplicationsService, UploadsService, JobsService],
})
export class ApplicationsModule {}
