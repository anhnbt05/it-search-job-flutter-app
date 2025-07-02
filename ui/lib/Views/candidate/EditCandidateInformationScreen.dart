import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ui/Services/auth_forgetpassword_service.dart';

import '../../Constants/color_constants.dart';
import '../../Helpers/toastification.dart';
import '../../Models/Enum.dart';
import '../../ViewModels/candidate/EditCandidateInformationViewModel.dart';
import '../../ViewModels/candidate/ProfileCandidateViewModel.dart';

class EditCandidateInformationScreen extends StatefulWidget {
  EditCandidateInformationScreen({super.key});

  @override
  State<EditCandidateInformationScreen> createState() =>
      _EditCandidateInformationScreenState();
}

class _EditCandidateInformationScreenState
    extends State<EditCandidateInformationScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<
        EditCandidateInformationViewModel,
        ProfileCandidateViewModel>(
      builder: (context, viewModel, profileViewModel, _) {
        if (profileViewModel.candidate == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
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
                leading: IconButton(
                  icon: Icon(Icons.chevron_left, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                automaticallyImplyLeading: false,
                backgroundColor: ColorConstants.appbarColor,
                centerTitle: false,
                title: Row(
                  children:[ Flexible(
                    child: Text(
                      "Chỉnh sửa hồ sơ cá nhân",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ]
                ),
              ),
                body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints
                          .maxHeight),
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
                                Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // -------- BÊN TRÁI --------
                                          Column(
                                            children: [
                                              // Avatar
                                              Container(
                                                width: 140,
                                                height: 140,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.white, width: 2),
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
                                                      : CircleAvatar(
                                                    radius: 50,
                                                    backgroundImage: NetworkImage(profileViewModel.candidate?.AvatarUrl ?? ""),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),

                                              ElevatedButton(
                                                onPressed: viewModel.pickImage,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  elevation: 0,
                                                  side: const BorderSide(color: Colors.grey),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: const [
                                                    Icon(Icons.camera_alt, size: 16, color: Colors.grey),
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
                                            ],
                                          ),

                                          // -------- BÊN PHẢI --------
                                          ElevatedButton.icon(
                                            onPressed: viewModel.pickCVFile,
                                            icon: Icon(
                                              viewModel.CVFile != null ? Icons.check_circle : Icons.picture_as_pdf,
                                              size: 18,
                                              color: viewModel.CVFile != null ? Colors.green : Colors.grey,
                                            ),
                                            label: Text(
                                              viewModel.CVFile != null
                                                  ? "Đã chọn CV"
                                                  : "Tải CV",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: viewModel.CVFile != null ? Colors.green : Colors.grey,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              elevation: 0,
                                              side: BorderSide(
                                                color: viewModel.CVFile != null ? Colors.green : Colors.grey,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
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
                                                " ${profileViewModel.candidate!
                                                    .Email}",
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
                                        top: 7,
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
                                      controller: viewModel
                                          .phoneNumberController,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 7,
                                        top: 7,
                                        bottom: 5,
                                      ),
                                      child: Text(
                                        "Giới thiệu:",
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
                                      controller: viewModel.bioController,
                                    ),

                                    Padding(
                                      padding:  const EdgeInsets.only(left: 7, top: 7, bottom: 5),
                                      child: Row(
                                        children: [
                                           Text(
                                            "Trình độ:",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton2<eLevel>(
                                                isDense: true,
                                                hint: Text(
                                                  "Chọn trình độ",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.normal,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                value: viewModel.levelSelected,
                                                items: eLevel.values.map((level) {
                                                  return DropdownMenuItem<eLevel>(
                                                    value: level,
                                                    child: Text(
                                                    viewModel.getLevelName(level),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.normal,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (eLevel? newValue) {
                                                  viewModel.setLevelSelected(newValue);
                                                },
                                                buttonStyleData: ButtonStyleData(
                                                  width: MediaQuery.of(context).size.width - 185,
                                                  height: 40,
                                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: viewModel.levelBorderColor),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                                dropdownStyleData: DropdownStyleData(
                                                  width: MediaQuery.of(context).size.width - 185,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(8),
                                                      color: Colors.white
                                                  ),
                                                ),
                                                iconStyleData: IconStyleData(
                                                  icon: Icon(Icons.arrow_drop_down),
                                                ),
                                                onMenuStateChange: (isOpen) {
                                                  if (isOpen) {
                                                    viewModel.setLevelBorderColor(Colors.blue);
                                                  } else {
                                                    if (viewModel.levelSelected != null) {
                                                      viewModel.setLevelBorderColor(Colors.grey.shade400);
                                                    } else {
                                                      viewModel.setLevelBorderColor(Colors.red);
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 7,
                                        top: 7,
                                        bottom: 5,
                                      ),
                                      child: Text(
                                        "Chứng chỉ:",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: viewModel.certificationControllers.length,
                                      itemBuilder: (context, index) {
                                        return Row(
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  child: customTextField(
                                                    hintText: "Nhập chứng chỉ...",
                                                    height: 40,
                                                    textInputType: TextInputType.text,
                                                    controller: viewModel.certificationControllers[index],
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.close, size: 18, color: Colors.black),
                                                onPressed: () => viewModel.removeCertification(index),
                                                style: IconButton.styleFrom(
                                                  backgroundColor: Colors.red[100],
                                                  side: BorderSide(color: Colors.grey, width: 1),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8, right: 8, top: 0, bottom: 8),
                                        child: ElevatedButton.icon(
                                          onPressed: viewModel.addCertification,
                                          icon: Icon(Icons.add, size: 18, color: Colors.grey),
                                          label: Text(
                                            "Thêm chứng chỉ",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            elevation: 0,
                                            side: BorderSide(color: Colors.grey),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Thêm padding bên trong button
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
                              await AuthForgetPasswordService().forgotPassword(profileViewModel.candidate!.Email);
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  bool isSendingOTP = false;

                                  return StatefulBuilder(
                                      builder: (context, setState) {
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
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        barrierColor: Colors.black.withOpacity(
                                            0.5),
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.blue,
                                            ),
                                          );
                                        },
                                      );

                                     await viewModel.updateCandidateInfo(
                                          context);
                                      final profileViewModel = Provider.of<ProfileCandidateViewModel>(context, listen: false);
                                      await profileViewModel.fetchCandidateInfo(context: context);
                                      Navigator.of(context, rootNavigator: true).pop();
                                      Navigator.pop(context);
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(
                                        Colors.blue,
                                      ),
                                      shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          side: BorderSide(
                                              color: Colors.transparent),
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
          ),
        );
      },
    );
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
}
