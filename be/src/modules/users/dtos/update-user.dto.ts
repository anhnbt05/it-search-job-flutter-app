import { BadRequestException } from '@nestjs/common';
import { plainToClass, Transform, Type } from 'class-transformer';
import {
  IsNotEmpty,
  IsOptional,
  IsPhoneNumber,
  IsString,
  ValidateNested,
} from 'class-validator';
import { UpdateCandidateDto, UpdateRecruiterDto } from 'src/modules/users/dtos';

export class UpdateUserDto {
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly FullName?: string;

  @IsOptional()
  @IsPhoneNumber()
  readonly PhoneNumber?: string;

  @IsOptional()
  @ValidateNested()
  @Type(() => UpdateCandidateDto)
  @Transform(({ value }) => {
    if (typeof value === 'string') {
      try {
        return plainToClass(UpdateCandidateDto, JSON.parse(value));
      } catch {
        throw new BadRequestException(
          'updateCandidateDto phải là chuỗi JSON hợp lệ.',
        );
      }
    }
    return value;
  })
  readonly updateCandidateDto?: UpdateCandidateDto;

  @IsOptional()
  @ValidateNested()
  @Type(() => UpdateRecruiterDto)
  @Transform(({ value }) => {
    if (typeof value === 'string') {
      try {
        return plainToClass(UpdateRecruiterDto, JSON.parse(value));
      } catch (err) {
        throw new BadRequestException(
          'updateRecruiterDto phải là chuỗi JSON hợp lệ.',
        );
      }
    }
    return value;
  })
  readonly updateRecruiterDto?: UpdateRecruiterDto;
}
