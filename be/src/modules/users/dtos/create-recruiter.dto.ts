import { Type } from 'class-transformer';
import {
  IsNotEmpty,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import {
  CreateCompanyDto,
  CreateExistingCompanyDto,
} from 'src/modules/users/dtos';

export class CreateRecruiterDto {
  @IsString()
  @IsNotEmpty()
  readonly Position!: string;

  @IsOptional()
  @ValidateNested()
  @Type(() => CreateExistingCompanyDto)
  readonly createExistingCompanyDto?: CreateExistingCompanyDto;

  @IsOptional()
  @ValidateNested()
  @Type(() => CreateCompanyDto)
  @IsNotEmpty()
  readonly createCompanyDto?: CreateCompanyDto;
}
