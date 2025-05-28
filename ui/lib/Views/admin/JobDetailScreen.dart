import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Constants/color_constants.dart';
import '../../Models/Jobs.dart';
import '../../ViewModels/admin/JobDetailViewModel.dart';

class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({super.key});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  @override
  Widget build(BuildContext context) {
    var viewModel = Provider.of<JobDetailViewModel>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: false,
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: ColorConstants.appbarColor,
          title: Center(child: Text('Thông tin bài đăng',style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500,),)),
          bottom: displaySelection(viewModel: viewModel),
        ),
      ),
      body: JobDetailBody(context, viewModel),
    );
  }
}

Widget JobDetailBody(BuildContext context, JobDetailViewModel viewModel) {
  return FutureBuilder<cJobs?>(
      future: viewModel.jobFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        } else {
          return Container(
              color: Colors.white,
              child: SingleChildScrollView(
                  child: Column(
                      children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 12, top: 15),
                                child: Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: EdgeInsets.only(right: 10),
                                  child: (viewModel.job!.Recruiter.Company
                                      .LogoUrl != null)
                                      ? Image.network(
                                    viewModel.job!.Recruiter.Company.LogoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade200,
                                        child: Icon(
                                            Icons.broken_image,
                                            color: Colors.grey),
                                      );
                                    },
                                  )
                                      : Container(
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                        Icons.business, color: Colors.grey),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 7, right: 5),
                                      child: Text(viewModel.job!.Title,
                                        softWrap: true,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 20,
                                          height: 1.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 7),
                                      child: Text(viewModel.job!.Recruiter.Company.Name,
                                        style: TextStyle(fontSize: 15),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 5),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xffe5f1fb),
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                  child: Text(viewModel.job!.Level.toString()[0].toUpperCase() +
                                                      viewModel.job!.Level.toString().substring(1),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: ColorConstants.subTextColor,
                                                    ),
                                                  ),
                                                )
                                            ),
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.only(left: 5),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xffe5f1fb),
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                  child: Text(() {
                                                    switch (viewModel.job!.Type) {
                                                      case 'full_time':
                                                        return 'Toàn thời gian';
                                                      case 'part_time':
                                                        return 'Bán thời gian';
                                                      case 'remote':
                                                        return 'Làm việc từ xa';
                                                      case 'free_lance':
                                                        return 'Làm việc tự do';
                                                      default:
                                                        return 'Khác';
                                                    }
                                                  }(),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: ColorConstants.subTextColor,
                                                    ),
                                                  ),
                                                )
                                            ),
                                          ),
                                        ]
                                    ),
                                  ],
                                ),
                              ),
                            ]
                        ),
                        SizedBox(height: 7,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            constraints: BoxConstraints(
                              minHeight: 25,
                              maxHeight: 30,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: viewModel.job!.Categories.length,
                                itemBuilder: (context, idx) {
                                  return Container(
                                    margin: EdgeInsets.only(left: 5),
                                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            width: 0.5,
                                            color: Colors.grey.shade700
                                        )
                                    ),
                                    child: Center(
                                      child: Text(
                                        viewModel.job!.Categories[idx],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                          height: 1.0,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        titleinJD(title: 'Thông tin công việc', isCompulsory: false, context: context),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(viewModel.job!.Description??"", textAlign: TextAlign.justify,),
                        ),
                        SizedBox(height: 10,),
                        ...iconTitle(icon: Icons.location_on_outlined, title: viewModel.job!.Address),
                        ...iconTitle(icon: Icons.attach_money, title: viewModel.job!.Salary),
                        ...iconTitle(icon: Icons.access_time_outlined, title: 'Thời gian làm việc: ${viewModel.job!.WorkingTimes}'),
                        ...iconTitle(icon: Icons.groups_outlined, title: "Số lượng tuyển: ${viewModel.job!.Vacancies} người"),
                        SizedBox(height: 10,),
                        titleinJD(title: 'Mô tả công việc', context: context),
                        Padding(
                          padding: const EdgeInsets.only(left: 18, right: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: viewModel.job!.JobDescriptions.map((desc) => Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Text(
                                '- $desc',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            )).toList(),
                          ),
                        ),
                        titleinJD(title: 'Yêu cầu công việc', context: context),
                        Padding(
                          padding: const EdgeInsets.only(left: 18, right: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: viewModel.job!.JobRequirements.map((desc) => Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Text(
                                '- $desc',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            )).toList(),
                          ),
                        ),
                        titleinJD(title: 'Phúc lợi', context: context),
                        Padding(
                          padding: const EdgeInsets.only(left: 18, right: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: viewModel.job!.JobBenefits.map((desc) => Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Text(
                                '- $desc',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            )).toList(),
                          ),
                        ),
                      ]
                  )
              )
          );
        }
      }
  );
}

