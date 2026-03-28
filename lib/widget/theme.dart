import 'dart:ui' as ui;

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../controllers/theme_controller.dart';
import 'colors.dart';
import 'custom_text.dart';

const fontExtraLight = 'ExtraLight';
const fontLight = 'Light';
const fontRegular = 'Regular';
const fontMedium = 'Medium';
const fontSemiBold = 'SemiBold';
const fontBold = 'Bold';

int cartCount = 0;

final ThemeController themeController = Get.find();

ThemeData buildLightThemeData() {
  return ThemeData(
    scaffoldBackgroundColor: appLightBackground,
    radioTheme: RadioThemeData(fillColor: WidgetStateProperty.all(gray)),
    iconTheme: IconThemeData(color: black, size: 25.sp),
    listTileTheme: const ListTileThemeData(iconColor: black, textColor: black),
    fontFamily: fontRegular,
    textTheme: TextTheme(
      bodyMedium: TextStyle(fontFamily: fontRegular, fontSize: 18.sp),
      bodyLarge: TextStyle(fontFamily: fontRegular, fontSize: 18.sp),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.fromLTRB(18, 15, 18, 15),
      filled: false,
      fillColor: white,
      labelStyle: TextStyle(fontSize: 14.sp, color: colorPrimary),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: textInputBorderColor.withValues(alpha: 0.2), width: 0.7.w),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: colorPrimary, width: 1.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: red, width: 1.w),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: white),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: red, width: 1.w),
      ),
      hintStyle: TextStyle(color: bodyColor.withValues(alpha: 0.5), fontSize: 18.sp),
      suffixIconColor: black,
      prefixIconColor: grey,
      isDense: true,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(fontFamily: fontBold, fontSize: 22.sp),
      actionsIconTheme: const IconThemeData(color: white),
      iconTheme: const IconThemeData(color: white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.green,
        backgroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    ),
  );
}

ThemeData buildDarkThemeData() {
  return ThemeData(
    scaffoldBackgroundColor: appBackground,
    radioTheme: RadioThemeData(fillColor: WidgetStateProperty.all(colorPrimary)),
    iconTheme: const IconThemeData(color: gray, size: 25),
    listTileTheme: const ListTileThemeData(iconColor: white, textColor: white),
    fontFamily: fontRegular,
    textTheme: TextTheme(
      bodyMedium: TextStyle(fontFamily: fontRegular, color: white, fontSize: 16.sp),
      bodyLarge: TextStyle(fontFamily: fontRegular, fontSize: 16.sp, color: white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
      prefixIconColor: colorPrimary,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.r),
        borderSide: BorderSide(color: textInputBorderColor, width: 1.w),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.r),
        borderSide: BorderSide(color: colorPrimary, width: 1.w),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.r),
        borderSide: BorderSide(color: red, width: 1.w),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.r),
        borderSide: BorderSide(color: colorPrimary, width: 0.w),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.r),
        borderSide: BorderSide(color: red, width: 0.5.w),
      ),
      hintStyle: TextStyle(color: white.withValues(alpha: 0.5), fontSize: 16.sp),
      suffixIconColor: black,
      isDense: true,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: appBackground,
      elevation: 0,
      titleTextStyle: TextStyle(fontFamily: fontBold, fontSize: 22.sp),
      actionsIconTheme: const IconThemeData(color: white),
      iconTheme: const IconThemeData(color: white),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Colors.transparent),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: colorPrimary,
        backgroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    ),
  );
}

