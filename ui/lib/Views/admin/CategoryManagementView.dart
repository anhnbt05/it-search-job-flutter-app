import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/Constants/color_constants.dart';

import '../../Helpers/toastification.dart';
import '../../Models/Categories.dart';
import '../../ViewModels/admin/CategoryManagementViewModel.dart';

Widget CategoryManagementScreen(BuildContext context) {
  var viewModel = Provider.of<CategoryManagementViewModel>(context);
  if (viewModel.categories != null) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: body(context: context, viewModel: viewModel),
    );

  }
  return FutureBuilder(
    future: viewModel.categoryF,
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
        return body(context: context, viewModel: viewModel);
      }
    },
  );
}

Widget body({required BuildContext context, required CategoryManagementViewModel viewModel}) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          children: [
            Expanded(
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
                          viewModel.filterCategoryByName(value);
                        },
                        cursorColor: Colors.grey,
                        decoration: const InputDecoration(border: InputBorder.none),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (dialogContext) {
                    return Dialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      insetPadding: EdgeInsets.all(9),
                      child: Container(
                        width: MediaQuery.of(dialogContext).size.width - 10,
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Thêm danh mục công việc',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  fontFamily: 'Poppins'
                              ),
                            ),
                            SizedBox(height: 5),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  'Tên danh mục',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      fontFamily: 'Poppins'
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 2),
                            Container(
                              height: 60,
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: SizedBox.expand(
                                child: TextField(
                                  autofocus: true,
                                  maxLines: null,
                                  minLines: null,
                                  expands: true,
                                  controller: viewModel.nameController,
                                  textAlignVertical: TextAlignVertical.top,
                                  keyboardType: TextInputType.text,
                                  style: TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'Nhập tên danh mục...',
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
                            SizedBox(height: 7),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                    viewModel.nameController.clear();
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
                                    if (viewModel.nameController.text.trim().isEmpty) {
                                      showErrorToastification(
                                          title: "Lỗi",
                                          message: "Vui lòng nhập tên danh mục"
                                      );
                                      return;
                                    }

                                    showDialog(
                                      context: context,
                                      barrierColor: Colors.black.withOpacity(0.5),
                                      barrierDismissible: false,
                                      builder: (loadingContext) {
                                        return const Center(
                                          child: CircularProgressIndicator(
                                              color: Colors.blue
                                          ),
                                        );
                                      },
                                    );

                                    try {
                                      bool success = await viewModel.addCategory(
                                        dialogContext,
                                        viewModel.nameController.text.trim(),
                                      );

                                      Navigator.of(context).pop();

                                      if (success) {
                                        Navigator.of(dialogContext).pop();
                                      }
                                    } catch (e) {
                                      Navigator.of(context).pop();
                                      showErrorToastification(
                                          title: "Lỗi",
                                          message: e.toString()
                                      );
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
                                    'Xác nhận thêm',
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
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                minimumSize: Size(0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 1),
                  Text(
                    'Thêm',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      const SizedBox(height: 7),
      Flexible(
        child: ListView.builder(
          itemCount: viewModel.categories!.length,
          itemBuilder: (context, index) {
            return item(
              viewModel: viewModel,
              category: viewModel.categories![index],
              context: context,
              index: index + 1,
            );
          },
        ),
      ),
    ],
  );
}

Widget item({
  required CategoryManagementViewModel viewModel,
  required cCategories category,
  required BuildContext context,
  required int index,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
        borderRadius: BorderRadius.circular(5),
        border: Border.all(width: 1, color: Colors.transparent),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 7),
        child: Row(
          children: [
            Text(
              index.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: ColorConstants.subTextColor,
              ),
            ),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                category.CategoryName!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
