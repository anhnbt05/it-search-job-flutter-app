import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ui/Helpers/toastification.dart';
import 'package:ui/Models/Enum.dart';
import 'package:ui/Services/user_service.dart';
import 'package:ui/ViewModels/admin/RecruiterInforViewModel.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Constants/color_constants.dart';

class RecruiterInforScreen extends StatefulWidget {
  RecruiterInforScreen({super.key});

  @override
  State<RecruiterInforScreen> createState() => _RecruiterInforScreenState();
}

class _RecruiterInforScreenState extends State<RecruiterInforScreen> {
  @override
  Widget build(BuildContext context) {
    var viewModel = Provider.of<RecruiterInforViewModel>(context);
    return Theme(
      data: ThemeData(fontFamily: "Poppins"),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.chevron_left, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          toolbarHeight: 45,
          backgroundColor: ColorConstants.appbarColor,
          centerTitle: true,
          title: Text(
            "Hồ sơ nhà tuyển dụng",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: FutureBuilder(
          future: viewModel.recruiterFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              );
            } else if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              );
            } else
            {
              return Container(
                color: Colors.white,
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
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
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    child: ClipOval(
                                      child: Image.network(
                                        viewModel.recruiter!.AvatarUrl,
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    viewModel.recruiter!.FullName,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    viewModel.recruiter!.Position,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 7,),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: (viewModel.recruiter!.Status == 'active') ? Color(0x80d4ffd3) : Color(0x80ffd1d1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      child: Text(
                                        (viewModel.recruiter!.Status == 'active') ? "Hoạt động" : "Bị khóa",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: (viewModel.recruiter!.Status == 'active') ? Color(0xff368313) : Color(0xffbf2929)
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    height: 35,
                                    child: ListTile(
                                      dense: true,
                                      leading: Icon(
                                        Icons.phone_outlined,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      title: Text(
                                        viewModel.recruiter!.PhoneNumber,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: 35,
                                      maxHeight: 60,
                                    ),
                                    child: ListTile(
                                      dense: true,
                                      leading: Icon(
                                        Icons.email_outlined,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      title: Text(
                                        viewModel.recruiter!.Email,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    dense: true,
                                    leading: Icon(
                                      Icons.business_center_outlined,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                    title: Text(
                                      viewModel.recruiter!.Company.Name,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  ListTile(
                                    dense: true,
                                    leading: Icon(
                                      Icons.location_city_outlined,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                    title: Text(
                                      "${viewModel.recruiter!.CompanyLocations.BranchName}: ${viewModel.recruiter!.CompanyLocations.Address}",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  SizedBox(height: 5,),
                                  (viewModel.recruiter!.Status == 'active') ? Align(
                                    alignment: Alignment.centerRight,
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
                                                "Bạn có chắc chắn muốn khóa tài khoản người dùng ${viewModel.recruiter!.FullName} không?",
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
                                    )
                                  ) : SizedBox.shrink(),
                                ],
                              ),
                            ),
                          ),
                          Container(
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
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Image.network(viewModel.recruiter!.Company.LogoUrl!, width: 100, height: 100, fit: BoxFit.cover,),
                                  ),
                                  SizedBox(width: 5,),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(viewModel.recruiter!.Company.Name,
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.link, color: Colors.blue, size: 20),
                                            SizedBox(width: 5),
                                            GestureDetector(
                                              onTap: () async {
                                                final websiteUrl = viewModel.recruiter!.Company.WebsiteUrl;
                                                final Uri uri = Uri.parse(
                                                  websiteUrl.startsWith('http')
                                                      ? websiteUrl
                                                      : 'https://$websiteUrl',
                                                );

                                                try {
                                                  if (!await launchUrl(
                                                    uri,
                                                    mode: LaunchMode.externalApplication,
                                                  )) {
                                                    throw Exception('Không thể mở được liên kết: $uri');
                                                  }
                                                } catch (e) {
                                                  print('Lỗi mở URL: $uri - $e');
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Không thể mở liên kết website'),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Text(
                                                viewModel.recruiter!.Company.WebsiteUrl,
                                                style: TextStyle(fontSize: 14, color: Colors.blue),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ]
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
