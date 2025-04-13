import { HttpService } from '@nestjs/axios';
import {
  BadRequestException,
  Injectable,
  InternalServerErrorException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { format } from 'date-fns';
import * as fs from 'fs';
import * as path from 'path';
import * as PDFDocument from 'pdfkit';
import { firstValueFrom } from 'rxjs';
import {
  handleGenerateTimestamp,
  REPORT_FILE_NAME,
  ReportType,
  TITLE_REPORT,
} from 'src/libs/common/utils';
import { IReportStrategy } from 'src/modules/dashboards/interfaces';

@Injectable()
export class PdfReportStrategy implements IReportStrategy {
  constructor(
    private readonly configService: ConfigService,
    private readonly httpService: HttpService,
  ) {}

  async generate(
    data: any[],
    type: ReportType,
    StartDate?: Date,
    EndDate?: Date,
  ): Promise<string> {
    if (type !== ReportType.PDF)
      throw new BadRequestException(
        'Kiểu báo cáo phải có định dạng là file .pdf',
      );

    const timestamp = handleGenerateTimestamp();

    let filePath = `./uploads/${timestamp}-${REPORT_FILE_NAME}_`;

    if (StartDate && EndDate) {
      filePath += `tu_${this.handleFormatDateTime(StartDate)}_den_${this.handleFormatDateTime(EndDate)}`;
    } else if (StartDate) {
      filePath += `tu_${this.handleFormatDateTime(StartDate)}`;
    } else if (EndDate) {
      filePath += `den_${this.handleFormatDateTime(EndDate)}`;
    } else {
      filePath += 'hien-tai';
    }

    filePath += `.${ReportType.PDF.toString()}`;

    try {
      const fontPath = path.join(
        process.cwd(),
        'src',
        'libs/common',
        'assets/fonts',
        'NotoSans.ttf',
      );

      const doc = new PDFDocument();

      doc.registerFont('NotoSans', fontPath).font('NotoSans');

      doc.pipe(fs.createWriteStream(filePath));

      const response = await firstValueFrom(
        this.httpService.get<ArrayBuffer>(
          this.configService.get<string>('application.logo_url', ''),
          { responseType: 'arraybuffer' },
        ),
      );

      const imageBuffer = Buffer.from(new Uint8Array(response.data));

      doc.image(imageBuffer, 50, 30, { width: 50 });

      doc
        .fontSize(16)
        .fillColor('black')
        .text(this.configService.get<string>('application.name', ''), 110, 35)
        .fontSize(10)
        .fillColor('gray')
        .text(
          this.configService.get<string>('application.description', ''),
          110,
          55,
        );

      doc
        .moveDown(2)
        .fontSize(18)
        .fillColor('black')
        .text(TITLE_REPORT, { align: 'center' });

      data.forEach((item) => {
        doc.moveDown(1);

        doc
          .fontSize(12)
          .fillColor('black')
          .text(`Tên công ty: `, { continued: true })
          .font('NotoSans')
          .text(item.companyName as string)
          .font('NotoSans');

        const total = item.totalApplications ?? 0;

        doc
          .fontSize(10)
          .fillColor('black')
          .text(`Tổng số công việc: ${item.totalJobs ?? 0}`);

        if (!total) {
          doc.text(`Tổng đơn ứng tuyển: 0`);
        } else {
          doc.text(
            `Tổng đơn ứng tuyển: ${total} - Đang chờ: ${item.totalPendingApplications ?? 0} - Đã chấp nhận: ${item.totalAcceptedApplications ?? 0} - Bị từ chối: ${item.totalRejectedApplications ?? 0}`,
          );
        }

        const acceptanceRate =
          item.acceptanceRate === 0
            ? '0%'
            : `${(item.acceptanceRate * 100).toFixed(2)}%`;

        doc
          .text(`Tỷ lệ chấp nhận: ${acceptanceRate}`)
          .text(
            `Công việc có nhiều đơn nhất: ${item.mostAppliedJobTitle || 'Không có'}`,
          );

        doc
          .moveDown(0.5)
          .fontSize(10)
          .fillColor('gray')
          .text('Xu hướng ứng tuyển theo tháng:');

        if (item.applicationTrendMonthly?.length) {
          item.applicationTrendMonthly.forEach((trend: any) => {
            const [year, month] = trend.month.split('-');
            const monthFormatted = `${month}/${year}`;
            doc.text(
              `- Tháng ${monthFormatted}: ${trend.totalApplications} đơn`,
              {
                indent: 20,
              },
            );
          });
        } else {
          doc.text('Không có dữ liệu ứng tuyển theo tháng.', {
            indent: 20,
          });
        }

        doc
          .moveDown(1)
          .moveTo(50, doc.y)
          .lineTo(550, doc.y)
          .lineWidth(0.5)
          .strokeColor('gray')
          .stroke();
      });

      let dateRangeText = 'Thời gian báo cáo';

      if (StartDate || EndDate) {
        const formattedStart = StartDate
          ? format(StartDate, 'dd/MM/yyyy')
          : null;

        const formattedEnd = EndDate ? format(EndDate, 'dd/MM/yyyy') : null;

        if (formattedStart && formattedEnd) {
          dateRangeText += ` từ ngày ${formattedStart} đến ${formattedEnd}`;
        } else if (formattedStart) {
          dateRangeText += ` từ ngày ${formattedStart} đến hiện tại (ngày ${format(new Date(), 'dd/MM/yyyy')})`;
        } else if (formattedEnd) {
          dateRangeText += ` đến ngày ${formattedEnd} (tính từ đầu hệ thống)`;
        }
      } else {
        dateRangeText += ` toàn bộ dữ liệu đến thời điểm hiện tại (ngày ${format(new Date(), 'dd/MM/yyyy')})`;
      }

      doc
        .moveDown(2)
        .fontSize(10)
        .fillColor('gray')
        .text(dateRangeText, { align: 'center' });

      doc.end();
    } catch (err) {
      console.error(err);

      throw new InternalServerErrorException(
        `Đã xảy ra lỗi khi tạo file báo cáo dạng ${ReportType.PDF.toString()}`,
      );
    }

    return filePath;
  }

  private handleFormatDateTime = (date: Date) => format(date, 'dd/MM/yyyy');
}
