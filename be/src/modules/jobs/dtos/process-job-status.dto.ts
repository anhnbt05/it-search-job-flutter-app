import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  ArrayNotEmpty,
  IsArray,
  IsNotEmpty,
  IsOptional,
  IsString,
} from 'class-validator';

export class ProcessJobStatusDto {
  @ApiPropertyOptional({
    name: 'openJobIds',
    description: 'Danh sách các mã định danh (ID) của công việc cần chấp thuận',
    type: [String],
    example: [
      'c1f917bf-f4ab-434a-a446-d4dfded60687',
      'cf15bd11-16a3-46af-a832-4bd1d3af6230',
    ],
  })
  @IsOptional()
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly openJobIds?: string[];

  @ApiPropertyOptional({
    name: 'rejectedJobIds',
    description: 'Danh sách các mã định danh (ID) của công việc cần từ chối',
    type: [String],
    example: [
      'cf15bd11-16a3-46af-a832-4bd1d3af6230',
      'cf15bd11-16a3-46af-a832-4bd1d3af6230',
    ],
  })
  @IsOptional()
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly rejectedJobIds?: string[];
}
