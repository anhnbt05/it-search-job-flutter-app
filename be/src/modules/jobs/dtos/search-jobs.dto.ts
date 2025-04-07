import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class SearchJobsDto {
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly CategoryName!: string;
}
