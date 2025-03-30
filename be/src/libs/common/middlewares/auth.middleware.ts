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

    if (!authHeader) throw new UnauthorizedException('No token provided.');

    const token = authHeader.split(' ')[1];

    const supabase = this.supabaseService.getClient();

    const { data, error } = await supabase.auth.getUser(token);

    if (error) throw new UnauthorizedException('Invalid token.');

    req['user'] = data.user;

    next();
  }
}
