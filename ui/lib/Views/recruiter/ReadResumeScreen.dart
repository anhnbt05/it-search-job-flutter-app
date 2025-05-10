import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:ui/Constants/color_constants.dart';
import 'package:ui/Helpers/toastification.dart';
import 'package:ui/Models/Applications.dart';
import 'package:ui/Models/Jobs.dart';
import 'package:ui/ViewModels/recruiter/CandidatesAppliesViewModel.dart';

class ReadResumeScreen extends StatefulWidget {
  ReadResumeScreen(
    this.name,
    this.resumeUrl,
    this.Id,
    this.job,
    this.applications,
    this.status,
    this.viewModel, {
    super.key,
  });

  cJobs_recruiter job;
  List<cApplications_recruiter> applications;
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
    var viewModel = widget.viewModel;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: (widget.status == 'pending') ? Size.fromHeight(90) : Size.fromHeight(50),
        child: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: ColorConstants.appbarColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.name,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              IconButton(
                onPressed: () async {
                  if (await viewModel.isFileExist(widget.resumeUrl, fileName: "${widget.name}-${widget.job.Title}.pdf") == true) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          title: Text(
                            "Xác nhận",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          content: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: "Bạn đã tải "),
                                TextSpan(
                                  text: "${widget.name}-${widget.job.Title}.pdf.",
                                  style: TextStyle(fontStyle: FontStyle.italic,
                                  decoration: TextDecoration.underline,),
                                ),
                                TextSpan(text: "\nBạn có muốn tải lại không?"),
                              ],
                            ),
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
                                'Thoát',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await viewModel.startDownload(widget.resumeUrl,
                                    fileName: "${widget.name}-${widget.job.Title}.pdf");
                                Navigator.of(context).pop();
                                showTopToastification(content: "Đã tải thành công ${widget.name}-${widget.job.Title}.pdf", title: "Thành công", color: Colors.green, icon: Icons.save_alt);
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Color(0xee65c29c),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Tải lại',
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
                  } else {
                    await viewModel.startDownload(widget.resumeUrl,
                        fileName: "${widget.name}-${widget.job.Title}.pdf");
                    showTopToastification(content: "Đã tải thành công ${widget.name}-${widget.job.Title}.pdf", title: "Thành công", color: Colors.green, icon: Icons.save_alt);
                  }
                },
                icon: Icon(Icons.save_alt_outlined, color: Colors.white,)
              )
            ],
          ),
          bottom: displaySelection(viewModel: widget.viewModel, Id: widget.Id, status: widget.status),
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


PreferredSize? displaySelection({
  required CandidatesAppliesViewModel viewModel,
  required String Id,
  required String status,
}) {
  if (status != 'pending') {
    return null;
  } else {
    return PreferredSize(
      preferredSize: Size.fromHeight(40),
      child: Builder(builder: (buttonContext) {
        return Container(
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
                    context: buttonContext,
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
                                      Navigator.pop(dialogContext);
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
                                      final currentDialogContext = dialogContext;

                                      if (viewModel.rejectReason.text.isEmpty) {
                                        showErrorToastification(
                                            message: 'Lý do từ chối không được để trống',
                                            title: 'Lỗi'
                                        );
                                      } else {
                                        showDialog(
                                          context: currentDialogContext,
                                          barrierColor: Colors.black.withOpacity(0.5),
                                          barrierDismissible: false,
                                          builder: (BuildContext loadingContext) {
                                            return Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.blue,
                                              ),
                                            );
                                          },
                                        );

                                        final result = await viewModel.rejectApplication(
                                          applicationId: Id,
                                          reason: viewModel.rejectReason.text,
                                        );
                                        if (currentDialogContext.mounted) {
                                          Navigator.of(currentDialogContext).pop();

                                          if (result) {
                                            Navigator.of(currentDialogContext).pop();
                                            Navigator.of(buttonContext).pop();
                                          }
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
                    context: buttonContext,
                    builder: (dialogContext) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        title: Text(
                          "Xác nhận",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        content: Text(
                          "Bạn có chắc chắn muốn chấp nhận ứng viên này không?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
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
                              final currentDialogContext = dialogContext;
                              final currentButtonContext = buttonContext;

                              showDialog(
                                context: currentDialogContext,
                                barrierColor: Colors.black.withOpacity(0.5),
                                barrierDismissible: false,
                                builder: (BuildContext loadingContext) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.blue,
                                    ),
                                  );
                                },
                              );

                              await viewModel.approveApplication(Id);
                              if (currentDialogContext.mounted) {
                                Navigator.of(currentDialogContext).pop();
                                Navigator.of(currentDialogContext).pop();
                              }
                              if (currentButtonContext.mounted) {
                                Navigator.of(currentButtonContext).pop();
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
        );
      }),
    );
  }
}