import 'dart:typed_data';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/Constants/color_constants.dart';

import '../../Models/Jobs.dart';
import '../../ViewModels/recruiter/PostedJobsManagementViewModel.dart';

Widget PostedJobsManagementScreen(BuildContext context) {
  var viewModel = Provider.of<PostedJobsManagementViewModel>(context);
  return FutureBuilder<List<cJobs_recruiter?>>(
    future: viewModel.jobsFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        );
      }

      return FutureBuilder(
        future: viewModel.recruiter,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          } else {
            return body(context: context, viewModel: viewModel);
          }
        },
      );
    },
  );
}

Widget body({
  required BuildContext context,
  required PostedJobsManagementViewModel viewModel,
}) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 5, left: 10, right: 5),
        child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  Image.network(
                    viewModel.recruiterInfo!.AvatarUrl,
                    width: 50,
                    height: 50,
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/title-background.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            viewModel.recruiterInfo!.FullName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            viewModel.recruiterInfo!.Company.Name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ColorConstants.subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: Offset(0, 12),
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                          width: 1,
                          color: Colors.grey.shade800,
                        )
                    )
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      color: Colors.white,
                      width: 4,
                      height: 20,
                      child: SizedBox.shrink(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 1,
                      ),
                      child: Center(
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.green,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(1),
                                child: Icon(
                                  Icons.check_outlined,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              color: Colors.white,
                              width: 2,
                              height: 20,
                              child: SizedBox.shrink(),
                            ),
                            Container(
                                color: Colors.white,
                                child: Text(
                                  'Đã đăng: ${viewModel.jobs_open.length} bài',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),

                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      width: 15,
                      height: 20,
                      child: SizedBox.shrink(),
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 1, right: 10, bottom: 1
                        ),
                        child: Center(
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.yellow.shade700,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(1),
                                  child: Icon(
                                    Icons.access_time,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                color: Colors.white,
                                width: 2,
                                height: 20,
                                child: SizedBox.shrink(),
                              ),
                              Container(
                                color: Colors.white,
                                child: Text(
                                  'Chờ duyệt: ${viewModel.jobs_pending.length} bài',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              Container(
                                color: Colors.white,
                                width: 4,
                                height: 20,
                                child: SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      JobsList(context, viewModel)
    ],
  );
}


Widget JobsList(BuildContext context, PostedJobsManagementViewModel viewModel) {
 return Expanded(
   child: Padding(
     padding: const EdgeInsets.only(top: 5),
     child: ListView(
       children: [
         JobsFilter(context, viewModel),
       ],
     ),
   ),
 );
}

Widget JobsFilter(BuildContext context, PostedJobsManagementViewModel viewModel) {
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
                  value: "open",
                  child: Text("Đã đăng", style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),),
                ),
                DropdownMenuItem<String>(
                  value: "pending",
                  child: Text("Chờ duyệt", style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),),
                )
              ],
              onChanged: (value){
                viewModel.setStatusFilter(value);
              },
              buttonStyleData: ButtonStyleData(
                width: MediaQuery.of(context).size.width / 2 - 80,
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                /*
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.blue,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),*/
              ),
              dropdownStyleData: DropdownStyleData(
                elevation: 1,
                width: MediaQuery.of(context).size.width / 2 - 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white
                ),
              ),
              iconStyleData: IconStyleData(
                icon: Icon(Icons.arrow_drop_down),
              ),
              onMenuStateChange: (isOpen) {
                /*if (isOpen) {
                      viewModel.setJobTypeBorderColor(Colors.blue);
                    } else {
                      if (viewModel.check == false || viewModel.jobTypeSelected != null)
                        viewModel.setJobTypeBorderColor(Colors.grey.shade400);
                      else viewModel.setJobTypeBorderColor(Colors.red);
                    }*/
              },
            ),
          ),
        ),
      ],
    ),
  );
}