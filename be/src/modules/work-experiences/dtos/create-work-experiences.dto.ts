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

export class CreateWorkExperiencesDto {
  @IsString({ message: 'Tên công ty phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Tên công ty không được là chuỗi rỗng.' })
  readonly CompanyName!: string;

  @IsString({ message: 'Tên vị trí phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Tên vị trí phải là chuỗi không rỗng.' })
  readonly Position!: string;

  @IsISO8601(
    {},
    {
      message:
        'Ngày bắt đầu kinh nghiệm làm việc phải là một chuỗi ISO8601 hợp lệ.',
    },
  )
  readonly StartDate!: string;

  @IsOptional()
  @IsISO8601(
    {},
    {
      message:
        'Ngày kết thúc kinh nghiệm làm việc phải là một chuỗi ISO8601 hợp lệ.',
    },
  )
  readonly EndDate?: string;

  @IsArray({
    message:
      'Danh sách các đảm nhiệm của bạn trong kinh nghiệm làm việc phải là dạng mảng.',
  })
  @ArrayNotEmpty({
    message:
      'Danh sách các đảm nhiệm của bạn trong king nghiệm làm việc không được là mảng rỗng.',
  })
  @IsString({ each: true, message: 'Mô tả đảm nhiệm phải là dạng chuỗi.' })
  @IsNotEmpty({
    each: true,
    message: 'Mô tả đảm nhiệm phải là chuỗi không rỗng.',
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
  readonly Descriptions!: string[];

  @IsString({
    message: 'Địa điểm của kinh nghiệm làm việc phải có dạng chuỗi.',
  })
  @IsNotEmpty({
    message: 'Địa điểm của kinh nghiệm làm việc phải là chuỗi không rỗng.',
  })
  readonly Location!: string;

  @IsEnum(JobType, {
    message: 'Hình thức làm việc phải nằm trong danh sách đã được liệt kê.',
  })
  readonly JobType!: JobType;
}
