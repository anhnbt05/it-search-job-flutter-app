import { JobType, Level } from '@prisma/client';
import {
  ArrayNotEmpty,
  IsArray,
  IsEnum,
  IsISO8601,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
} from 'class-validator';

export class UpdateJobDto {
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly Title?: string;

  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly Description?: string;

  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly Address?: string;

  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly Salary?: string;

  @IsOptional()
  @IsNumber()
  @IsPositive()
  readonly Vacancies?: number;

  @IsOptional()
  @IsEnum(JobType)
  readonly Type?: JobType;

  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly WorkingTimes?: string;

  @IsOptional()
  @IsNotEmpty()
  @IsISO8601()
  readonly ExpiredDate?: Date;

  @IsOptional()
  @IsEnum(Level)
  readonly Level?: Level;

  @IsOptional()
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly Descriptions?: string[];

  @IsOptional()
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly Benefits?: string[];

  @IsOptional()
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly Requirements?: string[];
}
