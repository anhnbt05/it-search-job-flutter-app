import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString, IsUUID } from 'class-validator';

export class SearchUsersDto {
  @ApiPropertyOptional({
    name: 'candidateId',
    description: 'Mã định danh (ID) của ứng viên.',
    example: '891addf9-d54d-4c88-852d-fe96cb295536',
  })
  @IsOptional()
  @IsUUID('4', { message: 'Mã định danh của ứng viên phải ở dạng UUID.' })
  readonly candidateId?: string;

  @ApiPropertyOptional({
    name: 'recruiterId',
    description: 'Mã định danh (ID) của nhà tuyển dụng.',
    example: 'a8631991-bac3-491b-a5d1-90d1acff95a2',
  })
  @IsOptional()
  @IsUUID('4', { message: 'Mã định danh của nhà tuyển dụng phải ở dạng UUID.' })
  readonly recruiterId?: string;
}
