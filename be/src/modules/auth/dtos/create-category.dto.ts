import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class CreateCategoryDto {
  @ApiProperty({
    name: 'CategoryName',
    description: 'Tên của danh mục',
    example: 'Web Development',
  })
  @IsString()
  @IsNotEmpty()
  readonly CategoryName!: string;
}
