import { createKeyv } from '@keyv/redis';
import { HttpModule } from '@nestjs/axios';
import { CacheModule } from '@nestjs/cache-manager';
import {
  MiddlewareConsumer,
  Module,
  NestModule,
  RequestMethod,
} from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import configurations from 'src/config/configurations';
import { AuthMiddleware } from 'src/libs/common/middlewares/auth.middleware';
import {
  excludes,
  HTTP_MODULE_MAX_REDIRECT,
  HTTP_MODULE_TIMEOUT,
} from 'src/libs/common/utils';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './modules/auth/auth.module';
import { EmailsModule } from './modules/emails/emails.module';
import { JobsModule } from './modules/jobs/jobs.module';
import { SupabaseModule } from './modules/supabase/supabase.module';
import { UploadsModule } from './modules/uploads/uploads.module';
import { UsersModule } from './modules/users/users.module';
import { WorkExperiencesModule } from './modules/work-experiences/work-experiences.module';
import { CompaniesModule } from './modules/companies/companies.module';

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
    SupabaseModule,
    UploadsModule,
    EmailsModule,
    JobsModule,
    WorkExperiencesModule,
    CompaniesModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    return consumer
      .apply(AuthMiddleware)
      .exclude(
        ...excludes.map((route) => ({
          path: route,
          method: RequestMethod.ALL,
        })),
      )
      .forRoutes('*');
  }
}
