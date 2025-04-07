import { IsEmail, IsNotEmpty, IsString, ValidateIf } from 'class-validator';

export class ResetPasswordDto {
  @IsString()
  @IsNotEmpty()
  readonly newPassword!: string;

  @IsEmail({}, { message: 'Email không hợp lệ, vui lòng nhập đúng định dạng.' })
  @IsNotEmpty({ message: 'Email không được để trống.' })
  readonly email!: string;
}
