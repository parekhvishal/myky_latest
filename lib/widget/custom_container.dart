import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomContainer extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;
  final Widget child;

  const CustomContainer({super.key, required this.child, this.margin, this.padding, this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
      padding: padding ?? EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}
