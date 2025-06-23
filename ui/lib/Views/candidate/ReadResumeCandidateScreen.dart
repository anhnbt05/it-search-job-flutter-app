import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:ui/Constants/color_constants.dart';

class ReadResumeCandidateScreen extends StatefulWidget {
  final String name;
  final String? resumeUrl;

  const ReadResumeCandidateScreen({
    super.key,
    required this.name,
    required this.resumeUrl,
  });

  @override
  State<ReadResumeCandidateScreen> createState() =>
      _ReadResumeCandidateScreenState();
}

class _ReadResumeCandidateScreenState
    extends State<ReadResumeCandidateScreen> {
  @override
  Widget build(BuildContext context) {
    final isResumeAvailable =
        widget.resumeUrl != null && widget.resumeUrl!.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: ColorConstants.appbarColor,
        title: Text(
          widget.name,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: isResumeAvailable
          ? SfPdfViewer.network(
        widget.resumeUrl!,
        canShowScrollStatus: true,
        canShowPaginationDialog: true,
      )
          : const Center(
        child: Text(
          "Bạn chưa upload file CV.",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
