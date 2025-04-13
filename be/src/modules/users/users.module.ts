import { Module } from '@nestjs/common';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { UploadsModule } from 'src/modules/uploads/uploads.module';
import { UploadsService } from 'src/modules/uploads/uploads.service';
import { SupabaseModule } from 'nestjs-supabase-js';

@Module({
  imports: [
    UploadsModule,
    SupabaseModule.injectClient('adminClient', 'anonClient'),
  ],
  controllers: [UsersController],
  providers: [UsersService, UploadsService],
  exports: [UsersService],
})
export class UsersModule {}
