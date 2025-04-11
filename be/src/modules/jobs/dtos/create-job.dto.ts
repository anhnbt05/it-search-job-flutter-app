import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
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

export class CreateJobDto {
  @ApiProperty({
    name: 'Title',
    description: 'Tiêu đề (tên) của công việc',
    example: 'Thực tập sinh Web Developer',
  })
  @IsString({ message: 'Tiêu đề của công việc phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Tiêu đề của công việc không được để trống.' })
  readonly Title!: string;

  @ApiPropertyOptional({
    name: 'Description',
    description: 'Mô tả chung cho công việc',
    example:
      'Chúng tôi đang tìm kiếm thực tập sinh đam mê lập trình web để tham gia các dự án thực tế và phát triển kỹ năng chuyên môn',
  })
  @IsOptional()
  @IsString({ message: 'Mô tả cho công việc phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Mô tả cho công việc không được để trống.' })
  readonly Description?: string;

  @ApiProperty({
    name: 'Address',
    description: 'Địa chỉ làm việc của công việc.',
    example: 'Quận Bình Thạnh, TP. Hồ Chí Minh, Việt Nam',
  })
  @IsString({ message: 'Địa chỉ làm việc của công việc phải là dạng chuỗi.' })
  @IsNotEmpty({
    message: 'Địa chỉ làm việc của công việc không được để trống.',
  })
  readonly Address!: string;

  @ApiProperty({
    name: 'Salary',
    description: 'Mức lương của công việc.',
    example: 'Hỗ trợ 3,000,000 - 5,000,000 VND/tháng',
  })
  @IsString({ message: 'Mức lương của công việc phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Mức lương của công việc không được để trống.' })
  readonly Salary!: string;

  @ApiProperty({
    type: Number,
    name: 'Vancancies',
    description: 'Số lượng ứng viên cần tuyển của công việc.',
    example: 3,
  })
  @IsNumber({}, { message: 'Số lượng ứng viên cần tuyển phải là một con số.' })
  @IsPositive({
    message: 'Số lượng ứng viên cần tuyển phải là một con số dương.',
  })
  readonly Vacancies!: number;

  @ApiProperty({
    enum: [JobType],
    description: 'Hình thức làm việc',
    example: JobType.free_lance,
  })
  @IsEnum(JobType, {
    message:
      'Hình thức làm việc của công việc không phù hợp với danh sách đã cho.',
  })
  readonly Type!: JobType;

  @ApiProperty({
    name: 'WorkingTimes',
    description: 'Thời gian làm việc của công việc.',
    example: 'Thứ 2 - Thứ 6, 8:30 - 17:30',
  })
  @IsString({ message: 'Thời gian làm việc của công việc phải là dạng chuỗi.' })
  @IsNotEmpty({
    message: 'Thời gian làm việc của công việc không được để trống.',
  })
  readonly WorkingTimes!: string;

  @ApiProperty({
    name: 'ExpiredDate',
    description: 'Thời gian hết hạn của công việc',
    example: '2025-06-15T23:59:59.000Z',
  })
  @IsNotEmpty({ message: 'Ngày hết hạn của công việc không được để trống.' })
  @IsISO8601(
    {},
    {
      message:
        'EndDate phải đúng định dạng ISO8601 (yyyy-mm-dd hoặc yyyy-mm-ddThh:mm:ssZ)',
    },
  )
  readonly ExpiredDate!: Date;

  @ApiProperty({
    name: 'Level',
    enum: [Level],
    description: 'Vị trí mong muốn cho công việc này',
    example: Level.fresher,
  })
  @IsEnum(Level, {
    message:
      'Vị trí mong muốn cho công việc không tìm thấy trong danh sách cho trước.',
  })
  readonly Level!: Level;

  @ApiProperty({
    name: 'Categories',
    description: 'Danh sách các danh mục của công việc',
    type: [String],
    example: ['Full Stack', 'Back End', 'Mobile'],
  })
  @IsArray({
    message: 'Danh sách các danh mục của công việc phải là dạng mảng.',
  })
  @ArrayNotEmpty({
    message: 'Danh sách các danh mục của công việc không được là mảng rỗng.',
  })
  @IsString({ each: true, message: 'Tên của danh mục phải là dạng chuỗi.' })
  @IsNotEmpty({
    each: true,
    message: 'Tên của danh mục không được là chuỗi rỗng.',
  })
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
  @IsArray({
    message: 'Danh sách các mô tả cho công việc phải là dạng mảng.',
  })
  @ArrayNotEmpty({
    message: 'Danh sách các mô tả cho công việc phải là mảng không rỗng.',
  })
  @IsString({ each: true, message: 'Tên mô tả phải là dạnh chuỗi.' })
  @IsNotEmpty({
    each: true,
    message: 'Tên mô tả phải là dạng chuỗi không rỗng.',
  })
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
  @IsArray({
    message: 'Danh sách các lợi ích của công việc phải là dạng mảng.',
  })
  @ArrayNotEmpty({
    message: 'Danh sách các lợi ích của công việc phải là mảng không rỗng.',
  })
  @IsString({ each: true, message: 'Tên của lợi ích phải là dạng chuỗi.' })
  @IsNotEmpty({
    each: true,
    message: 'Tên của lợi ích không được là chuỗi rỗng.',
  })
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
  @IsArray({
    message: 'Danh sách các yêu cầu của công việc phải là dạng mảng.',
  })
  @ArrayNotEmpty({
    message: 'Danh sách các yêu cầu của công việc phải là mảng không rỗng.',
  })
  @IsString({ each: true, message: 'Tên của yêu cầu phải là dạng chuỗi.' })
  @IsNotEmpty({
    each: true,
    message: 'Tên của yêu cầu không được là chuỗi rỗng.',
  })
  readonly Requirements!: string[];
}
