  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import 'package:ui/Constants/api_constants.dart';
  import 'package:ui/Models/Jobs.dart';
  import 'package:ui/Views/candidate/FillterButtomSheetView.dart';

  import '../../Services/application_candidate_service.dart';
  import '../../Services/job_service.dart';
  import '../../ViewModels/candidate/FindJobsViewModel.dart';
  import 'JobDetailView.dart';

  class FindJobsView extends StatelessWidget {
  //   const FindJobsView({super.key});
  //
  //   @override
  //   State<FindJobsView> createState() => _FindJobsViewState();
  // }
  //
  // class _FindJobsViewState extends State<FindJobsView> {
  //   late FindJobsViewModel viewModel;
  //
  //   @override
  //   void initState() {
  //     super.initState();
  //     viewModel = FindJobsViewModel();
  //     viewModel.fetchJobs();
  //   }

    @override
    Widget build(BuildContext context) {
      return ChangeNotifierProvider(
        create: (_) => FindJobsViewModel()..fetchJobs(context),
        child: Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: Consumer<FindJobsViewModel>(
            builder: (context, viewModel, _) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                context.read<FindJobsViewModel>().filterJobs(value);
                              },
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                builder: (context) => FilterBottomSheetView(viewModel: viewModel),
                              );
                            },
                            icon: const Icon(Icons.tune, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: viewModel.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : viewModel.error != null
                        ? Center(child: Text('Đã xảy ra lỗi: ${viewModel.error}'))
                        : viewModel.jobs.isEmpty
                        ? const Center(child: Text('Không có công việc nào.'))
                        : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: viewModel.jobs.length,
                      itemBuilder: (context, index) {
                        final job = viewModel.jobs[index];
                        if (job == null) return const SizedBox();
                        return JobCard(job: job);
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
    final cJobs_recruiter job;

    const JobCard({super.key, required this.job});

    @override
    Widget build(BuildContext context) {
      return Consumer<FindJobsViewModel>(
        builder: (context, viewModel, _) {
          final recruiter = job.Recruiter;
          final categories = job.Categories;
          final jobId = job.ID.toString();
          final isFavorite = viewModel.isJobFavorited(jobId);
          print('Job ${jobId} is favorite? $isFavorite');
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
                      child: (recruiter.Company.LogoUrl != null && recruiter.Company.LogoUrl!.isNotEmpty)
                          ? Image.network(
                        recruiter.Company.LogoUrl!,
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
                            recruiter.Company.Name ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (isFavorite) {
                          viewModel.removeFavoriteJob(jobId,context);
                        } else {
                           viewModel.addFavoriteJob(jobId,context);
                        }
                      },
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.blue : Colors.grey,
                      ),
                      tooltip: isFavorite ? 'Bỏ lưu công việc' : 'Lưu công việc',
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    _buildInfoRow(Icons.place, job.Address),
                    _buildInfoRow(Icons.monetization_on, job.Salary),
                    _buildInfoRow(Icons.access_time, job.WorkingTimes),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((cat) => _buildTag(cat)).toList(),
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
                    ElevatedButton.icon(
                      onPressed: () async {
                        final applicationService = ApplicationCandidateService();
                        await applicationService.applyForJob(
                          jobId: job.ID,
                          context: context,
                        );
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
        },
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
  }

