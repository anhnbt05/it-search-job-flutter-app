import { IsEmail } from 'class-validator';

export class ForgetPasswordDto {
  @IsEmail({}, { message: 'Email không hợp lệ, vui lòng nhập đúng định dạng.' })
  readonly email!: string;
}
