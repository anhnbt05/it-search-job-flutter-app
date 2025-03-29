import { Type } from 'class-transformer';
import {
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
  ValidateNested,
} from 'class-validator';
import { CreateCompanyDto } from 'src/modules/users/dtos';

export class CreateRecruiterDto {
  @IsString()
  @IsNotEmpty()
  readonly Position!: string;

  @IsOptional()
  @IsUUID()
  @IsNotEmpty()
  readonly companyID!: string;

  @IsOptional()
  @ValidateNested()
  @Type(() => CreateCompanyDto)
  @IsNotEmpty()
  readonly createCompanyDto?: CreateCompanyDto;
}
