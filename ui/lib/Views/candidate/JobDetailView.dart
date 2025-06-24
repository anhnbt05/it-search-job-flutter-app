import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/Helpers/helpers.dart';
import '../../Models/Enum.dart';
import '../../ViewModels/candidate/DetailJobViewModel.dart';

extension JobStatusExtension on eJobStatus {
  String toVietnamese() {
    switch (this) {
      case eJobStatus.open:
        return 'Đang mở';
      case eJobStatus.closed:
        return 'Đã đóng';
      case eJobStatus.pending:
        return 'Đang chờ';
      case eJobStatus.rejected:
        return 'Bị từ chối';
    }
  }
  static eJobStatus? fromString(String status) {
    try {
      return eJobStatus.values.firstWhere(
            (e) => e.toString().split('.').last == status.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}

class JobDetailView extends StatelessWidget {
  final String jobId;

  const JobDetailView({super.key, required this.jobId});


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DetailJobViewModel()..fetchJobDetail(jobId,context),
      child: Consumer<DetailJobViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return _buildScaffold(
              context,
              const Center(child: CircularProgressIndicator()),
            );
          }

          if (viewModel.error != null) {
            return _buildScaffold(
              context,
              Center(child: Text(viewModel.error!)),
            );
          }

          final job = viewModel.jobDetail;
          final recruiter = job?.Recruiter;

          return _buildScaffold(
            context,
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _iconText(Icons.business, "Công ty tuyển dụng", recruiter?.Company.Name ?? "N/A"),
                  _iconText(Icons.location_on, "Địa điểm làm việc", job?.Address ?? "N/A"),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _iconText(Icons.attach_money, "Mức lương", job?.Salary ?? "N/A"),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _iconText(Icons.people, "Số lượng tuyển", '${job?.Vacancies ?? 0} người'),
                        ),
                      ],
                    ),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _iconText(Icons.work_outline, "Hình thức làm việc",JobTypeExtension.fromString(job!.Type)?.toVietnamese() ?? "N/A"),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _iconText(Icons.access_time, "Thời gian làm việc", job?.WorkingTimes ?? "N/A"),
                        ),
                      ],
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(child: _iconText(Icons.school, "Trình độ yêu cầu", LevelExtension.fromString(job!.Level)?.toVietnamese() ?? "N/A")),
                      const SizedBox(width: 16),
                      Expanded(child: _iconText(
                          Icons.check_circle_outline,
                          "Tình trạng",
                          job?.Status != null
                              ? JobStatusExtension.fromString(job!.Status)?.toVietnamese() ?? "N/A"
                              : "N/A"
                      )),
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _iconText(
                          Icons.calendar_today,
                          "Ngày đăng",
                          _formatDate(job?.PostedAt ?? DateTime.now()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _iconText(
                          Icons.calendar_today,
                          "Hạn nộp",
                          _formatDate(job?.ExpiredAt ?? DateTime.now()),
                        ),
                      ),
                    ],
                  ),


                  _sectionTitle("Danh mục"),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: job?.Categories.map(_buildTag).toList() ?? [],
                  ),

                  _sectionTitle("Mô tả công việc"),
                  ...job?.JobDescriptions.map(_buildBulletItem).toList() ?? [],

                  _sectionTitle("Yêu cầu công việc"),
                  ...job?.JobRequirements.map(_buildBulletItem).toList() ?? [],

                  _sectionTitle("Quyền lợi"),
                  ...job?.JobBenefits.map(_buildBulletItem).toList() ?? [],

                  const SizedBox(height: 24),
                  // Center(
                  //   child: ElevatedButton.icon(
                  //     onPressed: () {
                  //       // TODO: Gửi đơn ứng tuyển
                  //     },
                  //     icon: const Icon(Icons.send),
                  //     label: const Text('Nộp đơn ngay'),
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: const Color(0xFF2563EB),
                  //       foregroundColor: Colors.white,
                  //       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Scaffold _buildScaffold(BuildContext context, Widget body) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết công việc"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: body,
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF111827),
        ),
      ),
    );
  }

  Widget _iconText(IconData icon, String label, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xFF2563EB)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF111827),
                    )),
                const SizedBox(height: 2),
                Text(content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4B5563),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
