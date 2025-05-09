import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/Models/Jobs.dart';

import '../../ViewModels/candidate/FindJobsViewModel.dart';

class FindJobsView extends StatelessWidget {
  const FindJobsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FindJobsViewModel()..fetchJobs(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Consumer<FindJobsViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.error != null) {
              return Center(
                child: Text('Đã xảy ra lỗi: ${viewModel.error}'),
              );
            }

            if (viewModel.jobs.isEmpty) {
              return const Center(child: Text('Không có công việc nào.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.jobs.length,
              itemBuilder: (context, index) {
                final job = viewModel.jobs[index];
                if (job == null) return const SizedBox();
                return JobCard(job: job);
              },
            );
          },
        ),
      ),
    );
  }
}
class JobCard extends StatelessWidget {
  final cJobs_recruiter job;

  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final recruiter = job.Recruiter;
    final categories = job.Categories;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.Title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Lưu việc yêu thích
                },
                icon: const Icon(Icons.bookmark_border),
                color: Color(0xFF2563EB),
                tooltip: 'Lưu công việc',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            recruiter.Company.Name.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.place, job.Address),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.monetization_on, job.Salary),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.access_time, job.WorkingTimes),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((cat) => _buildTag(cat)).toList(),
          ),
          const Divider(height: 24, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Điều hướng đến trang chi tiết
                    },
                    icon:  Icon(Icons.visibility, size: 18, color: Color(0xFF2563EB)),
                    label: const Text(
                      'Xem chi tiết',
                      style: TextStyle(color: Color(0xFF2563EB)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Gửi đơn ứng tuyển
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Nộp đơn'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14),
          ),
        ),
      ],
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
}
