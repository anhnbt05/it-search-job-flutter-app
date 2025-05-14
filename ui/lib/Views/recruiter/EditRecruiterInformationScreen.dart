import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ui/Services/auth_forgetpassword_service.dart';

import '../../Constants/color_constants.dart';
import '../../Helpers/toastification.dart';
import '../../ViewModels/recruiter/EditRecruiterInformationViewModel.dart';
import '../../ViewModels/recruiter/ProfileViewModel.dart';

class EditRecruiterInformationScreen extends StatefulWidget {
  EditRecruiterInformationScreen({super.key});

  @override
  State<EditRecruiterInformationScreen> createState() =>
      _EditRecruiterInformationScreenState();
}

class _EditRecruiterInformationScreenState
    extends State<EditRecruiterInformationScreen> {
  @override
  Widget build(BuildContext context) {
    var viewModel = Provider.of<EditRecruiterInformationViewModel>(context);
    var profileViewModel = Provider.of<RecruiterProfileViewModel>(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Theme(
        data: ThemeData(fontFamily: "Poppins"),
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 45,
            automaticallyImplyLeading: false,
            backgroundColor: ColorConstants.appbarColor,
            centerTitle: true,
            title: Center(
              child: Text(
                "Chỉnh sửa hồ sơ cá nhân",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 120,
                              color: Color(0x3fBBD6FF),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8, right: 15),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Image.network(
                                    profileViewModel.recruiterInfo!.Company.LogoUrl!,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                SizedBox(height: 20),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 28),
                                    child: Container(
                                      width: 140,
                                      height: 140,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 70,
                                        backgroundColor: Colors.white,
                                        child: viewModel.avtImage != null
                                            ? ClipOval(
                                          child: Image.file(
                                            viewModel.avtImage!,
                                            fit: BoxFit.cover,
                                            width: 140,
                                            height: 140,
                                          ),
                                        )
                                            : CircularProgressIndicator(color: Colors.blue,),
                                      ),
                                    ),

                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        viewModel.pickImage();
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                              Colors.white,
                                            ),
                                        elevation: WidgetStateProperty.all(0),
                                        splashFactory: NoSplash.splashFactory,
                                        shadowColor: MaterialStateProperty.all(
                                          Colors.transparent,
                                        ),
                                        overlayColor: WidgetStateProperty.all(
                                          Colors.transparent,
                                        ),
                                        minimumSize: WidgetStateProperty.all(
                                          Size(120, 32),
                                        ),
                                        shape: WidgetStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            side: BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.camera_alt,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            "Đổi ảnh đại diện",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 7,
                                    top: 0,
                                    bottom: 5,
                                  ),
                                  child: Center(
                                    child: Text.rich(
                                      maxLines: 2,
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Email:",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                " ${profileViewModel.recruiterInfo!.Email}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        Padding(
                          padding: const EdgeInsets.all(3),
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(5, 5),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 7,
                                    top: 5,
                                    bottom: 5,
                                  ),
                                  child: Text(
                                    "Họ và tên:",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                customTextField(
                                  hintText: "",
                                  height: 40,
                                  textInputType: TextInputType.text,
                                  controller: viewModel.fullNameController,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 7,
                                    top: 0,
                                    bottom: 5,
                                  ),
                                  child: Text(
                                    "Số điện thoại:",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                customTextField(
                                  hintText: "",
                                  height: 40,
                                  textInputType: TextInputType.text,
                                  controller: viewModel.phoneNumberController,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 7,
                                    top: 0,
                                    bottom: 5,
                                  ),
                                  child: Text(
                                    "Chức vụ:",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                customTextField(
                                  hintText: "",
                                  height: 40,
                                  textInputType: TextInputType.text,
                                  controller: viewModel.positionController,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    top: 5,
                                    bottom: 5,
                                    right: 10,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 5,
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text.rich(
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  "${profileViewModel.recruiterInfo!.CompanyLocations.BranchName}: ",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  profileViewModel
                                                      .recruiterInfo!
                                                      .CompanyLocations
                                                      .Address,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 0),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white,
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                viewModel.otpController.clear();
                                await AuthForgetPasswordService().forgotPassword(profileViewModel.recruiterInfo!.Email);
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) {
                                    bool isSendingOTP = false;

                                    return StatefulBuilder(
                                      builder: (conext, setState) {
                                        return Dialog(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                10),
                                          ),
                                          insetPadding: EdgeInsets.all(9),
                                          child: Container(
                                            width: MediaQuery
                                                .of(context)
                                                .size
                                                .width - 20,
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Xác thực OTP',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 25,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  'Mã xác thực (OTP) gồm 6 chữ số đã được gửi đến địa chỉ email của bạn. Vui lòng kiểm tra hộp thư và nhập mã OTP để tiếp tục.',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                  textAlign: TextAlign
                                                      .justify,),
                                                Align(
                                                  alignment: Alignment
                                                      .centerLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .only(left: 5, top: 20),
                                                    child: Text(
                                                      'Mã OTP:',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight
                                                            .w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Container(
                                                  height: 50,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                  ),
                                                  child: SizedBox.expand(
                                                    child: TextField(
                                                      controller: viewModel
                                                          .otpController,
                                                      textAlignVertical:
                                                      TextAlignVertical.top,
                                                      keyboardType: TextInputType
                                                          .text,
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                      decoration: InputDecoration(
                                                        hintText: 'Ví dụ: 123456...',
                                                        hintStyle: TextStyle(
                                                          color: Colors.grey,
                                                        ),
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius
                                                              .circular(
                                                            5,
                                                          ),
                                                        ),
                                                        isDense: true,
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius
                                                              .circular(
                                                            5,
                                                          ),
                                                          borderSide: BorderSide(
                                                            color: Colors.grey,
                                                            width: 0.5,
                                                          ),
                                                        ),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius
                                                              .circular(
                                                            5,
                                                          ),
                                                          borderSide: BorderSide(
                                                            color: Colors.blue,
                                                            width: 1,
                                                          ),
                                                        ),
                                                        contentPadding: EdgeInsets
                                                            .symmetric(
                                                          horizontal: 10,
                                                          vertical: 6,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .end,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      style: TextButton
                                                          .styleFrom(
                                                        overlayColor: Colors
                                                            .transparent,
                                                      ),
                                                      child: Text(
                                                        'Hủy',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                    (!isSendingOTP)
                                                        ? TextButton(
                                                      onPressed: () async {
                                                        if (viewModel.otpController.text.isEmpty) {
                                                          showErrorToastification(title: "Lỗi", message: "Vui lòng nhập mã OTP");
                                                          return;
                                                        }
                                                        if (viewModel.otpController.text.length != 6) {
                                                          showErrorToastification(title: "Lỗi", message: "Mã OTP phải có 6 chữ số");
                                                          return;
                                                        }
                                                        setState((){isSendingOTP = true;});
                                                        await viewModel.verifyOTP(context).then((value) {
                                                          setState(() {
                                                            isSendingOTP =false;
                                                          });
                                                          if (value.success == true) {
                                                            viewModel.newPasswordController.clear();
                                                            viewModel.confirmNewPasswordController.clear();
                                                            Navigator.pop(context);
                                                            showDialog(
                                                              context: context,
                                                              builder: (context) {
                                                                bool obscureText = true;
                                                                return StatefulBuilder(
                                                                    builder: (conext, setState) {
                                                                      return Dialog(
                                                                        backgroundColor: Colors.white,
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                              10),
                                                                        ),
                                                                        insetPadding: EdgeInsets.all(9),
                                                                        child: Container(
                                                                          width: MediaQuery
                                                                              .of(context)
                                                                              .size
                                                                              .width - 20,
                                                                          padding: EdgeInsets.all(10),
                                                                          child: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            children: [
                                                                              Text(
                                                                                'Đặt lại mật khẩu',
                                                                                style: TextStyle(
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontSize: 25,
                                                                                ),
                                                                              ),
                                                                              Align(
                                                                                alignment: Alignment
                                                                                    .centerLeft,
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets
                                                                                      .only(left: 5, top: 20),
                                                                                  child: Text(
                                                                                    'Mật khẩu mới: ',
                                                                                    style: TextStyle(
                                                                                      fontSize: 14,
                                                                                      fontWeight: FontWeight
                                                                                          .w500,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              SizedBox(height: 5),
                                                                              Container(
                                                                                height: 35,
                                                                                padding: EdgeInsets.symmetric(
                                                                                  horizontal: 5,
                                                                                ),
                                                                                child: SizedBox.expand(
                                                                                  child: TextField(
                                                                                    autofocus: true,
                                                                                    obscureText: obscureText,
                                                                                    controller: viewModel
                                                                                        .newPasswordController,
                                                                                    textAlignVertical:
                                                                                    TextAlignVertical.top,
                                                                                    keyboardType: TextInputType
                                                                                        .text,
                                                                                    style: TextStyle(
                                                                                        fontSize: 14),
                                                                                    decoration: InputDecoration(
                                                                                      suffixIcon: IconButton(
                                                                                        icon: Icon(
                                                                                          obscureText ? Icons.visibility_off : Icons.visibility,
                                                                                          size: 15,
                                                                                        ),
                                                                                        onPressed: () {
                                                                                          setState(() {
                                                                                            obscureText = !obscureText;
                                                                                          });
                                                                                        },
                                                                                      ),
                                                                                      hintText: 'Nhập mật khẩu mới...',
                                                                                      hintStyle: TextStyle(
                                                                                        color: Colors.grey,
                                                                                      ),
                                                                                      border: OutlineInputBorder(
                                                                                        borderRadius: BorderRadius
                                                                                            .circular(
                                                                                          5,
                                                                                        ),
                                                                                      ),
                                                                                      isDense: true,
                                                                                      enabledBorder: OutlineInputBorder(
                                                                                        borderRadius: BorderRadius
                                                                                            .circular(
                                                                                          5,
                                                                                        ),
                                                                                        borderSide: BorderSide(
                                                                                          color: Colors.grey,
                                                                                          width: 0.5,
                                                                                        ),
                                                                                      ),
                                                                                      focusedBorder: OutlineInputBorder(
                                                                                        borderRadius: BorderRadius
                                                                                            .circular(
                                                                                          5,
                                                                                        ),
                                                                                        borderSide: BorderSide(
                                                                                          color: Colors.blue,
                                                                                          width: 1,
                                                                                        ),
                                                                                      ),
                                                                                      contentPadding: EdgeInsets
                                                                                          .symmetric(
                                                                                        horizontal: 10,
                                                                                        vertical: 6,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Align(
                                                                                alignment: Alignment
                                                                                    .centerLeft,
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets
                                                                                      .only(left: 5, top: 10),
                                                                                  child: Text(
                                                                                    'Nhập lại mật khẩu mới: ',
                                                                                    style: TextStyle(
                                                                                      fontSize: 14,
                                                                                      fontWeight: FontWeight
                                                                                          .w500,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              SizedBox(height: 5),
                                                                              Container(
                                                                                height: 35,
                                                                                padding: EdgeInsets.symmetric(
                                                                                  horizontal: 5,
                                                                                ),
                                                                                child: SizedBox.expand(
                                                                                  child: TextField(
                                                                                    obscureText: obscureText,
                                                                                    controller: viewModel
                                                                                        .confirmNewPasswordController,
                                                                                    textAlignVertical:
                                                                                    TextAlignVertical.top,
                                                                                    keyboardType: TextInputType
                                                                                        .text,
                                                                                    style: TextStyle(
                                                                                        fontSize: 14),
                                                                                    decoration: InputDecoration(
                                                                                      suffixIcon: IconButton(
                                                                                        icon: Icon(
                                                                                          obscureText ? Icons.visibility_off : Icons.visibility,
                                                                                          size: 15,
                                                                                        ),
                                                                                        onPressed: () {
                                                                                          setState(() {
                                                                                            obscureText = !obscureText;
                                                                                          });
                                                                                        },
                                                                                      ),
                                                                                      hintText: 'Nhập lại mật khẩu mới...',
                                                                                      hintStyle: TextStyle(
                                                                                        color: Colors.grey,
                                                                                      ),
                                                                                      border: OutlineInputBorder(
                                                                                        borderRadius: BorderRadius
                                                                                            .circular(
                                                                                          5,
                                                                                        ),
                                                                                      ),
                                                                                      isDense: true,
                                                                                      enabledBorder: OutlineInputBorder(
                                                                                        borderRadius: BorderRadius
                                                                                            .circular(
                                                                                          5,
                                                                                        ),
                                                                                        borderSide: BorderSide(
                                                                                          color: Colors.grey,
                                                                                          width: 0.5,
                                                                                        ),
                                                                                      ),
                                                                                      focusedBorder: OutlineInputBorder(
                                                                                        borderRadius: BorderRadius
                                                                                            .circular(
                                                                                          5,
                                                                                        ),
                                                                                        borderSide: BorderSide(
                                                                                          color: Colors.blue,
                                                                                          width: 1,
                                                                                        ),
                                                                                      ),
                                                                                      contentPadding: EdgeInsets
                                                                                          .symmetric(
                                                                                        horizontal: 10,
                                                                                        vertical: 6,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              SizedBox(height: 10,),
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment
                                                                                    .end,
                                                                                children: [
                                                                                  TextButton(
                                                                                    onPressed: () {
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    style: TextButton
                                                                                        .styleFrom(
                                                                                      overlayColor: Colors
                                                                                          .transparent,
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
                                                                                      if (viewModel.newPasswordController.text != viewModel.confirmNewPasswordController.text) {
                                                                                        showErrorToastification(title: "Lỗi", message: "Mật khẩu nhập lại không khớp với mật khẩu mới");
                                                                                        return;
                                                                                      }
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
                                                                                      await viewModel.resetPassword(context).then((value) {
                                                                                        Navigator.pop(context);
                                                                                        if (value.success == true) {
                                                                                          Navigator.pop(context);
                                                                                        }
                                                                                      });
                                                                                    },
                                                                                    style: TextButton
                                                                                        .styleFrom(
                                                                                      backgroundColor: Color(
                                                                                          0xee65c29c),
                                                                                      foregroundColor: Colors
                                                                                          .white,
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius
                                                                                            .circular(10),
                                                                                      ),
                                                                                    ),
                                                                                    child: Text(
                                                                                      'Lưu thay đổi',
                                                                                      style: TextStyle(
                                                                                        fontWeight: FontWeight
                                                                                            .bold,
                                                                                        fontSize: 16,
                                                                                      ),
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                );
                                                              },
                                                            );
                                                          }
                                                        });
                                                      },
                                                      style: TextButton
                                                          .styleFrom(
                                                        backgroundColor: Color(
                                                            0xee65c29c),
                                                        foregroundColor: Colors
                                                            .white,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius
                                                              .circular(10),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Tiếp tục',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    )
                                                        : Container(
                                                      height: 40,
                                                      width: 90,
                                                      alignment: Alignment.center,
                                                      child: SizedBox(
                                                        height: 24,
                                                        width: 24,
                                                        child: CircularProgressIndicator(
                                                          color: Colors.blue,
                                                        ),
                                                      ),
                                                    )

                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    );
                                  },
                                );
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.white,
                                ),
                                elevation: WidgetStateProperty.all(0),
                                splashFactory: NoSplash.splashFactory,
                                shadowColor: MaterialStateProperty.all(
                                  Colors.transparent,
                                ),
                                overlayColor: WidgetStateProperty.all(
                                  Colors.transparent,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Thay đổi mật khẩu",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,

                          child: Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: ElevatedButton(
                              onPressed: () {
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
                                
                                viewModel.updateRecruiterInfo(context, viewModel.userId).then((value) => Navigator.pop(context));
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.blue,
                                ),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    side: BorderSide(color: Colors.transparent),
                                  ),
                                ),
                                elevation: WidgetStateProperty.all(0),
                                splashFactory: NoSplash.splashFactory,
                                shadowColor: MaterialStateProperty.all(
                                  Colors.transparent,
                                ),
                                overlayColor: WidgetStateProperty.all(
                                  Colors.transparent,
                                ),
                              ),
                              child: Text(
                                "Lưu thay đổi",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

Container customTextField({
  required String? hintText,
  required double height,
  required TextEditingController controller,
  TextInputType textInputType = TextInputType.multiline,
  Function(String)? change,
  List<TextInputFormatter>? format,
}) {
  return Container(
    height: height,
    padding: EdgeInsets.symmetric(horizontal: 10),
    child: SizedBox.expand(
      child: TextField(
        inputFormatters: format,
        onChanged: change,
        controller: controller,
        textAlignVertical: TextAlignVertical.top,
        keyboardType: textInputType,
        expands:
            (textInputType != TextInputType.number &&
                textInputType != TextInputType.text),
        maxLines:
            (textInputType == TextInputType.text ||
                    textInputType == TextInputType.number)
                ? 1
                : null,
        minLines: null,
        style: TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          isDense: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Colors.grey, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Colors.blue, width: 1),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        ),
      ),
    ),
  );
}
