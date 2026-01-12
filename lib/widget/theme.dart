import 'dart:ui' as ui;

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';

// type for litview Builder
typedef Widget ListItemBuilder(dynamic itemData, int index);

//type for Gridview Builder
typedef Widget GridItemBuilder(dynamic itemData, int index);

// const fontThin = 'Thin';

// const fontMedium = 'Medium';

const fontLight = 'Light';
const fontRegular = 'Regular';
// const fontMedium = 'Medium';
const fontSemibold = 'SemiBold';
const fontBold = 'Bold';
const fontInterLight = 'InterLight';
const fontMedium = 'InterRegular';
const fontInterBold = 'InterBold';
const fontInterSemiBold = 'InterSemiBold';
const fontPoppinsBold = 'PoppinsBold';
const fontPoppinsRegular = 'PoppinsRegular';
const fontPoppinsMedium = 'PoppinsMedium';
const fontPoppinsSemiBold = 'PoppinsSemiMedium';
const fontLexendBold = 'LexendBold';
const fontLexendRegular = 'LexendRegular';
const fontLexendMedium = 'LexendMedium';
const fontLexendSemiBold = 'LexendSemiMedium';

/* font sizes*/
const textSizeExtraSmall = 10.0;
const textSizeSmall = 12.0;
const textSizeSMedium = 14.0;
const textSizeMedium = 16.0;
const textSizeLargeMedium = 18.0;
const textSizeNormal = 20.0;
const textSizeLarge = 22.0;
const textSizeXLarge = 30.0;

/* margin */
const spacing_control_half = 2.0;
const spacing_control = 4.0;
const spacing_standard = 8.0;
const spacing_middle = 10.0;
const spacing_standard_new = 16.0;
const spacing_large = 24.0;
const spacing_xlarge = 32.0;
const spacing_xxLarge = 40.0;

const bodyColor = Color(0XFF000700);

Color colorPrimary = Color(0xFF00089E);
//Color(0xff2736BD)

Color colorAccent = Color(0xffF2B34A);
const textColorPrimary = Color(0XFF333333);
const textColorSecondary = Color(0XFF747474);
const colorPrimary_light = Color(0XFFE9E9E9);
const colorPrimaryDark = Color(0XFF212121);
const newClientColor = Color(0XFF7047A7);

const view_color = Color(0XFFDADADA);

const app_background = Color(0XFFE9E9E9);
const icon_color = Color(0XFF747474);
const selected_tab = Color(0XFFFCE9E9);
const primary = Color(0Xff0047ba);
const red = Color(0XFFF10202);
const blue = Color(0XFF1D36C0);
const green = Color(0XFF4CAF50);
const edit_text_background = Color(0XFFE8E8E8);
const shadow = Color(0X70E2E2E5);
const shadow_color = Color(0X95E9EBF0);
const color_primary_light = Color(0XFFFCE8E8);
const bg_bottom_sheet = Color(0XFFFFF1F1);
const white = Color(0XFFffffff);
const white_color = Color(0XFFffffff);

const profileImage = 'assets/images/users.png';
const attach = 'assets/images/icon_attach.svg';

const logo = "assets/images/myky_new_logo_1.png";
const bg = "assets/images/bg.jpeg";
const loginImage = "assets/images/bags.jpeg";
const logo1 = "assets/images/logo1.png";
const noImage = "assets/images/placeholder.png";
const rocket = "assets/images/rocket.gif";
// const login_bg = 'assets/images/login_bg.svg';
const menu = "assets/images/menu.svg";
const cart = "assets/images/cart.svg";

int cartCount = 0;

