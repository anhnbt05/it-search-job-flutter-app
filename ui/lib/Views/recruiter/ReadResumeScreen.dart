import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:ui/Helpers/toastification.dart';
import 'package:ui/Models/model.dart';
import 'package:ui/ViewModels/recruiter/CandidatesAppliesViewModel.dart';

class ReadResumeScreen extends StatefulWidget {
  ReadResumeScreen(
    this.name,
    this.resumeUrl,
    this.Id,
    this.status,
    this.viewModel, {
    super.key,
  });

  String Id;
  String status;
  String name;
  String resumeUrl;
  CandidatesAppliesViewModel viewModel;

  @override
  State<ReadResumeScreen> createState() => _ReadResumeScreenState();
}

class _ReadResumeScreenState extends State<ReadResumeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: (widget.status == 'pending') ? Size.fromHeight(90) : Size.fromHeight(50),
        child: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: color,
          title: Text(
            widget.name,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          bottom: displaySelection(context: context, viewModel: widget.viewModel, Id: widget.Id, status: widget.status),
        ),
      ),
      body: SfPdfViewer.network(
        widget.resumeUrl,
        canShowScrollStatus: true,
        canShowPaginationDialog: true,
      ),
    );
  }
}


PreferredSize? displaySelection({required BuildContext context, required CandidatesAppliesViewModel viewModel, required String Id, required String status}) {
  if (status != 'pending') return null; else {
    return PreferredSize(
    preferredSize: Size.fromHeight(40),
    child: Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            style: TextButton.styleFrom().copyWith(
              overlayColor: MaterialStateProperty.all(
                Color(0x15fa3a4b),
              ),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    insetPadding: EdgeInsets.all(9),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 10,
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lý do từ chối',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            height: 150,
                            padding: EdgeInsets.symmetric(
                              horizontal: 5,
                            ),
                            child: SizedBox.expand(
                              child: TextField(
                                autofocus: true,
                                maxLines: null,
                                minLines: null,
                                expands: true,
                                controller: viewModel.rejectReason,
                                textAlignVertical:
                                TextAlignVertical.top,
                                keyboardType: TextInputType.text,
                                style: TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Nhập lý do từ chối...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      5,
                                    ),
                                  ),
                                  isDense: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      5,
                                    ),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 0.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      5,
                                    ),
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
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
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
                                  print(
                                    viewModel.rejectReason.text,
                                  );
                                  showDialog(
                                    context: context,
                                    barrierColor: Colors.black
                                        .withOpacity(0.5),
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return Center(
                                        child:
                                        CircularProgressIndicator(
                                          color: Colors.blue,
                                        ),
                                      );
                                    },
                                  );
                                  if (viewModel.rejectReason.text.isEmpty) {
                                    showErrorToastification_applicationProcess(
                                        message: 'Lý do từ chối không được để trống');
                                    Navigator.of(context).pop();
                                  }
                                  else {
                                    final result = await viewModel
                                        .rejectApplication(
                                      applicationId: Id,
                                      reason: viewModel
                                          .rejectReason
                                          .text,
                                    );
                                    Navigator.of(context).pop();

                                    if (result) {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    }
                                  }
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Color(0xeef5797a),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Xác nhận từ chối',
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
            child: Text(
              'Từ chối',
              style: TextStyle(color: Color(0xfffa3a4b), fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(width: 5),

          TextButton(
            style: TextButton.styleFrom().copyWith(
              overlayColor: MaterialStateProperty.all(
                Color(0x1565c29c),
              ),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    title: Text(
                      "Xác nhận",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    content: Text(
                      "Bạn có chắc chắn muốn chấp nhận ứng viên này không?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
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
                            builder: (BuildContext context) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.blue,
                                ),
                              );
                            },
                          );

                          await viewModel.approveApplication(Id,);
                          Navigator.of(context).pop();
                          Navigator.pop(context);
                          Navigator.pop(context);
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
            child: Text(
              'Chấp nhận',
              style: TextStyle(color: Color(0xff65c29c), fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(width: 5),
        ],
      ),
    ),
  );
  }
}