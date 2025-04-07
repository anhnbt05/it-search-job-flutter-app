import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Request } from 'express';
import { Observable } from 'rxjs';
import { ROLES_KEY } from 'src/libs/common/decorators';
import { SupabaseUserToken } from 'src/libs/common/utils';

@Injectable()
export class RoleAuthGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(
    context: ExecutionContext,
  ): boolean | Promise<boolean> | Observable<boolean> {
    const requiredRoles = this.reflector.getAllAndOverride<string[]>(
      ROLES_KEY,
      [context.getClass(), context.getHandler()],
    );

    if (!requiredRoles || !requiredRoles.length) return true;

    const request = context.switchToHttp().getRequest<Request>();

    const {
      app_metadata: { role },
    } = request.user as SupabaseUserToken;

    if (!requiredRoles.includes(role))
      throw new ForbiddenException(
        'Bạn không có quyền truy cập vào tài nguyên của đường dẫn này.',
      );

    return true;
  }
}
