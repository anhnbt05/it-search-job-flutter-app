import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ViewModels/admin/NotificationViewModel.dart';

Widget NotificationScreen(BuildContext context) {
  var viewModel = Provider.of<NotificationViewModel>(context);
  return FutureBuilder(future: viewModel.notificationsF, builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(child: Text(snapshot.error.toString()));
    } else {
      return ListView.builder(
        itemCount: viewModel.notifications.length,
          itemBuilder: (context, index) {
          return Text('${viewModel.notifications[index].content}');
      }
      );
    }
  }
  );
}