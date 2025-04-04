import { ArrayNotEmpty, IsArray, IsNotEmpty, IsString } from 'class-validator';

export class DeleteJobFavoritesDto {
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  readonly jobIds!: string[];
}
