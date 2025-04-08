import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class UpdateRecruiterDto {
  @ApiPropertyOptional({
    description: 'Vị trí công việc hiện tại của nhà tuyển dụng',
    example: 'Trưởng phòng tuyển dụng',
  })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  readonly Postion?: string;
}
