import { BadRequestException, Injectable } from '@nestjs/common';
import { format } from 'date-fns';
import * as ExcelJS from 'exceljs';
import * as fs from 'fs';
import * as path from 'path';
import {
  handleGenerateTimestamp,
  REPORT_FILE_NAME,
  ReportType,
} from 'src/libs/common/utils';
import { IReportStrategy } from 'src/modules/dashboards/interfaces';

@Injectable()
export class ExcelReportStrategy implements IReportStrategy {
  async generate(
    data: any[],
    type: ReportType,
    StartDate?: Date,
    EndDate?: Date,
  ): Promise<string> {
    if (type !== ReportType.EXCEL)
      throw new BadRequestException(
        `Kiểu báo cáo phải có định dạng là file .xlsx`,
      );

    const workbook = new ExcelJS.Workbook();

    const summarySheet = workbook.addWorksheet('Tổng Quan');

    summarySheet.columns = [
      { header: 'Tên công ty', key: 'companyName', width: 30 },
      { header: 'Số lượng tin tuyển dụng', key: 'totalJobs', width: 20 },
      { header: 'Tổng đơn ứng tuyển', key: 'totalApplications', width: 20 },
      {
        header: 'Tổng đơn ứng tuyển đang chờ xử lý',
        key: 'totalPendingApplications',
        width: 20,
      },
      {
        header: 'Tổng đơn ứng tuyển đã chấp thuận',
        key: 'totalAcceptedApplications',
        width: 20,
      },
      {
        header: 'Tổng đơn ứng tuyển từ chối',
        key: 'totalRejectedApplications',
        width: 20,
      },
      {
        header: 'Tỷ lệ nhận đơn ứng tuyển của ứng viên',
        key: 'acceptanceRate',
        width: 20,
      },
      {
        header: 'Bài tuyển dụng thu hút nhiều ứng viên nộp đơn nhất',
        key: 'mostAppliedJobTitle',
        width: 50,
      },
    ];

    let dateRangeText = 'Thời gian báo cáo';

    if (StartDate || EndDate) {
      const formattedStart = StartDate
        ? this.handleFormatDateTime(StartDate)
        : null;

      const formattedEnd = EndDate ? this.handleFormatDateTime(EndDate) : null;

      if (formattedStart && formattedEnd) {
        dateRangeText += ` từ ngày ${formattedStart} đến ${formattedEnd}`;
      } else if (formattedStart) {
        dateRangeText += ` từ ngày ${formattedStart} đến hiện tại (ngày ${this.handleFormatDateTime(new Date())})`;
      } else if (formattedEnd) {
        dateRangeText += ` đến ngày ${formattedEnd} (tính từ đầu hệ thống)`;
      }
    } else {
      dateRangeText += ` toàn bộ dữ liệu đến thời điểm hiện tại (ngày ${this.handleFormatDateTime(new Date())})`;
    }

    summarySheet.mergeCells('A1:H1');

    const dateCell = summarySheet.getCell('A1');

    dateCell.value = dateRangeText;

    dateCell.alignment = { horizontal: 'left' };

    dateCell.font = { italic: true, color: { argb: 'FF666666' } };

    summarySheet.addRow([]);

    summarySheet.addRow(summarySheet.columns.map((col) => col.header));

    data.forEach((item: any) => {
      summarySheet.addRow(item);
    });

    const trendSheet = workbook.addWorksheet('Xu Hướng Ứng Tuyển');

    trendSheet.columns = [
      {
        header: 'Tên công ty',
        key: 'companyName',
        width: 30,
      },
      {
        header: 'Tháng',
        key: 'month',
        width: 15,
      },
      {
        header: 'Tổng đơn ứng tuyển',
        key: 'totalApplications',
        width: 25,
      },
    ];

    trendSheet.mergeCells('A1:C1');

    const trendDateCell = trendSheet.getCell('A1');

    trendDateCell.value = dateRangeText;

    trendDateCell.alignment = { horizontal: 'left' };

    trendDateCell.font = { italic: true, color: { argb: 'FF666666' } };

    trendSheet.addRow([]);

    trendSheet.addRow(trendSheet.columns.map((col) => col.header));

    (data ?? []).forEach((item) => {
      const trends = Array.isArray(item.applicationTrendMonthly)
        ? item.applicationTrendMonthly
        : [];

      if (trends.length === 0) {
        trendSheet.addRow({
          companyName: item.companyName,
          month: 'Không có dữ liệu',
          totalApplications: 'Không có dữ liệu',
        });
      } else {
        trends.forEach((trend: any) => {
          trendSheet.addRow({
            companyName: item.companyName,
            month: trend.month,
            totalApplications: trend.totalApplications,
          });
        });
      }
    });

    const timestamp = handleGenerateTimestamp();

    let filePath = `./uploads/${timestamp}-${REPORT_FILE_NAME}_`;

    if (StartDate && EndDate) {
      filePath += `tu_${this.safeFormatDateTime(StartDate)}_den_${this.safeFormatDateTime(EndDate)}`;
    } else if (StartDate) {
      filePath += `tu_${this.safeFormatDateTime(StartDate)}`;
    } else if (EndDate) {
      filePath += `den_${this.safeFormatDateTime(EndDate)}`;
    } else {
      filePath += 'hien-tai';
    }

    filePath += `.${ReportType.EXCEL.toString()}`;

    const dir = path.dirname(filePath);

    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }

    await workbook.xlsx.writeFile(filePath);

    return filePath;
  }

  private safeFormatDateTime = (date: Date) =>
    this.handleFormatDateTime(date).replace(/\//g, '-');

  private handleFormatDateTime = (date: Date) => format(date, 'dd/MM/yyyy');
}
