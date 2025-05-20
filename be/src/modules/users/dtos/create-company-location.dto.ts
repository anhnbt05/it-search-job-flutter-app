import { IsNotEmpty, IsString, IsUUID } from 'class-validator';

export class CreateCompanyLocationDto {
  @IsString({ message: 'Tên của chi nhánh phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Tên của chi nhánh không được là chuỗi rỗng.' })
  readonly BranchName!: string;

  @IsString({ message: 'Địa chỉ chi tiết của chi nhánh phải là dạng chuỗi.' })
  @IsNotEmpty({
    message: 'Địa chỉ chi tiết của chi nhánh không được là chuỗi rỗng.',
  })
  readonly Address!: string;

  @IsUUID('4', {
    message: 'Tỉnh, thành phố không được để trống.',
  })
  readonly LocationID!: string;
}
