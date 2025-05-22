import { ApiProperty } from '@nestjs/swagger';
import { ArrayNotEmpty, IsArray, IsUUID } from 'class-validator';

export class CreateJobFavoritesDto {
  @ApiProperty({
    name: 'jobIds',
    type: [String],
    description:
      'Danh sách các mã định danh (ID) của các công việc mà ứng viên ưa thích.',
    example: [
      '2180647a-d0e5-4062-a4a1-28de8bdf539e',
      '2180647a-d0e5-4062-a4a1-28de8bdf539e',
    ],
  })
  @IsArray({
    message: 'Danh sách các mã định danh của các công việc phải là dạng mảng',
  })
  @ArrayNotEmpty({
    message:
      'Danh sách các mã định danh của công việc không được là mảng rỗng.',
  })
  @IsUUID('4', {
    each: true,
    message: 'Mã định danh của công việc phải có dạng là UUID.',
  })
  readonly jobIds!: string[];
}
