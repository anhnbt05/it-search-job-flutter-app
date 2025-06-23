import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../Helpers/helpers.dart';
import '../../Models/WorkExperiences.dart';
import '../../ViewModels/candidate/EditCandidateInformationViewModel.dart';
import '../../ViewModels/candidate/WorkExperiencesViewModel.dart';
import '../../ViewModels/recruiter/CandidateProfileViewModel.dart';

class CandidateProfileView extends StatelessWidget {
  CandidateProfileView({super.key, required this.candidateID});
  late String candidateID;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CandidateProfileViewModel(candidateID)..fetchCandidateInfo(context: context),
      child: Consumer<CandidateProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("Hồ sơ ứng viên", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),),
                centerTitle: true,
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                toolbarHeight: 45,
                leading: IconButton(
                  icon: Icon(Icons.chevron_left, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              body: const Center(child: CircularProgressIndicator(color: Colors.blue)),
            );
          }

          if (viewModel.error != null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("Hồ sơ ứng viên", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),),
                centerTitle: true,
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                toolbarHeight: 45,
                leading: IconButton(
                  icon: Icon(Icons.chevron_left, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              body: Center(child: Text(viewModel.error!, style: const TextStyle(color: Colors.red))),
            );
          }

          final candidate = viewModel.candidate;

          if (candidate == null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("Hồ sơ ứng viên", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),),
                centerTitle: true,
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                toolbarHeight: 45,
                leading: IconButton(
                  icon: Icon(Icons.chevron_left, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              body: const Center(child: Text("Không có dữ liệu ứng viên.")),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text("Hồ sơ ứng viên", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),),
              centerTitle: true,
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              toolbarHeight: 45,
              leading: IconButton(
                icon: Icon(Icons.chevron_left, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body:
            Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              child: ClipOval(
                                child: Image.network(
                                  candidate.AvatarUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(child: CircularProgressIndicator(color: Colors.blue));
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.person, color: Colors.grey, size: 60,);
                                  },
                                ),
                              ),
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
                                label: Text(LevelExtension.fromString(candidate.Level)!.toVietnamese(), style: const TextStyle(color: Colors.white)),
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
                        return _WorkExperienceItem(exp: exp);
                      }),
                    ],
                  ),
                ),
              ],
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

class _WorkExperienceItem extends StatefulWidget {
  final cWorkExperiences exp;

  const _WorkExperienceItem({
    required this.exp
  });

  @override
  __WorkExperienceItemState createState() => __WorkExperienceItemState();
}

class __WorkExperienceItemState extends State<_WorkExperienceItem> {
  String _formatDate(DateTime? date) {
    if (date == null) return 'hiện tại';
    return DateFormat('dd/MM/yyyy').format(date!);
  }

  @override
  Widget build(BuildContext context) {
    final formattedStartDate = _formatDate(widget.exp.StartDate);
    final formattedEndDate = _formatDate(widget.exp.EndDate);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: ClipOval(
                    child: Image.network(
                      widget.exp.CompanyLogoUrl ?? '',
                      fit: BoxFit.cover,
                      width: 56,
                      height: 56,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.business, size: 28, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.exp.Position ?? "",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(widget.exp.CompanyName ?? "", style: const TextStyle(color: Colors.grey)),
                      Text('${formattedStartDate} - ${formattedEndDate} • ${JobTypeExtension.fromString(widget.exp.JobType)!.toVietnamese()}'),
                      Text(widget.exp.Location ?? "", style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 8),
                      ...(widget.exp.Descriptions ?? []).map((desc) => Text("• $desc")).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}