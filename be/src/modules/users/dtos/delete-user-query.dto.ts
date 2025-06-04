import { IsEnum } from 'class-validator';
import { RoleEnum } from 'src/libs/common/utils';

export class DeleteUserQueryDto {
  @IsEnum(RoleEnum)
  readonly role!: RoleEnum;
}
