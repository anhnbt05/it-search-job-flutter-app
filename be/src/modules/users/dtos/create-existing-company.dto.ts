import { IsUUID } from 'class-validator';

export class CreateExistingCompanyDto {
  @IsUUID('4', { message: 'Mã định danh của công ty phải ở dạng UUID.' })
  readonly companyID!: string;

  @IsUUID('4', {
    message: 'Mã định danh của địa điểm công ty phải ở dạng UUID.',
  })
  readonly companyLocationID!: string;
}
