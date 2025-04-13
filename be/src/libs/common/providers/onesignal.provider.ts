import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  createConfiguration,
  DefaultApi,
  Notification,
} from '@onesignal/node-onesignal';
import {
  DEFAULT_TTL_PUSH_NOTIFICATION,
  handleFormatUserNotificationContent,
  PushNotificationData,
} from 'src/libs/common/utils';

@Injectable()
export class OneSignalProvider {
  private oneSignalClient: DefaultApi;
  private oneSignalAppId: string;

  constructor(private readonly configService: ConfigService) {
    this.oneSignalAppId = configService.get<string>('onesignal.app_id', '');

    const configuration = createConfiguration({
      restApiKey: configService.get<string>('onesignal.api_key', ''),
    });

    this.oneSignalClient = new DefaultApi(configuration);
  }

  public handleSendPushNotification = async (
    pushNotificationData: PushNotificationData,
  ) => {
    try {
      const { playerIds, type, metadata, title } = pushNotificationData;

      const contentParts = handleFormatUserNotificationContent(type, metadata);

      const message = contentParts.join('\n');

      const notification: Notification = {
        app_id: this.oneSignalAppId,
        include_subscription_ids: playerIds,
        headings: {
          vi: title,
          en: title,
        },
        contents: {
          vi: message,
          en: message,
        },
        data: metadata,
        ttl: DEFAULT_TTL_PUSH_NOTIFICATION,
        small_icon: this.configService.get<string>('application.icon_url', ''),
      };

      await this.oneSignalClient.createNotification(notification);
    } catch (err) {
      console.error(err);
      throw err;
    }
  };
}
