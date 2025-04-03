import {
  ArrayNotEmpty,
  IsArray,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
} from 'class-validator';
import { LevelEnum } from 'src/libs/common/utils';

export class CreateCandidateDto {
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly Bio?: string;

  @IsEnum(LevelEnum)
  @IsNotEmpty()
  readonly Level!: LevelEnum;

  @IsOptional()
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly Certifications?: string[];
}
