import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension ENIntExtensions on int? {
  Widget get heightBox => SizedBox(height: this?.h);

  Widget get widthBox => SizedBox(width: this?.w);
}

extension CustomWidgetExtensions on Widget? {
  Widget appPadding({double horizontal = 14.0, double vertical = 8.0}) => Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical), child: this);
}
