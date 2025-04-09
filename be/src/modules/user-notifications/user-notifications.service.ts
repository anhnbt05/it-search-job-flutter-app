import {
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { Notifications } from '@prisma/client';
import { SupabaseClient } from '@supabase/supabase-js';
import { InjectSupabaseClient } from 'nestjs-supabase-js';
import { CreateUserNotificationDto } from 'src/modules/user-notifications/dtos';

@Injectable()
export class UserNotificationsService {
  constructor(
    @InjectSupabaseClient('adminClient')
    private readonly adminSupabaseClient: SupabaseClient,
    @InjectSupabaseClient('anonClient')
    private readonly anonSupabaseClient: SupabaseClient,
  ) {}

  public handleCreateUserNotification = async (
    createUserNotificationDto: CreateUserNotificationDto,
    userId: string,
  ) => {
    try {
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

      const { error } = await this.adminSupabaseClient
        .from('UserNotifications')
        .insert([
          {
            Content,
            Metadata: metadata,
            UserID: userId,
            NotificationID: notification.ID,
          },
        ]);

      if (error) {
        console.error(error);

        throw new InternalServerErrorException(
          'Đã xảy ra lỗi khi tạo mới thông báo cho người dùng.',
        );
      }
    } catch (err) {
      console.error(err);
      throw err;
    }
  };
}
