import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class UpdateCompanyDto {
  @ApiPropertyOptional({
    name: 'Name',
    description: 'Tên mới của công ty',
    example: 'Công ty Công nghệ ABC',
  })
  @IsOptional()
  @IsString({ message: 'Tên của công ty phải ở dạng chuỗi.' })
  @IsNotEmpty({ message: 'Tên của công ty không được để trống.' })
  readonly Name?: string;

  @ApiPropertyOptional({
    name: 'WebsiteUrl',
    description: 'Địa chỉ website mới của công ty',
    example: 'https://abc.com',
  })
  @IsOptional()
  @IsString({ message: 'Địa chỉ của website công ty phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Địa chỉ của website công ty không được để trống.' })
  readonly WebsiteUrl?: string;

  @ApiPropertyOptional({
    name: 'Description',
    description: 'Mô tả mới về công ty (bio)',
    example: 'Công ty của chúng tôi chuyên về phần mềm...',
  })
  @IsOptional()
  @IsString({ message: 'Mô tả cho công ty phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Mô tả cho công ty không được để trống.' })
  readonly Description?: string;
}
