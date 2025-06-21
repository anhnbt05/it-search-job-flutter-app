import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:ui/Constants/color_constants.dart';
import 'package:ui/Models/Jobs.dart';
import 'package:ui/ViewModels/recruiter/CandidatesAppliesViewModel.dart';

import '../../Models/Applications.dart';
import 'ReadResumeScreen.dart';

Widget CandidatesAppliedScreen(BuildContext context) {
  var viewModel = Provider.of<CandidatesAppliesViewModel>(context);
  if (viewModel.jobs != null && viewModel.applications != null) {
    return ListView.builder(
        padding: EdgeInsets.only(bottom: 7),
        itemCount: viewModel.jobs!.length,
        itemBuilder: (context, index) {
          if (viewModel.applications == null) {
            return SizedBox.shrink();
          }
          return JobItem(context, index, viewModel.jobs!,
              viewModel.applications![index]);
        }
    );
  }
  return Container(
    color: Colors.white,
    child: Center(
      child: FutureBuilder<List<cJobs_recruiter?>?>(
          future: viewModel.postedJobsManagementViewModel.jobsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(
                color: Colors.blue,
              ));
            }

            if (viewModel.jobs == null || viewModel.jobs!.isEmpty) {
              return const Center(child: Text('Bạn chưa có bài đăng nào'));
            }

            return FutureBuilder(
                future: viewModel.applicationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(
                      color: Colors.blue,
                    ));
                  }
                  return ListView.builder(
                      padding: EdgeInsets.only(bottom: 7),
                      itemCount: viewModel.jobs!.length,
                      itemBuilder: (context, index) {
                        if (viewModel.applications == null) {
                          return SizedBox.shrink();
                        }
                        return JobItem(context, index, viewModel.jobs!,
                            viewModel.applications![index]);
                      }
                  );
                }
            );
          }
      ),
    ),
  );
}

Widget JobItem(BuildContext context, int index, List<cJobs_recruiter?> jobs, List<cApplications_recruiter>? applications) {
  bool hasNewApplications = (applications == null || applications.isEmpty) ? false : applications.any((application) => application.Status == 'pending');
  return Padding(
    padding: const EdgeInsets.only(top: 12.0, left: 8.0, right: 8.0),
    child: Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: (hasNewApplications) ? Colors.grey.shade300 : Colors.transparent,
          width: (hasNewApplications) ? 1 : 0,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jobs[index]!.Title.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                  ),
                ),

                Text(
                  "${jobs[index]!.PostedAt.day.toString().padLeft(2, '0')}/${jobs[index]!.PostedAt.month.toString().padLeft(2, '0')}/${jobs[index]!.PostedAt.year} - ${jobs[index]!.ExpiredAt.day.toString().padLeft(2, '0')}/${jobs[index]!.ExpiredAt.month.toString().padLeft(2, '0')}/${jobs[index]!.ExpiredAt.year}",
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 3,),
                Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Color(0x052196f3),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        (hasNewApplications) ? Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Text("Mới", style: TextStyle(fontSize:13, color: Colors.redAccent, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),),
                        ) : SizedBox.shrink(),
                        Icon(Icons.group_outlined, size: 20, color: ColorConstants.subTextColor,),
                        SizedBox(width: 2,),
                        Text("Có ${applications!.length} đơn ứng tuyển", style: TextStyle(fontSize:13, color: ColorConstants.subTextColor, fontWeight: FontWeight.w500),),
                        SizedBox(width: 5,),
                      ],
                    )
                )
              ],
            ),
          ),
          initiallyExpanded: hasNewApplications,
          shape: Border.all(style: BorderStyle.none),
          controlAffinity: ListTileControlAffinity.leading,
          iconColor: Colors.black,
          collapsedIconColor: Colors.black,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text.rich(
                TextSpan(
                  text: "Số ứng viên được duyệt: ",
                  style: TextStyle(
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text: "${(applications.isEmpty)
                          ? "0"
                          : applications
                          .where((application) => application.Status == 'accepted')
                          .length}/${jobs[index]!.Vacancies}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' người ',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 5,),
            CandidateApplied_list(index, applications, jobs[index]!),
          ],
        ),
      ),
    ),
  );
}

Widget CandidateApplied_list(int index, List<cApplications_recruiter>? applications, cJobs_recruiter job) {
  if (applications == null || applications.isEmpty) {
    return Center(
        child: Text(
          'Chưa có ứng viên nào ứng tuyển vào vị trí này',
          style: TextStyle(
            fontSize: 12,
          ),
        )
    );
  }
  return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        return CandidateApplied(index, applications[index], applications, job, context);
      });
}

Widget CandidateApplied(int index, cApplications_recruiter application, List<cApplications_recruiter> applications, cJobs_recruiter job, BuildContext context) {
  final viewModel = Provider.of<CandidatesAppliesViewModel>(context, listen: false);

  return Padding(
    padding: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (application.Status == 'pending') ? Color(0x109E9E9E) : Colors.white,
          border: Border(
            left: BorderSide(
              color: (application.Status == 'pending')
                  ? Colors.transparent
                  : (application.Status == 'accepted')
                  ? Colors.green
                  : Colors.red,
              width: 3,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    width: 2.2,
                    color: (application.Status == 'accepted')
                        ? Colors.green
                        : (application.Status == 'pending')
                        ? Colors.transparent
                        : Colors.red,
                  )
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(application.Candidate.AvatarUrl, width: MediaQuery
                    .of(context)
                    .size
                    .width / 10, height: MediaQuery
                    .of(context)
                    .size
                    .width / 10,),
              ),
            ),
            SizedBox(width: MediaQuery
                .of(context)
                .size
                .width / 60),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.Candidate.FullName.toString(),
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: Color(0x60bbdefb),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          child: Text(
                            '${application.AppliedAt.day.toString().padLeft(
                                2, '0')}/${application.AppliedAt.month
                                .toString().padLeft(2, '0')}/${application
                                .AppliedAt.year}',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),

            Builder(
                builder: (buttonContext) {
                  return IconButton(
                    onPressed: () {
                      Navigator.push(
                          buttonContext,
                          MaterialPageRoute(
                              builder: (context) => ReadResumeScreen(
                                  application.Candidate.FullName,
                                  application.ResumeUrl,
                                  application.ID,
                                  job,
                                  applications,
                                  application.Status,
                                  viewModel
                              )
                          )
                      );
                    },
                    icon: Icon(Icons.article_outlined),
                    padding: EdgeInsets.zero,
                  );
                }
            ),

            IconButton(
              onPressed: () {},
              icon: Icon(Icons.person_outline),
              padding: EdgeInsets.zero,
            )
          ],
        ),
      ),
    ),
  );
}