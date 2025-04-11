import { ApiPropertyOptional } from '@nestjs/swagger';
import { Level } from '@prisma/client';
import { Expose } from 'class-transformer';
import {
  ArrayNotEmpty,
  IsArray,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
} from 'class-validator';

export class UpdateCandidateDto {
  @ApiPropertyOptional({
    description: 'Danh sách các chứng chỉ mà ứng viên có',
    example: ['IELTS 7.5', 'Google Developer Certificate'],
    type: [String],
  })
  @Expose()
  @IsOptional()
  @IsArray({
    message: 'Danh sách các chứng chỉ của ứng viên phải ở dạng mảng.',
  })
  @ArrayNotEmpty({
    message: 'Danh sách các chứng chỉ của ứng viên phải là mảng không rỗng.',
  })
  @IsString({ each: true, message: 'Tên của chứng chỉ phải là dạng chuỗi.' })
  @IsNotEmpty({
    each: true,
    message: 'Tên của chứng chỉ không đuọc là chuỗi rỗng.',
  })
  readonly Certifications?: string[];

  @ApiPropertyOptional({
    description: 'Giới thiệu ngắn gọn về bản thân',
    example:
      'Sinh viên năm cuối Đại học Bách Khoa, yêu thích lập trình backend.',
  })
  @IsOptional()
  @IsString({ message: 'Tiểu sử của bản thân phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Tiểu sử của bản thân không được là chuỗi rỗng.' })
  readonly Bio?: string;

  @ApiPropertyOptional({
    description: 'Cấp độ kinh nghiệm của ứng viên',
    enum: Level,
    example: Level.mid,
  })
  @IsOptional()
  @IsEnum(Level, {
    message:
      'Cấp độ kinh nghiệm của ứng viên phải nằm trong danh sách liệt kê.',
  })
  readonly Level?: Level;
}
