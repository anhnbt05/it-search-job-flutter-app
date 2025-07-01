import { Module } from '@nestjs/common';
import { WorkExperiencesService } from './work-experiences.service';
import { WorkExperiencesController } from './work-experiences.controller';
import { UploadsModule } from 'src/modules/uploads/uploads.module';
import { UploadsService } from 'src/modules/uploads/uploads.service';
import { UsersModule } from 'src/modules/users/users.module';
import { UsersService } from 'src/modules/users/users.service';
import { SupabaseModule } from 'nestjs-supabase-js';
import { OneSignalProvider } from 'src/libs/common/providers';
import { HttpModule } from '@nestjs/axios';

@Module({
  imports: [
    UploadsModule,
    UsersModule,
    SupabaseModule.injectClient('adminClient', 'anonClient'),
    HttpModule,
  ],
  controllers: [WorkExperiencesController],
  providers: [
    WorkExperiencesService,
    UploadsService,
    UsersService,
    OneSignalProvider,
  ],
})
export class WorkExperiencesModule {}
