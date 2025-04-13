import {
  ArrayNotEmpty,
  IsArray,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
} from 'class-validator';
import { LevelEnum } from 'src/libs/common/utils';

export class CreateCandidateDto {
  @IsOptional()
  @IsString({ message: 'Tiểu sử phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Tiểu sử không được để trống.' })
  readonly Bio?: string;

  @IsEnum(LevelEnum, {
    message: 'Vui lòng chọn trình độ hợp lệ trong danh sách đã cho.',
  })
  readonly Level!: LevelEnum;

  @IsOptional()
  @IsArray({ message: 'Các chứng chỉ gửi đi (nếu có) phải ở dạng mảng.' })
  @ArrayNotEmpty({
    message: 'Các chứng chỉ gửi đi (nếu có) phải là mảng không rỗng.',
  })
  @IsString({ each: true, message: 'Tên của chứng chỉ phải là dạng chuỗi.' })
  @IsNotEmpty({ each: true, message: 'Tên của chứng chỉ không được để trống.' })
  readonly Certifications?: string[];
}