Widget formField(
  String hintText, {
  isPassword = false,
  bool textCapital = false,
  bool enableInterAction = true,
  bool isRegexToRemoveEmoji = true,
  String? labelText,
  bool? obscureText,
  FocusNode? focusNode,
  TextInputAction? textInputAction,
  TextEditingController? controller,
  FormFieldSetter<String>? onSaved,
  FormFieldValidator<String>? validator,
  int? maxLength,
  bool enabled = true,
  ValueChanged<String>? onChanged,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  Widget? suffixIcon,
  Widget? prefixIcon,
  int maxLines = 1,
  TextCapitalization? textCapitalization,
  ValueChanged<String>? onFieldSubmitted,
  labelColor = labelInputColor,
  bool readOnly = false,
  int? errorMaxLine = 1,
  Color borderColor = colorPrimary,
  Function()? onTap,
}) {
  String regexToRemoveEmoji = r'[^\x00-\x7F]';
  if (isRegexToRemoveEmoji == true) {
    if (inputFormatters == null) {
      inputFormatters = [FilteringTextInputFormatter.deny(RegExp(regexToRemoveEmoji))];
    } else {
      inputFormatters.add(FilteringTextInputFormatter.deny(RegExp(regexToRemoveEmoji)));
    }
  }
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 2)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          CustomText(labelText, fontSize: 14.sp, fontFamily: fontSemiBold),
          10.height,
        ],
        TextFormField(
          focusNode: focusNode,
          readOnly: readOnly,
          enabled: enabled,
          obscureText: isPassword,
          enableInteractiveSelection: enableInterAction,
          controller: controller,
          validator: validator,
          onSaved: onSaved,
          onChanged: onChanged,
          onTap: onTap,
          maxLength: maxLength,
          textCapitalization: textCapital ? TextCapitalization.characters : TextCapitalization.none,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          style: TextStyle(color: black.withValues(alpha: 0.5), fontSize: 18.sp),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            hintText: hintText,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            prefixIconConstraints: BoxConstraints(
              maxWidth: 50.w,
              maxHeight: 50.h,
              minWidth: 40.w,
              minHeight: 40.h,
            ),
            counterText: '',
            errorMaxLines: errorMaxLine,
          ),
          maxLines: maxLines,
        ),
      ],
    ),
  );
}

Widget dottedLine() {
  return const DottedLine(
    direction: Axis.horizontal,
    alignment: WrapAlignment.center,
    lineLength: double.infinity,
    lineThickness: 1.0,
    dashLength: 4.0,
    dashColor: gray,
    dashRadius: 0.0,
    dashGapLength: 4.0,
    dashGapColor: Colors.transparent,
    dashGapRadius: 0.0,
  );
}

BoxDecoration boxContain({
  double radius = 10,
  double borderWidth = 0.5,
  Color borderColor = Colors.transparent,
  Color? bgColor,
  var showShadow = true,
}) {
  return BoxDecoration(
    color: white,
    borderRadius: BorderRadius.all(Radius.circular(radius)),
    border: Border.all(color: borderColor, width: borderWidth),
    boxShadow: showShadow
        ? [
            const BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.16),
              blurRadius: 4,
              spreadRadius: 0,
              offset: Offset(0, 1),
            ),
          ]
        : [const BoxShadow(color: Colors.transparent)],
  );
}

String capitalize(String string) {
  if (string == null) {
    throw ArgumentError("string: $string");
  }

  if (string.isEmpty) {
    return string;
  }

  return string[0].toUpperCase() + string.substring(1);
}

Widget text(
  String text, {
  var fontSize = 16,
  textColor = black,
  var fontFamily = fontRegular,
  var isCentered = false,
  var maxLine = 1,
  var textAllCaps = false,
  var isLongText = false,
  var overflow,
  var decoration,
  var fontweight,
  var fontStyle,
}) {
  return Text(
    textAllCaps ? text.toUpperCase() : text,
    textAlign: isCentered ? TextAlign.center : TextAlign.start,
    maxLines: isLongText ? null : maxLine,
    style: TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      color: textColor,
      height: 1.5,
      decoration: decoration,
      fontWeight: fontweight,
      fontStyle: fontStyle,
    ),
    overflow: overflow,
  );
}

Widget rowHeading(var label, var subLabel) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
    child: Row(
      children: <Widget>[
        text(
          label,
          textColor: colorPrimary,
          fontFamily: fontMedium,
          fontSize: 14.0,
          isLongText: true,
        ).expand(flex: 45),
        Expanded(
          flex: 55,
          child: Align(
            alignment: Alignment.topRight,
            child: text(subLabel, fontSize: 16.0, fontFamily: fontBold, isLongText: true),
          ),
        ),
      ],
    ),
  );
}

