import { ISendMailOptions, MailerService } from '@nestjs-modules/mailer';
import { Injectable } from '@nestjs/common';
import { SUBJECT_EMAIL_MAP } from 'src/libs/common/utils';

@Injectable()
export class EmailsService {
  constructor(private readonly mailerService: MailerService) {}

  public sendEmail = async (
    email: string,
    templateName: string,
    context: Record<string, any>,
  ) => {
    try {
      const mailOptions: ISendMailOptions = {
        to: email,
        subject: SUBJECT_EMAIL_MAP[templateName],
        template: templateName,
        context,
      };

      if (context?.DownloadUrl) {
        const filename = context.DownloadUrl?.split('/').pop();

        mailOptions.attachments = [
          {
            filename,
            path: context.DownloadUrl,
          },
        ];
      }

      await this.mailerService.sendMail(mailOptions);
    } catch (err) {
      console.error(err);
      throw err;
    }
  };
}
