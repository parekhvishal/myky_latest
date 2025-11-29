import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart' hide white;
import 'package:unicons/unicons.dart';

import '../../../services/auth.dart';
import '../../../utils/app_utils.dart';
import '../../../widget/theme.dart';
import '../services/cart_service.dart';
import '../widget/paginated_list.dart';
import 'guest_login_service.dart';

final BottomSheetService bottomSheetService = BottomSheetService();

void showDialogSingleButton(BuildContext context, Map data,
    {GlobalKey<PaginatedListState>? customCode}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.only(right: 16.0),
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(75),
                bottomLeft: Radius.circular(75),
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: <Widget>[
                SizedBox(width: 20.0),
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(
                    data['status'] ? Icons.done : Icons.close,
                    color: data['status'] ? Colors.green : Colors.red,
                    size: 60.0,
                  ),
                ),
                SizedBox(width: 20.0),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        data['status'] ? "Success!" : "Oops!!!",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      SizedBox(height: 10.0),
                      Flexible(
                        child: Text(data['msg']),
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          MaterialButton(
                            child: Text("Ok"),
                            color: Colors.green,
                            colorBrightness: Brightness.dark,
                            onPressed: () {
                              Navigator.pop(context);
                              if (customCode != null) {
                                customCode.currentState!.refresh();
                              }
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget buildWishList(context, {Function? funAfterBack}) {
  return Container(
    width: 35.sp,
    height: 35.sp,
    decoration: BoxDecoration(
      color: const Color(0xFF658D28).withOpacity(0.1),
      border: Border.all(
        color: const Color(0xFF658D28).withOpacity(0.1),
        width: 0.6,
      ),
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF658D28).withOpacity(0.04),
          blurRadius: 2,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: IconButton(
      constraints: BoxConstraints(maxWidth: 35),
      onPressed: () {
        if (Auth.check()! || Auth.isGuestLoggedIn!) {
          AppUtils.redirect('/wishlist', callWhileBack: funAfterBack);
        } else {
          Get.bottomSheet(
            StatefulBuilder(builder: (BuildContext context,
                void Function(void Function()) setDialogState) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20.0),
                      topLeft: Radius.circular(20.0)),
                  color: white,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 12,
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Icon(
                          UniconsLine.times_circle,
                          color: Colors.grey,
                        ).onTap(() {
                          Get.back();
                        }),
                      ),
                      20.height,
                      AppButton(
                        shapeBorder:
                            RoundedRectangleBorder(borderRadius: radius(10)),
                        elevation: 30,
                        width: double.infinity,
                        color: const Color(0xff9afdcd),
                        padding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                        onTap: () {
                          Get.back();
                          bottomSheetService
                              .showBottomSheet(context)
                              .then((value) {
                            if (value != null && value) {
                              AppUtils.redirect('/wishlist',
                                  callWhileBack: funAfterBack);
                            }
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(UniconsLine.user),
                                10.width,
                                Text(
                                  'Login as a guest',
                                  style: TextStyle(
                                    fontFamily: fontBold,
                                    color: black,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      ),
                      20.height,
                      AppButton(
                        shapeBorder:
                            RoundedRectangleBorder(borderRadius: radius(10)),
                        elevation: 30,
                        width: double.infinity,
                        color: const Color(0xff6153d3),
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        onTap: () {
                          Get.back();
                          AppUtils.redirect(
                            'login-mlm',
                            pageToRedirectAfterLogin: '/wishlist',
                            callWhileBack: funAfterBack,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  UniconsLine.user_arrows,
                                  color: Colors.white,
                                ),
                                10.width,
                                Text(
                                  'Login as a myky member',
                                  style: TextStyle(
                                    fontFamily: fontBold,
                                    color: white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      20.height,
                    ],
                  ),
                ),
              );
            }),
          );
        }
      },
      icon: Icon(UniconsLine.heart, size: 18.sp,),
    ),
  );
}

Widget buildNotification(context, {Function? funAfterBack}) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF658D28).withOpacity(0.1),
      border: Border.all(
        color: const Color(0xFF658D28).withOpacity(0.1),
        width: 0.6,
      ),
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF658D28).withOpacity(0.04),
          blurRadius: 2,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: IconButton(
      constraints: BoxConstraints(maxWidth: 35),
      onPressed: () {
        if (Auth.check()! || Auth.isGuestLoggedIn!) {
          AppUtils.redirect('/notification', callWhileBack: funAfterBack);
        } else {
          Get.bottomSheet(
            StatefulBuilder(builder: (BuildContext context,
                void Function(void Function()) setDialogState) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20.0),
                      topLeft: Radius.circular(20.0)),
                  color: white,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 12,
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Icon(
                          UniconsLine.times_circle,
                          color: Colors.grey,
                        ).onTap(() {
                          Get.back();
                        }),
                      ),
                      20.height,
                      AppButton(
                        shapeBorder:
                            RoundedRectangleBorder(borderRadius: radius(10)),
                        elevation: 30,
                        width: double.infinity,
                        color: const Color(0xff9afdcd),
                        padding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                        onTap: () {
                          Get.back();
                          bottomSheetService
                              .showBottomSheet(context)
                              .then((value) {
                            if (value != null && value) {
                              AppUtils.redirect('/notification',
                                  callWhileBack: funAfterBack);
                            }
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(UniconsLine.user),
                                10.width,
                                Text(
                                  'Login as a guest',
                                  style: TextStyle(
                                    fontFamily: fontBold,
                                    color: black,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      ),
                      20.height,
                      AppButton(
                        shapeBorder:
                            RoundedRectangleBorder(borderRadius: radius(10)),
                        elevation: 30,
                        width: double.infinity,
                        color: const Color(0xff6153d3),
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        onTap: () {
                          Get.back();
                          AppUtils.redirect(
                            'login-mlm',
                            pageToRedirectAfterLogin: '/notification',
                            callWhileBack: funAfterBack,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  UniconsLine.user_arrows,
                                  color: Colors.white,
                                ),
                                10.width,
                                Text(
                                  'Login as a myky member',
                                  style: TextStyle(
                                    fontFamily: fontBold,
                                    color: white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      20.height,
                    ],
                  ),
                ),
              );
            }),
          );
        }
      },
      icon: Icon(UniconsLine.bell),
    ),
  );
}

Widget buildMLMCart(context,
    {Function? funAfterBack, bool isHomePage = false}) {
  return Container(
    width: 35.sp,
    height: 35.sp,
    decoration: BoxDecoration(
      color: const Color(0xFF658D28).withOpacity(0.1),
      border: Border.all(
        color: const Color(0xFF658D28).withOpacity(0.1),
        width: 0.6,
      ),
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF658D28).withOpacity(0.04),
          blurRadius: 2,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: InkWell(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            margin: EdgeInsets.only(right: spacing_middle),
            padding: EdgeInsets.all(spacing_standard),
            child: Icon(
              UniconsLine.shopping_bag,
              size: 18.sp,
            ),
          ),
          Positioned(
            right: -2,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorPrimary,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),

              child: Center(
                child: Obx(
                  () => text(
                    Cart.instance.cartCount.value.toString(),
                    textColor: white,
                    fontSize: textSizeSmall,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        if (Auth.check()! || Auth.isGuestLoggedIn!) {
          AppUtils.redirect('/cart', callWhileBack: funAfterBack);
        } else {
          Get.bottomSheet(
            StatefulBuilder(builder: (BuildContext context,
                void Function(void Function()) setDialogState) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20.0),
                      topLeft: Radius.circular(20.0)),
                  color: white,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 12,
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Icon(
                          UniconsLine.times_circle,
                          color: Colors.grey,
                        ).onTap(() {
                          Get.back();
                        }),
                      ),
                      20.height,
                      AppButton(
                        shapeBorder:
                            RoundedRectangleBorder(borderRadius: radius(10)),
                        elevation: 30,
                        width: double.infinity,
                        color: const Color(0xff9afdcd),
                        padding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                        onTap: () {
                          Get.back();
                          bottomSheetService
                              .showBottomSheet(context)
                              .then((value) {
                            if (value != null && value) {
                              AppUtils.redirect('/cart',
                                  callWhileBack: funAfterBack);
                            }
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(UniconsLine.user),
                                10.width,
                                Text(
                                  'Login as a guest',
                                  style: TextStyle(
                                    fontFamily: fontBold,
                                    color: black,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      ),
                      20.height,
                      AppButton(
                        shapeBorder:
                            RoundedRectangleBorder(borderRadius: radius(10)),
                        elevation: 30,
                        width: double.infinity,
                        color: const Color(0xff6153d3),
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        onTap: () {
                          Get.back();
                          AppUtils.redirect(
                            'login-mlm',
                            pageToRedirectAfterLogin: '/cart',
                            callWhileBack: funAfterBack,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  UniconsLine.user_arrows,
                                  color: Colors.white,
                                ),
                                10.width,
                                Text(
                                  'Login as a myky member',
                                  style: TextStyle(
                                    fontFamily: fontBold,
                                    color: white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      20.height,
                    ],
                  ),
                ),
              );
            }),
          );
        }
      },
      radius: spacing_standard_new,
    ),
  );
}

String validateMobile(String? value) {
  String pattern = r'[6789][0-9]{9}$';
  RegExp regExp = new RegExp(pattern);
  if (value!.length == 0) {
    return "Mobile is Required";
  } else if (value.length != 10) {
    return "Mobile number must 10 digits";
  } else if (!regExp.hasMatch(value)) {
    return "Mobile Number invalid";
  }
  return '';
}

String validateWhatsApp(String? value) {
  String pattern = r'[6789][0-9]{9}$';
  RegExp regExp = new RegExp(pattern);
  if (value!.length == 0) {
    return "WhatsApp number is Required";
  } else if (value.length != 10) {
    return "WhatsApp number must 10 digits";
  } else if (!regExp.hasMatch(value)) {
    return "WhatsApp Number invalid";
  }
  return '';
}
