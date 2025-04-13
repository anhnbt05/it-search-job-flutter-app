import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsOptional, IsString } from 'class-validator';

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

  @ApiPropertyOptional({
    name: 'playerId',
    description: 'OneSignal player ID để gửi push notification',
    example: 'abc123-onesignal-id',
  })
  @IsOptional()
  @IsString({ message: 'player ID phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'player ID phải là chuỗi không rỗng.' })
  readonly playerId?: string;

  @ApiPropertyOptional({
    name: 'deviceInfo',
    description: 'Thông tin thiết bị (Ví dụ: model, OS version) của người dùng',
    example: 'iPhone 12, iOS 14.4',
  })
  @IsOptional()
  @IsString({ message: 'Thông tin thiết bị phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Thông tin thiết bị phải là chuỗi không rỗng.' })
  readonly deviceInfo?: string;

  @ApiPropertyOptional({
    name: 'platform',
    description: 'Nền tảng của thiết bị (ví dụ: Android, iOS)',
    example: 'iOS',
  })
  @IsOptional()
  @IsString({ message: 'Nền tảng phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Nền tảng phải là chuỗi không rỗng.' })
  readonly platform?: string;
}
