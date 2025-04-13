import { ReportType } from 'src/libs/common/utils';

export interface IReportStrategy {
  generate(
    data: any[],
    type: ReportType,
    StartDate?: Date,
    EndDate?: Date,
  ): Promise<string> | string;
}
