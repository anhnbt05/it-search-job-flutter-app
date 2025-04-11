import { BadRequestException } from '@nestjs/common';
import { ApiPropertyOptional } from '@nestjs/swagger';
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
  @ApiPropertyOptional({
    description: 'Họ và tên mới đầy đủ của người dùng.',
    example: 'Nguyễn Văn A',
  })
  @IsOptional()
  @IsString({ message: 'Họ và tên phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Họ và tên không được là chuỗi rỗng.' })
  readonly FullName?: string;

  @ApiPropertyOptional({
    description: 'Số điện thoại mới của người dùng',
    example: '+84901234567',
  })
  @IsOptional()
  @IsPhoneNumber('VN', {
    message: 'Số điện thoại phải là ở Việt Nam và là hợp lệ.',
  })
  readonly PhoneNumber?: string;

  @ApiPropertyOptional({
    description: 'Thông tin cập nhật dành cho ứng viên',
    type: () => UpdateCandidateDto,
    example: {
      Certifications: ['Chứng chỉ tiếng Anh', 'Chứng chỉ lập trình'],
      Bio: 'Sinh viên năm cuối ngành CNTT',
      Level: 'fresher',
    },
  })
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

  @ApiPropertyOptional({
    description: 'Thông tin cập nhật dành cho nhà tuyển dụng',
    type: () => UpdateRecruiterDto,
    example: {
      Postion: 'Trưởng phòng nhân sự',
    },
  })
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
