import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
            } else {
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
                              padding: const EdgeInsets.all(10.0),
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
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Image.network(viewModel.recruiter!.Company.LogoUrl!, width: 100, height: 100, fit: BoxFit.cover,),
                                  ),
                                  SizedBox(height: 5,),
                                  Text(viewModel.recruiter!.Company.Name,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 2,),
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
