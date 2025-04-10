import { InjectFlowProducer } from '@nestjs/bullmq';
import { Injectable, NotFoundException } from '@nestjs/common';
import { Users } from '@prisma/client';
import { SupabaseClient } from '@supabase/supabase-js';
import { FlowProducer } from 'bullmq';
import { InjectSupabaseClient } from 'nestjs-supabase-js';
import {
  EMAIL_QUEUE_NAME,
  GENERATE_REPORT_QUEUE_NAME,
  REPORT_FLOW_PRODUCER,
  UPLOAD_REPORT_QUEUE_NAME,
} from 'src/libs/common/utils';
import { CreateReportDto } from 'src/modules/dashboards/dtos';

@Injectable()
export class ReportProducer {
  constructor(
    @InjectFlowProducer(REPORT_FLOW_PRODUCER)
    private readonly reportFlowProducer: FlowProducer,
    @InjectSupabaseClient('anonClient')
    private readonly anonSupabaseClient: SupabaseClient,
  ) {}

  async createReportFlow(createReportDto: CreateReportDto, userId: string) {
    const { data: admin } = await this.anonSupabaseClient
      .from('Users')
      .select('*')
      .eq('ID', userId)
      .maybeSingle<Users>();

    if (!admin)
      throw new NotFoundException(
        `Không tìm thấy quản trị viên có id '${userId}' trong hệ thống.`,
      );

    await this.reportFlowProducer.add({
      name: 'send-report-email',
      queueName: EMAIL_QUEUE_NAME,
      data: {
        email: admin.Email,
      },
      opts: { removeOnComplete: { age: 0 } },
      children: [
        {
          name: 'upload-report',
          queueName: UPLOAD_REPORT_QUEUE_NAME,
          opts: { removeOnComplete: { age: 0 } },
          children: [
            {
              name: 'generate-report',
              queueName: GENERATE_REPORT_QUEUE_NAME,
              data: { createReportDto },
              opts: { removeOnComplete: { age: 0 } },
            },
          ],
        },
      ],
    });
  }
}
