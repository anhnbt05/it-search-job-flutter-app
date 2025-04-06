import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class UpdateRecruiterDto {
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly Postion?: string;
}
