import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Req,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { AnyFilesInterceptor } from '@nestjs/platform-express';
import { ApiOperation, ApiResponse } from '@nestjs/swagger';
import { User } from '@supabase/supabase-js';
import { Request } from 'express';
import { FileValidationDecorator, Roles } from 'src/libs/common/decorators';
import { RoleAuthGuard } from 'src/libs/common/guards';
import { RoleEnum } from 'src/libs/common/utils';
import { UpdateUserDto } from 'src/modules/users/dtos';
import { UsersService } from './users.service';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @UseGuards(RoleAuthGuard)
  @Roles(RoleEnum.ADMIN)
  @ApiOperation({ summary: 'Get list of users (Admin only)' })
  @ApiResponse({
    status: 200,
    description: 'List of users retrieved successfully',
    schema: {
      example: [
        {
          ID: '550e8400-e29b-41d4-a716-446655440000',
          Email: 'user@example.com',
          FullName: 'John Doe',
          PhoneNumber: '+84393873630',
          Status: 'active',
          AvatarUrl: 'https://...',
          Role: 'candidate',
          CreatedAt: '2025-03-20T15:15:15Z',
          UpdatedAt: '2025-03-20T15:15:15Z',
          DeletedAt: null,
          IsEmailVerified: false,
        },
        {
          ID: '550e8400-e29b-41d4-a716-446655440000',
          Email: 'user@example.com',
          FullName: 'John Doe',
          PhoneNumber: '+84393873630',
          Status: 'active',
          AvatarUrl: 'https://...',
          Role: 'candidate',
          CreatedAt: '2025-03-20T15:15:15Z',
          UpdatedAt: '2025-03-20T15:15:15Z',
          DeletedAt: null,
          IsEmailVerified: false,
        },
      ],
    },
  })
  @ApiResponse({
    status: 403,
    description: 'Forbidden: Insufficient permissions',
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized: Missing or invalid token',
  })
  async getUsers() {
    return this.usersService.handleGetUsers();
  }

  @Get(':id')
  @UseGuards(RoleAuthGuard)
  @Roles(RoleEnum.ADMIN, RoleEnum.RECRUITER, RoleEnum.CANDIDATE)
  async getUser(
    @Param('id', ParseUUIDPipe) userId: string,
    @Req() request: Request,
  ) {
    const currentUserID = (request.user as User).id;

    return this.usersService.handleGetUser(userId, currentUserID);
  }

  @Patch(':id')
  @UseGuards(RoleAuthGuard)
  @Roles(RoleEnum.ADMIN, RoleEnum.CANDIDATE, RoleEnum.RECRUITER)
  @UseInterceptors(AnyFilesInterceptor())
  async updateUser(
    @Param('id', ParseUUIDPipe) userId: string,
    @Req() request: Request,
    @Body() updateUserDto: UpdateUserDto,
    @FileValidationDecorator() files: Express.Multer.File[],
  ) {
    const currentUserId = (request.user as User).id;

    return this.usersService.handleUpdateUser(
      userId,
      updateUserDto,
      currentUserId,
      files,
    );
  }

  @Delete(':id')
  @UseGuards(RoleAuthGuard)
  @Roles(RoleEnum.ADMIN)
  async deleteUser(@Param('id', ParseUUIDPipe) userId: string) {
    return this.usersService.handleDeleteUser(userId);
  }
}
