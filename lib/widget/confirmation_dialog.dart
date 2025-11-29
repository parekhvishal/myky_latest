import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart' hide white;

import 'theme.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String positiveLabel;
  final String negativeLabel;
  final VoidCallback onPositiveClick;
  final VoidCallback? onNegativeClick;
  double fontSize = 20.sp;

  ConfirmationDialog({
    Key? key,
    required this.title,
    this.positiveLabel = "YES",
    this.negativeLabel = "NO",
    this.onNegativeClick,
    required this.onPositiveClick,
    double? fontSize,
  }) : super(key: key) {
    if (fontSize != null) {
      this.fontSize = fontSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: boxDecorationDefault(
                    color: white,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 30.w),
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 15.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      15.height,
                      text(
                        title,
                        fontSize: fontSize,
                        isCentered: true,
                        isLongText: true,
                        fontFamily: fontBold,
                      ),
                      25.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppButton(
                            onTap: () {
                              if (onNegativeClick != null) {
                                onNegativeClick!();
                              } else {
                                Get.back();
                              }
                            },
                            elevation: 0,
                            child: text(
                              'NO',
                              fontFamily: fontBold,
                              fontSize: 18.sp,
                              textColor: white,
                            ),
                            color: colorPrimary,
                          ).cornerRadiusWithClipRRect(12),
                          20.width,
                          AppButton(
                            onTap: () {
                              onPositiveClick.call();
                            },
                            elevation: 0,
                            child: text(
                              'YES',
                              fontFamily: fontBold,
                              fontSize: 18.sp,
                            ),
                            color: Colors.grey,
                          ).cornerRadiusWithClipRRect(12),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
