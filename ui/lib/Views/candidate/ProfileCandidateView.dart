import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ui/ViewModels/candidate/ProfileCandidateViewModel.dart';
import 'package:ui/Views/candidate/EditWorkExperienceView.dart';
import 'package:ui/Views/candidate/PostWorkExperiencesView.dart';
import '../../Helpers/helpers.dart';
import '../../Helpers/toastification.dart';
import '../../Models/WorkExperiences.dart';
import '../../ViewModels/candidate/EditCandidateInformationViewModel.dart';
import '../../ViewModels/candidate/WorkExperiencesViewModel.dart';
import 'EditCandidateInformationScreen.dart';
import 'ReadResumeCandidateScreen.dart';

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
              body: Center(
                child: Text(
                  viewModel.error!,
                  style: const TextStyle(color: Colors.red, fontFamily: 'Poppins'),
                ),
              ),
            );
          }

          final candidate = viewModel.candidate;

          if (candidate == null) {
            return const Scaffold(
              body: Center(
                child: Text("Không có dữ liệu ứng viên.", style: TextStyle(fontFamily: 'Poppins')),
              ),
            );
          }

          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // App Bar Custom
                    SizedBox(
                      height: 50,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              iconSize: 28,
                              icon: const Icon(Icons.article_outlined, color: Colors.black),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReadResumeCandidateScreen(
                                      name: candidate.FullName,
                                      resumeUrl: candidate.ResumeUrl,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.black),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MultiProvider(
                                          providers: [
                                            ChangeNotifierProvider(
                                              create: (_) => EditCandidateInformationViewModel(context, candidate.ID),
                                            ),
                                            ChangeNotifierProvider.value(
                                              value: viewModel,
                                            ),
                                          ],
                                          child: EditCandidateInformationScreen(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.logout, color: Colors.red),
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      barrierColor: Colors.black.withOpacity(0.5),
                                      barrierDismissible: false,
                                      builder: (_) {
                                        return const Center(
                                          child: CircularProgressIndicator(color: Colors.blue),
                                        );
                                      },
                                    );
                                    await viewModel.signOut(context);
                                    Navigator.of(context, rootNavigator: true).pop();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Avatar + Thông tin
                    const SizedBox(height: 16),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(candidate.AvatarUrl ?? ""),
                    ),
                    const SizedBox(height: 12),
                    Text(candidate.FullName ?? "", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                    const SizedBox(height: 4),
                    Text(candidate.Email ?? "", style: const TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
                    Text(candidate.PhoneNumber ?? "", style: const TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
                    const SizedBox(height: 8),
                    if (candidate.Level != null)
                      Chip(
                        label: Text(
                          LevelExtension.fromString(candidate.Level)!.toVietnamese(),
                          style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                        ),
                        backgroundColor: Colors.blue,
                      ),

                    const SizedBox(height: 24),

                    _sectionTitle('Giới thiệu'),
                    Text(candidate.Bio ?? "", style: const TextStyle(fontFamily: 'Poppins')),

                    const SizedBox(height: 24),

                    _sectionTitle('Chứng chỉ'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (candidate.Certifications ?? []).map((cert) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.workspace_premium, size: 18, color: Colors.blue),
                                const SizedBox(width: 6),
                                Text(cert, style: const TextStyle(fontFamily: 'Poppins')),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionTitle('Kinh nghiệm làm việc'),
                        IconButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => MultiProvider(
                              providers: [
                                ChangeNotifierProvider.value(
                                  value: Provider.of<WorkExperiencesViewModel>(context, listen: false),
                                ),
                                ChangeNotifierProvider.value(
                                  value: viewModel,
                                ),
                              ],
                              child: PostWorkExperiencesView(),
                            ),
                            ),
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline, size: 28),
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),

                    ...(candidate.WorkExperiences ?? []).map((exp) {
                      return _WorkExperienceItem(
                        exp: exp,
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MultiProvider(
                                providers: [
                                  ChangeNotifierProvider.value(
                                    value: Provider.of<WorkExperiencesViewModel>(context, listen: false),
                                  ),
                                  ChangeNotifierProvider.value(
                                    value: viewModel,
                                  ),
                                ],
                                child: EditWorkExperienceView(workExperience: exp),
                              ),
                            ),
                          );
                        },
                          onDelete: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: Colors.white,
                                title: const Text(
                                  "Xác nhận",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    fontFamily: 'Poppins',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                content: const Text(
                                  'Bạn có chắc muốn xóa kinh nghiệm làm việc này?',
                                  style: TextStyle(fontFamily: 'Poppins'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    style: TextButton.styleFrom(
                                      overlayColor: Colors.transparent,
                                    ),
                                    child: const Text(
                                      'Hủy',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: TextButton.styleFrom(
                                      backgroundColor: Color(0xee65c29c),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'Đồng ý',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed != true) return;

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(child: CircularProgressIndicator()),
                            );

                            try {
                              final workExpViewModel = Provider.of<WorkExperiencesViewModel>(context, listen: false);
                              final profileViewModel = Provider.of<ProfileCandidateViewModel>(context, listen: false);

                              final success = await workExpViewModel.deleteWorkExperience(id: exp.ID!, context: context);

                              Navigator.of(context, rootNavigator: true).pop();

                              if (success) {
                                await profileViewModel.fetchCandidateInfo(context: context);

                              } else {
                                showTopToastification(
                                  title: "Lỗi",
                                  content: "Không thể xóa kinh nghiệm làm việc",
                                  color: Colors.red,
                                  icon: Icons.error,
                                );
                              }
                            } catch (e) {
                              Navigator.of(context, rootNavigator: true).pop();
                              showTopToastification(
                                title: "Lỗi",
                                content: "Đã xảy ra lỗi khi xóa kinh nghiệm",
                                color: Colors.red,
                                icon: Icons.error,
                              );
                            }
                          }

                      );
                    }).toList(),
                  ],
                ),
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
      child: Text(
          title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins'
          )
      ),
    );
  }
}

