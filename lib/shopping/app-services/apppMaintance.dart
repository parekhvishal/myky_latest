import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../services/size_config.dart';
import '../../widget/custom_container.dart';
import '../../widget/theme.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../widget/confirmation_dialog.dart';

class AppMaintenance extends StatefulWidget {
  const AppMaintenance({Key? key}) : super(key: key);

  @override
  State<AppMaintenance> createState() => _AppMaintenanceState();
}

class _AppMaintenanceState extends State<AppMaintenance> {
  Map? maintenance;

  Future<bool> _onWillPop() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: "Are you sure you want to exit?",
        onPositiveClick: () => SystemNavigator.pop(),
      ),
    );
    return Future.value(false);
  }

  @override
  void initState() {
    maintenance = Get.arguments;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: Scaffold(
        body: CustomContainer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/maintenance.png',
                  alignment: Alignment.center,
                  height: h(50),
                  width: width,
                ),
              ),
              50.height,
              Container(
                transform: Matrix4.translationValues(0, -20, 0),
                child: text(
                  "Under maintenance",
                  fontSize: 23.sp,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                transform: Matrix4.translationValues(0, -10, 0),
                child: text(
                  maintenance == null || maintenance!['message'] == null
                      ? "We are working very hard to add new features \n and improve the usability of our app."
                      : maintenance!['message'],
                  fontSize: 16.sp,
                  isCentered: true,
                  isLongText: true,
                ),
              ),
              30.height,
              Container(
                margin: EdgeInsets.only(left: 30.w, right: 30.w),
                child: CustomButton(
                  onPressed: () => SystemNavigator.pop(),
                  textContent: 'Exit',
                ),
              ),
              15.height,
            ],
          ),
        ),
      ),
    );
  }
}
