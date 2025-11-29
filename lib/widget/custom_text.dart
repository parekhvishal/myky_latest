import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';


class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color? textColor;
  final double height;
  final String? fontFamily;
  final bool isCentered;
  final int? maxLine;
  final bool textAllCaps;
  final bool isLongText;
  final TextOverflow? overflow;
  final TextDecoration? decoration;
  final FontWeight? fontWeight;
  final double? letterSpacing;
  final double? wordSpacing;
  final List<Shadow>? shadows;
  final bool? softWrap;
  final TextAlign? textAlign;

  const CustomText(
    this.text, {
    super.key,
    this.fontSize,
    this.textColor,
    this.height = 1.2,
    this.fontFamily,
    this.isCentered = false,
    this.maxLine,
    this.textAllCaps = false,
    this.isLongText = false,
    this.overflow,
    this.decoration,
    this.fontWeight,
    this.letterSpacing,
    this.wordSpacing,
    this.shadows,
    this.softWrap,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toString().isNotEmpty
          ? textAllCaps
              ? text.toUpperCase()
              : text
          : '',
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        color: textColor ?? black,
        height: height,
        decoration: decoration,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        shadows: shadows,
        wordSpacing: wordSpacing,
      ),
      textScaler: const TextScaler.linear(0.9),
      overflow: overflow,
      softWrap: softWrap,
      textAlign:
          isCentered
              ? TextAlign.center
              : (textAlign == null)
              ? TextAlign.start
              : textAlign,
      maxLines: isLongText ? null : maxLine,
    );
  }
}
