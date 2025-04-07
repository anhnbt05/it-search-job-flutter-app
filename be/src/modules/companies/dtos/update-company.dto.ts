import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class UpdateCompanyDto {
  @ApiPropertyOptional({
    name: 'Name',
    description: 'Tên mới của công ty',
    example: 'Công ty Công nghệ ABC',
  })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly Name?: string;

  @ApiPropertyOptional({
    name: 'WebsiteUrl',
    description: 'Địa chỉ website mới của công ty',
    example: 'https://abc.com',
  })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly WebsiteUrl?: string;

  @ApiPropertyOptional({
    name: 'Description',
    description: 'Mô tả mới về công ty (bio)',
    example: 'Công ty của chúng tôi chuyên về phần mềm...',
  })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly Description?: string;
}
