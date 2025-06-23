import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ui/Constants/color_constants.dart';

import '../../Helpers/helpers.dart';
import '../../Models/Candidates.dart';
import '../../Models/WorkExperiences.dart';
import '../../ViewModels/admin/CandidateInforViewModel.dart';
import '../../ViewModels/candidate/WorkExperiencesViewModel.dart';

class CandidateInforView extends StatelessWidget {
  CandidateInforView({super.key, required this.candidateID});
  late String candidateID;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CandidateInforViewModel(candidateID)..fetchCandidateInfo(context: context),
      child: Consumer<CandidateInforViewModel>(
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
              toolbarHeight: 45,
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: Icon(Icons.chevron_left, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body:
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(3, 3),
                          )
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ), child : Column(
                      children: [
                        SizedBox(height: 8),
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
                        Text(candidate.FullName,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(candidate.Email, style: TextStyle(color: Colors.grey[600])),
                        Text(candidate.PhoneNumber, style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 5),
                        Text(LevelExtension.fromString(candidate.Level)!.toVietnamese(), style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 5),
                        Container(
                          decoration: BoxDecoration(
                            color: (viewModel.candidate!.Status == 'active') ? Color(0x80d4ffd3) : Color(0x80ffd1d1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            child: Text(
                              (viewModel.candidate!.Status == 'active') ? "Hoạt động" : "Bị khóa",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: (viewModel.candidate!.Status == 'active') ? Color(0xff368313) : Color(0xffbf2929)
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5,),
                        (viewModel.candidate!.Status == 'active') ? Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: TextButton(
                                onPressed: () async {
                                  BuildContext? loadingContext;
                                  BuildContext? alertContext;
                                  showDialog(
                                    context: context,
                                    builder: (alertContext) {
                                      return AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: Text(
                                          "Xác nhận",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        content: Text(
                                          "Bạn có chắc chắn muốn khóa tài khoản người dùng ${viewModel.candidate!.FullName} không?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(alertContext);
                                            },
                                            style: TextButton.styleFrom(
                                              overlayColor: Colors.transparent,
                                            ),
                                            child: Text(
                                              'Không đồng ý',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              showDialog(
                                                context: context,
                                                barrierColor: Colors.black.withOpacity(0.5),
                                                barrierDismissible: false,
                                                builder: (BuildContext ctx) {
                                                  loadingContext = ctx;
                                                  return Center(
                                                    child: CircularProgressIndicator(color: Colors.blue),
                                                  );
                                                },
                                              );

                                              bool success = await viewModel.banUser(context);
                                              Navigator.pop(alertContext);
                                              if (loadingContext != null) {
                                                Navigator.pop(loadingContext!);
                                              }
                                              if (success) {
                                                Navigator.pop(context);
                                              }
                                            },
                                            style: TextButton.styleFrom(
                                              backgroundColor: Color(0xee65c29c),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: Text(
                                              'Đồng ý',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Color(0xffff5656),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                  minimumSize: Size(0, 0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius
                                        .circular(10),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.lock_outline),
                                    SizedBox(width: 5,),
                                    Text(
                                      'Khoá tài khoản',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                        ) : SizedBox.shrink(),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                  ),
                  SizedBox(height: 15,),
                  _sectionTitle('Giới thiệu'),
                  Text(candidate.Bio ?? ""),

                  const SizedBox(height: 24),

                  _sectionTitle('Chứng chỉ'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (candidate.Certifications ?? []).map((cert) {
                      return Chip(
                        backgroundColor: Colors.white,
                        label: Text(cert),
                        avatar: const Icon(Icons.workspace_premium, size: 18),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  _sectionTitle('Kinh nghiệm làm việc'),
                  ...(candidate.WorkExperiences ?? []).map((exp) {
                    return _WorkExperienceItem(
                      exp: exp,
                    );
                  }).toList(),
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

class _WorkExperienceItem extends StatefulWidget {
  final Candidate_admin_WorkExperience exp;

  const _WorkExperienceItem({
    required this.exp,
  });

  @override
  __WorkExperienceItemState createState() => __WorkExperienceItemState();
}

class __WorkExperienceItemState extends State<_WorkExperienceItem> {
  String _formatDate(DateTime? date) {
    if (date == null) return 'nay';
    return DateFormat('dd/MM/yyyy').format(date!);
  }

  @override
  Widget build(BuildContext context) {
    final formattedStartDate = _formatDate(widget.exp.StartDate);
    final formattedEndDate = _formatDate(widget.exp.EndDate);

    return Card(
      color: Colors.white,
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
                      Text(widget.exp.Position,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      Text(widget.exp.CompanyName ?? "", style: TextStyle(color: ColorConstants.subTextColor)),
                      SizedBox(height: 8),
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