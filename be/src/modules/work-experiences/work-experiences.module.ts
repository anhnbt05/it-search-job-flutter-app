import { Module } from '@nestjs/common';
import { WorkExperiencesService } from './work-experiences.service';
import { WorkExperiencesController } from './work-experiences.controller';
import { UploadsModule } from 'src/modules/uploads/uploads.module';
import { UploadsService } from 'src/modules/uploads/uploads.service';
import { UsersModule } from 'src/modules/users/users.module';
import { UsersService } from 'src/modules/users/users.service';
import { SupabaseModule } from 'nestjs-supabase-js';

@Module({
  imports: [
    UploadsModule,
    UsersModule,
    SupabaseModule.injectClient('adminClient', 'anonClient'),
  ],
  controllers: [WorkExperiencesController],
  providers: [WorkExperiencesService, UploadsService, UsersService],
})
export class WorkExperiencesModule {}
