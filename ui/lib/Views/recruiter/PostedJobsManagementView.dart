import 'dart:typed_data';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:ui/Constants/color_constants.dart';

import '../../Models/Jobs.dart';
import '../../ViewModels/recruiter/EditJobViewModel.dart';
import '../../ViewModels/recruiter/PostedJobsManagementViewModel.dart';
import 'EditJobScreen.dart';

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
  return GestureDetector(
    onTap: (){
      print("ok");
    },
    child: Column(
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
                                fontWeight: FontWeight.w500,
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
                                    'Đã đăng: ${viewModel.jobs_open.length + viewModel.jobs_closed.length} bài',
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
    ),
  );
}

Widget JobsList(BuildContext context, PostedJobsManagementViewModel viewModel) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: ListView(
        children: [
          JobsFilter(context, viewModel),
            if (viewModel.jobs.isEmpty && viewModel.statusFilter == 'all')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                child: const Center(
                  child: Text(
                    'Bạn hiện không có bài đăng tuyển dụng nào',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (viewModel.jobs.isEmpty && viewModel.statusFilter == 'open')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                child: const Center(
                  child: Text(
                    'Bạn hiện không có bài đăng tuyển dụng nào đang mở',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (viewModel.jobs.isEmpty && viewModel.statusFilter == 'pending')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                  child: const Center(
                    child: Text(
                      'Bạn hiện không có bài đăng tuyển dụng nào đang chờ duyệt',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else if (viewModel.jobs.isEmpty && viewModel.statusFilter == 'closed_rejected')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                    child: const Center(
                      child: Text(
                        'Bạn hiện không có bài đăng tuyển dụng nào đã đóng hoặc bị từ chối',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
          else
          ...List.generate(
            viewModel.jobs.length,
                (index) => JobsItem(context, viewModel, index),
          ),
          const SizedBox(height: 5),
        ],
      ),
    ),
  );
}


Widget JobsItem(BuildContext context, PostedJobsManagementViewModel viewModel, int index) {
  return Padding(
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
                  Container(
                    height: 50,
                    width: 50,
                    margin: EdgeInsets.only(right: 10),
                    child: (viewModel.recruiterInfo?.Company.LogoUrl != null)
                        ? Image.network(
                      viewModel.recruiterInfo!.Company.LogoUrl!,
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

                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          viewModel.jobs[index]!.Title,
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Status(context, viewModel, index),
                        SizedBox(height: 5,),
                        Salary(context, viewModel, index),
                        SizedBox(height: 5),
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
                        Text(viewModel.jobs[index]!.Description,
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
              ActionField(context, viewModel, index),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget ActionField(BuildContext context,
    PostedJobsManagementViewModel viewModel, int index) {
  if (viewModel.jobs[index]!.Status != 'open') {
    return
      Column(
        children: [
          SizedBox(height: 10,),
          SizedBox(
            height: 22,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  (viewModel.jobs[index]!.Status != 'closed') ? TextButton(
                    style: ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: MaterialStateProperty.all(
                          Colors.transparent),
                      elevation: MaterialStateProperty.all(0),
                      padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 5, vertical: 0)),
                      minimumSize: MaterialStateProperty.all(Size(30, 30)),
                      backgroundColor: MaterialStateProperty.all(
                          Colors.transparent),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (_) => EditJobViewModel(ID: viewModel.jobs[index]!.ID, recruiter: viewModel.recruiterInfo!),
                            child: EditJobScreen(),
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    width: 0.5,
                                    color: Colors.blue
                                )
                            ),
                            child: Icon(
                              Icons.edit_note_sharp, color: Colors.white,
                              size: 18,)),
                        SizedBox(width: 5,),
                        Text('Chỉnh sửa',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.normal
                          ),
                        ),
                      ],
                    ),
                  ) : SizedBox.shrink(),

                  TextButton(
                    style: ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: MaterialStateProperty.all(
                          Colors.transparent),
                      elevation: MaterialStateProperty.all(0),
                      padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 5, vertical: 0)),
                      minimumSize: MaterialStateProperty.all(Size(30, 30)),
                      backgroundColor: MaterialStateProperty.all(
                          Colors.transparent),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
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
                              "Bạn có chắc chắn muốn xoá bài tuyển dụng ${viewModel
                                  .jobs[index]!.Title} không?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  overlayColor: Colors.transparent,
                                ),
                                child: Text(
                                  'Thoát',
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
                                    builder: (BuildContext context) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.blue,
                                        ),
                                      );
                                    },
                                  );

                                  await viewModel.deleteJob(
                                      Id: viewModel.jobs[index]!.ID);
                                  Navigator.of(context).pop();
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Color(0xeef5797a),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Xóa',
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
                    child: Row(
                      children: [
                        Container(
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    width: 0.5,
                                    color: Colors.red
                                )
                            ),
                            child: Icon(
                              Icons.close_rounded, color: Colors.white,
                              size: 18,)),
                        SizedBox(width: 5,),
                        Text('Xóa bài đăng',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.normal
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
            ),
          ),
        ],
      );
  }
  return SizedBox.shrink();
}

