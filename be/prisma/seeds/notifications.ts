import { NotificationType } from '@prisma/client';

export const Notifications: Array<{ Title: string; Type: NotificationType }> = [
  {
    Title: 'Nhà tuyển dụng vừa đăng tin mới',
    Type: NotificationType.admin_new_job_post,
  },
  {
    Title: 'Đơn ứng tuyển của bạn đã được chấp nhận',
    Type: NotificationType.candidate_application_approved,
  },
  {
    Title: 'Đơn ứng tuyển của bạn đã bị từ chối',
    Type: NotificationType.candidate_application_rejected,
  },
  {
    Title: 'Tin tuyển dụng của bạn đã được duyệt',
    Type: NotificationType.recruiter_job_approved,
  },
  {
    Title: 'Tin tuyển dụng của bạn đã bị từ chối',
    Type: NotificationType.recruiter_job_rejected,
  },
  {
    Title: 'Có ứng viên mới ứng tuyển bài đăng của bạn',
    Type: NotificationType.recruiter_new_application,
  },
];
