import { ApiProperty } from '@nestjs/swagger';
import { IsEnum } from 'class-validator';
import { RoleEnum } from 'src/libs/common/utils';

export class UnlockUserQueryDto {
  @ApiProperty({
    name: 'role',
    description: 'Vai trò của người dùng cần mở khoá tài khoản',
    example: 'candidate',
  })
  @IsEnum(RoleEnum, {
    message: `Vai trò của người dùng phải là nhà tuyển dụng hoặc ứng viên.`,
  })
  readonly role!: RoleEnum;
}
