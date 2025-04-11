import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class CreateCategoryDto {
  @ApiProperty({
    name: 'CategoryName',
    description: 'Tên của danh mục',
    example: 'Web Development',
  })
  @IsString({ message: 'Tên của danh mục phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Tên của danh mục không được để trống.' })
  readonly CategoryName!: string;
}
