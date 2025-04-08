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
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly Certifications?: string[];

  @ApiPropertyOptional({
    description: 'Giới thiệu ngắn gọn về bản thân',
    example:
      'Sinh viên năm cuối Đại học Bách Khoa, yêu thích lập trình backend.',
  })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly Bio?: string;

  @ApiPropertyOptional({
    description: 'Cấp độ kinh nghiệm của ứng viên',
    enum: Level,
    example: Level.mid,
  })
  @IsOptional()
  @IsEnum(Level)
  readonly Level?: Level;
}
