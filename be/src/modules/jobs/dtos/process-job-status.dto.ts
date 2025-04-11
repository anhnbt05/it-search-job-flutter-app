import { Type } from 'class-transformer';
import {
  ArrayNotEmpty,
  IsArray,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
  ValidateNested,
} from 'class-validator';

export class RejectedJobStatusDto {
  @IsUUID('4', { message: 'Mã định danh của công việc phải có dạng UUID.' })
  readonly jobId!: string;

  @IsOptional()
  @IsString({ message: 'Lý do phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Lý do phải là dạng chuỗi không rỗng.' })
  readonly reason?: string;
}

export class ProcessJobStatusDto {
  @IsOptional()
  @IsArray({
    message:
      'Danh sách các mã định danh của công việc đồng ý mở phải là dạng mảng.',
  })
  @ArrayNotEmpty({
    message:
      'Danh sách các mã định danh của công việc đồng ý mở là một mảng không rỗng.',
  })
  @IsUUID('4', {
    message: 'Mã định danh của công việc muốn mở phải có dạng UUID.',
  })
  readonly openJobIds?: string[];

  @IsOptional()
  @IsArray({ message: 'Danh sách các công việc mà từ chối phải là dạng mảng.' })
  @ArrayNotEmpty({
    message: 'Danh sách các công việc mà từ chối phải là mảng không rỗng.',
  })
  @ValidateNested({ each: true })
  @Type(() => RejectedJobStatusDto)
  readonly rejectedJobs?: RejectedJobStatusDto[];
}
