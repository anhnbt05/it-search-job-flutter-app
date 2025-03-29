import { IsEmail, IsNotEmpty, IsString } from 'class-validator';

export class ResetPasswordDto {
  @IsString()
  @IsNotEmpty()
  readonly newPassword!: string;

  @IsEmail()
  @IsNotEmpty()
  readonly email!: string;
}
