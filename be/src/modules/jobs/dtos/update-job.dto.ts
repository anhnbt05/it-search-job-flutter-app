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
  @IsString({ message: 'Tiêu đề của công việc phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Tiêu đề của công việc không được là chuỗi rỗng.' })
  readonly Title?: string;

  @ApiPropertyOptional({
    name: 'Description',
    description: 'Mô tả chung của công việc (Nếu có)',
    example:
      'Chúng tôi đang tìm kiếm thực tập sinh đam mê lập trình web để tham gia các dự án thực tế và phát triển kỹ năng chuyên môn',
  })
  @IsOptional()
  @IsString({ message: 'Mô tả của công việc phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Mô tả của công việc không được là chuỗi rỗng.' })
  readonly Description?: string;

  @ApiPropertyOptional({
    name: 'Address',
    description: 'Địa chỉ làm việc (Nếu có)',
    example: 'Quận Tân Bình, TP. Hồ Chí Minh, Việt Nam',
  })
  @IsOptional()
  @IsString({ message: 'Địa chỉ làm việc của công việc phải là dạng chuỗi.' })
  @IsNotEmpty({
    message: 'Địa chỉ làm việc của công việc phải là chuỗi không rỗng.',
  })
  readonly Address?: string;

  @ApiPropertyOptional({
    name: 'Salary',
    description: 'Mức lương của công việc (Nếu có)',
    example: 'Hỗ trợ 3,000,000 - 5,000,000 VND/tháng',
  })
  @IsOptional()
  @IsString({ message: 'Mức lương của công việc phải là dạng chuỗi.' })
  @IsNotEmpty({
    message: 'Mức lương của công việc phải là dạng chuỗi không rỗng.',
  })
  readonly Salary?: string;

  @ApiPropertyOptional({
    name: 'Vacancies',
    description: 'Số lượng ứng viên cần tuyển (Nếu có)',
    example: 5,
    type: Number,
  })
  @IsOptional()
  @IsNumber({}, { message: 'Số lượng ứng viên cần tuyển phải là dạng số.' })
  @IsPositive({ message: 'Số lượng ứng viên cần tuyển phải là số dương.' })
  readonly Vacancies?: number;

  @ApiPropertyOptional({
    name: 'Type',
    description: 'Loại hình công việc (Nếu có)',
    example: JobType.free_lance,
    enum: JobType,
  })
  @IsOptional()
  @IsEnum(JobType, {
    message: 'Loại hình công việc phải nằm trong danh sách đã liệt kê.',
  })
  readonly Type?: JobType;

  @ApiPropertyOptional({
    name: 'WorkingTimes',
    description: 'Thời gian làm việc của công việc (Nếu có)',
    example: 'Thứ 2 - Thứ 6, 8:30 - 17:30',
  })
  @IsOptional()
  @IsString({ message: 'Thời gian làm việc phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Thời gian làm việc phải là chuỗi không rỗng.' })
  readonly WorkingTimes?: string;

  @ApiPropertyOptional({
    name: 'ExpiredDate',
    description: 'Thời gian hết hạn của công việc (Nếu có)',
    example: '2025-06-15T23:59:59.000Z',
  })
  @IsOptional()
  @IsNotEmpty({ message: 'Ngày hết hạn của công việc không được để trống' })
  @IsISO8601(
    {},
    {
      message:
        'EndDate phải đúng định dạng ISO8601 (yyyy-mm-dd hoặc yyyy-mm-ddThh:mm:ssZ)',
    },
  )
  readonly ExpiredDate?: string;

  @ApiPropertyOptional({
    name: 'Level',
    description: 'Vị trị mong muốn cho công việc này (Nếu có)',
    enum: Level,
    example: Level.fresher,
  })
  @IsOptional()
  @IsEnum(Level, {
    message:
      'Vị trí mong muốn cho công việc phải nằm trong danh sách đã liệt kê.',
  })
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
  @IsArray({ message: 'Danh sách các mô tả cho công việc phải là dạng mảng.' })
  @ArrayNotEmpty({
    message: 'Danh sách các mô tả cho công việc phỉ là mảng không rỗng.',
  })
  @IsString({ each: true, message: 'Mô tả cho công việc phải là dạng chuỗi.' })
  @IsNotEmpty({
    each: true,
    message: 'Mô tả cho công việc không được là chuỗi rỗng.',
  })
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
  @IsArray({
    message: 'Danh sách các lợi ích của công việc phải là dạng mảng.',
  })
  @ArrayNotEmpty({
    message: 'Danh sách các lợi ích của công việc phải là mảng không rỗng.',
  })
  @IsString({
    each: true,
    message: 'Lợi ích của công việc phải là dạng chuỗi.',
  })
  @IsNotEmpty({
    each: true,
    message: 'Lợi ích của công việc phải là chuỗi không rỗng.',
  })
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
  @IsArray({
    message: 'Danh sách các yêu cầu của công việc phải là dạng mảng.',
  })
  @ArrayNotEmpty({
    message: 'Danh sách các yêu cầu của công việc phải là mảng không rỗng.',
  })
  @IsString({
    each: true,
    message: 'Yêu cầu của công việc phải là dạng chuỗi.',
  })
  @IsNotEmpty({
    each: true,
    message: 'Yêu cầu của công việc phải là chuỗi không rỗng.',
  })
  readonly Requirements?: string[];

  @ApiPropertyOptional({
    name: 'Categories',
    description: 'Các danh mục mới của công việc (Nếu có)',
    type: [String],
    example: ['Back End', 'Front End'],
  })
  @IsOptional()
  @IsArray({ message: 'Danh sách các danh mục công việc phải là dạng mảng.' })
  @ArrayNotEmpty({
    message: 'Danh sách các danh mục công việc phải là mảng không rỗng.',
  })
  @IsString({ each: true, message: 'Danh mục công việc phải là dạng chuỗi.' })
  @IsNotEmpty({
    each: true,
    message: 'Danh mục công việc phải là chuỗi không rỗng.',
  })
  readonly Categories?: string[];
}
