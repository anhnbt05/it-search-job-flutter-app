import { Cache, CACHE_MANAGER } from '@nestjs/cache-manager';
import {
  Inject,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import {
  Notifications,
  UserDevices,
  UserNotifications,
  Users,
} from '@prisma/client';
import { SupabaseClient } from '@supabase/supabase-js';
import { InjectSupabaseClient } from 'nestjs-supabase-js';
import { CreateUserNotificationDto } from 'src/modules/user-notifications/dtos';
import { PushNotificaitonProducer } from 'src/modules/user-notifications/producers';
import { WebsocketGateway } from 'src/modules/websockets/websockets.gateway';

@Injectable()
export class UserNotificationsService {
  constructor(
    @InjectSupabaseClient('adminClient')
    private readonly adminSupabaseClient: SupabaseClient,
    @InjectSupabaseClient('anonClient')
    private readonly anonSupabaseClient: SupabaseClient,
    private readonly websocketsGateway: WebsocketGateway,
    private readonly pushNotificationProducer: PushNotificaitonProducer,
    @Inject(CACHE_MANAGER) private readonly cacheManager: Cache,
  ) {}

  public handleCreateUserNotification = async (
    createUserNotificationDto: CreateUserNotificationDto,
    userId: string,
  ) => {
    try {
      const { data: user } = await this.anonSupabaseClient
        .from('Users')
        .select('*')
        .eq('ID', userId)
        .maybeSingle<Users>();

      if (!user)
        throw new NotFoundException(
          `Không tìm thấy người dùng có id '${userId}' trong hệ thống.`,
        );

      const { data: userDevices } = await this.anonSupabaseClient
        .from('UserDevices')
        .select('*')
        .eq('UserID', userId)
        .overrideTypes<UserDevices[], { merge: false }>();

      const { Type, Content, metadata } = createUserNotificationDto;

      const { data: notification } = await this.anonSupabaseClient
        .from('Notifications')
        .select('*')
        .eq('Type', Type)
        .maybeSingle<Notifications>();

      if (!notification)
        throw new NotFoundException(
          `Không tìm thấy thông báo có kiểu là '${Type}' trong hệ thống.`,
        );

      const { data, error } = await this.adminSupabaseClient
        .from('UserNotifications')
        .insert([
          {
            Content,
            Metadata: metadata,
            UserID: userId,
            NotificationID: notification.ID,
          },
        ])
        .select()
        .single<UserNotifications>();

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi tạo mới thông báo cho người dùng.',
        );
      }

      const statusOfUser = await this.cacheManager.get(`user:${userId}:status`);

      if (
        statusOfUser &&
        typeof statusOfUser === 'string' &&
        statusOfUser === 'online'
      ) {
        this.websocketsGateway.sendNotificationToUserRealTime(
          user,
          createUserNotificationDto.Type,
          data,
        );
      } else if (userDevices?.length)
        await this.pushNotificationProducer.handleAddPushNotificationToQueue({
          playerIds: userDevices.map((ud) => ud.PlayerID),
          title: notification.Title,
          type: Type,
          metadata,
        });
    } catch (err) {
      console.error(err);
      throw err;
    }
  };
}
