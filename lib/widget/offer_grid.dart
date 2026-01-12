import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OfferGrid extends StatelessWidget {
  const OfferGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Left side - Flex 3
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Container(
                  height: 180.h,
                  width: double.infinity,
                  // padding: EdgeInsets.symmetric(
                  //   horizontal: 16.w,
                  //   vertical: 8.h,
                  // ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 162, 157, 254),
                        Color.fromARGB(255, 255, 255, 255),
                        Color.fromARGB(255, 248, 225, 254),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.r),

                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(102, 0, 0, 0),
                        offset: Offset.zero,
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    "assets/grid/offlineStore.png",
                    height: double.infinity,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  height: 70.h,

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 255, 255, 255),
                        Color.fromARGB(255, 255, 206, 255),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20.r),

                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(102, 0, 0, 0),
                        offset: Offset.zero,
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    "assets/grid/map.png",
                    height: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            flex: 2,
            child: Column(
              children: [
                Container(
                  height: 125.h,
                  width: double.infinity,
                  // padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 199, 255, 204),
                        Color.fromARGB(255, 255, 255, 255),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.r),

                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(102, 0, 0, 0),
                        offset: Offset.zero,
                        blurRadius: 12,
                      ),
                    ],
                  ),

                  child: Image.asset(
                    "assets/grid/coins.png",
                    height: double.infinity,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  height: 125.h,
                  width: double.infinity,

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 158, 234, 255),
                        Color.fromARGB(255, 229, 248, 255),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.r),

                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(102, 0, 0, 0),
                        offset: Offset.zero,
                        blurRadius: 12,
                      ),
                    ],
                  ),

                  child: Image.asset(
                    "assets/grid/recharge.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
