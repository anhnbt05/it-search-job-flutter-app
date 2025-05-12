import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class UpdateRecruiterDto {
  @ApiPropertyOptional({
    description: 'Vị trí công việc hiện tại của nhà tuyển dụng',
    example: 'Trưởng phòng tuyển dụng',
  })
  @IsOptional()
  @IsString({ message: 'Vị trí công việc phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Vị trí công việc phải là chuỗi không rỗng.' })
  readonly Position?: string;
}
