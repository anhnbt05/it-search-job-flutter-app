import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsUUID } from 'class-validator';

export class CreateCompanyLocationDto {
  @ApiProperty({
    name: 'BranchName',
    description: 'Tên của chi nhánh',
    example: 'Chi nhánh 1',
  })
  @IsString({ message: 'Tên của chi nhánh phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Tên của chi nhánh không được là chuỗi rỗng.' })
  readonly BranchName!: string;

  @ApiProperty({
    name: 'Address',
    description: 'Địa chỉ chi tiết của chi nhánh',
    example: '123 Đường A, Huyện B, Tỉnh C',
  })
  @IsString({ message: 'Địa chỉ chi tiết của chi nhánh phải là dạng chuỗi.' })
  @IsNotEmpty({
    message: 'Địa chỉ chi tiết của chi nhánh không được là chuỗi rỗng.',
  })
  readonly Address!: string;

  @ApiProperty({
    name: 'LocationID',
    description: 'ID của tỉnh thành mà chi nhánh này thuộc về.',
    example: 'id-2e234234-423423-dad',
  })
  @IsUUID('4', {
    message: 'Mã định danh của tỉnh, thành phố phải có dạng là UUID.',
  })
  readonly LocationID!: string;
}