class _WorkExperienceItem extends StatefulWidget {
  final cWorkExperiences exp;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WorkExperienceItem({
    required this.exp,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  __WorkExperienceItemState createState() => __WorkExperienceItemState();
}

class __WorkExperienceItemState extends State<_WorkExperienceItem> {
  bool _showActions = false;

  String _formatDate(DateTime? date) {
    return date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Hiện tại';
  }

  @override
  Widget build(BuildContext context) {
    final formattedStartDate = _formatDate(widget.exp.StartDate);
    final formattedEndDate = _formatDate(widget.exp.EndDate);
    final jobType = JobTypeExtension.fromString(widget.exp.JobType)?.toVietnamese() ?? widget.exp.JobType;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                if (widget.exp.CompanyLogoUrl != null && widget.exp.CompanyLogoUrl!.isNotEmpty)
                  ClipOval(
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
                          width: 56,
                          height: 56,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.business, size: 28, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Vị trí công việc:', widget.exp.Position ?? ""),
                      const SizedBox(height: 8),
                      _buildInfoRow('Công ty:', widget.exp.CompanyName ?? ""),
                    ],
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onPressed: () {
                    setState(() {
                      _showActions = !_showActions;
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildInfoRow('Thời gian:', '$formattedStartDate - $formattedEndDate'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Hình thức:', jobType),
                  const SizedBox(height: 8),
                  _buildInfoRow('Địa điểm:', widget.exp.Location ?? ""),
                ],
              ),
            ),

            if ((widget.exp.Descriptions ?? []).isNotEmpty) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mô tả công việc:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins'
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...(widget.exp.Descriptions ?? []).map((desc) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontFamily: 'Poppins')),
                          Expanded(
                            child: Text(
                              desc,
                              style: const TextStyle(fontFamily: 'Poppins'),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ],

            if (_showActions)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text(
                          "Chỉnh sửa",
                          style: TextStyle(fontFamily: 'Poppins')
                      ),
                      onPressed: widget.onEdit,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      label: const Text(
                          "Xóa",
                          style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'Poppins'
                          )
                      ),
                      onPressed: widget.onDelete,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'Poppins',
          color: Colors.black,
          fontSize: 14,
        ),
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ' $value'),
        ],
      ),
    );
  }
}