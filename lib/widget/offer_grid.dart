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
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
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
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(102, 0, 0, 0),
                        offset: Offset.zero,
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Super Card",
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color.fromARGB(255, 71, 68, 255),
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              "Flat 3% cashback on UPI",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 100.h,
                        width: 140.w,
                        child: Image.asset("assets/images/supercard.png"),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  height: 90.h,
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 255, 255, 255),
                        Color.fromARGB(255, 255, 206, 255),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(102, 0, 0, 0),
                        offset: Offset.zero,
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Credit Score",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Check For Free",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Image.asset(
                        "assets/images/credit.png",
                        height: 80.h,
                        width: 40.w,
                        fit: BoxFit.cover,
                      ),
                    ],
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
                  height: 135.h,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
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
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(102, 0, 0, 0),
                        offset: Offset.zero,
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 40.h,
                        width: 80.w,
                        child: Image.asset(
                          "assets/images/racharge.png",

                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 2.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Recharges",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          //SizedBox(height: 1),
                          Text(
                            "&Bills",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "10% off on Airtel",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  height: 135.h,
                  width: double.infinity,
                  padding: EdgeInsets.all(8.r),
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
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(102, 0, 0, 0),
                        offset: Offset.zero,
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 50.h,
                        width: 140.w,
                        child: Image.asset(
                          "assets/images/tail.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Flight",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Check For Free",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
