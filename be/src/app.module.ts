import { createKeyv } from '@keyv/redis';
import { HttpModule } from '@nestjs/axios';
import { CacheModule } from '@nestjs/cache-manager';
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { SupabaseModule } from 'nestjs-supabase-js';
import configurations from 'src/config/configurations';
import {
  HTTP_MODULE_MAX_REDIRECT,
  HTTP_MODULE_TIMEOUT,
} from 'src/libs/common/utils';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ApplicationsModule } from './modules/applications/applications.module';
import { AuthModule } from './modules/auth/auth.module';
import { CompaniesModule } from './modules/companies/companies.module';
import { EmailsModule } from './modules/emails/emails.module';
import { JobsModule } from './modules/jobs/jobs.module';
import { UploadsModule } from './modules/uploads/uploads.module';
import { UserNotificationsModule } from './modules/user-notifications/user-notifications.module';
import { UsersModule } from './modules/users/users.module';
import { WorkExperiencesModule } from './modules/work-experiences/work-experiences.module';
import { DashboardsModule } from './modules/dashboards/dashboards.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
      load: [configurations],
    }),
    CacheModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      isGlobal: true,
      useFactory: (configService: ConfigService) => ({
        stores: [
          createKeyv(configService.get<string>('redis_url', 'localhost:6379')),
        ],
      }),
    }),
    HttpModule.register({
      timeout: HTTP_MODULE_TIMEOUT,
      maxRedirects: HTTP_MODULE_MAX_REDIRECT,
    }),
    AuthModule,
    UsersModule,
    SupabaseModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => [
        {
          name: 'adminClient',
          supabaseConfig: {
            supabaseKey: configService.get<string>(
              'supabase.service_role_key',
              '',
            ),
            supabaseUrl: configService.get<string>('supabase.url', ''),
          },
        },
        {
          name: 'anonClient',
          supabaseConfig: {
            supabaseKey: configService.get<string>('supabase.anon_key', ''),
            supabaseUrl: configService.get<string>('supabase.url', ''),
          },
        },
      ],
    }),
    UploadsModule,
    EmailsModule,
    JobsModule,
    WorkExperiencesModule,
    CompaniesModule,
    ApplicationsModule,
    UserNotificationsModule,
    DashboardsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
