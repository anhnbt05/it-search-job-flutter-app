import {
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { Notifications, UserNotifications, Users } from '@prisma/client';
import { SupabaseClient } from '@supabase/supabase-js';
import { InjectSupabaseClient } from 'nestjs-supabase-js';
import { CreateUserNotificationDto } from 'src/modules/user-notifications/dtos';
import { UserNotificationsGateway } from 'src/modules/user-notifications/gateways';

@Injectable()
export class UserNotificationsService {
  constructor(
    @InjectSupabaseClient('adminClient')
    private readonly adminSupabaseClient: SupabaseClient,
    @InjectSupabaseClient('anonClient')
    private readonly anonSupabaseClient: SupabaseClient,
    private readonly userNotificationsGateway: UserNotificationsGateway,
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

      this.userNotificationsGateway.sendNotificationToUser(
        user,
        createUserNotificationDto.Type,
        data,
      );
    } catch (err) {
      console.error(err);
      throw err;
    }
  };
}
