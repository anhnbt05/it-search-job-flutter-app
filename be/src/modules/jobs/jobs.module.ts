import { Module } from '@nestjs/common';
import { JobsService } from './jobs.service';
import { JobsController } from './jobs.controller';
import { SupabaseModule } from 'nestjs-supabase-js';
import { UsersModule } from 'src/modules/users/users.module';
import { UsersService } from 'src/modules/users/users.service';
import { UploadsModule } from 'src/modules/uploads/uploads.module';

@Module({
  imports: [
    SupabaseModule.injectClient('adminClient', 'anonClient'),
    UsersModule,
    UploadsModule,
  ],
  controllers: [JobsController],
  providers: [JobsService, UsersService],
  exports: [JobsService],
})
export class JobsModule {}
