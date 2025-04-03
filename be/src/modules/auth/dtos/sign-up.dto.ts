import { Type } from 'class-transformer';
import {
  IsEmail,
  IsIn,
  IsNotEmpty,
  IsOptional,
  IsPhoneNumber,
  IsString,
  ValidateNested,
} from 'class-validator';
import { CreateCandidateDto, CreateRecruiterDto } from 'src/modules/users/dtos';

export class SignUpDto {
  @IsEmail()
  readonly Email!: string;

  @IsString()
  @IsNotEmpty()
  readonly Password!: string;

  @IsString()
  @IsNotEmpty()
  readonly FullName!: string;

  @IsPhoneNumber()
  @IsNotEmpty()
  readonly PhoneNumber!: string;

  @IsIn(['recruiter', 'candidate'])
  readonly Role!: 'recruiter' | 'candidate';

  @IsOptional()
  @ValidateNested()
  @Type(() => CreateCandidateDto)
  readonly createCandidateDto?: CreateCandidateDto;

  @IsOptional()
  @ValidateNested()
  @Type(() => CreateRecruiterDto)
  readonly createRecruiterDto?: CreateRecruiterDto;
}
