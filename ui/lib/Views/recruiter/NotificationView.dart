import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Services/notification_service.dart';
import '../../ViewModels/AuthViewModel.dart';
import '../../ViewModels/recruiter/NotificationViewModel.dart';

Widget NotificationScreen(BuildContext context) {
  var viewModel = Provider.of<NotificationViewModel>(context);
  var loginVM = Provider.of<AuthViewModel>(context, listen: false);
  return FutureBuilder(future: viewModel.notificationsF, builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue,));
    } else if (snapshot.hasError) {
      return Center(child: CircularProgressIndicator(color: Colors.blue,));
    } else {
      return ListView.builder(
          itemCount: viewModel.notifications.length,
          itemBuilder: (context, index) {
            return ElevatedButton(child: Text('${viewModel.notifications[index].Metadata['jobTitle']}'), onPressed: () {
              NotificationService().deleteNotification(context, loginVM.userId!, viewModel.notifications[index].ID);
            });
          }
      );
    }
  }
  );
}