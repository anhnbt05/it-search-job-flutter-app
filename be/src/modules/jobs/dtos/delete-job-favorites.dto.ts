import { ApiProperty } from '@nestjs/swagger';
import { ArrayNotEmpty, IsArray, IsUUID } from 'class-validator';

export class DeleteJobFavoritesDto {
  @ApiProperty({
    name: 'jobIds',
    type: [String],
    description:
      'Danh sách các mã định danh (ID) của các công việc mà ứng viên muốn xoá khỏi danh sách ưa thích.',
    example: [
      '2180647a-d0e5-4062-a4a1-28de8bdf539e',
      '2180647a-d0e5-4062-a4a1-28de8bdf539e',
    ],
  })
  @IsArray({
    message: 'Danh sách các công việc cần xoá phải có dạng một mảng.',
  })
  @ArrayNotEmpty({
    message: 'Danh sách các công việc cần xoá phải là mảng không rỗng.',
  })
  @IsUUID('4', { message: 'Mã định danh của công việc phải là dạng UUID.' })
  readonly jobIds!: string[];
}
