import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../widget/network_image.dart';
import 'package:nb_utils/nb_utils.dart';

class AnnouncementService {
  AnnouncementService._internal();

  static final AnnouncementService _instance = AnnouncementService._internal();

  static AnnouncementService get instance => _instance;

  checkForAnnouncementPopUp(context, List popups) async {
    if (popups.isNotEmpty) {
      for (var model in popups) {
        await showDialogForPopups(model, context);
      }
    }
  }

  Future showDialogForPopups(model, context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 8.0,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              PNetworkImage(
                model['image'],
                width: 500.w,
                height: 500.h,
                fit: BoxFit.cover,
                borderRadius: 15.r,
              ),
              Positioned(
                right: 10.w,
                top: 10.h,
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    alignment: Alignment.centerRight,
                    width: 30.sp,
                    height: 30.sp,
                    padding: EdgeInsets.all(5.sp),
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0Xff252A30)),
                    child: Icon(
                      Icons.close,
                      color: white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).cornerRadiusWithClipRRect(15.r),
      ),
    ).then((value) {
      // Storage.set('showAnnouncement', false);
    });
  }
}
