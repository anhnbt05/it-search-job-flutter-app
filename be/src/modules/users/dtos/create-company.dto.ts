import { Type } from 'class-transformer';
import {
  IsNotEmpty,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { CreateCompanyLocationDto } from 'src/modules/users/dtos';

export class CreateCompanyDto {
  @IsString({ message: 'Tên của công ty phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Tên của công ty phải là chuỗi không rỗng.' })
  readonly Name!: string;

  @IsOptional()
  @IsString({ message: 'Địa chỉ website của công ty phải là dạng chuỗi.' })
  @IsNotEmpty({
    message: 'Địa chỉ website của công ty phải là chuỗi không rỗng.',
  })
  readonly WebsiteUrl?: string;

  @IsOptional()
  @IsString({ message: 'Mô tả cho công ty phải là dạng chuỗi.' })
  @IsNotEmpty({ message: 'Mô tả cho công ty phải là chuỗi không rỗng.' })
  readonly Description?: string;

  @ValidateNested()
  @Type(() => CreateCompanyLocationDto)
  @IsNotEmpty({
    message: 'Dữ liệu cần để tạo chi tiết chi nhánh không được để trống.',
  })
  readonly createCompanyLocationDto!: CreateCompanyLocationDto;
}
