import { NotificationType } from '@prisma/client';
import * as bcryptjs from 'bcryptjs';
import { format } from 'date-fns';

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

    default:
      return [
        'Bạn có một thông báo mới, vui lòng kiểm tra để biết thêm chi tiết.',
      ];
  }
};
