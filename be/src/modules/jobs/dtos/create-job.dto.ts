import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { JobType, Level } from '@prisma/client';
import {
  ArrayNotEmpty,
  IsArray,
  IsISO8601,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
} from 'class-validator';

export class CreateJobDto {
  @ApiProperty({
    name: 'Title',
    description: 'Tiêu đề (tên) của công việc',
    example: 'Thực tập sinh Web Developer',
  })
  @IsString()
  @IsNotEmpty()
  readonly Title!: string;

  @ApiPropertyOptional({
    name: 'Description',
    description: 'Mô tả chung cho công việc',
    example:
      'Chúng tôi đang tìm kiếm thực tập sinh đam mê lập trình web để tham gia các dự án thực tế và phát triển kỹ năng chuyên môn',
  })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly Description?: string;

  @ApiProperty({
    name: 'Address',
    description: 'Địa chỉ làm việc của công việc.',
    example: 'Quận Bình Thạnh, TP. Hồ Chí Minh, Việt Nam',
  })
  @IsString()
  @IsNotEmpty()
  readonly Address!: string;

  @ApiProperty({
    name: 'Salary',
    description: 'Mức lương của công việc.',
    example: 'Hỗ trợ 3,000,000 - 5,000,000 VND/tháng',
  })
  @IsString()
  @IsNotEmpty()
  readonly Salary!: string;

  @ApiProperty({
    type: Number,
    name: 'Vancancies',
    description: 'Số lượng ứng viên cần tuyển của công việc.',
    example: 3,
  })
  @IsNumber()
  @IsPositive()
  readonly Vacancies!: number;

  @ApiProperty({
    enum: [JobType],
    description: 'Hình thức làm việc',
    example: JobType.free_lance,
  })
  @IsString()
  @IsNotEmpty()
  readonly Type!: string;

  @ApiProperty({
    name: 'WorkingTimes',
    description: 'Thời gian làm việc của công việc.',
    example: 'Thứ 2 - Thứ 6, 8:30 - 17:30',
  })
  @IsString()
  @IsNotEmpty()
  readonly WorkingTimes!: string;

  @ApiProperty({
    name: 'ExpiredDate',
    description: 'Thời gian hết hạn của công việc',
    example: '2025-06-15T23:59:59.000Z',
  })
  @IsNotEmpty()
  @IsISO8601()
  readonly ExpiredDate!: Date;

  @ApiProperty({
    name: 'Level',
    enum: [Level],
    description: 'Vị trí mong muốn cho công việc này',
    example: Level.fresher,
  })
  @IsString()
  @IsNotEmpty()
  readonly Level!: Level;

  @ApiProperty({
    name: 'Categories',
    description: 'Danh sách các danh mục của công việc',
    type: [String],
    example: ['Full Stack', 'Back End', 'Mobile'],
  })
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly Categories!: string[];

  @ApiProperty({
    name: 'Descriptions',
    description: 'Danh sách các mô tả (Job Description) của công việc',
    type: [String],
    example: [
      'Tham gia phát triển giao diện người dùng bằng HTML, CSS, JavaScript.',
      'Học hỏi và áp dụng React vào các dự án nội bộ.',
      'Hỗ trợ kiểm thử và xử lý lỗi trên hệ thống.',
    ],
  })
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly Descriptions!: string[];

  @ApiProperty({
    name: 'Benefits',
    description: 'Danh sách các lợi ích mà công việc mang lại.',
    type: [String],
    example: [
      'Có mentor hướng dẫn trong suốt thời gian thực tập.',
      'Hỗ trợ chi phí, có cơ hội trở thành nhân viên chính thức.',
      'Môi trường làm việc thân thiện, linh hoạt giờ giấc.',
    ],
  })
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly Benefits!: string[];

  @ApiProperty({
    name: 'Requirements',
    description: 'Danh sách các yêu cầu của công việc.',
    type: [String],
    example: [
      'Sinh viên năm 3 trở lên chuyên ngành CNTT hoặc liên quan.',
      'Biết cơ bản HTML, CSS, JavaScript.',
      'Biết React là một lợi thế.',
      'Chăm chỉ, ham học hỏi, có tinh thần trách nhiệm.',
    ],
  })
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly Requirements!: string[];
}
