import { BadRequestException } from '@nestjs/common';
import { JobType } from '@prisma/client';
import { Transform } from 'class-transformer';
import {
  ArrayNotEmpty,
  IsArray,
  IsEnum,
  IsISO8601,
  IsNotEmpty,
  IsOptional,
  IsString,
} from 'class-validator';

export class UpdateWorkExperiencesDto {
  @IsOptional()
  @IsString({
    message: 'Tên công ty phải có dạng chuỗi.',
  })
  @IsNotEmpty({
    message: 'Tên công ty phải là chuỗi không rỗng.',
  })
  readonly CompanyName?: string;

  @IsOptional()
  @IsString({
    message: 'Vị trí đảm nhiệm phải ở dạng chuỗi.',
  })
  @IsNotEmpty({ message: 'Vị trí đảm nhiệm phải là chuỗi không rỗng.' })
  readonly Position?: string;

  @IsOptional()
  @IsISO8601(
    {},
    {
      message: 'Ngày bắt đầu vị trí kinh nghiệm làm việc phải có dạng ISO8601.',
    },
  )
  readonly StartDate?: string;

  @IsOptional()
  @IsISO8601(
    {},
    {
      message:
        'Ngày kết thúc vị trí kinh nghiệm làm việc phải có dạng ISO8601.',
    },
  )
  readonly EndDate?: string | null;

  @IsOptional()
  @IsArray({
    message: 'Mô tả các trách nhiệm phải có dạng mảng.',
  })
  @ArrayNotEmpty({
    message: 'Mô tả các trách nhiệm phải là mảng không rỗng.',
  })
  @IsString({ each: true, message: 'Trách nhiệm phải là dạng chuỗi.' })
  @IsNotEmpty({
    each: true,
    message: 'Trách nhiệm phải là dạng chuỗi không rỗng.',
  })
  @Transform(({ value }) => {
    if (typeof value === 'string') {
      try {
        const parsed = JSON.parse(value);
        if (Array.isArray(parsed)) return parsed;
      } catch {
        throw new BadRequestException(
          'Descriptions phải là một mảng hợp lệ (JSON array).',
        );
      }
    }
    return value;
  })
  readonly Descriptions?: string[];

  @IsOptional()
  @IsString({
    message: 'Địa điểm làm việc phải là dạng chuỗi.',
  })
  @IsNotEmpty({
    message: 'Địa điểm làm việc phải là dạng chuỗi không rỗng.',
  })
  readonly Location?: string;

  @IsOptional()
  @IsEnum(JobType, {
    message: 'Hình thức làm việc phải nằm trong danh sách được liệt kê.',
  })
  readonly JobType?: JobType;
}