ListView listviewBuilder(
  ListItemBuilder itemBuilder, {
  @required List? items,
  EdgeInsets? padding,
  int? itemCount,
  bool? shrinkWrap,
  Axis scrollDirection = Axis.vertical,
  ScrollPhysics? scrollPhysics,
}) {
  return ListView.builder(
    itemCount: (items != null) ? items.length : itemCount,
    padding: padding,
    scrollDirection: scrollDirection,
    shrinkWrap: (shrinkWrap != null) ? shrinkWrap : true,
    itemBuilder: (BuildContext ctxt, int index) {
      return index < items!.length
          ? itemBuilder(items[index], index)
          : SizedBox.shrink();
    },
    physics: scrollPhysics,
  );
}

ThemeData buildThemeData() {
  return ThemeData(
    primarySwatch: createMaterialColor(colorPrimary),
    scaffoldBackgroundColor: Color(0xffF5F8FA),
    useMaterial3: true,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
    ),
    dialogBackgroundColor: Colors.white,
    unselectedWidgetColor: Colors.black,
    dividerColor: Colors.white,
    dialogTheme: DialogThemeData(shape: dialogShape()),
    bottomSheetTheme: BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: radiusOnly(
          topLeft: defaultRadius,
          topRight: defaultRadius,
        ),
      ),
      backgroundColor: Colors.white,
    ),
    cardColor: Colors.white,
    radioTheme: RadioThemeData(fillColor: MaterialStateProperty.all(gray)),
    iconTheme: IconThemeData(color: Colors.black, size: 25.sp),
    listTileTheme: const ListTileThemeData(
      iconColor: Colors.black,
      textColor: Colors.black,
    ),
    fontFamily: fontRegular,
    textTheme: TextTheme(
      bodyMedium: TextStyle(
        fontFamily: fontRegular,
        color: Colors.black,
        fontSize: 18.sp,
      ),
      bodyLarge: TextStyle(fontFamily: fontRegular, fontSize: 16.sp),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 17),
      filled: true,
      fillColor: white,
      prefixIconColor: colorPrimary,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: textPrimaryColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: colorPrimary, width: 0.5.w),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: redColor, width: 1.0),
        gapPadding: 0,
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: white, width: 0.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: redColor, width: 1.5),
      ),
      hintStyle: TextStyle(
        color: textPrimaryColor.withOpacity(0.5),
        fontSize: 16.sp,
      ),
      suffixIconColor: black,
      isDense: true,
    ),
    appBarTheme: appBarTheme(),
  );
}

AppBarTheme appBarTheme() {
  return AppBarTheme(
    color: white,
    elevation: 1,
    titleTextStyle: TextStyle(
      fontFamily: fontSemibold,
      fontSize: 16.sp,
      color: Colors.black,
    ),
    actionsIconTheme: IconThemeData(color: Colors.black),
    iconTheme: IconThemeData(color: Colors.black),
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

GridView gridviewBuilder(
  List? items,
  GridItemBuilder itemBuilder, {
  ScrollPhysics? physics,
  EdgeInsets? padding,
  bool? shrinkWrap,
  Axis scrollDirection = Axis.vertical,
  @required int? numberOfColumns,
  @required double? verticleSpacing,
  @required double? horizontalSpacing,
  bool? primary,
  double? childAspectRatio,
}) {
  return GridView.builder(
    itemCount: items!.length,
    padding: padding,
    primary: primary,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: numberOfColumns!,
      crossAxisSpacing: horizontalSpacing!,
      mainAxisSpacing: verticleSpacing!,
      childAspectRatio: childAspectRatio != null ? childAspectRatio : 10 / 10,
    ),
    scrollDirection: scrollDirection,
    shrinkWrap: (shrinkWrap != null) ? shrinkWrap : true,
    itemBuilder: (BuildContext ctxt, int index) {
      return index < items.length
          ? itemBuilder(items[index], index)
          : SizedBox.shrink();
    },
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
  var fontSize = textSizeMedium,
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
          textColor: primary,
          fontFamily: fontMedium,
          fontSize: 14.0,
          isLongText: true,
        ).expand(flex: 45),
        Expanded(
          flex: 55,
          child: Align(
            alignment: Alignment.topRight,
            child: text(
              subLabel,
              fontSize: 16.0,
              fontFamily: fontBold,
              isLongText: true,
            ),
          ),
        ),
      ],
    ),
  );
}