Divider view() {
  return Divider(color: textColorSecondary, height: 0.5);
}

BoxDecoration boxDecoration({
  double radius = 2,
  Color? color = Colors.transparent,
  Color? bgColor = white,
  var showShadow = false,
}) {
  return BoxDecoration(
    color: bgColor,
    boxShadow: showShadow
        ? [BoxShadow(color: Color(0XFFF2F2F2), blurRadius: 10, spreadRadius: 2)]
        : [BoxShadow(color: Colors.transparent)],
    border: Border.all(color: color!),
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}

Widget scaffoldBackgroundImage({
  required Widget child,
  dynamic customBgImage, // String asset path OR ImageProvider
  BoxFit fit = BoxFit.cover,
  Alignment alignment = Alignment.center,
  Color overlayColor = Colors.transparent,
  double overlayOpacity = 0.0,
  double blurSigma = 0.0, // set >0 to apply blur
  EdgeInsetsGeometry? padding,
  bool safeArea = false,
}) {
  // Resolve image provider
  ImageProvider? _imageProvider;
  if (customBgImage is String && customBgImage.isNotEmpty) {
    _imageProvider = AssetImage(customBgImage);
  } else if (customBgImage is ImageProvider) {
    _imageProvider = customBgImage;
  } else {
    _imageProvider = null; // no background
  }

  Widget background = Container(
    width: double.infinity,
    height: double.infinity,
    color: Colors.transparent,
    child: _imageProvider != null
        ? Image(
            image: _imageProvider,
            fit: fit,
            alignment: alignment,
            width: double.infinity,
            height: double.infinity,
          )
        : const SizedBox.shrink(),
  );

  // Apply blur if requested
  if (blurSigma > 0 && _imageProvider != null) {
    background = Stack(
      children: [
        background,
        Positioned.fill(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }

  // overlay to tweak contrast
  final overlay = Container(color: overlayColor.withOpacity(overlayOpacity.clamp(0.0, 1.0)));

  Widget content = Stack(
    children: [
      Positioned.fill(child: background),
      if (overlayOpacity > 0) Positioned.fill(child: overlay),
      Positioned.fill(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Container(padding: padding ?? EdgeInsets.zero, color: Colors.transparent, child: child),
        ),
      ),
    ],
  );

  return safeArea ? SafeArea(child: content) : content;
}

Widget formFieldOld(
  context,
  hint, {
  isEnabled = true,
  isDummy = false,
  TextEditingController? controller,
  isPasswordVisible = false,
  isPassword = false,
  keyboardType = TextInputType.text,
  FormFieldValidator<String>? validator,
  onSaved,
  textInputAction = TextInputAction.next,
  ValueChanged<String?>? onChanged,
  List<TextInputFormatter>? inputFormatters,
  FocusNode? focusNode,
  FocusNode? nextFocus,
  Widget? suffixIcon,
  IconData? prefixIcon,
  maxLine = 1,
  readOnly = false,
  suffixIconSelector,
  Color? borderSideColor,
  Widget? suffixWidget,
  maxLength,
  TextCapitalization? textCapitalization,
  bool? obscureText,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.2), offset: Offset(3, 3), blurRadius: 5, spreadRadius: 1),
        BoxShadow(
          color: Colors.white.withOpacity(0.5),
          offset: Offset(-2, -2),
          blurRadius: 5,
          spreadRadius: 1,
        ),
      ],
    ),
    child: TextFormField(
      controller: controller,
      obscureText: obscureText ?? (isPassword ? isPasswordVisible : false),
      cursorColor: colorPrimary,
      maxLines: maxLine,
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
      readOnly: readOnly,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      onChanged: onChanged,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      maxLength: maxLength,
      onFieldSubmitted: (arg) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        }
      },
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorPrimary),
        ),
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderSideColor ?? Colors.transparent),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        counterText: "",
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 16,
          color: textColorSecondary.withOpacity(0.7),
          shadows: [Shadow(blurRadius: 2.0, color: Colors.black.withOpacity(0.1), offset: Offset(1, 1))],
        ),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: textColorSecondary, size: 20) : null,
        suffixIcon: suffixWidget,
      ),
      style: TextStyle(
        fontSize: 18,
        color: isDummy ? Colors.transparent : colorPrimaryDark,
        fontFamily: fontRegular,
      ),
    ),
  );
}

