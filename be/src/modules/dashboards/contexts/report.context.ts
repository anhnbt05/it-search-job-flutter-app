import { BadRequestException, Injectable } from '@nestjs/common';
import { ReportType } from 'src/libs/common/utils';
import { IReportStrategy } from 'src/modules/dashboards/interfaces';
import {
  ExcelReportStrategy,
  PdfReportStrategy,
} from 'src/modules/dashboards/strategies';

@Injectable()
export class ReportContext {
  private strategies: { [key: string]: IReportStrategy } = {};

  constructor(
    private readonly pdfReportStrategy: PdfReportStrategy,
    private readonly excelReportStrategy: ExcelReportStrategy,
  ) {
    this.strategies['pdf'] = this.pdfReportStrategy;
    this.strategies['xlsx'] = this.excelReportStrategy;
  }

  public getStrategy = (type: ReportType) => {
    const strategy = this.strategies[type];

    if (!strategy)
      throw new BadRequestException(
        `Loại báo cáo '${type}' chưa được hỗ trợ trong hệ thống.`,
      );

    return strategy;
  };
}
