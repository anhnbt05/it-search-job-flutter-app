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
  @IsEmail({}, { message: 'Email không hợp lệ, vui lòng nhập đúng định dạng.' })
  readonly Email!: string;

  @IsString({ message: 'Mật khẩu đăng nhập phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Mật khẩu đăng nhập không được để trống.' })
  readonly Password!: string;

  @IsString({ message: 'Họ và tên phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Họ và tên không được để trống.' })
  readonly FullName!: string;

  @IsPhoneNumber('VN', {
    message: 'Số điện thoại phải ở Việt Nam và là hợp lệ (ex: +84...).',
  })
  readonly PhoneNumber!: string;

  @IsIn(['recruiter', 'candidate'], {
    message: 'Chỉ có thể chọn vai trò là nhà tuyển dụng hoặc ứng viên.',
  })
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
