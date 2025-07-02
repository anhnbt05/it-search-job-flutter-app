import { NotificationType } from '@prisma/client';
import * as bcryptjs from 'bcryptjs';
import { format } from 'date-fns';
import { PrismaService } from 'src/modules/prisma/prisma.service';
import { v4 as uuidv4 } from 'uuid';

export const hashPassword = (password: string) => {
  const salt = bcryptjs.genSaltSync();

  return bcryptjs.hashSync(password, salt);
};

export const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

export const handleFormatUserNotificationContent = (
  type: NotificationType,
  metadata: Record<string, any>,
) => {
  switch (type) {
    case NotificationType.admin_new_job_post: {
      const createdAt = format(new Date(), 'dd/MM/yyyy hh:mm:ss a');

      return [
        `Bài tuyển dụng mới: ${metadata.jobTitle}`,
        `Tạo bởi: ${metadata.companyName || 'N/A'}`,
        `Vào lúc: ${createdAt}`,
      ];
    }

    case NotificationType.candidate_application_approved:
      return [
        `Chúc mừng! Đơn ứng tuyển của bạn cho công việc ${metadata.jobTitle || 'không rõ'} đã được chấp nhận.`,
        `Bạn sẽ sớm được liên hệ từ nhà tuyển dụng. Hãy kiểm tra email hoặc ứng dụng thường xuyên!`,
      ];

    case NotificationType.candidate_application_rejected:
      return [
        `Rất tiếc! Đơn ứng tuyển của bạn cho công việc ${metadata.jobTitle || 'không rõ'} đã không được chọn.`,
        `Đừng nản lòng, bạn có thể tiếp tục tìm kiếm những cơ hội phù hợp khác trong hệ thống.`,
      ];

    case NotificationType.recruiter_job_approved:
      return [
        `Bài đăng ${metadata.jobTitle || 'không rõ'} của bạn đã được quản trị viên duyệt.`,
        `Bài đăng sẽ bắt đầu hiển thị với ứng viên từ bây giờ.`,
      ];

    case NotificationType.recruiter_job_rejected:
      return [
        `Bài đăng ${metadata.jobTitle || 'không rõ'} của bạn đã bị quản trị viên từ chối.`,
        metadata.reason
          ? `Lý do từ chối: ${metadata.reason}`
          : `Vui lòng kiểm tra lại nội dung bài đăng và gửi lại.`,
      ];

    case NotificationType.recruiter_new_application: {
      const createdAt = format(new Date(), 'dd/MM/yyyy hh:mm:ss a');

      return [
        `Ứng viên ${metadata.candidateName || 'N/A'} đã ứng tuyển vào công việc ${metadata.jobTitle || 'không rõ'}.`,
        `Vào lúc: ${createdAt}.`,
      ];
    }

    case NotificationType.recruiter_job_expiring_soon: {
      const expiredAtFormatted = metadata.jobExpiredAt
        ? format(new Date(metadata.jobExpiredAt as string), 'dd/MM/yyyy')
        : 'không xác định';

      return [
        `Công việc "${metadata.jobTitle || 'không rõ'}" của bạn sẽ hết hạn vào ngày ${expiredAtFormatted}.`,
        `Bạn có thể kéo dài thêm thời gian hết hạn hoặc đóng công việc lại nếu cần thiết.`,
      ];
    }

    case NotificationType.recruiter_job_expired: {
      return [
        `Công việc "${metadata.jobTitle || 'không rõ'}" của bạn đã bị đóng do hết hạn đăng tuyển.`,
        `Bạn có thể cân nhắc xoá công việc này nếu cần thiết.`,
      ];
    }

    case NotificationType.candidate_job_closed: {
      return [
        `Công việc "${metadata.jobTitle || 'không rõ'}" mà bạn đã ứng tuyển hiện đã ngừng hiển thị do đã tuyển đủ số lượng ứng viên.`,
        `Bạn có thể khám phá thêm các công việc khác phù hợp trên hệ thống.`,
      ];
    }

    default:
      return [
        'Bạn có một thông báo mới, vui lòng kiểm tra để biết thêm chi tiết.',
      ];
  }
};

export const handleFormatDateTime = (date: Date) => {
  return format(date, 'yyyy/MM/dd');
};

export const handleGenerateTimestamp = () => {
  const now = new Date();

  const timestamp = `${now.getFullYear()}-${(now.getMonth() + 1)
    .toString()
    .padStart(2, '0')}-${now.getDate().toString().padStart(2, '0')}`;

  const uuid = uuidv4();

  return `${timestamp}_${uuid}`;
};

export function collectMessages(
  error: any,
): { field: string; message: string }[] {
  const messages: { field: string; message: string }[] = [];

  if (error.constraints) {
    for (const msg of Object.values(
      error.constraints as Record<string, string>,
    )) {
      messages.push({ field: error.property, message: msg });
    }
  }

  if (error.children && error.children.length > 0) {
    for (const child of error.children) {
      const nestedMessages = collectMessages(child).map((m) => ({
        field: `${error.property}.${m.field}`,
        message: m.message,
      }));
      messages.push(...nestedMessages);
    }
  }

  return messages;
}

export const handleGetNotificationEventByType = (type: NotificationType) => {
  if (type.startsWith('candidate_')) return 'candidate_notification';

  if (type.startsWith('recruiter_')) return 'recruiter_notification';

  if (type.startsWith('admin_')) return 'admin_notification';

  return 'user_notification';
};

export function normalizeUrl(url: string): string {
  return url.replace(/([^:]\/)\/+/g, '$1');
}

export async function fixInvalidUrls(prisma: PrismaService) {
  const updates = [
    { table: 'users', column: 'AvatarUrl' },
    { table: 'companies', column: 'LogoUrl' },
    { table: 'applications', column: 'ResumeUrl' },
  ];

  for (const { table, column } of updates) {
    const records = await prisma[table].findMany();

    for (const record of records) {
      const oldUrl = record[column];

      if (!oldUrl) continue;

      const newUrl = normalizeUrl(oldUrl as string);
      if (newUrl !== oldUrl) {
        await prisma[table].update({
          where: { ID: record.ID },
          data: { [column]: newUrl },
        });
      }
    }
  }
}
