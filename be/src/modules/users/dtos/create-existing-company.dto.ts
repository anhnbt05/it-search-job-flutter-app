import { IsNotEmpty, IsUUID } from 'class-validator';

export class CreateExistingCompanyDto {
  @IsUUID()
  @IsNotEmpty()
  readonly companyID!: string;

  @IsUUID()
  @IsNotEmpty()
  readonly companyLocationID!: string;
}
