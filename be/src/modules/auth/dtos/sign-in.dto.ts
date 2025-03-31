import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsString } from 'class-validator';

export class SignInDto {
  @ApiProperty({
    name: 'email',
    description: 'Email of user.',
    example: 'lengocanhpyne363@gmail.com',
  })
  @IsEmail()
  readonly email!: string;

  @ApiProperty({
    name: 'password',
    description: 'Password of user.',
    example: 'user123',
  })
  @IsString()
  @IsNotEmpty()
  readonly password!: string;
}
