import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsString } from 'class-validator';

export class SignInDto {
  @ApiProperty({
    name: 'email',
    description: 'Email of user.',
    example: 'lengocanhpyne363@gmail.com',
  })
  @IsEmail({}, { message: 'Email không hợp lệ, vui lòng nhập đúng định dạng.' })
  readonly email!: string;

  @ApiProperty({
    name: 'password',
    description: 'Password of user.',
    example: 'user123',
  })
  @IsString({ message: 'Mật khẩu đăng nhập phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Mật khẩu đăng nhập không được để trống.' })
  readonly password!: string;
}
