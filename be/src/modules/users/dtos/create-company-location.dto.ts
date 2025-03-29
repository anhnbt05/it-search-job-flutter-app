import { IsNotEmpty, IsString, IsUUID } from 'class-validator';

export class CreateCompanyLocationDto {
  @IsString()
  @IsNotEmpty()
  readonly BranchName!: string;

  @IsString()
  @IsNotEmpty()
  readonly Address!: string;

  @IsUUID()
  @IsNotEmpty()
  readonly LocationID!: string;
}
