import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ViewModels/recruiter/ProfileViewModel.dart';

Widget ProfileScreen(BuildContext context) {
  var viewModel = Provider.of<RecruiterProfileViewModel>(context);
  if (viewModel.recruiterFuture != null) {
    return body(context);
  } else {
    return FutureBuilder(
      future: viewModel.recruiterFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }
        return body(context);
      }
    );
  }
}

Widget body(BuildContext context) {
  var viewModel = Provider.of<RecruiterProfileViewModel>(context);
  return Container(
    color: Colors.orange.shade100,
    child: Center(
      child: Text(
        viewModel.recruiterInfo!.FullName,
        style: TextStyle(fontSize: 24),
      ),
    ),
  );
}