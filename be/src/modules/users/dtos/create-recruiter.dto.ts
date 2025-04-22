import { IsNotEmpty, IsString, IsUUID } from 'class-validator';

export class CreateRecruiterDto {
  @IsString({ message: 'Vị trí của bạn phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Vị trí của bạn không được để trống.' })
  readonly Position!: string;

  @IsUUID('4', { message: 'Mã định danh của công ty phải ở dạng UUID.' })
  readonly companyID!: string;

  @IsUUID('4', {
    message: 'Mã định danh của địa điểm công ty phải ở dạng UUID.',
  })
  readonly companyLocationID!: string;
}
