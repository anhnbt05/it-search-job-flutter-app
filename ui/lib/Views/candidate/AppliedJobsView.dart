import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/Models/Applications.dart';
import 'package:ui/ViewModels/candidate/AppliedJobsViewModel.dart';
import 'JobDetailView.dart';

class AppliedJobsView extends StatelessWidget {
  const AppliedJobsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppliedJobsViewModel()..fetchAllAppliedJobs(context),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Consumer<AppliedJobsViewModel>(
          builder: (context, viewModel, _) {
            return Column(
              children: [
                _buildStatusFilter(viewModel),
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.errorMessage != null
                      ? Center(child: Text('Đã xảy ra lỗi: ${viewModel.errorMessage}'))
                      : viewModel.filteredJobs.isEmpty
                      ? const Center(child: Text('Không có công việc ứng tuyển nào.'))
                      : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.filteredJobs.length,
                    itemBuilder: (context, index) {
                      return JobCard(appliedJob: viewModel.filteredJobs[index]);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusFilter(AppliedJobsViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Hiển thị:',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 7),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isDense: true,
                value: viewModel.statusFilter,
                items: [
                  DropdownMenuItem<String>(
                    value: "all",
                    child: Text("Tất cả", style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),),
                  ),
                  DropdownMenuItem<String>(
                    value: "pending",
                    child: Text("Đang chờ", style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),),
                  ),
                  DropdownMenuItem<String>(
                    value: "approved",
                    child: Text("Đã chấp nhận", style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),),
                  ),
                  DropdownMenuItem<String>(
                    value: "interview",
                    child: Text("Mời phỏng vấn", style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),),
                  ),
                  DropdownMenuItem<String>(
                    value: "rejected",
                    child: Text("Đã từ chối", style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),),
                  ),
                ],
                onChanged: (value) {
                  viewModel.filterByStatus(value!);
                },
                buttonStyleData: ButtonStyleData(
                  width: 150,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                ),
                dropdownStyleData: DropdownStyleData(
                  elevation: 1,
                  width: 150,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white
                  ),
                ),
                iconStyleData: IconStyleData(
                  icon: Icon(Icons.arrow_drop_down),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final AppliedJobWithDetail appliedJob;

  const JobCard({super.key, required this.appliedJob});

  @override
  Widget build(BuildContext context) {
    final job = appliedJob.application.Job;
    final recruiter = job?.Recruiter;
    final categories = job?.Categories;
    final application = appliedJob.application;

    if (job == null) {
      return const SizedBox.shrink();
    }

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: recruiter?.Company.LogoUrl != null
                    ? Image.network(
                  recruiter!.Company.LogoUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 30, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.Title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recruiter?.Company.Name ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildApplicationStatus(application.Status),
                _buildAppliedTime(application.AppliedAt),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildInfoRow(Icons.place, job.Address),
              _buildInfoRow(Icons.monetization_on, job.Salary),
              _buildInfoRow(Icons.access_time, job.WorkingTimes),
            ],
          ),

          const SizedBox(height: 12),

          // Tags
          if (categories != null && categories.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) => _buildTag(cat)).toList(),
            ),

          const Divider(height: 24, color: Color(0xFFE5E7EB)),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobDetailView(jobId: job.ID),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility, size: 18, color: Color(0xFF2563EB)),
                label: const Text(
                  'Xem chi tiết',
                  style: TextStyle(color: Color(0xFF2563EB)),
                ),
              ),
              const SizedBox(width: 12),
              if (application.Status.toLowerCase() == 'pending')
                ElevatedButton.icon(
                  onPressed: () async {
                    final viewModel = Provider.of<AppliedJobsViewModel>(context, listen: false);
                    await viewModel.deleteApplication(
                      context: context,
                      applicationId: application.ID,
                    );
                    await viewModel.fetchAllAppliedJobs(context);
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text('Xoá đơn'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppliedTime(DateTime appliedAt) {
    try {
      final appliedTime = appliedAt;
      final formattedTime = '${appliedTime.day}/${appliedTime.month}/${appliedTime.year}';

      return Row(
        children: [
          Icon(Icons.timer_outlined, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            'Ngày ứng tuyển: $formattedTime',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      );
    } catch (e) {
      return const SizedBox();
    }
  }

  Widget _buildApplicationStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Row(
          children: [
            Icon(Icons.access_time, size: 14, color: Colors.orange.shade800),
            const SizedBox(width: 4),
            Text('Đang chờ xử lý',
              style: TextStyle(
                  color: Colors.orange.shade800,
                  fontSize: 13,
                  fontWeight: FontWeight.normal
              ),
            ),
          ],
        );
      case 'approved':
        return Row(
          children: [
            Icon(Icons.check_circle, size: 14, color: Colors.green),
            const SizedBox(width: 4),
            Text('Đã được chấp nhận',
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 13,
                  fontWeight: FontWeight.normal
              ),
            ),
          ],
        );
      case 'rejected':
        return Row(
          children: [
            Icon(Icons.highlight_off, size: 14, color: Colors.red),
            const SizedBox(width: 4),
            Text('Đã bị từ chối',
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.normal
              ),
            ),
          ],
        );
      case 'interview':
        return Row(
          children: [
            Icon(Icons.calendar_today, size: 14, color: Colors.blue),
            const SizedBox(width: 4),
            Text('Được mời phỏng vấn',
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 13,
                  fontWeight: FontWeight.normal
              ),
            ),
          ],
        );
      case 'hired':
        return Row(
          children: [
            Icon(Icons.work, size: 14, color: Colors.green.shade800),
            const SizedBox(width: 4),
            Text('Đã được tuyển dụng',
              style: TextStyle(
                  color: Colors.green.shade800,
                  fontSize: 13,
                  fontWeight: FontWeight.normal
              ),
            ),
          ],
        );
      default:
        return Row(
          children: [
            Icon(Icons.help, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text('Trạng thái không xác định',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.normal
              ),
            ),
          ],
        );
    }
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 6, height: 25),
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