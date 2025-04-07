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
  @IsString()
  @IsNotEmpty()
  readonly CompanyName!: string;

  @IsString()
  @IsNotEmpty()
  readonly Position!: string;

  @IsISO8601()
  readonly StartDate!: string;

  @IsOptional()
  @IsISO8601()
  readonly EndDate?: string;

  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
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

  @IsString()
  @IsNotEmpty()
  readonly Location!: string;

  @IsEnum(JobType)
  readonly JobType!: JobType;
}
