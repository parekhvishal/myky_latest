import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myky_clone/widget/theme.dart';
import 'package:nb_utils/nb_utils.dart';

class CustomSelectDateContainer extends StatelessWidget {
  final String title;
  final GestureTapCallback onTap;
  final bool isCloseVisible;

  const CustomSelectDateContainer({
    Key? key,
    required this.title,
    required this.onTap,
    this.isCloseVisible = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      decoration: boxDecorationDefault(
        borderRadius: radius(10.r),
        border: Border.all(
          width: 1.w,
          color: gray,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: 20.sp,
            height: 20.sp,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorPrimary.withOpacity(0.8),
            ),
            child: Icon(
              Icons.calendar_month,
              size: 13.sp,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.sp),
            child: text(
              title,
              fontSize: 12.sp,
              fontFamily: fontMedium,
            ),
          ),
          isCloseVisible == true
              ? GestureDetector(
                  onTap: onTap,
                  child: Icon(
                    Icons.close,
                    size: 20.sp,
                    color: redColor,
                  ),
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