floatingInput(
  String hintText, {
  isPassword = false,
  bool readonly = false,
  bool? obscureText,
  TextEditingController? controller,
  FormFieldSetter<String>? onSaved,
  FormFieldValidator<String>? validator,
  int? maxLength,
  ValueChanged<String>? onChanged,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  Widget? suffixIcon,
  Widget? prefixIcon,
  int maxLines = 1,
  GestureTapCallback? onTap,
}) {
  return TextFormField(
    readOnly: readonly,
    obscureText: isPassword,
    controller: controller,
    validator: validator,
    onSaved: onSaved,
    onChanged: onChanged,
    maxLength: maxLength,
    inputFormatters: inputFormatters,
    keyboardType: keyboardType,
    cursorColor: colorPrimary,
    onTap: onTap,
    decoration: InputDecoration(
      labelText: hintText,
      isDense: true,
      labelStyle: TextStyle(fontSize: 16, color: textColorPrimary.withOpacity(0.7), fontFamily: fontMedium),
      // prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      counterText: '',
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
    ),
    maxLines: maxLines,
  );
}

class CustomButtonOld extends StatefulWidget {
  var textContent;
  VoidCallback? onPressed;
  var isStroked = false;
  Color? customColor;

  CustomButtonOld({
    @required this.textContent,
    @required this.onPressed,
    this.isStroked = false,
    this.customColor,
  });

  @override
  CustomButtonOldState createState() => CustomButtonOldState();
}

class CustomButtonOldState extends State<CustomButtonOld> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 12),
        alignment: Alignment.center,
        child: text(
          widget.textContent,
          textColor: widget.isStroked ? colorPrimary : white,
          isCentered: true,
          fontFamily: fontSemiBold,
          textAllCaps: true,
        ),
        decoration: widget.isStroked
            ? boxDecoration(
                bgColor: Colors.transparent,
                color: widget.customColor != null ? widget.customColor! : colorPrimary,
                radius: 5,
              )
            : boxDecoration(
                bgColor: widget.customColor != null ? widget.customColor! : colorPrimary,
                radius: 5,
              ),
      ),
    );
  }
}

Widget emptyWidget(
  BuildContext context,
  String image,
  String title,
  String desc, {
  bool showRetry = false,
  Function? onRetry,
}) {
  return Container(
    color: white,
    constraints: BoxConstraints(maxWidth: 500.0),
    height: MediaQuery.of(context).size.height,
    child: Stack(
      children: [
        Image.asset(
          image,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.fitWidth,
        ),
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: Container(
            decoration: boxDecoration(radius: 10, showShadow: true, bgColor: Colors.grey[200]!),
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                text(
                  title,
                  textColor: colorPrimaryDark,
                  fontFamily: fontBold,
                  fontSize: 18,
                  maxLine: 2,
                  isCentered: true,
                ),
                SizedBox(height: 5),
                text(desc, isCentered: true, isLongText: true),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

BoxDecoration gradientBoxDecoration({
  double radius = 10,
  Color color = Colors.transparent,
  Color gradientColor2 = white,
  Color gradientColor1 = white,
  var showShadow = false,
}) {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [gradientColor1, gradientColor2],
    ),
    boxShadow: showShadow
        ? [BoxShadow(color: Color(0X95E9EBF0), blurRadius: 10, spreadRadius: 2)]
        : [BoxShadow(color: Colors.transparent)],
    border: Border.all(color: color),
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}
