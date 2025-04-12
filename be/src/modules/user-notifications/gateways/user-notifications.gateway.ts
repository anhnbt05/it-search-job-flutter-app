import { NotFoundException } from '@nestjs/common';
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
import { handleGetNotificationEventByType } from 'src/libs/common/utils';

@WebSocketGateway({
  namespace: '/notifications',
  cors: {
    origin: '*',
  },
})
export class UserNotificationsGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  private readonly server: Server;

  constructor(
    @InjectSupabaseClient('anonClient')
    private readonly anonSupabaseClient: SupabaseClient,
  ) {}

  private connectedUsers: Map<string, string> = new Map();

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

      this.connectedUsers.set(userId, client.id);

      console.log(`Người dùng có tên '${user.FullName}' đã online.`);
    }
  }

  async handleDisconnect(client: Socket) {
    const userId = [...this.connectedUsers.entries()].find(
      ([, socketId]) => socketId === client.id,
    )?.[0];

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

      this.connectedUsers.delete(userId);

      console.log(`Người dùng có tên '${user.FullName}' đã offline.`);
    }
  }

  public sendNotificationToUser = (
    user: Users,
    type: NotificationType,
    notification: UserNotifications,
  ) => {
    const socketId = this.connectedUsers.get(user.ID);

    if (socketId) {
      const event = handleGetNotificationEventByType(type);

      this.server.to(socketId).emit(event, notification);

      console.log(
        `Đã gửi thông báo real time đến người dùng có tên '${user.FullName}'`,
      );
    } else {
      console.log(`Người dùng '${user.FullName}' đã ofline.`);
    }
  };
}
