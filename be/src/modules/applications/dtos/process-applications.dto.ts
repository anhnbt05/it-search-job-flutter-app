import { ApiProperty } from '@nestjs/swagger';
import {
  ArrayNotEmpty,
  IsArray,
  IsNotEmpty,
  IsOptional,
  IsString,
} from 'class-validator';

export class ProcessApplicationsDto {
  @ApiProperty({
    description: 'Danh sách các mã định danh (ID) muốn chấp nhận',
    type: [String],
    required: false,
    example: [
      'c1f917bf-f4ab-434a-a446-d4dfded60687',
      'c1f917bf-f4ab-434a-a446-d4dfded60687',
    ],
  })
  @IsOptional()
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly acceptedApplicationIds?: string[];

  @ApiProperty({
    description: 'Danh sách các mã định danh (ID) muốn từ chối',
    type: [String],
    required: false,
    example: [
      'c1f917bf-f4ab-434a-a446-d4dfded60687',
      'c1f917bf-f4ab-434a-a446-d4dfded60687',
    ],
  })
  @IsOptional()
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly rejectedApplicationIds?: string[];
}
