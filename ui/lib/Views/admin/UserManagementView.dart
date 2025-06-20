import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/Constants/color_constants.dart';
import 'package:ui/Models/Enum.dart';
import 'package:ui/Services/user_service.dart';
import 'package:ui/ViewModels/admin/UserNavigationViewModel.dart';
import 'package:ui/ViewModels/candidate/JoblistNavigationViewModel.dart';
import 'package:ui/Views/admin/RecruiterInforScreen.dart';

import '../../Models/Users.dart';
import '../../ViewModels/admin/RecruiterInforViewModel.dart';
import '../../ViewModels/admin/UserManagementViewModel.dart';

Widget UserManagementScreen(BuildContext context) {
  var viewModel = Provider.of<UserManagementViewModel>(context);
  var controller = Provider.of<UserNavigationViewModel>(context);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (controller.pageController.hasClients) {
      int currentPage = controller.pageController.page?.round() ?? 0;
      if (currentPage != controller.index) {
        controller.pageController.jumpToPage(controller.index);
      }
    }
  });

  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
      FocusScope.of(context).unfocus();
    },
    child: PageView(
      controller: controller.pageController,
      physics: NeverScrollableScrollPhysics(),
      children: [
        candidatePage(context, viewModel),
        recruiterPage(context, viewModel),
      ],
    ),
  );
}

Widget candidatePage(BuildContext context, UserManagementViewModel viewModel) {
  if (viewModel.userCandidates != null) {
    return candidateBody(viewModel);
  }
  return FutureBuilder(
    future: viewModel.usersFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        );
      } else {
        return candidateBody(viewModel);
      }
    },
  );
}

Widget candidateBody(UserManagementViewModel viewModel) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    viewModel.filterCandidateByName(value);
                  },
                  cursorColor: Colors.grey,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isDense: true,
              value: viewModel.statusFilter_candidate,
              items: [
                DropdownMenuItem<String>(
                  value: "all",
                  child: Text("Tất cả", style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),),
                ),
                DropdownMenuItem<String>(
                  value: "active",
                  child: Text("Còn hoạt động", style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),),
                ),
                DropdownMenuItem<String>(
                  value: "inactive",
                  child: Text("Đã bị khóa", style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),),
                ),
              ],
              buttonStyleData: ButtonStyleData(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
              dropdownStyleData: DropdownStyleData(
                elevation: 1,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white
                ),
              ),
              onChanged: (value){
                viewModel.filterCandidateByStatus(value);
              },
              iconStyleData: IconStyleData(
                icon: Icon(Icons.arrow_drop_down),
              ),
            ),
          ),
        ),
      ),
      Expanded(
        child: (viewModel.userCandidates!.isNotEmpty) ? ListView.builder(
          itemCount: viewModel.userCandidates!.length,
          itemBuilder: (context, index) {
            return candidateItem(context, viewModel.userCandidates![index]!, viewModel);
          },
        ) : Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text("Không tìm thấy người dùng", style: TextStyle(fontSize: 14, color: Colors.grey.shade600),),
        ),
      ),
    ],
  );
}

Widget recruiterPage(BuildContext context, UserManagementViewModel viewModel) {
  if (viewModel.userCandidates != null) {
    return recruiterBody(viewModel);
  }
  return FutureBuilder(
    future: viewModel.usersFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        );
      } else if (!snapshot.hasData) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        );
      } else {
        return recruiterBody(viewModel);
      }
    },
  );
}

