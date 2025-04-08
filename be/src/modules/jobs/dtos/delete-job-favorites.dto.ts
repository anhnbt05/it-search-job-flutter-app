import { ApiProperty } from '@nestjs/swagger';
import { ArrayNotEmpty, IsArray, IsNotEmpty, IsString } from 'class-validator';

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
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly jobIds!: string[];
}
