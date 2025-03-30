import { Type } from 'class-transformer';
import {
  IsNotEmpty,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { CreateCompanyLocationDto } from 'src/modules/users/dtos';

export class CreateCompanyDto {
  @IsString()
  @IsNotEmpty()
  readonly Name!: string;

  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly WebsiteUrl?: string;

  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly Description?: string;

  @ValidateNested()
  @Type(() => CreateCompanyLocationDto)
  @IsNotEmpty()
  readonly createCompanyLocationDto!: CreateCompanyLocationDto;
}
