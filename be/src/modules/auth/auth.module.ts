import { HttpModule } from '@nestjs/axios';
import { Module } from '@nestjs/common';
import { MulterModule } from '@nestjs/platform-express';
import * as multer from 'multer';
import { EmailsModule } from 'src/modules/emails/emails.module';
import { EmailsProducer } from 'src/modules/emails/producers';
import { UploadsModule } from 'src/modules/uploads/uploads.module';
import { UploadsService } from 'src/modules/uploads/uploads.service';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JobsModule } from 'src/modules/jobs/jobs.module';
import { JobsService } from 'src/modules/jobs/jobs.service';
import { SupabaseModule } from 'nestjs-supabase-js';
import { SupabaseGuard } from 'src/libs/common/guards';

@Module({
  imports: [
    HttpModule,
    MulterModule.register({
      storage: multer.diskStorage({
        destination: './uploads',
        filename: (req, file, cb) => {
          const timestamp = Date.now();
          const sanitizedOriginalName = file.originalname.replace(/\s+/g, '_');
          cb(null, `${timestamp}-${sanitizedOriginalName}`);
        },
      }),
    }),
    UploadsModule,
    EmailsModule,
    JobsModule,
    SupabaseModule.injectClient('adminClient', 'anonClient'),
  ],
  controllers: [AuthController],
  providers: [AuthService, UploadsService, EmailsProducer, JobsService],
})
export class AuthModule {}
