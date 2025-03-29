import { Controller, Get, UseGuards } from '@nestjs/common';
import { Roles } from 'src/libs/common/decorators';
import { RoleAuthGuard } from 'src/libs/common/guards';
import { RoleEnum } from 'src/libs/common/utils';
import { UsersService } from './users.service';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @UseGuards(RoleAuthGuard)
  @Roles(RoleEnum.ADMIN, RoleEnum.RECRUITER)
  async getUsers() {
    return this.usersService.handleGetUsers();
  }
}
