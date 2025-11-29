import 'package:boxicons/boxicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:myky_clone/utils/en_extensions.dart';
import 'package:nb_utils/nb_utils.dart' hide SizeConfig;
import 'package:pinch_zoom/pinch_zoom.dart';

import '../services/size_config.dart';
import 'network_image.dart';

class ImageDialog extends StatelessWidget {
  final String url;

  const ImageDialog({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PinchZoom(
            maxScale: 2.5,
            onZoomStart: () {},
            onZoomEnd: () {},
            child: PNetworkImage(
              url,
              height: 500.h,
              borderRadius: 12,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ).marginSymmetric(horizontal: 20.w),
          25.heightBox,
          Icon(
            Boxicons.bx_x_circle,
            size: 35.sp,
            color: white,
          ).onTap(
            () {
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
