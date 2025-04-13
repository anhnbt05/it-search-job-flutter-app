import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return `Chào mừng bạn đến với ứng dụng backend của đồ án 'Tìm kiếm việc làm cho dân IT' trong môn Nhập môn ứng dụng di động SE114.P21.`;
  }
}
