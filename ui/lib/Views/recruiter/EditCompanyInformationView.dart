import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ui/ViewModels/recruiter/EditRecruiterInformationViewModel.dart';
import 'package:ui/Views/recruiter/EditRecruiterInformationScreen.dart';

import '../../Constants/color_constants.dart';
import '../../Helpers/toastification.dart';
import '../../ViewModels/recruiter/EditCompanyInformationViewModel.dart';
import '../../ViewModels/recruiter/ProfileViewModel.dart';

class EditCompanyInformationScreen extends StatefulWidget {
  EditCompanyInformationScreen({super.key});

  @override
  State<EditCompanyInformationScreen> createState() =>
      _EditCompanyInformationScreenState();
}

class _EditCompanyInformationScreenState
    extends State<EditCompanyInformationScreen> {
  @override
  Widget build(BuildContext context) {
    var viewModel = Provider.of<EditCompanyInformationViewModel>(context);
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
            leading: IconButton(
              icon: Icon(Icons.chevron_left, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
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
                            Container(height: 120, color: Color(0x3fBBD6FF)),
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
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child:
                                          profileViewModel
                                                      .recruiterInfo!
                                                      .Company
                                                      .LogoUrl !=
                                                  null
                                              ? ClipOval(
                                                child: Image.network(
                                                  profileViewModel
                                                      .recruiterInfo!
                                                      .Company
                                                      .LogoUrl!,
                                                  fit: BoxFit.cover,
                                                  width: 140,
                                                  height: 140,
                                                ),
                                              )
                                              : CircularProgressIndicator(
                                                color: Colors.blue,
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
                                    "Tên công ty:",
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
                                  controller: viewModel.nameController,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 7,
                                    top: 7,
                                    bottom: 5,
                                  ),
                                  child: Text(
                                    "Địa chỉ trang web:",
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
                                  controller: viewModel.websiteURLController,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 7,
                                    top: 7,
                                    bottom: 5,
                                  ),
                                  child: Text(
                                    "Mô tả:",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                customTextField(
                                  hintText: "",
                                  height: 120,
                                  textInputType: TextInputType.multiline,
                                  controller: viewModel.descriptionController,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 7,
                                        top: 10,
                                        bottom: 5,
                                      ),
                                      child: Text(
                                        "Danh sách chi nhánh:",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        showAddBranchDialog(context);
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                              Colors.white,
                                            ),
                                        shape: WidgetStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            side: BorderSide(
                                              color: Colors.transparent,
                                            ),
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
                                        padding: WidgetStateProperty.all(
                                          EdgeInsets.zero,
                                        ),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        minimumSize: WidgetStateProperty.all(
                                          Size(0, 0),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Row(
                                          children: [
                                            Text(
                                              "Thêm chi nhánh",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w300,
                                                color:
                                                    ColorConstants.subTextColor,
                                              ),
                                            ),
                                            Icon(
                                              Icons
                                                  .keyboard_double_arrow_right_outlined,
                                              color:
                                                  ColorConstants.subTextColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 7),
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: profileViewModel.branches.length,
                                    itemBuilder: (context, index) {
                                      return branchItems(context, index);
                                    },
                                  ),
                                ),
                                SizedBox(height: 10),
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
                                await viewModel.editCompany(context);
                                Navigator.pop(context);
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

  Future showAddBranchDialog(BuildContext context) {
    var viewModel = Provider.of<EditCompanyInformationViewModel>(
      context,
      listen: false,
    );
    String? _provinceSelected;
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (conext, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              insetPadding: EdgeInsets.all(9),
              child: Container(
                width: MediaQuery.of(context).size.width - 20,
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Thêm chi nhánh',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, top: 5),
                        child: Text(
                          'Tên chi nhánh:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 45,
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: SizedBox.expand(
                        child: TextField(
                          controller: viewModel.branchNameController,
                          textAlignVertical: TextAlignVertical.top,
                          keyboardType: TextInputType.text,
                          style: TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Nhập tên chi nhánh',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            isDense: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, top: 2),
                        child: Text(
                          'Tỉnh/Thành phố:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isDense: true,
                        hint: Text(
                          "Chọn tỉnh thành đặt chi nhánh",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey,
                          ),
                        ),
                        value: _provinceSelected,
                        items:
                            (viewModel.provinceList).map((item) {
                              return DropdownMenuItem<String>(
                                value: item.id,
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (String? value) {
                          viewModel.setSelectedProvince(value);
                          setState(() {
                            _provinceSelected = value;
                          });
                        },
                        buttonStyleData: ButtonStyleData(
                          width: MediaQuery.of(context).size.width - 50,
                          height: 36,
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(width: 0.5, color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 250,
                          width: MediaQuery.of(context).size.width - 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                        ),
                        iconStyleData: IconStyleData(
                          icon: Icon(Icons.arrow_drop_down),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, top: 12),
                        child: Text(
                          'Địa chỉ chi tiết:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 90,
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: SizedBox.expand(
                        child: TextField(
                          maxLines: null,
                          expands: true,
                          controller: viewModel.branchAddressController,
                          textAlignVertical: TextAlignVertical.top,
                          keyboardType: TextInputType.multiline,
                          style: TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Nhập địa chỉ chi tiết',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            isDense: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
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
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            viewModel.clear();
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            overlayColor: Colors.transparent,
                          ),
                          child: Text(
                            'Hủy',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                        Builder(
                          builder: (dialogContext) {
                            return TextButton(
                              onPressed: () async {
                                showDialog(
                                  context: dialogContext,
                                  barrierColor: Colors.black.withOpacity(0.5),
                                  barrierDismissible: false,
                                  builder: (_) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.blue,
                                      ),
                                    );
                                  },
                                );

                                var success = await viewModel.addBranch(context);
                                if (success) {
                                  setState(() {
                                    _provinceSelected = null;
                                  });
                                }
                                Navigator.pop(dialogContext);
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xee65c29c),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Thêm',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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

Widget branchItems(BuildContext context, int index) {
  var viewModel = Provider.of<RecruiterProfileViewModel>(context);
  return Container(
    width: 200,
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 5,
          offset: Offset(5, 5),
        ),
      ],
      borderRadius: BorderRadius.circular(5),
      color: Colors.white,
    ),
    margin: EdgeInsets.only(left: 5, right: 5, bottom: 5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(3),
          child: Text(
            viewModel.branches[index]!.BranchName!,
            style: TextStyle(
              color: ColorConstants.subTextColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
          child: Text(
            viewModel.branches[index]!.Address!,
            style: TextStyle(fontSize: 11),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
