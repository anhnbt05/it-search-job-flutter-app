import { IsEmail, IsNotEmpty, IsString, MinLength } from 'class-validator';

export class ResetPasswordDto {
  @IsString({ message: 'Mật khẩu mới phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Mật khẩu mới không được để trống.' })
  @MinLength(8, {
    message: 'Độ dài của mật khẩu mới phải có độ dài ít nhất là 8 kí tự.',
  })
  readonly newPassword!: string;

  @IsEmail({}, { message: 'Email không hợp lệ, vui lòng nhập đúng định dạng.' })
  readonly email!: string;
}