TextStyle primaryTextStyle1({
  double? fontSize,
  Color color = textColorPrimary,
  FontWeight weight = FontWeight.normal,
  String? fontFamily,
  double? letterSpacing,
}) {
  return TextStyle(
    fontSize: fontSize,
    color: color,
    fontWeight: weight,
    fontFamily: fontFamily,
    letterSpacing: letterSpacing,
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

Container inputBoxStyle(
  var hintText, {
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
  GestureTapCallback? onTap,
}) {
  return Container(
    decoration: boxDecoration(radius: 6, showShadow: false, bgColor: white),
    child: TextFormField(
      style: TextStyle(fontSize: textSizeMedium, fontFamily: fontRegular),
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
        isDense: true,
        hintText: hintText,
        filled: true,
        fillColor: white,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        counterText: "",
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: white, width: 0.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: white, width: 0.0),
        ),
      ),
    ),
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
  final overlay = Container(
    color: overlayColor.withOpacity(overlayOpacity.clamp(0.0, 1.0)),
  );

  Widget content = Stack(
    children: [
      Positioned.fill(child: background),
      if (overlayOpacity > 0) Positioned.fill(child: overlay),
      Positioned.fill(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Container(
            padding: padding ?? EdgeInsets.zero,
            color: Colors.transparent,
            child: child,
          ),
        ),
      ),
    ],
  );

  return safeArea ? SafeArea(child: content) : content;
}

Widget formField(
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
      borderRadius: BorderRadius.circular(spacing_standard),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          offset: Offset(3, 3),
          blurRadius: 5,
          spreadRadius: 1,
        ),
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
          borderRadius: BorderRadius.circular(spacing_standard),
          borderSide: BorderSide(color: colorPrimary),
        ),
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(spacing_standard),
          borderSide: BorderSide(color: borderSideColor ?? Colors.transparent),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        counterText: "",
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: textSizeMedium,
          color: textColorSecondary.withOpacity(0.7),
          shadows: [
            Shadow(
              blurRadius: 2.0,
              color: Colors.black.withOpacity(0.1),
              offset: Offset(1, 1),
            ),
          ],
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: textColorSecondary, size: 20)
            : null,
        suffixIcon: suffixWidget,
      ),
      style: TextStyle(
        fontSize: textSizeLargeMedium,
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
      labelStyle: primaryTextStyle1(
        fontSize: 16,
        color: textColorPrimary.withOpacity(0.7),
        fontFamily: fontMedium,
      ),
      // prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      counterText: '',
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black12),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: colorPrimary),
      ),
    ),
    maxLines: maxLines,
  );
}

class CustomButton extends StatefulWidget {
  var textContent;
  VoidCallback? onPressed;
  var isStroked = false;
  Color? customColor;

  CustomButton({
    @required this.textContent,
    @required this.onPressed,
    this.isStroked = false,
    this.customColor,
  });

  @override
  CustomButtonState createState() => CustomButtonState();
}

class CustomButtonState extends State<CustomButton> {
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
          fontFamily: fontSemibold,
          textAllCaps: true,
        ),
        decoration: widget.isStroked
            ? boxDecoration(
                bgColor: Colors.transparent,
                color: widget.customColor != null
                    ? widget.customColor!
                    : colorPrimary,
                radius: 5,
              )
            : boxDecoration(
                bgColor: widget.customColor != null
                    ? widget.customColor!
                    : colorPrimary,
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
            decoration: boxDecoration(
              radius: 10,
              showShadow: true,
              bgColor: Colors.grey[200]!,
            ),
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
                  fontSize: textSizeLargeMedium,
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
  double radius = spacing_middle,
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
        ? [BoxShadow(color: shadow_color, blurRadius: 10, spreadRadius: 2)]
        : [BoxShadow(color: Colors.transparent)],
    border: Border.all(color: color),
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}
