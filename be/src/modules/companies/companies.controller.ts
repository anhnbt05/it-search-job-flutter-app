import {
  Body,
  Controller,
  Param,
  ParseUUIDPipe,
  Patch,
  Req,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { AnyFilesInterceptor } from '@nestjs/platform-express';
import {
  ApiBody,
  ApiForbiddenResponse,
  ApiNotFoundResponse,
  ApiOperation,
  ApiParam,
  ApiResponse,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { User } from '@supabase/supabase-js';
import { Request } from 'express';
import { FileValidationDecorator, Roles } from 'src/libs/common/decorators';
import { RoleAuthGuard, SupabaseGuard } from 'src/libs/common/guards';
import { RoleEnum } from 'src/libs/common/utils';
import { UpdateCompanyDto } from 'src/modules/companies/dtos';
import { CompaniesService } from './companies.service';

@Controller('companies')
export class CompaniesController {
  constructor(private readonly companiesService: CompaniesService) {}

  @Patch(':id')
  @ApiOperation({
    summary: 'Cập nhật công ty',
    description:
      'Đường dẫn này dùng để cập nhật thông tin công ty của nhà tuyển dụng.',
  })
  @ApiResponse({
    status: 200,
    schema: {
      example: {
        success: true,
        message: 'Đã cập nhật thành công thông tin mới về công ty của bạn.',
      },
    },
  })
  @ApiUnauthorizedResponse({
    schema: {
      example: {
        message:
          'Bạn cần cung cấp token để truy cập vào tài nguyên của đường dẫn này.',
        error: 'Unauthorized',
        statusCode: 401,
      },
    },
  })
  @ApiBody({
    type: UpdateCompanyDto,
    description: 'Dữ liệu cần gửi đi để cập nhật thông tin cho công ty.',
  })
  @ApiForbiddenResponse({
    examples: {
      example1: {
        summary: 'Không phải role recruiter thì bị cấm.',
        value: {
          message:
            'Bạn không có quyền truy cập vào tài nguyên của đường dẫn này.',
          error: 'Forbidden',
          statusCode: 403,
        },
      },
      example2: {
        summary:
          'Có role recruiter nhưng không phải cập nhật công ty của chính mình.',
        value: {
          message: 'Bạn chỉ có thể chỉnh sửa công ty của chính mình.',
          error: 'Forbidden',
          statusCode: 403,
        },
      },
    },
  })
  @ApiParam({
    name: 'id',
    description: 'Mã định danh (ID) duy nhât của công ty',
    example: '2180647a-d0e5-4062-a4a1-28de8bdf539e',
  })
  @ApiNotFoundResponse({
    schema: {
      example: {
        message:
          "Không tìm thấy công ty có id '2180647a-d0e5-4062-a4a1-28de8bdf5392' trong hệ thống.",
        error: 'Not Found',
        statusCode: 404,
      },
    },
  })
  @UseInterceptors(AnyFilesInterceptor())
  @UseGuards(SupabaseGuard, RoleAuthGuard)
  @Roles(RoleEnum.RECRUITER)
  async updateCompany(
    @Param('id', ParseUUIDPipe) companyId: string,
    @Body() updateCompanyDto: UpdateCompanyDto,
    @Req() request: Request,
    @FileValidationDecorator() files?: Express.Multer.File[],
  ) {
    const userId = (request.user as User).id;

    return this.companiesService.handleUpdateCompany(
      companyId,
      updateCompanyDto,
      userId,
      files?.find((file) => file.fieldname === 'logoFile'),
    );
  }
}
