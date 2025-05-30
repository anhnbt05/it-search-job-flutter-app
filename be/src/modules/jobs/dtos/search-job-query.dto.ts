import { ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  ArrayNotEmpty,
  IsArray,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
} from 'class-validator';

export class SearchJobQueryDto {
  @ApiPropertyOptional({
    name: 'locationId',
    description: 'Mã định danh của tỉnh, thành phố cần tìm kiếm.',
    example: '123f7d52-dfc9-480c-9352-6b57a708f95f',
  })
  @IsOptional()
  @IsUUID('4', { message: 'Tỉnh, thành phố không được để trống.' })
  readonly locationId?: string;

  @ApiPropertyOptional({
    name: 'categoryNames',
    description: 'Mảng các tên danh mục cần tìm kiếm.',
    example: ['Back End', 'Front End'],
    isArray: true,
    type: String,
  })
  @IsOptional()
  @Transform(({ value }) =>
    typeof value === 'string'
      ? value
          .split(',')
          .map((v) => v.trim())
          .filter((v) => v !== '')
      : value,
  )
  @IsArray({ message: 'Danh sách danh mục phải là một mảng.' })
  @ArrayNotEmpty({ message: 'Danh sách danh mục không được để trống.' })
  @IsString({ each: true, message: 'Mỗi danh mục phải là một chuỗi.' })
  @IsNotEmpty({ each: true, message: 'Không được có danh mục rỗng.' })
  readonly categoryNames?: string[];
}
