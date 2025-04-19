import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:ui/Models/Jobs.dart';
import 'package:ui/ViewModels/recruiter/CandidatesAppliesViewModel.dart';

import '../../Models/Applications.dart';
import 'ReadResumeScreen.dart';

Widget CandidatesAppliedScreen(BuildContext context, CandidatesAppliesViewModel viewModel) {
  var viewModel = Provider.of<CandidatesAppliesViewModel>(context);

  return Container(
      color: Colors.white,
      child: Center(
        child: FutureBuilder<List<cJobs_recruiter?>?>(
          future: viewModel.jobsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(
                color: Colors.blue,
              ));
            }

            if (viewModel.jobs.isEmpty) {
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
                    itemCount: viewModel.jobs.length,
                    itemBuilder: (context, index) {
                      return JobItem(context, index, viewModel.jobs, viewModel.applications[index]);
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
  return Padding(
    padding: const EdgeInsets.only(top: 12.0, left: 8.0, right: 8.0),
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade100,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
        color: (applications == null || applications.isEmpty) ? Colors.grey.shade100 : Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              jobs[index]!.Title.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17
              ),
            ),

            Text(
              "${jobs[index]!.PostedAt.day.toString().padLeft(2, '0')}/${jobs[index]!.PostedAt.month.toString().padLeft(2, '0')}/${jobs[index]!.PostedAt.year}"
            ),

            SizedBox(
              height: (applications == null || applications.isEmpty) ? 0 : 10,
            ),

            CandidateApplied_list(index, applications),
          ],
        ),
      ),
    ),
  );
}

Widget CandidateApplied_list(int index, List<cApplications_recruiter>? applications) {
  if (applications == null || applications.isEmpty) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Center(
        child: Text(
          'Chưa có ứng viên nào ứng tuyển vào vị trí này',
          style: TextStyle(
            fontSize: 12,
          ),
        )
      ),
    );
  }
  return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        return CandidateApplied(index, applications[index], context);
      });
}

Widget CandidateApplied(int index, cApplications_recruiter application, BuildContext context) {
  return
    ClipRRect(
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
            Image.network(application.Candidate.AvatarUrl, width: MediaQuery
                .of(context)
                .size
                .width / 10, height: MediaQuery
                .of(context)
                .size
                .width / 10),
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

            IconButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(
                    builder: (context) => ReadResumeScreen(
                        application.Candidate.FullName, application.ResumeUrl, application.ID, application.Status, Provider.of<CandidatesAppliesViewModel>(context)
                    )
                )
                );


              },
              icon: Icon(Icons.article_outlined),
              padding: EdgeInsets.zero,
            ),

            IconButton(
              onPressed: () {},
              icon: Icon(Icons.remove_red_eye_outlined),
              padding: EdgeInsets.zero,
            )
          ],
        ),
      ),
    );
}