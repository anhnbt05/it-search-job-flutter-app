import { IsEmail, IsNotEmpty, IsString, Length } from 'class-validator';

export class VerifyResetPasswordOtpDto {
  @IsString()
  @IsNotEmpty()
  @Length(6, 6, { message: 'OTP length must be equal to 6 characters.' })
  readonly otp!: string;

  @IsEmail()
  @IsNotEmpty()
  readonly email!: string;
}
