import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomContainer extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;
  final Border? border;
  final BorderRadius? borderRadius;
  final Color? color;
  final Widget child;

  const CustomContainer({
    Key? key,
    required this.child,
    this.margin,
    this.padding,
    this.gradient,
    this.border,
    this.color,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ??
          EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 5.h,
          ),
      padding: padding ??
          EdgeInsets.symmetric(
            vertical: 10.h,
            horizontal: 10.w,
          ),
      decoration: BoxDecoration(
        gradient: gradient,
        border: border,
        borderRadius: borderRadius,
        color: color,
      ),
      child: child,
    );
  }
}
