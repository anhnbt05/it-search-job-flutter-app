import { MailerModule } from '@nestjs-modules/mailer';
import { HandlebarsAdapter } from '@nestjs-modules/mailer/dist/adapters/handlebars.adapter';
import { BullModule } from '@nestjs/bullmq';
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { join } from 'path';
import { EmailsProcessor } from 'src/modules/emails/processors';
import { EmailsProducer } from 'src/modules/emails/producers';
import { EmailsService } from './emails.service';

@Module({
  imports: [
    MailerModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        transport: {
          host: configService.get<string>('mailer.host', ''),
          port: configService.get<number>('mailer.port', 587),
          secure: false,
          auth: {
            user: configService.get<string>('mailer.user'),
            pass: configService.get<string>('mailer.password'),
          },
        },
        defaults: {
          from: '"IT Job Support" <support@yourdomain.com>',
        },
        template: {
          dir: join(process.cwd(), 'src', 'modules', 'emails', 'templates'),
          adapter: new HandlebarsAdapter(),
          options: {
            strict: true,
          },
        },
      }),
    }),
    BullModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        connection: {
          url: configService.get<string>('redis_url', ''),
        },
      }),
    }),
    BullModule.registerQueue({
      name: 'emails-queue',
    }),
  ],
  providers: [EmailsService, EmailsProducer, EmailsProcessor],
  exports: [EmailsProcessor, EmailsService, EmailsProducer, BullModule],
})
export class EmailsModule {}
