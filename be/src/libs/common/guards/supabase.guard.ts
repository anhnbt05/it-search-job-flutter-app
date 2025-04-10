import { Injectable, UnauthorizedException } from '@nestjs/common';
import { SupabaseClient } from '@supabase/supabase-js';
import { Request } from 'express';
import {
  BaseSupabaseAuthGuard,
  InjectSupabaseClient,
} from 'nestjs-supabase-js';

@Injectable()
export class SupabaseGuard extends BaseSupabaseAuthGuard {
  constructor(
    @InjectSupabaseClient('anonClient')
    private readonly anonSupabaseClient: SupabaseClient,
  ) {
    super(anonSupabaseClient);
  }

  protected async extractTokenFromRequest(
    request: Request,
  ): Promise<string | undefined> {
    const authHeader = request.headers['authorization'];

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException(
        'Bạn cần cung cấp token để truy cập vào tài nguyên của đường dẫn này.',
      );
    }

    const token = authHeader.replace('Bearer ', '');

    const { error } = await this.anonSupabaseClient.auth.getUser(token);

    if (error)
      throw new UnauthorizedException(
        'Token không hợp lệ hoặc đã hết hạn. Vui lòng cung cấp token hợp lệ.',
      );

    return token;
  }
}
