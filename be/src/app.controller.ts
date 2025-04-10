import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { API_TAGS } from 'src/libs/common/utils';

@Controller()
@ApiTags(API_TAGS.APP)
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  @ApiOperation({
    summary: 'Đường gốc gốc của ứng dụng',
    description: 'Đường dẫn gốc của ứng dụng.',
  })
  @ApiResponse({
    status: 200,
    schema: {
      example: `Chào mừng bạn đến với ứng dụng backend của đồ án 'Tìm kiếm việc làm cho dân IT' trong môn Nhập môn ứng dụng di động SE114.P21.`,
    },
  })
  getHello(): string {
    return this.appService.getHello();
  }
}
