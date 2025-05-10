import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/Models/Jobs.dart';
import '../../ViewModels/candidate/DetailJobViewModel.dart';

class JobDetailView extends StatelessWidget {
  final String jobId;

  const JobDetailView({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DetailJobViewModel()..fetchJobDetail(jobId),
      child: Consumer<DetailJobViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Chi tiết công việc"),
                backgroundColor: const Color(0xFF2563EB),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (viewModel.error != null) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Chi tiết công việc"),
                backgroundColor: const Color(0xFF2563EB),
              ),
              body: Center(
                child: Text(viewModel.error!),
              ),
            );
          }

          final job = viewModel.jobDetail;
          final recruiter = job?.Recruiter;

          return Scaffold(
            appBar: AppBar(
              title: Text(job?.Title ?? "Job Detail"),
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            backgroundColor: const Color(0xFFF9FAFB),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Công ty tuyển dụng"),
                  _textContent(recruiter?.Company.Name ?? "N/A"),

                  _sectionTitle("Địa điểm làm việc"),
                  _textContent(job?.Address ?? "N/A"),

                  _sectionTitle("Mức lương"),
                  _textContent(job?.Salary ?? "N/A"),

                  _sectionTitle("Số lượng tuyển"),
                  _textContent('${job?.Vacancies ?? 0} người'),

                  _sectionTitle("Hình thức làm việc"),
                  _textContent(job?.Type ?? "N/A"),

                  _sectionTitle("Thời gian làm việc"),
                  _textContent(job?.WorkingTimes ?? "N/A"),

                  _sectionTitle("Trình độ yêu cầu"),
                  _textContent(job?.Level ?? "N/A"),

                  _sectionTitle("Tình trạng"),
                  _textContent(job?.Status ?? "N/A"),

                  _sectionTitle("Ngày đăng & Hạn nộp"),
                  _textContent(
                    'Đăng ngày: ${_formatDate(job?.PostedAt ?? DateTime.now())}\nHết hạn: ${_formatDate(job?.ExpiredAt ?? DateTime.now())}',
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
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Gửi đơn ứng tuyển
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Nộp đơn ngay'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
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

  Widget _textContent(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
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
