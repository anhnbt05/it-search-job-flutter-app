import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../ViewModels/recruiter/ProfileViewModel.dart';

Widget ProfileScreen(BuildContext context) {
  var viewModel = Provider.of<RecruiterProfileViewModel>(context);
  if (viewModel.recruiterInfo != null) {
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
      },
    );
  }
}

Widget body(BuildContext context) {
  var viewModel = Provider.of<RecruiterProfileViewModel>(context);
  return SingleChildScrollView(
    child: Column(
      children: [
        Container(
          height:
              MediaQuery.of(context).size.height -
              kToolbarHeight -
              kBottomNavigationBarHeight -
              35,
          child: PageView(
            controller: viewModel.pageController,
            children: [RecruiterInfo(context), CompanyInfo(context)],
          ),
        ),
        SmoothPageIndicator(
          controller: viewModel.pageController,
          count: 2,
          effect: const WormEffect(
            dotHeight: 4,
            dotWidth: 4,
            activeDotColor: Colors.blue,
          ),
        ),
      ],
    ),
  );
}

Widget RecruiterInfo(BuildContext context) {
  var viewModel = Provider.of<RecruiterProfileViewModel>(context);
  return Card(
    surfaceTintColor: Colors.white,
    color: Colors.white,
    elevation: 2,
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 50,
                  child: Image.network(viewModel.recruiterInfo!.AvatarUrl),
                ),
                SizedBox(height: 5),
                Text(
                  viewModel.recruiterInfo!.FullName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                Text(
                  viewModel.recruiterInfo!.Position,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Container(
                  height: 35,
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.phone_outlined,
                      color: Colors.green,
                      size: 20,
                    ),
                    title: Text(
                      viewModel.recruiterInfo!.PhoneNumber,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 35, maxHeight: 60),
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.email_outlined,
                      color: Colors.green,
                      size: 20,
                    ),
                    title: Text(
                      viewModel.recruiterInfo!.Email,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.location_city_outlined,
                    color: Colors.green,
                    size: 20,
                  ),
                  title: Text(
                    viewModel.recruiterInfo!.CompanyLocations.Address,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    print("Ok");
                  },
                  child: Icon(Icons.edit, size: 25),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    print("Ok");
                  },
                  child: Icon(Icons.exit_to_app, size: 25, color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget CompanyInfo(BuildContext context) {
  var viewModel = Provider.of<RecruiterProfileViewModel>(context);
  return Card(
    surfaceTintColor: Colors.white,
    color: Colors.white,
    elevation: 2,
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1, color: Colors.black12),
                  ),
                  child: Image.network(
                    viewModel.recruiterInfo!.Company.LogoUrl!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  viewModel.recruiterInfo!.Company.Name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Container(
                  height: 35,
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.link, color: Colors.blue, size: 20),
                    title: GestureDetector(
                      onTap: () async {
                        final websiteUrl =
                            viewModel.recruiterInfo!.Company.WebsiteUrl;
                        final Uri uri = Uri.parse(
                          websiteUrl.startsWith('http')
                              ? websiteUrl
                              : 'https://$websiteUrl',
                        );

                        try {
                          if (!await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          )) {
                            throw Exception('Không thể mở được liên kết: $uri');
                          }
                        } catch (e) {
                          print('Lỗi mở URL: $uri - $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Không thể mở liên kết website'),
                            ),
                          );
                        }
                      },
                      child: Text(
                        viewModel.recruiterInfo!.Company.WebsiteUrl,
                        style: TextStyle(fontSize: 14, color: Colors.blue),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                  title: Text(
                    viewModel.recruiterInfo!.Company.Description,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 6,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: GestureDetector(
              onTap: () {
                print("Ok");
              },
              child: Icon(Icons.edit, size: 25),
            ),
          ),
        ),
      ],
    ),
  );
}
