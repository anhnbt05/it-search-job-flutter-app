import { Level } from '@prisma/client';
import { Expose } from 'class-transformer';
import {
  ArrayNotEmpty,
  IsArray,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
} from 'class-validator';

export class UpdateCandidateDto {
  @Expose()
  @IsOptional()
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly Certifications?: string[];

  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly Bio?: string;

  @IsOptional()
  @IsEnum(Level)
  readonly Level?: Level;
}
