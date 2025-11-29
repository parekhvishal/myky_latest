import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InnerShadowContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color color;
  final Color borderColor;
  final Offset? offset;

  const InnerShadowContainer({
    Key? key,
    required this.child,
    this.margin,
    this.padding,
    this.radius = 20,
    this.color = const Color(0xffffffff),
    this.borderColor = const Color(0xff2736BD),
    this.offset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: (padding != null)
          ? padding
          : EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 5.h,
            ),
      margin: (margin != null)
          ? margin
          : EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 5.h,
            ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(radius.r),
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor,
            offset: (offset != null) ? offset! : const Offset(1, 6),
          ),
        ],
        color: color,
      ),
      child: child,
    );
  }
}
