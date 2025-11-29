import 'dart:convert';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';

import '../services/api.dart';
import '../services/auth.dart';
import '../widget/network_image.dart';
import '../widget/theme.dart';

class AppUtils {
  static int videoSize = 20;

  static String getKeyValueFromJsonObject(dynamic jsonObj, String valueToCompare) {
    String valueOfKey = '';
    final data = jsonObj as Map;

    for (var key in data.keys) {
      var value = data[key];
      if (valueToCompare == key) {
        valueOfKey = value;
        break;
      }
    }
    return valueOfKey;
  }

  static String changeDateFormat(String originalDate) {
    DateTime original = DateFormat("yyyy-MM-dd").parse(originalDate);
    var outputFormat = DateFormat('dd-MM-yyyy');
    var converted = outputFormat.format(original);

    return converted;
  }

  static Color setStatusColor(String status) {
    String sts = status.toLowerCase();
    Color colorToReturn = HexColor('#7047a7');
    if (sts == 'success' ||
        sts == 'active' ||
        sts == 'un used' ||
        sts == 'credit' ||
        sts == 'approved' ||
        sts == 'achieved' ||
        sts == 'open' ||
        sts == 'completed' ||
        sts == 'win' ||
        sts == 'dispatched') {
      colorToReturn = const Color(0XFF1abc9c);
    } else if (sts == 'pending' || sts == 'used' || sts == 'not applied' || sts == 'in-checkout') {
      colorToReturn = const Color(0XFFf7b84b);
    } else if (sts == 'blocked') {
      colorToReturn = Colors.black;
    } else if (sts == 'debit' ||
        sts == 'fail' ||
        sts == 'failed' ||
        sts == 'rejected' ||
        sts == 'close' ||
        sts == 'closed' ||
        sts == 'loss' ||
        sts == 'cancelled') {
      colorToReturn = const Color(0XFFf1556c);
    } else if (sts == 'in-progress' ||
        sts == 'authorize' ||
        sts == 'processing' ||
        sts == 'dispatch') {
      colorToReturn = const Color(0XFF4FC6E0);
    } else if (sts == 'blocked') {
      colorToReturn = const Color(0XFF131314);
    }
    return colorToReturn;
  }

