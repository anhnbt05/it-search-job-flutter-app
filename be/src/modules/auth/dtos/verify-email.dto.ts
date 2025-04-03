import { IsEmail, IsNotEmpty, IsString, Length } from 'class-validator';

export class VerifyEmailDto {
  @IsEmail()
  readonly email!: string;

  @IsString()
  @IsNotEmpty()
  @Length(6, 6, { message: 'OTP length must be equal 6 characters.' })
  readonly otp!: string;
}
