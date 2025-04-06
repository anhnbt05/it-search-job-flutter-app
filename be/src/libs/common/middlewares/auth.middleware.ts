import {
  Injectable,
  NestMiddleware,
  UnauthorizedException,
} from '@nestjs/common';
import { NextFunction, Request, Response } from 'express';
import { SupabaseService } from 'src/modules/supabase/supabase.service';

@Injectable()
export class AuthMiddleware implements NestMiddleware {
  constructor(private readonly supabaseService: SupabaseService) {}

  async use(req: Request, res: Response, next: NextFunction) {
    const authHeader = req.headers.authorization;

    if (!authHeader)
      throw new UnauthorizedException(
        'Bạn cần cung cấp access token để truy cập vào tài nguyên của đường dẫn này.',
      );

    const token = authHeader.split(' ')[1];

    const supabase = this.supabaseService.getClient();

    const { data, error } = await supabase.auth.getUser(token);

    if (error)
      throw new UnauthorizedException(
        'Bạn đã cung cấp acess token không hợp lệ hoặc đã hết hạn. Vui lòng thử lại.',
      );

    req['user'] = data.user;

    next();
  }
}
