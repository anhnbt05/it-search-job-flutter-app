import { ApiProperty } from '@nestjs/swagger';
import { IsUUID } from 'class-validator';

export class CreateApplicationDto {
  @ApiProperty({
    name: 'JobID',
    description: 'Mã định dạng (ID) của công việc',
    example: '2180647a-d0e5-4062-a4a1-28de8bdf539e',
  })
  @IsUUID()
  readonly JobId!: string;
}
