import { ApiPropertyOptional } from '@nestjs/swagger';
import { JobType, Level } from '@prisma/client';
import {
  ArrayNotEmpty,
  IsArray,
  IsEnum,
  IsISO8601,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
} from 'class-validator';

export class UpdateJobDto {
  @ApiPropertyOptional({
    name: 'Title',
    description: 'Tiêu đề mới của công việc (Nếu có)',
    example: 'Thực tập sinh Web Developer',
  })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly Title?: string;

  @ApiPropertyOptional({
    name: 'Description',
    description: 'Mô tả chung của công việc (Nếu có)',
    example:
      'Chúng tôi đang tìm kiếm thực tập sinh đam mê lập trình web để tham gia các dự án thực tế và phát triển kỹ năng chuyên môn',
  })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly Description?: string;

  @ApiPropertyOptional({
    name: 'Address',
    description: 'Địa chỉ làm việc (Nếu có)',
    example: 'Quận Tân Bình, TP. Hồ Chí Minh, Việt Nam',
  })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly Address?: string;

  @ApiPropertyOptional({
    name: 'Salary',
    description: 'Mức lương của công việc (Nếu có)',
    example: 'Hỗ trợ 3,000,000 - 5,000,000 VND/tháng',
  })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly Salary?: string;

  @ApiPropertyOptional({
    name: 'Vacancies',
    description: 'Số lượng ứng viên cần tuyển (Nếu có)',
    example: 5,
    type: Number,
  })
  @IsOptional()
  @IsNumber()
  @IsPositive()
  readonly Vacancies?: number;

  @ApiPropertyOptional({
    name: 'Type',
    description: 'Loại hình công việc (Nếu có)',
    example: JobType.free_lance,
    enum: JobType,
  })
  @IsOptional()
  @IsEnum(JobType)
  readonly Type?: JobType;

  @ApiPropertyOptional({
    name: 'WorkingTimes',
    description: 'Thời gian làm việc của công việc (Nếu có)',
    example: 'Thứ 2 - Thứ 6, 8:30 - 17:30',
  })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly WorkingTimes?: string;

  @ApiPropertyOptional({
    name: 'ExpiredDate',
    description: 'Thời gian hết hạn của công việc (Nếu có)',
    example: '2025-06-15T23:59:59.000Z',
  })
  @IsOptional()
  @IsNotEmpty()
  @IsISO8601()
  readonly ExpiredDate?: string;

  @ApiPropertyOptional({
    name: 'Level',
    description: 'Vị trị mong muốn cho công việc này (Nếu có)',
    enum: Level,
    example: Level.fresher,
  })
  @IsOptional()
  @IsEnum(Level)
  readonly Level?: Level;

  @ApiPropertyOptional({
    name: 'Descriptions',
    description: 'Các yêu cầu của công việc (Nếu có)',
    type: [String],
    example: [
      'Tham gia phát triển giao diện người dùng bằng HTML, CSS, JavaScript.',
      'Hỗ trợ kiểm thử và xử lý lỗi trên hệ thống.',
    ],
  })
  @IsOptional()
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly Descriptions?: string[];

  @ApiPropertyOptional({
    name: 'Benefits',
    description: 'Các lợi ích của công việc (Nếu có)',
    type: [String],
    example: [
      'Có mentor hướng dẫn trong suốt thời gian thực tập.',
      'Hỗ trợ chi phí, có cơ hội trở thành nhân viên chính thức.',
    ],
  })
  @IsOptional()
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly Benefits?: string[];

  @ApiPropertyOptional({
    name: 'Requirements',
    description: 'Các yêu cầu của công việc (Nếu có)',
    type: [String],
    example: [
      'Sinh viên năm 3 trở lên chuyên ngành CNTT hoặc liên quan.',
      'Biết React là một lợi thế.',
    ],
  })
  @IsOptional()
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly Requirements?: string[];
}
