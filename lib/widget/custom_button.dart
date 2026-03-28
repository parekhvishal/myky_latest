import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myky_clone/widget/theme.dart';
import 'package:nb_utils/nb_utils.dart';

import 'colors.dart';
import 'custom_text.dart';

class CustomButton extends StatelessWidget {
  final String? label;
  final double? width;
  final double? height;
  final Gradient? gradient;
  final VoidCallback? onPressed;
  final Color? textColor;
  final Color? bgColor;
  final double? fontSize;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.width,
    this.height,
    this.gradient,
    this.textColor,
    this.bgColor = colorPrimary,
    this.fontSize = 16,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      shapeBorder: RoundedRectangleBorder(borderRadius: radius(12.r)),
      color: bgColor,
      elevation: 1,
      margin: margin ?? EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
      padding: padding ?? EdgeInsets.symmetric(vertical: 5.h, horizontal: 5.w),
      onTap: () {
        if (onPressed != null) {
          onPressed!();
        }
      },
      hoverColor: colorAccent,
      focusColor: colorAccent,
      width: width ?? double.infinity,
      height: height ?? 50.h,
      enableScaleAnimation: true,
      child: CustomText(
        label.validate().toUpperCase(),
        fontFamily: fontBold,
        textColor: textColor != null ? Colors.black : Colors.white,
        fontSize: fontSize,
        letterSpacing: 0.5,
      ),
    );
  }
}
