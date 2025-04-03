import { Controller, Get, UseGuards } from '@nestjs/common';
import { Roles } from 'src/libs/common/decorators';
import { RoleAuthGuard } from 'src/libs/common/guards';
import { RoleEnum } from 'src/libs/common/utils';
import { UsersService } from './users.service';
import { ApiOperation, ApiResponse } from '@nestjs/swagger';

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
}
