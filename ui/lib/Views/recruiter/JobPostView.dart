import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ui/ViewModels/recruiter/ProfileViewModel.dart';

import '../../Helpers/helpers.dart';
import '../../Models/Enum.dart';
import '../../ViewModels/recruiter/JobPostViewModel.dart';

Widget PostJobScreen(BuildContext context) {
  var viewModel = Provider.of<JobPostViewModel>(context);
  var recruiterVM = Provider.of<RecruiterProfileViewModel>(context);
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
      FocusScope.of(context).unfocus();
    },
    child: Container(
      color: Colors.white,
      child: (recruiterVM.recruiterInfo == null)
          ? Center(child: CircularProgressIndicator(color: Colors.blue),)
          : SingleChildScrollView(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Container(
                    height: 80,
                    width: 80,
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: (recruiterVM.recruiterInfo?.Company.LogoUrl != null)
                        ? Image.network(
                      recruiterVM.recruiterInfo!.Company.LogoUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.blue),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                    )
                        : Center(
                      child: Icon(Icons.business, color: Colors.grey),
                    ),
                  )
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 10, right: 5),
                        child: Text(recruiterVM.recruiterInfo!.Company.Name,
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            height: 1.2,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.person_outline, size: 15),
                            SizedBox(width: 5),
                            Text(recruiterVM.recruiterInfo!.FullName,
                              style: TextStyle(fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            titleinJD(title: 'Tên công việc', isCompulsory: true),
            customTextField(
              hintText: 'Nhập tên công việc...',
              height: 40,
              textInputType: TextInputType.text,
              controller: viewModel.nameText,
              isCompulsory: true,
              context: context,
            ),

            titleinJD(title: 'Thông tin mô tả', isCompulsory: false),
            customTextField(
              hintText: 'Chúng tôi đang tìm kiếm...',
              height: 120,
              controller: viewModel.descriptionText,
              isCompulsory: false,
              context: context
            ),

            Row(
              children: [
                titleinJD(title: 'Số lượng tuyển', isCompulsory: true),
                SizedBox(
                  width: 85,
                  child: Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: customTextField(
                      hintText: '',
                      height: 40,
                      textInputType: TextInputType.number,
                      controller: viewModel.vacancyText,
                      isCompulsory: true,
                      format: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      context: context
                    ),
                  ),
                ),
                Text(
                  'người',
                )
              ],
            ),

            Padding(padding: EdgeInsets.only(top: 5),
              child:
              Row(
                children: [
                  titleinJD(title: 'Hình thức làm việc', isCompulsory: true),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10),
                    child:
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<eJobType>(
                        isDense: true,
                        hint: Text("Chọn hình thức", style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                        ),),
                        value: viewModel.jobTypeSelected,
                        items: viewModel.jobType.map((jobType) {
                          return DropdownMenuItem<eJobType>(
                            value: eJobType.values.firstWhere(
                                    (e) => e.toString().split('.').last == jobType.keys.first
                            ),
                            child: Text(jobType.toString().split(":").last.split("}").first,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal
                              ),),
                          );
                        }).toList(),
                        onChanged: (eJobType? newValue) {
                          viewModel.setJobTypeSelected(newValue);
                        },
                        buttonStyleData: ButtonStyleData(
                          width: MediaQuery.of(context).size.width - 172,
                          height: 40,
                          padding: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: viewModel.jobTypeBorderColor
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          width: MediaQuery.of(context).size.width - 170,
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
                            viewModel.setJobTypeBorderColor(Colors.blue);
                          } else {
                            if (viewModel.check == false || viewModel.jobTypeSelected != null)
                              viewModel.setJobTypeBorderColor(Colors.grey.shade400);
                            else viewModel.setJobTypeBorderColor(Colors.red);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(padding: EdgeInsets.only(top: 5),
              child:
              Row(
                children: [
                  titleinJD(title: 'Cấp độ chuyên môn', isCompulsory: true),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10),
                    child:
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<eLevel>(
                        isDense: true,
                        hint: Text("Chọn cấp độ", style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                        ),
                        ),
                        value: viewModel.jobLevelSelected,
                        items: viewModel.jobLevel.map((jobLevel) {
                          return DropdownMenuItem<eLevel>(
                            value: eLevel.values.firstWhere(
                                    (e) => e.toString().split('.').last == jobLevel.keys.first
                            ),
                            child: Text(jobLevel.toString().split(":").last.split("}").first,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),),
                          );
                        }).toList(),
                        onChanged: (eLevel? newValue) {
                          viewModel.setJobLevelSelected(newValue);
                        },
                        buttonStyleData: ButtonStyleData(
                          width: MediaQuery.of(context).size.width - 185,
                          height: 40,
                          padding: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: viewModel.jobLevelBorderColor
                            ),
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
                            viewModel.setJobLevelBorderColor(Colors.blue);
                          } else {
                            if (viewModel.check == false || viewModel.jobLevelSelected != null)
                              viewModel.setJobLevelBorderColor(Colors.grey.shade400);
                            else viewModel.setJobLevelBorderColor(Colors.red);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Row(
              children: [
                titleinJD(title: 'Lĩnh vực:', isCompulsory: true),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 5, right: 10),
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: viewModel.jobCategorySelectedList.length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: EdgeInsets.only(left: 13),
                          height: 50,
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                viewModel.jobCategorySelectedList[index],
                                style: TextStyle(fontSize: 14),
                              ),
                              IconButton(
                                onPressed: () {viewModel.deleteSelectedJobCategory(index);},
                                icon: Icon(Icons.close, size: 20, color: Colors.grey.shade500,),
                                constraints: BoxConstraints(
                                  minWidth: 30,
                                  minHeight: 30,
                                ),
                                padding: EdgeInsets.zero,
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isDense: true,
                  hint: Text("Chọn lĩnh vực công việc", style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                  ),
                  value: viewModel.jobCategorySelected,
                  items: (viewModel.categoriesList ?? []).where((e) {
                    final map = Map<String, String>.from(e);
                    return (viewModel.jobCategoryIDList ?? []).contains(map.keys.first);
                  }
                  ).map((item) {
                    final map = Map<String, String>.from(item);
                    return DropdownMenuItem<String>(
                      value: map.keys.first,
                      child: Text(map.values.first, style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    viewModel.setSelectedJobCategory(value);
                  },
                  buttonStyleData: ButtonStyleData(
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    padding: EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: viewModel.jobCategoryBorderColor
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 300,
                    width: MediaQuery.of(context).size.width,
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
                      viewModel.setJobCategoryBorderColor(Colors.blue);
                    } else {
                      if (viewModel.check == false || viewModel.jobCategorySelectedList.isNotEmpty) {
                        viewModel.setJobCategoryBorderColor(Colors.grey.shade400);
                      } else {
                        viewModel.setJobCategoryBorderColor(Colors.red);
                      }
                    }
                  },
                  dropdownSearchData: DropdownSearchData(
                    searchController: viewModel.textEditingController,
                    searchInnerWidgetHeight: 50,
                    searchInnerWidget: Container(
                      height: 50,
                      padding: const EdgeInsets.only(
                        top: 8,
                        bottom: 4,
                        right: 8,
                        left: 8,
                      ),
                      child: TextFormField(
                        expands: true,
                        maxLines: null,
                        controller: viewModel.textEditingController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          hintText: 'Tìm kiếm...',
                          hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.blue.shade900, width: 1),
                          ),
                        ),
                      ),
                    ),
                    searchMatchFn: (DropdownMenuItem<String> item, String searchValue) {
                      final search = removeVietnameseAccentsRegex(searchValue.toLowerCase().trim());
                      final String itemText = item.child is Text
                          ? (item.child as Text).data?.toLowerCase() ?? ''
                          : '';
                      final normalizedItemText = removeVietnameseAccentsRegex(itemText);
                      return normalizedItemText.contains(search);
                    },
                  ),
                ),
              ),
            ),


            titleinJD(title: 'Nơi làm việc', isCompulsory: false),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                        textAlign: TextAlign.justify,
                        TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: "${recruiterVM.recruiterInfo!.CompanyLocations.BranchName}: ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: recruiterVM.recruiterInfo!.CompanyLocations.Address,
                              style: TextStyle(fontSize: 14,),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 5,),
            titleinJD(title: 'Mô tả công việc', isCompulsory: true),
            customTextField(
              hintText: 'Nhập mô tả công việc...',
              height: 350,
              controller: viewModel.jobDescriptionsText,
              isCompulsory: true,
              context: context
            ),

            SizedBox(height: 10,),
            titleinJD(title: 'Yêu cầu công việc', isCompulsory: true),
            customTextField(
              hintText: 'Nhập yêu cầu công việc...',
              height: 300,
              controller: viewModel.jobRequirementsText,
              isCompulsory: true,
              context: context
            ),

            SizedBox(height: 10,),
            titleinJD(title: 'Phúc lợi', isCompulsory: true),
            customTextField(
              hintText: 'Nhập phúc lợi...',
              height: 250,
              controller: viewModel.jobBenefitsText,
              isCompulsory: true,
              context: context
            ),

            SizedBox(height: 10,),
            titleinJD(title: 'Thời gian làm việc', isCompulsory: true),
            customTextField(
              hintText: 'Nhập thời gian làm việc...',
              height: 120,
              controller: viewModel.workingTimeText,
              isCompulsory: true,
              context: context
            ),

            SizedBox(height: 5,),
            Padding(padding: EdgeInsets.only(top: 5),
              child:
              Row(
                children: [
                  titleinJD(title: 'Lương', isCompulsory: true),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10),
                    child:
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isDense: true,
                        hint: Text("Chọn hình thức lương", style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                        ),),
                        value: viewModel.salaryTypeSelected,
                        items: [
                          {"ID": "negotiable", "Name": "Thỏa thuận"},
                          {"ID": "fixed", "Name": "Cố định"},
                          {"ID": "upto", "Name": "Tối đa"},
                          {"ID": "range", "Name": "Khoảng"},
                        ].map((item) {
                          return DropdownMenuItem<String>(
                            value: item["ID"],
                            child: Text(item["Name"]!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          viewModel.setSalaryTypeSelected(newValue);
                        },
                        buttonStyleData: ButtonStyleData(
                          width: MediaQuery.of(context).size.width - 84,
                          height: 40,
                          padding: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: viewModel.salaryTypeBorderColor
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          width: 300,
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
                            viewModel.setSalaryTypeBorderColor(Colors.blue);
                          } else {
                            if (viewModel.check == false || viewModel.salaryTypeSelected == null) {
                              viewModel.setSalaryTypeBorderColor(Colors.red);
                            } else {
                              viewModel.setSalaryTypeBorderColor(Colors.grey.shade400);
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            salaryInput(viewModel.salaryTypeSelected, viewModel, context) ?? SizedBox.shrink(),

            Row(
              children: [
                titleinJD(title: 'Hạn nộp hồ sơ', isCompulsory: true),
                SizedBox(width: 10,),
                Container(
                  width: MediaQuery.of(context).size.width - 200,
                  height: 35,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: viewModel.expiredDateBorderColor, width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  alignment: Alignment.bottomCenter,
                  child: Center(
                    child: Text(
                      (viewModel.selectedDate == null)
                          ? 'Chưa chọn ngày'
                          : "${viewModel.selectedDate!
                          .day}/${viewModel.selectedDate!
                          .month}/${viewModel.selectedDate!.year}",
                      style: TextStyle(
                        fontSize: 15,
                        color: (viewModel.selectedDate == null) ? Colors.grey : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Builder(
                  builder: (context) => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      shape: CircleBorder(
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        locale: Locale('vi', 'VN'),
                        context: context,
                        initialDate: viewModel.selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2100),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: Theme.of(context).colorScheme.copyWith(
                                primary: Colors.blue,
                                onPrimary: Colors.white,
                                surface: Colors.white,
                                onSurface: Colors.black,
                              ),
                              datePickerTheme: DatePickerThemeData(
                                backgroundColor: Colors.white,
                                headerBackgroundColor: Colors.blue,
                                headerForegroundColor: Colors.white,
                                weekdayStyle: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                                dayStyle: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                                todayBackgroundColor: MaterialStateProperty.all(
                                  Colors.blue.withOpacity(0.1),
                                ),
                                todayForegroundColor: MaterialStateProperty.all(
                                  Colors.blue.shade600,
                                ),
                                dayBackgroundColor: MaterialStateProperty.resolveWith((states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return Colors.blue;
                                  }
                                  return null;
                                }),
                                dayForegroundColor: MaterialStateProperty.resolveWith((states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return Colors.white;
                                  }
                                  return Colors.black87;
                                }),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                dayShape: MaterialStateProperty.all(
                                  CircleBorder(),
                                ),
                                cancelButtonStyle: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all(
                                    Colors.grey,
                                  ),
                                )
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (pickedDate != null) {
                        viewModel.setSelectedDate(pickedDate);
                      }
                    },
                    child: Center(
                      child: Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                )
              ],
            ),

            Row(
              children: [
                Checkbox(
                  value: viewModel.isAccept,
                  onChanged: (_) {viewModel.setIsAccept();},
                  activeColor: Colors.blue,
                  side: BorderSide(
                    color: Colors.grey,
                    width: 2
                  )
                ),

                SizedBox(
                  width: MediaQuery.of(context).size.width - 190,
                  child:
                  Text(
                    'Tôi đồng ý với chính sách & quy định đăng bài đối với nhà tuyển dụng',
                    style: TextStyle(
                      fontSize: 9,
                    ),
                    softWrap: true,
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 10), child:

                Builder(
                  builder: (BuildContext dialogContext) {
                    return ElevatedButton(
                      onPressed: () async {
                        showDialog(
                          context: dialogContext,
                          barrierDismissible: false,
                          barrierColor: Colors.black.withOpacity(0.5),
                          builder: (BuildContext context) {
                            return const Center(
                              child: CircularProgressIndicator(color: Colors.blue),
                            );
                          },
                        );
                        await viewModel.post(dialogContext);
                        Navigator.of(dialogContext, rootNavigator: true).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        elevation: 0,
                        minimumSize: const Size(120, 35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Đăng bài",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                )

                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget? salaryInput(String? option, JobPostViewModel jobPostProvider, BuildContext context) {
  var viewModel = Provider.of<JobPostViewModel>(context);
  if (option == null) return null;
  switch (option) {
    case 'negotiable': return null;
    case 'fixed':
    case 'upto':
      return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width - 203,
          child: Padding(
            padding: EdgeInsets.only(top: 5),
            child: customTextField(
              hintText: 'Nhập số tiền...',
              format: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              height: 40,
              textInputType: TextInputType.number,
              controller: viewModel.salaryNumber1,
              isCompulsory: true,
              context: context
            ),
          ),
        ),

        salaryUnitComboBox(jobPostProvider)
      ],
    );
    case 'range':
      return Column(
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text('Từ'),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 33,
                child: Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: customTextField(
                    hintText: 'Tối thiểu...',
                    height: 40,
                    textInputType: TextInputType.number,
                    format: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    controller: viewModel.salaryNumber1,
                    isCompulsory: true,
                    context: context
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text('Đến'),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 33,
                child: Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: customTextField(
                    hintText: 'Tối đa...',
                    height: 40,
                    format: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    textInputType: TextInputType.number,
                    controller: viewModel.salaryNumber2,
                    isCompulsory: true,
                    context: context
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: salaryUnitComboBox(jobPostProvider),
            ),
          ),
        ],
      );
  }
  return null;
}

Padding salaryUnitComboBox(JobPostViewModel jobPostProvider) {
  return Padding(padding: EdgeInsets.symmetric(horizontal: 0),
    child:
    DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isDense: true,
        value: jobPostProvider.salaryUnitSelected,
        items: [
          "triệu VNĐ/tháng",
          "VNĐ/tháng",
          "VNĐ/tuần",
          "VNĐ/ngày",
          "USD/tháng",
          "USD/tuần",
          "USD/ngày",
        ].map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
          );
        }).toList(),
        onChanged: (String? newValue) {
          jobPostProvider.setSalaryUnitSelected(newValue!);
        },
        buttonStyleData: ButtonStyleData(
          width: 192,
          height: 40,
          padding: EdgeInsets.symmetric(
              horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
                color: jobPostProvider.salaryUnitBorderColor
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          width: 192,
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
            jobPostProvider.setSalaryUnitBorderColor(Colors.blue);
          } else {
            jobPostProvider.setSalaryUnitBorderColor(Colors.grey.shade400);
          }
        },
      ),
    ),
  );
}

Align titleinJD({required String title, required bool isCompulsory}) {
  return Align(
    alignment: Alignment.topLeft,
    child: Padding(
      padding: EdgeInsets.only(top: 5, left: 10, bottom: 3),
      child: RichText(
        text: TextSpan(
            text: title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500, color: Colors.black,
              fontFamily:'Poppins',
            ),
            children: [
              (isCompulsory == true) ?
              TextSpan(
                  text: '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w100,
                  )
              ) : TextSpan(text: ''),
              TextSpan(
                  text: ':',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  )
              )
            ]
        ),
      ),
    ),
  );
}

Container customTextField({required String? hintText,required double height, required TextEditingController controller,TextInputType textInputType = TextInputType.multiline, Function(String)? change, required BuildContext context, required bool isCompulsory, List<TextInputFormatter>? format}) {
  var viewModel = Provider.of<JobPostViewModel>(context);
  var isValid = (viewModel.check == false || isCompulsory == false || (isCompulsory == true && controller.text.isNotEmpty));
  return Container(
    height: height,
    padding: EdgeInsets.symmetric(horizontal: 10),
    child :SizedBox.expand(
      child: TextField(
        inputFormatters: format,
        onChanged: change,
          controller: controller,
          textAlignVertical: TextAlignVertical.top,
          keyboardType: textInputType,
          expands: (textInputType != TextInputType.number && textInputType != TextInputType.text),
          maxLines: (textInputType == TextInputType.text || textInputType == TextInputType.number) ? 1 : null,
          minLines: null,
          style: TextStyle(
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            isDense: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                  color: isValid
                      ? Colors.grey
                      : Colors.red,
                  width: isValid
                      ? 0.5
                      : 1
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: Colors.blue, width: 1),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          )
      ),
    ),
  );

}
