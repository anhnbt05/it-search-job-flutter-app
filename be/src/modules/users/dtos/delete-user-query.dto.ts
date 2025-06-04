import { ApiProperty } from '@nestjs/swagger';
import { IsEnum } from 'class-validator';
import { RoleEnum } from 'src/libs/common/utils';

export class DeleteUserQueryDto {
  @ApiProperty({
    name: 'role',
    description: 'Vai trò cần muốn xoá.',
    example: RoleEnum.CANDIDATE,
    enum: RoleEnum,
  })
  @IsEnum(RoleEnum)
  readonly role!: RoleEnum;
}
