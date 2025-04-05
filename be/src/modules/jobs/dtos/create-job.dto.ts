import {
  ArrayNotEmpty,
  IsArray,
  IsISO8601,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
} from 'class-validator';

export class CreateJobDto {
  @IsString()
  @IsNotEmpty()
  readonly Title!: string;

  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly Description?: string;

  @IsString()
  @IsNotEmpty()
  readonly Address!: string;

  @IsString()
  @IsNotEmpty()
  readonly Salary!: string;

  @IsNumber()
  @IsPositive()
  readonly Vacancies!: number;

  @IsString()
  @IsNotEmpty()
  readonly Type!: string;

  @IsString()
  @IsNotEmpty()
  readonly WorkingTimes!: string;

  @IsNotEmpty()
  @IsISO8601()
  readonly ExpiredDate!: Date;

  @IsString()
  @IsNotEmpty()
  readonly Level!: string;

  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly Categories!: string[];

  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly Descriptions!: string[];

  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly Benefits!: string[];

  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly Requirements!: string[];
}
