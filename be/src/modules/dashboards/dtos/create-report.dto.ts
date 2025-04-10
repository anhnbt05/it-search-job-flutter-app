import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { IsRealDate } from 'src/libs/common/decorators';
import { ReportType } from 'src/libs/common/utils';

export class CreateReportDto {
  @ApiPropertyOptional({
    name: 'StartDate',
    description:
      'Ngày bắt đầu lọc dữ liệu (phải đúng định dạng YYYY-MM-DD và phải là một ngày hợp lệ.)',
    example: '2025-04-08',
  })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  @IsRealDate({
    message:
      'Ngày bắt đầu phải đúng định dạng YYYY-MM-DD và là một ngày hợp lệ.',
  })
  readonly StartDate?: string;

  @ApiPropertyOptional({
    name: 'EndDate',
    description:
      'Ngày kết thúc lọc dữ liệu (phải đúng định dạng YYYY-MM-DD và phải là một ngày hợp lệ.)',
    example: '2025-04-15',
  })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  @IsRealDate({
    message:
      'Ngày kết thúc phải đúng định dạng YYYY-MM-DD và là một ngày hợp lệ.',
  })
  readonly EndDate?: string;

  @ApiProperty({
    enum: ReportType,
    description: 'Loại báo cáo (pdf hoặc xlsx)',
    example: ReportType.EXCEL,
  })
  @IsEnum(ReportType)
  readonly Type!: ReportType;
}
