import { IsEmail, IsNotEmpty, IsString, Length } from 'class-validator';

export class VerifyResetPasswordOtpDto {
  @IsString({ message: 'Mã OTP phải ở dạng chuỗi.' })
  @IsNotEmpty({ message: 'Mã OTP không được để trống.' })
  @Length(6, 6, { message: 'Mã OTP phải có độ dài là 6 kí tự.' })
  readonly otp!: string;

  @IsEmail({}, { message: 'Email không hợp lệ, vui lòng nhập đúng định dạng.' })
  readonly email!: string;
}
