import { HttpService } from '@nestjs/axios';
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  createConfiguration,
  DefaultApi,
  Notification,
} from '@onesignal/node-onesignal';
import { firstValueFrom } from 'rxjs';
import {
  DEFAULT_TTL_PUSH_NOTIFICATION,
  handleFormatUserNotificationContent,
  PushNotificationData,
} from 'src/libs/common/utils';

@Injectable()
export class OneSignalProvider {
  private oneSignalClient: DefaultApi;
  private oneSignalAppId: string;

  constructor(
    private readonly configService: ConfigService,
    private readonly httpService: HttpService,
  ) {
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

      const allPlayerIds = await this.getAllPlayerIdsFromOneSignal();

      const activePlayerIds = playerIds.filter((id) =>
        allPlayerIds.includes(id),
      );

      const contentParts = handleFormatUserNotificationContent(type, metadata);

      const message = contentParts.join('\n');

      const notification: Notification = {
        app_id: this.oneSignalAppId,
        include_subscription_ids: activePlayerIds,
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

  private getAllPlayerIdsFromOneSignal = async (): Promise<string[]> => {
    const limit = 300;
    let offset = 0;
    let hasMore = true;
    const allPlayerIds: string[] = [];

    while (hasMore) {
      const response = await firstValueFrom(
        this.httpService.get(`https://onesignal.com/api/v1/players`, {
          headers: {
            Authorization: `Basic ${this.configService.get<string>('onesignal.api_key', '')}`,
          },
          params: {
            app_id: this.oneSignalAppId,
            limit,
            offset,
          },
        }),
      );

      const players = response.data.players || [];

      allPlayerIds.push(...(players.map((p: any) => p.id) as string[]));

      hasMore = players.length === limit;
      offset += limit;
    }

    return allPlayerIds;
  };

  public getInvalidPlayerIds = async (storedPlayerIds: string[]) => {
    const allValidPlayerIds = await this.getAllPlayerIdsFromOneSignal();

    return storedPlayerIds.filter((id) => !allValidPlayerIds.includes(id));
  };
}
