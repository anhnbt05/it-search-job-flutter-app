import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/ViewModels/candidate/ProfileCandidateViewModel.dart';
import 'package:ui/Views/candidate/PostWorkExperiencesView.dart';

class ProfileCandidateView extends StatelessWidget {
  const ProfileCandidateView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileCandidateViewModel()..fetchCandidateInfo(context: context),
      child: Consumer<ProfileCandidateViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (viewModel.error != null) {
            return Scaffold(
              body: Center(child: Text(viewModel.error!, style: const TextStyle(color: Colors.red))),
            );
          }

          final candidate = viewModel.candidate;

          if (candidate == null) {
            return const Scaffold(
              body: Center(child: Text("Không có dữ liệu ứng viên.")),
            );
          }

          return Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(candidate.AvatarUrl ?? ""),
                        ),
                        const SizedBox(height: 12),
                        Text(candidate.FullName ?? "",
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(candidate.Email ?? "", style: const TextStyle(color: Colors.grey)),
                        Text(candidate.PhoneNumber ?? "", style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        if (candidate.Level != null)
                          Chip(
                            label: Text(candidate.Level!, style: const TextStyle(color: Colors.white)),
                            backgroundColor: Colors.blue,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _sectionTitle('Giới thiệu'),
                  Text(candidate.Bio ?? ""),

                  const SizedBox(height: 24),

                  _sectionTitle('Chứng chỉ'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (candidate.Certifications ?? []).map((cert) {
                      return Chip(
                        label: Text(cert),
                        avatar: const Icon(Icons.workspace_premium, size: 18),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  _sectionTitle('Kinh nghiệm làm việc'),
                  ...(candidate.WorkExperiences ?? []).map((exp) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(exp.CompanyLogoUrl ?? ""),
                              radius: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(exp.Position ?? "",
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  Text(exp.CompanyName ?? "", style: const TextStyle(color: Colors.grey)),
                                  Text('${exp.StartDate} - ${exp.EndDate} • ${exp.JobType}'),
                                  Text(exp.Location ?? "", style: const TextStyle(fontSize: 13)),
                                  const SizedBox(height: 8),
                                  ...(exp.Descriptions ?? []).map((desc) => Text("• $desc")).toList(),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PostWorkExperiencesView()));
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Thêm kinh nghiệm làm việc"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
