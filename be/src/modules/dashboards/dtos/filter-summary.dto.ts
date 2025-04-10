import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { IsRealDate } from 'src/libs/common/decorators';

export class FilterSummaryDto {
  @ApiPropertyOptional({
    name: 'StartDate',
    description:
      'Ngày bắt đầu muốn lọc, theo format: YYYY-MM-DD và phải là ngày hợp lệ.',
    example: '2025-01-10',
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
      'Ngày kết thúc lọc, theo format: YYYY-MM-DD và phải là ngày hợp lệ.',
    example: '2025-01-15',
  })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  @IsRealDate({
    message:
      'Ngày kết thúc phải đúng định dạng YYYY-MM-DD và là một ngày hợp lệ.',
  })
  readonly EndDate?: string;
}
