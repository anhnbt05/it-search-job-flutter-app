import { IsEmail, IsNotEmpty, IsString, Length } from 'class-validator';

export class VerifyEmailDto {
  @IsEmail({}, { message: 'Email không hợp lệ, vui lòng nhập đúng định dạng.' })
  readonly email!: string;

  @IsString({ message: 'Mã OTP phải ở dạng chuỗi.' })
  @IsNotEmpty({ message: 'Mã OTP không được để trống.' })
  @Length(6, 6, { message: 'Độ dài của mã OTP phải là 6 kí tự.' })
  readonly otp!: string;
}
