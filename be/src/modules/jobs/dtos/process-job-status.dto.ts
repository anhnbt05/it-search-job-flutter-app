import { Type } from 'class-transformer';
import {
  ArrayNotEmpty,
  IsArray,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
  ValidateNested,
} from 'class-validator';

export class RejectedJobStatusDto {
  @IsString()
  @IsUUID()
  @IsNotEmpty()
  readonly jobId!: string;

  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly reason?: string;
}

export class ProcessJobStatusDto {
  @IsOptional()
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly openJobIds?: string[];

  @IsOptional()
  @IsArray()
  @ArrayNotEmpty()
  @ValidateNested({ each: true })
  @Type(() => RejectedJobStatusDto)
  readonly rejectedJobs?: RejectedJobStatusDto[];
}
