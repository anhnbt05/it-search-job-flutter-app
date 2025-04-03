import { IsEmail, IsNotEmpty, IsString } from 'class-validator';

export class UpdatePasswordDto {
  @IsString()
  @IsNotEmpty()
  readonly newPassword!: string;

  @IsEmail()
  @IsNotEmpty()
  readonly email!: string;
}
