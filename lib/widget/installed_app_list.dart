// installed_app_list.dart

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myky_clone/widget/theme.dart';
import 'package:nb_utils/nb_utils.dart';

class InstalledAppList extends StatelessWidget {
  final List<Map<String, String>> installedApps;

  // Constructor to accept the list of installed apps
  const InstalledAppList({
    Key? key,
    required this.installedApps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: installedApps.length,
      itemBuilder: (context, index) {
        final app = installedApps[index];
        return Container(
          padding: EdgeInsets.all(5.sp),
          margin: EdgeInsets.only(bottom: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: colorPrimary, // Border color
                width: 0.2, // Border width
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 35.0,
                    width: 35.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Image.asset(
                      app['appIcon']!,
                      height: 25.0,
                      width: 25.0,
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app['appName']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Icon(Icons.chevron_right, size: 20.0),
            ],
          ),
        ).onTap(() async {
          await LaunchApp.openApp(
            androidPackageName: app['packageName']!,
          );
        });
      },
    );
  }
}
