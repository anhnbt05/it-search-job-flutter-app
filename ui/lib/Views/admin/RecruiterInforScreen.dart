import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ui/Services/auth_forgetpassword_service.dart';
import 'package:ui/ViewModels/admin/RecruiterInforViewModel.dart';

import '../../Constants/color_constants.dart';
import '../../Helpers/toastification.dart';
import '../../ViewModels/recruiter/EditRecruiterInformationViewModel.dart';
import '../../ViewModels/recruiter/ProfileViewModel.dart';

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
          toolbarHeight: 45,
          automaticallyImplyLeading: false,
          backgroundColor: ColorConstants.appbarColor,
          centerTitle: true,
          title: Center(
            child: Text(
              "Thông tin nhà tuyển dụng",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
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
              return Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                      SizedBox(height: 20),
                    ],
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