List<Widget> iconTitle({required IconData icon,required String title}) {
  return [
      SizedBox(height: 5,),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            SizedBox(width: 10,),
            Icon(icon, color: Colors.black, size: 16,),
            SizedBox(width: 5,),
            Expanded(child: Text(title, style: TextStyle(fontSize: 14), softWrap: true,)),
          ],
        ),
      )
    ];
}

Align titleinJD({required String title, bool isCompulsory = true, required BuildContext context}) {
  var viewModel = Provider.of<JobDetailViewModel>(context);
  return Align(
    alignment: Alignment.topLeft,
    child: Padding(
      padding: EdgeInsets.only(top: 5, left: 10, bottom: 3),
      child: RichText(
        text: TextSpan(
            text: "$title:",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500, color: Color(0xff26649c),
              fontFamily:'Poppins',
            ),
            children: [
              (isCompulsory == false && viewModel.job!.Description == null) ?
              TextSpan(
                  text: ' Không có',
                  style: TextStyle(
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w100,
                  )
              ) : TextSpan(text: ''),
            ]
        ),
      ),
    ),
  );
}

PreferredSize? displaySelection({
  required JobDetailViewModel viewModel,
}) {
return PreferredSize(
      preferredSize: Size.fromHeight(40),
      child: Builder(builder: (buttonContext) {
        return Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom().copyWith(
                  overlayColor: MaterialStateProperty.all(
                    Color(0x15fa3a4b),
                  ),
                ),
                onPressed: () {
                  if (viewModel.job != null) {
                    showDialog(
                      barrierDismissible: false,
                      context: buttonContext,
                      builder: (dialogContext) {
                        return Dialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          insetPadding: EdgeInsets.all(9),
                          child: Container(
                            width: MediaQuery
                                .of(dialogContext)
                                .size
                                .width - 10,
                            padding: EdgeInsets.all(10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Lý do từ chối',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  height: 150,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),
                                  child: SizedBox.expand(
                                    child: TextField(
                                      autofocus: true,
                                      maxLines: null,
                                      minLines: null,
                                      expands: true,
                                      controller: viewModel.reasonController,
                                      textAlignVertical:
                                      TextAlignVertical.top,
                                      keyboardType: TextInputType.text,
                                      style: TextStyle(fontSize: 14),
                                      decoration: InputDecoration(
                                        hintText: 'Nhập lý do từ chối...',
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        isDense: true,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                            width: 0.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.blue,
                                            width: 1,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(dialogContext);
                                      },
                                      style: TextButton.styleFrom(
                                        overlayColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        'Hủy',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        final currentDialogContext = dialogContext;

                                        showDialog(
                                          context: currentDialogContext,
                                          barrierColor: Colors.black
                                              .withOpacity(0.5),
                                          barrierDismissible: false,
                                          builder: (
                                              BuildContext loadingContext) {
                                            return Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.blue,
                                              ),
                                            );
                                          },
                                        );
                                        bool success = await viewModel
                                            .rejectJob(buttonContext).then((
                                            value) => value.success);
                                        Navigator.of(currentDialogContext)
                                            .pop();
                                        if (success) {
                                          Navigator.pop(dialogContext);
                                          Navigator.pop(buttonContext);
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Color(0xeef5797a),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10),
                                        ),
                                      ),
                                      child: Text(
                                        'Xác nhận từ chối',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
                child: Text(
                  'Từ chối',
                  style: TextStyle(color: Color(0xfffa3a4b), fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(width: 5),

              TextButton(
                style: TextButton.styleFrom().copyWith(
                  overlayColor: MaterialStateProperty.all(
                    Color(0x1565c29c),
                  ),
                ),
                onPressed: () {
                  if (viewModel.job != null) {
                    showDialog(
                      barrierDismissible: false,
                      context: buttonContext,
                      builder: (dialogContext) {
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
                            "Bạn có chắc chắn muốn chấp nhận đơn ứng tuyển ${viewModel
                                .job!.Title} không?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
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
                                final currentDialogContext = dialogContext;

                                showDialog(
                                  context: currentDialogContext,
                                  barrierColor: Colors.black.withOpacity(0.5),
                                  barrierDismissible: false,
                                  builder: (BuildContext loadingContext) {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.blue,
                                      ),
                                    );
                                  },
                                );

                                bool success = await viewModel.approveJob(
                                    buttonContext).then((value) =>
                                value.success);
                                Navigator.of(currentDialogContext).pop();
                                if (success) {
                                  Navigator.pop(dialogContext);
                                  Navigator.pop(buttonContext);
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
                  }
                },
                child: Text(
                  'Chấp nhận',
                  style: TextStyle(color: Color(0xff65c29c), fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 5),
            ],
          ),
        );
      }),
    );
  }
