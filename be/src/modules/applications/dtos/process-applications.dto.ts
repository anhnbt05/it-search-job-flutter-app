import { Type } from 'class-transformer';
import {
  ArrayNotEmpty,
  IsArray,
  IsNotEmpty,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';

export class RejectedApplications {
  @IsString()
  @IsNotEmpty()
  readonly applicationId!: string;

  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly reason?: string;
}

export class ProcessApplicationsDto {
  @IsOptional()
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly acceptedApplicationIds?: string[];

  @IsOptional()
  @IsArray()
  @ArrayNotEmpty()
  @ValidateNested({ each: true })
  @Type(() => RejectedApplications)
  readonly rejectedApplications?: RejectedApplications[];
}
