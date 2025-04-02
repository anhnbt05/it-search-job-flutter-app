import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/helpers.dart';
import 'package:ui/providers.dart';
import 'package:ui/model.dart';

List<Widget> pageView_recruiter(BuildContext context) {
  return [
    ManagementScreen(),
    CandidatesAppliedScreen(),
    PostJobScreen(context),
    NotificationsScreen(),
    ProfileScreen(),
  ];
}

Widget ManagementScreen() {
  return Container(
    color: Colors.amberAccent.shade100,
    child: Center(
      child: Text("Quản lý", style: TextStyle(fontSize: 24)),
    ),
  );
}

Widget CandidatesAppliedScreen() {
  // TODO: Modify section below
  return Container(
    color: Colors.blue.shade100, // Màu nền nhạt
    child: Center(
      child: Text(
        "Danh sách ứng viên đã ứng tuyển",
        style: TextStyle(fontSize: 24),
      ),
    ),
  );
}

Widget PostJobScreen(BuildContext context) {
  var jobPostProvider = Provider.of<JobPostProvider>(context);

  return Container(
    color: Colors.white,
    child: SingleChildScrollView(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10, right: 5),
                      child: Text(
                        'Công ty TNHH Phát triển Công nghệ Thông tin và Truyền thông Việt Nam',
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 19,
                          fontFamily: 'Anton',
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
                          Text(
                            'Hồ Văn Tên',
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
          customTextField(hintText: 'Nhập tên công việc...', height: 40, textInputType: TextInputType.text),

          titleinJD(title: 'Thông tin mô tả', isCompulsory: false),
          customTextField(hintText: 'Chúng tôi đang tìm kiếm...', height: 120),

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
                    textInputType: TextInputType.text,
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
                    child: DropdownButton2<String>(
                      isDense: true,
                      hint: Text("Chọn hình thức", style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),),
                      value: jobPostProvider.jobTypeSelected,
                      items: jobType.map((jobType) {
                        return DropdownMenuItem<String>(
                          value: jobType["key"],
                          child: Text(jobType["value"]!,
                            style: TextStyle(
                              fontSize: 14,
                            ),),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        jobPostProvider.setJobTypeSelected(newValue);
                      },
                      buttonStyleData: ButtonStyleData(
                        width: 180,
                        height: 40,
                        padding: EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: jobPostProvider.jobTypeBorderColor
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      dropdownStyleData: DropdownStyleData(
                        width: 180,
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
                          jobPostProvider.setJobTypeBorderColor(Colors.blue);
                        } else {
                          jobPostProvider.setJobTypeBorderColor(Colors.grey.shade400);
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
                    child: DropdownButton2<String>(
                      isDense: true,
                      hint: Text("Chọn cấp độ", style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      ),
                      value: jobPostProvider.jobLevelSelected,
                      items: jobLevel.map((jobLevel) {
                        return DropdownMenuItem<String>(
                          value: jobLevel["key"],
                          child: Text(jobLevel["value"]!,
                            style: TextStyle(
                              fontSize: 14,
                            ),),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        jobPostProvider.setJobLevelSelected(newValue);
                      },
                      buttonStyleData: ButtonStyleData(
                        width: 180,
                        height: 40,
                        padding: EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: jobPostProvider.jobLevelBorderColor
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      dropdownStyleData: DropdownStyleData(
                        width: 180,
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
                          jobPostProvider.setJobLevelBorderColor(Colors.blue);
                        } else {
                          jobPostProvider.setJobLevelBorderColor(Colors.grey.shade400);
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
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: jobPostProvider.jobCategorySelectedList.length,
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
                            jobPostProvider.jobCategorySelectedList[index],
                            style: TextStyle(fontSize: 14),
                          ),

                          IconButton(
                            onPressed: () {jobPostProvider.deleteSelectedJobCategory(index);},
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
                  color: Colors.grey,
                ),
                ),
                value: jobPostProvider.jobCategorySelected,
                items: jobCategory.where((e) => ((jobPostProvider.jobCategoryList ?? [])).contains(e['key'])).map((item) {
                  return DropdownMenuItem<String>(
                    value: item["key"],
                    child: Text(item["value"]!, style: TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (String? value) {
                  jobPostProvider.setSelectedJobCategory(value);
                },
                buttonStyleData: ButtonStyleData(
                  width: MediaQuery.of(context).size.width,
                  height: 40,
                  padding: EdgeInsets.symmetric(
                      horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: jobPostProvider.jobCategoryBorderColor
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
                    jobPostProvider.setJobCategoryBorderColor(Colors.blue);
                  } else {
                    jobPostProvider.setJobCategoryBorderColor(Colors.grey.shade400);
                  }
                },
                dropdownSearchData: DropdownSearchData(
                  searchController: jobPostProvider.textEditingController,
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
                      controller: jobPostProvider.textEditingController,
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
                  searchMatchFn: (item, searchValue) {
                    return removeVietnameseAccentsRegex(jobCategory[jobCategory.indexWhere((e) => e['key'] == item.value)]['value']!).toString().toLowerCase().trim().contains(removeVietnameseAccentsRegex(searchValue).toLowerCase().trim());
                  },
                ),
              ),
            ),
          ),


        titleinJD(title: 'Nơi làm việc', isCompulsory: true),
          Column(
            children: List.generate(locations.length, (index) {
              return CheckboxListTile(
                title: Text(
                  locations[index],
                  style: TextStyle(
                    fontSize: 13,
                  ),),
                value: jobPostProvider.selectedLocations[index],
                onChanged: (bool? value) {
                  jobPostProvider.setLocationSelected(index, value);
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.blue,
              );
            }),
          ),

          titleinJD(title: 'Mô tả công việc', isCompulsory: true),
          customTextField(hintText: 'Nhập mô tả công việc...', height: 350),

          titleinJD(title: 'Yêu cầu công việc', isCompulsory: true),
          customTextField(hintText: 'Nhập yêu cầu công việc...', height: 300),

          titleinJD(title: 'Phúc lợi', isCompulsory: true),
          customTextField(hintText: 'Nhập phúc lợi...', height: 250),

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
                        color: Colors.grey,
                      ),),
                      value: jobPostProvider.salaryTypeSelected,
                      items: [
                        {"ID": "negotiable", "Name": "Thỏa thuận"},
                        {"ID": "fixed", "Name": "Cố định"},
                        {"ID": "upto", "Name": "Tối đa"},
                        {"ID": "range", "Name": "Khoảng"},
                      ].map((item) {
                        return DropdownMenuItem<String>(
                          value: item["ID"],
                          child: Text(item["Name"]!, style: TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        jobPostProvider.setSalaryTypeSelected(newValue);
                      },
                      buttonStyleData: ButtonStyleData(
                        width: 300,
                        height: 40,
                        padding: EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: jobPostProvider.salaryTypeBorderColor
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
                          jobPostProvider.setSalaryTypeBorderColor(Colors.blue);
                        } else {
                          jobPostProvider.setSalaryTypeBorderColor(Colors.grey.shade400);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          salaryInput(jobPostProvider.salaryTypeSelected, jobPostProvider) ?? SizedBox.shrink(),

          Row(
            children: [
              titleinJD(title: 'Hạn nộp hồ sơ', isCompulsory: true),
              SizedBox(width: 10,),
              Container(
                width: 170,
                height: 35,
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 0.5),
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.bottomCenter,
                child: Center(
                  child: Text(
                    (jobPostProvider.selectedDate == null)
                        ? 'Chưa chọn ngày'
                        : "${jobPostProvider.selectedDate!
                        .day}/${jobPostProvider.selectedDate!
                        .month}/${jobPostProvider.selectedDate!.year}",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(width: 10,),
              Builder(
                builder: (context) =>
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          alignment: Alignment.center,
                          backgroundColor: Color(0xE9E0F7FF),
                          elevation: 0,
                          shape: CircleBorder(
                            side: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                          fixedSize: Size(40, 40),
                          side: BorderSide(
                            color: Colors.grey,
                            width: .5,
                          ),
                        ),
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            locale: Locale('vi', 'VN'),
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2100),
                          );

                          if (pickedDate != null) {
                            jobPostProvider.setSelectedDate(pickedDate);
                          }
                        },
                        child: Icon(
                          Icons.calendar_month_outlined, color: Colors.black,
                          size: 20,
                        )
                    ),
              ),
            ],
          ),

          Row(
            children: [
              Checkbox(
                value: jobPostProvider.isAccept,
                onChanged: (_) {jobPostProvider.setIsAccept();},
                activeColor: Colors.blue,
              ),

              SizedBox(
                width: 200,
                child:
              Text(
                'Tôi đồng ý với chính sách & quy định đăng bài đối với nhà tuyển dụng',
                style: TextStyle(
                  fontSize: 9,
                ),
                maxLines: 2,
                softWrap: true,
              ),
              ),
              Padding(padding: EdgeInsets.only(left: 5), child:
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xE9E0F7FF),
                  elevation: 0,
                  minimumSize: Size(120, 35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(
                    color: Colors.blue,
                    width: 1,
                  ),
                ),
                child: Text(
                  "Đăng bài",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget? salaryInput(String? option, JobPostProvider jobPostProvider) {
  if (option == null) return null;
  switch (option) {
    case 'negotiable': return null;
    case 'fixed':
    case 'upto': return Row(
      children: [
        SizedBox(
          width: 180,
          child: Padding(
            padding: EdgeInsets.only(top: 5),
            child: customTextField(
              hintText: 'Nhập số tiền...',
              height: 40,
              textInputType: TextInputType.text,
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
                width: 160,
                child: Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: customTextField(
                    hintText: 'Tối thiểu...',
                    height: 40,
                    textInputType: TextInputType.text,
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text('Đến'),
              ),
              SizedBox(
                width: 160,
                child: Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: customTextField(
                    hintText: 'Tối đa...',
                    height: 40,
                    textInputType: TextInputType.text,
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

Padding salaryUnitComboBox(JobPostProvider jobPostProvider) {
  return Padding(padding: EdgeInsets.symmetric(horizontal: 0),
    child:
    DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isDense: true,
        value: jobPostProvider.salaryUnitSelected,
        items: [
          {"ID": "option 1", "Name": "triệu VNĐ/tháng"},
          {"ID": "option 2", "Name": "VNĐ/tháng"},
          {"ID": "option 3", "Name": "VNĐ/tuần"},
          {"ID": "option 4", "Name": "VNĐ/ngày"},
          {"ID": "option 5", "Name": "USD/tháng"},
          {"ID": "option 6", "Name": "USD/tuần"},
          {"ID": "option 7", "Name": "USD/ngày"},
        ].map((item) {
          return DropdownMenuItem<String>(
            value: item["ID"],
            child: Text(item["Name"]!, style: TextStyle(fontSize: 14)),
          );
        }).toList(),
        onChanged: (String? newValue) {
          jobPostProvider.setSalaryUnitSelected(newValue);
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
              fontWeight: FontWeight.bold, color: Colors.black,
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

Container customTextField({required String? hintText,required double height, TextInputType textInputType = TextInputType.multiline}) {
  return Container(
    height: height,
    padding: EdgeInsets.symmetric(horizontal: 10),
    child :SizedBox.expand(
    child: TextField(
        textAlignVertical: TextAlignVertical.top,
        keyboardType: textInputType,
        expands: (textInputType != TextInputType.text),
        maxLines: (textInputType == TextInputType.text) ? 1 : null,
        minLines: null,
        style: TextStyle(
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hintText ,
          hintStyle: TextStyle(
            color: Colors.grey,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
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
        )
    ),
    ),
  );

}

Widget NotificationsScreen() {
  // TODO: Modify section below
  return Container(
    color: Colors.red.shade100,
    child: Center(
      child: Text(
        "Thông báo",
        style: TextStyle(fontSize: 24),
      ),
    ),
  );
}

Widget ProfileScreen() {
  // TODO: Modify section below
  return Container(
    color: Colors.orange.shade100,
    child: Center(
      child: Text(
        "Hồ sơ",
        style: TextStyle(fontSize: 24),
      ),
    ),
  );
}

List<BottomNavigationBarItem> bottomNavigationItem_recruiter(BuildContext context) {
  return [
    tabItem(Icons.article_rounded, Icons.article_outlined, 'Quản lý', 0, context),
    tabItem(Icons.assignment_ind_rounded, Icons.assignment_ind_outlined, 'Ứng viên', 1, context),
    hiddenTabItem(),
    tabItem(Icons.notifications_rounded, Icons.notifications_outlined, 'Thông báo', 3, context),
    tabItem(Icons.person_2_rounded, Icons.person_2_outlined, 'Hồ sơ', 4, context),
  ];
}

Positioned buttonAddJDforRecruiter(role Role, BuildContext context) {
  var navigationProvider = Provider.of<BottomNavigationProvider>(context);
  if (Role == role.recruiter) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + (kBottomNavigationBarHeight / 2) - 25,
      left: MediaQuery.of(context).size.width / 2 - 25,
      child: AnimatedBuilder(
        animation: navigationProvider.animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: navigationProvider.animationController.value,
            child: child,
          );
        },
        child: GestureDetector(
          onTap: navigationProvider.onCenterButtonTap,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(0xFF071E26), // Xanh den
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  } else {
    return Positioned(child: SizedBox.shrink());
  }
}

Widget? appbarTitle_recruiter(int selectedIndex) {
  // Can be modified to better fit the design objectives
  switch (selectedIndex) {
    case 0:
      return Text('Quản lý',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),);
    case 1:
      return Text('Danh sách ứng viên',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),);
    case 2:
      return Text('Thêm tin tuyển dụng',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),);
    case 3:
      return Text('Thông báo',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),);
    case 4:
      return Text('Hồ sơ cá nhân',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),);
  }
  return null;
}