  static void onLoading(BuildContext context, String? msg) {
    if (!Get.isDialogOpen!) {
      Get.dialog(WillPopScope(
        onWillPop: () {
          return Future.value(false);
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                    color: Colors.white,
                    // width: 250,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 40,
                            width: 40,
                            child: const CircularProgressIndicator(
                              // backgroundColor: Colors.white,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.green, //<-- SEE HERE
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          DefaultTextStyle(
                            style: const TextStyle(
                                height: 1.5,
                                fontSize: 14,
                                fontFamily: fontBold,
                                color: Colors.black),
                            child: Text(
                              msg ?? "Your documents are\nuploading please wait..",
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                    ))),
          ),
        ),
      ));
    }
  }

  static Future showDialogForImageExpand(
    context, {
    String? imageURL,
    Widget? imageWidget,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            backgroundColor: Colors.lightGreen,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: colorAccent,
                  width: 1.w,
                ),
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1e1f2f46),
                    offset: Offset(
                      0.0,
                      64.0,
                    ),
                    blurRadius: 64.0,
                    spreadRadius: -48.0,
                  ), //BoxShadow
                ],
              ),
              padding: EdgeInsets.all(5.sp),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (imageURL != null)
                    PNetworkImage(
                      imageURL,
                      height: 500.sp,
                      width: 500.sp,
                      fit: BoxFit.fill,
                      borderRadius: 5.r,
                    ),
                  if (imageWidget != null) imageWidget,
                ],
              ),
            ));
      },
    );
  }

  static void handleLinkData(PendingDynamicLinkData data, {String? router}) {
    final Uri uri = data.link;
    String? encodedItemData;
    if (uri != null) {
      final dynamic queryParams = uri.queryParameters;
      if (queryParams.length > 0) {
        encodedItemData =
            queryParams.containsKey('product-detail') ? queryParams['product-detail'] : "";
        // String type = queryParams["type"];
        // verify the id is parsed correctly
      }
      Map itemData = json.decode(encodedItemData!);

      if (uri.path.toString().split('/').last != "register") {
        Get.toNamed(uri.path.toString().split('/').last, arguments: itemData);
      }

      // if (router == "login" && uri.path.toString().split('/').last == "register") {
      //   Get.toNamed("register", arguments: id);
      // } else if (uri.path.toString().split('/').last != "register") {
      //   Get.toNamed(uri.path.toString().split('/').last, arguments: id);
      // }
    }
  }

  static void copyText(text) {
    text.toString().copyToClipboard().then((value) {
      showSuccessSnackBar('Copied', secondsToDisplay: 1);
    });
  }

  static List<Map> getListFromJsonObject(Map jsonObj) {
    List<Map> list = [];
    jsonObj.forEach((key, value) {
      list.add({'id': key, 'type': value});
    });
    return list;
  }


  // static void showErrorSnackBar(String message) {
  //   GetBar(
  //     backgroundColor: Colors.red,
  //     duration: Duration(seconds: 3),
  //     // message: message,
  //     snackPosition: SnackPosition.TOP,
  //     messageText: Center(
  //       child: text(message, textColor: Colors.white, fontSize: 14.0, isLongText: true),
  //     ),
  //   ).show();
  // }
  //
  // static void showSuccessSnackBar(String message) {
  //   GetBar(
  //     backgroundColor: Colors.green,
  //     duration: Duration(seconds: 1),
  //     // message: message,
  //     messageText: Center(
  //       child: text(message, textColor: Colors.white, fontSize: 14.0, isLongText: true),
  //     ),
  //     snackPosition: SnackPosition.TOP,
  //   ).show();
  // }

  static void showErrorSnackBar(String message, {Color? color, int? secondsToDisplay}) {
    if (!Get.isSnackbarOpen) {
      GetSnackBar(
        backgroundColor: color ?? Colors.red,
        duration: Duration(seconds: secondsToDisplay ?? 3),
        snackPosition: SnackPosition.TOP,
        borderRadius: 10.r,
        margin: EdgeInsets.symmetric(
          horizontal: 15.w,
          vertical: 15.h,
        ),
        snackStyle: SnackStyle.FLOATING,
        messageText:
            Center(child: text(message, textColor: Colors.white, fontSize: 14.0, isLongText: true)),
      ).show();
    }
  }

  static void showSuccessSnackBar(String message, {Color? color, int? secondsToDisplay}) {
    GetSnackBar(
      backgroundColor: color ?? Colors.green,
      duration: Duration(seconds: secondsToDisplay ?? 3),
      isDismissible: false,
      snackPosition: SnackPosition.TOP,
      borderRadius: 10.r,
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      snackStyle: SnackStyle.FLOATING,
      messageText:
          Center(child: text(message, textColor: Colors.white, fontSize: 14.0, isLongText: true)),
    ).show();
  }

  static void showInfoSnackBar(String message, {Color? color}) {
    GetBar(
      backgroundColor: color == null ? primary : color,
      duration: Duration(seconds: 3),
      messageText: Center(
        child: text(message, textColor: Colors.white, fontSize: 14.0, isLongText: true),
      ),
      snackPosition: SnackPosition.TOP,
    ).show();
  }

  static redirect(routeName,
      {dynamic arguments,
      String? pageToRedirectAfterLogin,
      Function? callWhileBack,
      Function(dynamic value)? callWhileBackWithValue}) {
    if (routeName == 'login-mlm') {
      Get.toNamed(routeName, arguments: 'justBack')!.then((value) {
        if (Auth.check()! && pageToRedirectAfterLogin != null) {
          Get.toNamed(pageToRedirectAfterLogin);
        }

        if (callWhileBack != null) {
          callWhileBack();
        }
        if (callWhileBackWithValue != null && value != null) {
          callWhileBackWithValue(value);
        }
      });
    } else {
      Get.toNamed(routeName, arguments: arguments)!.then((value) {
        if (Get.isBottomSheetOpen!) {
          Get.back();
        }
        if (callWhileBack != null) {
          callWhileBack();
        }
      });
    }
  }

  static Future<dynamic> fetchPlans({code}) {
    return Api.http.get('https://www.keralarecharge.com/api/', queryParameters: {
      'api_key': 'ec720f6e2b32531ec17ff84f2d131132',
      'module': 'rechargeoffers',
      'operator': code,
      // 'operator': 'PR1',
      'format': 1,
    }).then((response) {
      if (response.data.runtimeType.toString() == 'List<dynamic>') {
        return response.data[0];
      } else {
        if (response.data.containsKey('error')) {
          return 'No Plans Found';
        } else {
          return 'Something Went Wrong';
        }
      }
    });
  }

  static Future<void> startTransaction(data) async {
    try {
      var response = AllInOneSdk.startTransaction(
        data['params']['MID'],
        data['params']['ORDERID'],
        data['amount'].toString(),
        // "1000",
        data['txnToken'],
        data['payTmCallbackUrl'],
        data['isStaging'],
        false,
      );
      response.then((value) {
        callPaymentProcess(data['params']['ORDERID'], data['orderId']);
      }).catchError((onError) {
        callPaymentProcess(data['params']['ORDERID'], data['orderId']);
        if (onError is PlatformException) {
        } else {}
      });
    } catch (err) {}
  }

  static callPaymentProcess(uniqueOrderNo, orderId) {
    Api.http.post('member/recharge/payment-process', data: {
      'order': uniqueOrderNo,
    }).then((response) {
      Get.toNamed('/recharge-thanks', arguments: orderId);
    });
  }

}
