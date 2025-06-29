import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/Models/JobFavorites.dart';
import 'package:ui/Models/Jobs.dart';

import '../../Constants/api_constants.dart';
import '../../Helpers/helpers.dart';
import '../../Helpers/toastification.dart';
import '../../Services/application_candidate_service.dart';
import '../../ViewModels/candidate/FavoritesJobsViewModel.dart';
import '../../ViewModels/candidate/FindJobsViewModel.dart';
import 'JobDetailView.dart';

class FavoritesJobsView extends StatelessWidget {
  const FavoritesJobsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FavoritesJobsViewModel()..fetchFavoritesJobs(context),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Consumer<FavoritesJobsViewModel>(
          builder: (context, viewModel, _) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Color(0xFFE5E7EB),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Đã thích: ${viewModel.jobs.length} bài',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Color(0xFFE5E7EB),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.error != null
                      ? Center(child: Text('Đã xảy ra lỗi: ${viewModel.error}'))
                      : viewModel.jobs.isEmpty
                      ? const Center(child: Text('Không có công việc yêu thích nào.'))
                      : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.jobs.length,
                    itemBuilder: (context, index) {
                      final job = viewModel.jobs[index];
                      if (job == null) return const SizedBox();
                      return JobCard(favoritejob: job);
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
}

class JobCard extends StatelessWidget {
  final cJobFavorites favoritejob;

  const JobCard({super.key, required this.favoritejob});

  @override
  Widget build(BuildContext context) {
    final recruiter = favoritejob.Job?.Recruiter;
    final categories = favoritejob.Job?.Categories;

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
                      favoritejob.Job!.Title,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              _buildInfoRow(Icons.place, favoritejob.Job!.Address),
              _buildInfoRow(Icons.monetization_on, favoritejob.Job!.Salary),
              _buildInfoRow(Icons.access_time, favoritejob.Job!.WorkingTimes),
              _buildInfoRow(Icons.work_outline, LevelExtension.fromString(favoritejob.Job!.Level)!.toVietnamese()),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories!.map((cat) => _buildTag(cat)).toList(),
          ),
          const Divider(height: 24, color: Color(0xFFE5E7EB)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobDetailView(jobId: favoritejob.Job!.ID),
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
              ElevatedButton.icon(
                onPressed: () async {
                  _showApplyDialog(context);
                },
                icon: const Icon(Icons.send),
                label: const Text('Nộp đơn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
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
  void _showApplyDialog(BuildContext context) {
    bool? useProfileCV;
    File? cvFile;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Nộp đơn ứng tuyển',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vui lòng chọn phương thức nộp CV',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),

                    InkWell(
                      onTap: () {
                        setState(() {
                          useProfileCV = true;
                          cvFile = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: useProfileCV == true
                              ? const Color(0xFF2563EB).withOpacity(0.1)
                              : Colors.transparent,
                          border: Border.all(
                            color: useProfileCV == true
                                ? const Color(0xFF2563EB)
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Radio<bool>(
                              value: true,
                              groupValue: useProfileCV,
                              onChanged: (value) {
                                setState(() {
                                  useProfileCV = value;
                                  cvFile = null;
                                });
                              },
                              activeColor: const Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sử dụng CV từ hồ sơ',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Chúng tôi sẽ sử dụng CV bạn đã tải lên trong hồ sơ cá nhân',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    InkWell(
                      onTap: () {
                        setState(() {
                          useProfileCV = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: useProfileCV == false
                              ? const Color(0xFF2563EB).withOpacity(0.1)
                              : Colors.transparent,
                          border: Border.all(
                            color: useProfileCV == false
                                ? const Color(0xFF2563EB)
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Radio<bool>(
                                  value: false,
                                  groupValue: useProfileCV,
                                  onChanged: (value) {
                                    setState(() {
                                      useProfileCV = value;
                                    });
                                  },
                                  activeColor: const Color(0xFF2563EB),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Tải lên CV mới',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            if (useProfileCV == false) ...[
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  final XFile? file = await openFile(
                                    acceptedTypeGroups: [
                                      XTypeGroup(
                                        label: 'Documents',
                                        extensions: ['pdf', 'doc', 'docx'],
                                      ),
                                    ],
                                  );
                                  if (file != null) {
                                    setState(() {
                                      cvFile = File(file.path);
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF2563EB),
                                  side: const BorderSide(
                                    color: Color(0xFF2563EB),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.upload_file, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      cvFile == null
                                          ? 'Chọn file CV'
                                          : 'Thay đổi file',
                                    ),
                                  ],
                                ),
                              ),

                              if (cvFile != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          cvFile!.path.split('/').last,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            cvFile = null;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),

                    if (useProfileCV == false && cvFile == null) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Vui lòng chọn file CV để tiếp tục',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : () async {
                    if (useProfileCV == null) {
                      showErrorToastification(
                        message: "Vui lòng chọn phương thức nộp CV",
                        title: "Lỗi",
                      );
                      return;
                    }

                    if (useProfileCV == false && cvFile == null) {
                      showErrorToastification(
                        message: "Vui lòng chọn file CV để tiếp tục",
                        title: "Lỗi",
                      );
                      return;
                    }

                    setState(() => isSubmitting = true);

                    try {
                      final applicationService = ApplicationCandidateService();
                      final success = await applicationService.applyForJob(
                        jobId: favoritejob.Job!.ID,
                        context: context,
                        cvFile: useProfileCV! ? null : cvFile,
                        useProfileCV: useProfileCV!,
                      );

                      if (success) {
                        Navigator.pop(context);
                      }
                    } finally {
                      setState(() => isSubmitting = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Xác nhận',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
