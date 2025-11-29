import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../services/size_config.dart';
import '../../utils/app_utils.dart';
import '../../widget/theme.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widget/custom_container.dart';

class AppUpdate extends StatefulWidget {
  const AppUpdate({Key? key}) : super(key: key);

  @override
  _AppUpdateState createState() => _AppUpdateState();
}

class _AppUpdateState extends State<AppUpdate> {
  String appUpdateUrl = '';
  @override
  void initState() {
    if (Get.arguments != null) {
      appUpdateUrl = Get.arguments['updateAppUrl'];
    }
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: CustomContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/images/rocket.gif',
                alignment: Alignment.center,
                height: h(50),
                width: width,
              ),
            ),
            50.height,
            Container(
              transform: Matrix4.translationValues(0, -20, 0),
              child: text(
                "New Update available",
                fontSize: 23.sp,
              ),
            ),
            Center(
              child: text(
                "Please update the app to enjoy full featured app with more benefits for you.",
                fontSize: 16.sp,
                isCentered: true,
                isLongText: true,
              ),
            ),
            40.height,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 60.w),
              child: CustomButton(
                textContent: 'Update',
                onPressed: () async {
                  if (appUpdateUrl.isNotEmpty) {
                    launch(appUpdateUrl);
                  } else {
                    AppUtils.showErrorSnackBar('There might be some issue with this URL');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
