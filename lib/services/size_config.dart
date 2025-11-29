import 'package:flutter/material.dart';

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;
  static double? blockSizeHorizontal;
  static double? blockSizeVertical;

  static double? _safeAreaHorizontal;
  static double? _safeAreaVertical;
  static double? safeBlockHorizontal;
  static double? safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;
    blockSizeHorizontal = screenWidth! / 100;
    blockSizeVertical = screenHeight! / 100;

    _safeAreaHorizontal =
        _mediaQueryData!.padding.left + _mediaQueryData!.padding.right;
    _safeAreaVertical =
        _mediaQueryData!.padding.top + _mediaQueryData!.padding.bottom;
    safeBlockHorizontal = (screenWidth! - _safeAreaHorizontal!) / 100;
    safeBlockVertical = (screenHeight! - _safeAreaVertical!) / 100;
  }

  static double width(double size) {
    return safeBlockHorizontal! * size;
  }

  static double height(double size) {
    return safeBlockVertical! * size;
  }

  static double size(double size) {
    return safeBlockHorizontal! * safeBlockVertical! * size / 10;
  }
}

double h(double height) {
  return SizeConfig.height(height);
}

double w(double width) {
  return SizeConfig.width(width);
}

double s(double size) {
  return SizeConfig.size(size);
}