Widget Level(BuildContext context, PostedJobsManagementViewModel viewModel, int index) {
  StringBuffer Level = StringBuffer();
  Level.write(viewModel.jobs[index]!.Level[0].toUpperCase());
  Level.write(viewModel.jobs[index]!.Level.substring(1));
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

Widget Salary(BuildContext context, PostedJobsManagementViewModel viewModel, int index) {
  return Container(
    width: MediaQuery.of(context).size.width - 80,
    child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 5),
        child: Row(
          children: [
            Icon(Icons.monetization_on_outlined, size: 14, color: Colors.grey.shade700,),
            SizedBox(width: 2,),
            Expanded(
              child: Text(viewModel.jobs[index]!.Salary,
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

Widget JobType(BuildContext context, PostedJobsManagementViewModel viewModel,
    int index) {
  final List<Map<String, String>> jobType = [
    {"full_time": "Toàn thời gian"},
    {"part_time": "Bán thời gian"},
    {"remote": "Làm việc từ xa"},
    {"free_lance": "làm việc tự do"}
  ];
  String JobType = jobType
      .firstWhere((e) => e.keys.first == viewModel.jobs[index]!.Type,
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

Widget Status(BuildContext context, PostedJobsManagementViewModel viewModel, int index) {
  if (viewModel.jobs[index]!.Status == 'open') {
    return Row(
      children: [
        Icon(Icons.verified_outlined, size: 14, color: Colors.green,),
        SizedBox(width: 2,),
        Text('Đang mở', style: TextStyle(
          fontWeight: FontWeight.normal,
          color: Colors.green,
          fontSize: 13,
        )),
      ],
    );
  } else if (viewModel.jobs[index]!.Status == 'pending') {
    return Row(
      children: [
        Icon(Icons.hourglass_top_outlined, size: 14, color: Colors.yellow.shade800,),
        SizedBox(width: 2,),
        Text('Đang chờ duyệt', style: TextStyle(
          fontWeight: FontWeight.normal,
          color: Colors.yellow.shade800,
          fontSize: 13,
        )),
      ],
    );
  } else if (viewModel.jobs[index]!.Status == 'rejected') {
    return Row(
      children: [
        Icon(Icons.highlight_off, size: 14, color: Colors.red,),
        SizedBox(width: 2,),
        Text('Đã bị từ chối', style: TextStyle(
          fontWeight: FontWeight.normal,
          color: Colors.red,
          fontSize: 13,
        )),
      ],
    );
  } else if (viewModel.jobs[index]!.Status == 'closed') {
    return Row(
      children: [
        Icon(Icons.lock_outline, size: 14, color: Colors.red,),
        SizedBox(width: 2,),
        Text('Đã đóng', style: TextStyle(
          fontWeight: FontWeight.normal,
          color: Colors.red,
          fontSize: 13,
        )),
      ],
    );
  }
  return SizedBox.shrink();
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
                  child: Text("Đang mở", style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),),
                ),
                DropdownMenuItem<String>(
                  value: "pending",
                  child: Text("Chờ duyệt", style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),),
                ),
                DropdownMenuItem<String>(
                  value: "closed_rejected",
                  child: Text("Đã đóng/Từ chối", style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),),
                ),

              ],
              onChanged: (value){
                viewModel.Filter(value);
              },
              buttonStyleData: ButtonStyleData(
                width: MediaQuery.of(context).size.width / 2 - 30,
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
              dropdownStyleData: DropdownStyleData(
                elevation: 1,
                width: MediaQuery.of(context).size.width / 2 - 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white
                ),
              ),
              iconStyleData: IconStyleData(
                icon: Icon(Icons.arrow_drop_down),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}