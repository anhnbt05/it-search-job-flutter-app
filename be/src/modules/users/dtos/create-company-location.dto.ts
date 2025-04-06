import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsUUID } from 'class-validator';

export class CreateCompanyLocationDto {
  @ApiProperty({
    name: 'BranchName',
    description: 'Tên của chi nhánh',
    example: 'Chi nhánh 1',
  })
  @IsString()
  @IsNotEmpty()
  readonly BranchName!: string;

  @ApiProperty({
    name: 'Address',
    description: 'Địa chỉ chi tiết của chi nhánh',
    example: '123 Đường A, Huyện B, Tỉnh C',
  })
  @IsString()
  @IsNotEmpty()
  readonly Address!: string;

  @ApiProperty({
    name: 'LocationID',
    description: 'ID của tỉnh thành mà chi nhánh này thuộc về.',
    example: 'id-2e234234-423423-dad',
  })
  @IsUUID()
  @IsNotEmpty()
  readonly LocationID!: string;
}
