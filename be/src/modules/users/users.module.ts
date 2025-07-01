import { HttpModule } from '@nestjs/axios';
import { Module } from '@nestjs/common';
import { SupabaseModule } from 'nestjs-supabase-js';
import { OneSignalProvider } from 'src/libs/common/providers';
import { UploadsModule } from 'src/modules/uploads/uploads.module';
import { UploadsService } from 'src/modules/uploads/uploads.service';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';

@Module({
  imports: [
    UploadsModule,
    SupabaseModule.injectClient('adminClient', 'anonClient'),
    HttpModule,
  ],
  controllers: [UsersController],
  providers: [UsersService, UploadsService, OneSignalProvider],
  exports: [UsersService],
})
export class UsersModule {}