Widget recruiterBody(UserManagementViewModel viewModel) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    viewModel.filterRecruiterByName(value);
                  },
                  cursorColor: Colors.grey,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isDense: true,
              value: viewModel.statusFilter_recruiter,
              items: [
                DropdownMenuItem<String>(
                  value: "all",
                  child: Text("Tất cả", style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),),
                ),
                DropdownMenuItem<String>(
                  value: "active",
                  child: Text("Còn hoạt động", style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),),
                ),
                DropdownMenuItem<String>(
                  value: "inactive",
                  child: Text("Đã bị khóa", style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),),
                ),
              ],
              buttonStyleData: ButtonStyleData(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
              dropdownStyleData: DropdownStyleData(
                elevation: 1,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white
                ),
              ),
              onChanged: (value){
                viewModel.filterRecruiterByStatus(value);
              },
              iconStyleData: IconStyleData(
                icon: Icon(Icons.arrow_drop_down),
              ),
            ),
          ),
        ),
      ),
      Expanded(
        child: (viewModel.userRecruiter!.isNotEmpty) ? ListView.builder(
          itemCount: viewModel.userRecruiter!.length,
          itemBuilder: (context, index) {
            return recruiterItem(context, viewModel.userRecruiter![index]!, viewModel);
          },
        ) : Padding (
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text("Không tìm thấy người dùng", style: TextStyle(fontSize: 14, color: Colors.grey.shade600),),
        ),
      ),
    ],
  );
}

double calculateTextWidth(BuildContext context) {
  final textPainter = TextPainter(
    text: TextSpan(text: "M" * 9, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout();

  return textPainter.size.width;
}


Widget candidateItem(BuildContext context, cUsers user, UserManagementViewModel viewModel) {
  return GestureDetector(
    onTap: () {
      print("OK");
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
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                      color: (user.Status! == eUserStatus.active) ? Color(0x80d4ffd3) : Color(
                          0x80ffd1d1),
                    ),
                    width: calculateTextWidth(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: (user.AvatarUrl != null)
                                ? NetworkImage(user.AvatarUrl!)
                                : null,
                            child: (user.AvatarUrl == null)
                                ? Icon(Icons.business, color: Colors.grey)
                                : null,
                          ),
                          SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            child: Text(
                              (user.Status! == eUserStatus.active) ? 'Hoạt động' : 'Bị khóa',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                color: (user.Status! == eUserStatus.active) ? Color(0xff368313) : Color(
                                    0xffbf2929)
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.FullName!,
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                            color: ColorConstants.subTextColor
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: [
                            Icon(Icons.email_outlined, size: 13, color: Color(0xff0c3093),),
                            SizedBox(width: 2,),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 3),
                                child: Text(user.Email!, style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 13, color: Color(0xff0c3093),),
                            SizedBox(width: 2,),
                            Text(user.PhoneNumber!, style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                            ),)
                          ],
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
  );
}

Widget recruiterItem(BuildContext context, cUsers user, UserManagementViewModel viewModel) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (_) => RecruiterInforViewModel(context, user.ID!),
            child: RecruiterInforScreen(),
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
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                      color: (user.Status! == eUserStatus.active) ? Color(0x80d4ffd3) : Color(
                          0x80ffd1d1),
                    ),
                    width: calculateTextWidth(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: (user.AvatarUrl != null)
                                ? NetworkImage(user.AvatarUrl!)
                                : null,
                            child: (user.AvatarUrl == null)
                                ? Icon(Icons.business, color: Colors.grey)
                                : null,
                          ),
                          SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            child: Text(
                              (user.Status! == eUserStatus.active) ? 'Hoạt động' : 'Bị khóa',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: (user.Status! == eUserStatus.active) ? Color(0xff368313) : Color(
                                      0xffbf2929)
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.FullName!,
                          style: TextStyle(
                              fontSize: 18,
                              height: 1.2,
                              fontWeight: FontWeight.w500,
                              color: ColorConstants.subTextColor
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: [
                            Icon(Icons.email_outlined, size: 13, color: Color(0xff0c3093),),
                            SizedBox(width: 2,),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 3),
                                child: Text(user.Email!, style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 13, color: Color(0xff0c3093),),
                            SizedBox(width: 2,),
                            Text(user.PhoneNumber!, style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                            ),)
                          ],
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
  );
}