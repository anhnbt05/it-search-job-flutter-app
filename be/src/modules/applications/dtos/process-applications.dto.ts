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

export class RejectedApplications {
  @IsUUID('4', { message: 'Mã định danh của đơn ứng tuyển phải có dạng UUID.' })
  @IsNotEmpty({
    message: 'Mã định danh của đơn ứng tuyển không được để trống.',
  })
  readonly applicationId!: string;

  @IsOptional({ message: 'Lý do (nếu có)' })
  @IsString({ message: 'Lý do từ chối đơn ứng tuyển phải là chuỗi.' })
  @IsNotEmpty({ message: 'Lý do từ chối đơn ứng tuyển không được để trống.' })
  readonly reason?: string;
}

export class ProcessApplicationsDto {
  @IsOptional()
  @IsArray({
    message: 'Các mã định danh của các đơn ứng tuyển phải là dạng mảng.',
  })
  @ArrayNotEmpty({
    message:
      'Các mã định danh của các đơn ứng tuyển phải là dạng mảng không được để trống.',
  })
  @IsUUID('4', {
    each: true,
    message: 'Mã định danh của đơn ứng tuyển phải có dạng là UUID.',
  })
  readonly acceptedApplicationIds?: string[];

  @IsOptional()
  @IsArray({
    message:
      'Danh sách các mã định danh kèm lý do từ chối của các đơn ứng tuyển phải là một mảng.',
  })
  @ArrayNotEmpty({
    message:
      'Danh sách mã định danh kèm lý do từ chối của các đơn ứng tuyển phải là một mảng không rỗng.',
  })
  @ValidateNested({ each: true })
  @Type(() => RejectedApplications)
  readonly rejectedApplications?: RejectedApplications[];
}
