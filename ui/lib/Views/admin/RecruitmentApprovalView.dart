import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ui/Constants/color_constants.dart';

import '../../Models/Jobs.dart';
import '../../ViewModels/admin/JobDetailViewModel.dart';
import '../../ViewModels/admin/RecruimentApprovalViewModel.dart';
import 'JobDetailScreen.dart';

Widget RecruitmentApprovalScreen(BuildContext context) {
  var viewModel = Provider.of<RecruiterApprovalViewModel>(context);

  if (viewModel.jobs == null) {
    return const Center(child: CircularProgressIndicator(color: Colors.blue));
  }

  return ListView.builder(
    itemCount: viewModel.jobs!.length,
    itemBuilder: (context, index) {
      return JobItem(context, index, viewModel);
    },
  );
}

Widget JobItem(BuildContext context, int index, RecruiterApprovalViewModel viewModel) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (_) => JobDetailViewModel(index: index, context: context),
            child: JobDetailScreen(),
          ),
        ),
      );
    },
    child: Padding(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
                width: 1,
                color: Colors.transparent
            )
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: IntrinsicHeight(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                  width: 2.2,
                                  color: Colors.transparent
                              )
                          ),
                          margin: EdgeInsets.only(right: 10),
                          child: ClipOval(
                            child: (viewModel.jobs![index]!.Recruiter
                                .AvatarUrl != null)
                                ? Image.network(
                              viewModel.jobs![index]!.Recruiter.AvatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: Icon(
                                      Icons.broken_image, color: Colors.grey),
                                );
                              },
                            )
                                : Container(
                              color: Colors.grey.shade200,
                              child: Icon(Icons.business, color: Colors.grey),
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Container(
                          height: 50,
                          width: 50,
                          margin: EdgeInsets.only(right: 10),
                          child: (viewModel.jobs![index]!.Recruiter.Company.LogoUrl != null)
                              ? Image.network(
                            viewModel.jobs![index]!.Recruiter.Company.LogoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: Icon(Icons.broken_image, color: Colors.grey),
                              );
                            },
                          )
                              : Container(
                            color: Colors.grey.shade200,
                            child: Icon(Icons.business, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            viewModel.jobs![index]!.Title,
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.2,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2,),
                          Text(viewModel.jobs![index]!.Recruiter.Company.Name!,
                            style: TextStyle(color: ColorConstants.subTextColor,
                                fontSize: 12.5),),
                          Text(
                            "${DateFormat('dd/MM/yyyy').format(viewModel.jobs![index]!.PostedAt)} - ${DateFormat('dd/MM/yyyy').format(viewModel.jobs![index]!.ExpiredAt)}",
                            style: TextStyle(color: Color(0xff52525a),
                                fontStyle: FontStyle.italic,
                                fontSize: 12),
                          ),
                          SizedBox(height: 10,),
                          Salary(context, viewModel, index),
                          SizedBox(height: 5),
                          Categories(context, viewModel, viewModel.jobs![index]!),
                          SizedBox(height: 3,),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                                children: [
                                  SizedBox(width: 5,),
                                  Level(context, viewModel, index),
                                  SizedBox(width: 5,),
                                  JobType(context, viewModel, index),
                                  SizedBox(width: 20,)
                                ]
                            ),
                          ),
                          SizedBox(height: 5,),
                          Text(viewModel.jobs![index]!.Description?? 'Không có',
                            maxLines: 5,
                            textAlign: TextAlign.justify,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget Categories(BuildContext context, RecruiterApprovalViewModel viewModel, cJobs_recruiter job) {
  return SizedBox(
    height: 30,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: job.Categories.length,
      itemBuilder: (context, idx) {
        return Container(
          margin: EdgeInsets.only(left: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                  width: 0.5,
                  color: Colors.grey.shade700
              )
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 5),
            child: Align(
              alignment: Alignment.center,
              child: Text(job.Categories[idx],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),),
            ),
          ),
        );
      },
    ),
  );
}

Widget Level(BuildContext context, RecruiterApprovalViewModel viewModel, int index) {
  StringBuffer Level = StringBuffer();
  Level.write(viewModel.jobs![index]!.Level[0].toUpperCase());
  Level.write(viewModel.jobs![index]!.Level.substring(1));
  return Container(
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
            width: 0.5,
            color: Colors.grey.shade700
        )
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 5),
      child: Text(Level.toString(),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade700,
        ),),
    ),
  );
}

Widget Salary(BuildContext context, RecruiterApprovalViewModel viewModel, int index) {
  return Container(
    width: MediaQuery.of(context).size.width - 80,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 5),
      child: Row(
        children: [
          Icon(Icons.monetization_on_outlined, size: 14, color: Colors.grey.shade700,),
          SizedBox(width: 2,),
          Expanded(
            child: Text(viewModel.jobs![index]!.Salary,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),),
          ),
        ],
      ),
    ),
  );
}

Widget JobType(BuildContext context, RecruiterApprovalViewModel viewModel,
    int index) {
  final List<Map<String, String>> jobType = [
    {"full_time": "Toàn thời gian"},
    {"part_time": "Bán thời gian"},
    {"remote": "Làm việc từ xa"},
    {"free_lance": "làm việc tự do"}
  ];
  String JobType = jobType
      .firstWhere((e) => e.keys.first == viewModel.jobs![index]!.Type,
    orElse: () => {"unknown": "Không xác định"},)
      .values
      .first;
  return Container(
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
            width: 0.5,
            color: Colors.grey.shade700
        )
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 5),
      child: Text(JobType,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade700,
        ),),
    ),
  );
}
