import { Cache, CACHE_MANAGER } from '@nestjs/cache-manager';
import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import {
  OnGatewayConnection,
  OnGatewayDisconnect,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { NotificationType, UserNotifications, Users } from '@prisma/client';
import { SupabaseClient } from '@supabase/supabase-js';
import { InjectSupabaseClient } from 'nestjs-supabase-js';
import { Server, Socket } from 'socket.io';
import {
  DEFAULT_STATUS_USER_ONLINE,
  handleGetNotificationEventByType,
} from 'src/libs/common/utils';

@WebSocketGateway({
  namespace: '/websockets/gateway',
  cors: {
    origin: '*',
  },
})
@Injectable()
export class WebsocketGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  private readonly server: Server;

  constructor(
    @Inject(CACHE_MANAGER) private readonly cacheManager: Cache,
    @InjectSupabaseClient('anonClient')
    private readonly anonSupabaseClient: SupabaseClient,
  ) {}

  async handleConnection(client: Socket) {
    const userId = client.handshake.query.userId as string;

    if (userId) {
      const { data: user } = await this.anonSupabaseClient
        .from('Users')
        .select('*')
        .eq('ID', userId)
        .maybeSingle<Users>();

      if (!user)
        throw new NotFoundException(
          `Không tìm thấy người dùng có id '${userId}' trong hệ thống.`,
        );

      await this.cacheManager.set(
        `user:${userId}:status`,
        'online',
        DEFAULT_STATUS_USER_ONLINE,
      );

      await client.join(userId);

      console.log(`Người dùng có tên '${user.FullName}' đã online.`);
    }
  }

  async handleDisconnect(client: Socket) {
    const userId = client.handshake.query.userId as string;

    if (userId) {
      const { data: user } = await this.anonSupabaseClient
        .from('Users')
        .select('*')
        .eq('ID', userId)
        .maybeSingle<Users>();

      if (!user)
        throw new NotFoundException(
          `Không tìm thấy người dùng có id '${userId}' trong hệ thống.`,
        );

      await this.cacheManager.del(`user:${userId}:status`);

      console.log(`Người dùng có tên '${user.FullName}' đã offline.`);
    }
  }

  public sendNotificationToUserRealTime = (
    user: Users,
    type: NotificationType,
    notification: any,
  ) => {
    const event = handleGetNotificationEventByType(type);

    this.server.to(user.ID).emit(event, notification);

    console.log(
      `Đã gửi thông báo real time đến người dùng có tên '${user.FullName}'`,
    );
  };
}
