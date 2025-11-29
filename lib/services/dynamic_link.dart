import 'dart:convert';
import 'dart:developer' as dev;

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:myky_clone/services/storage.dart';
import 'package:myky_clone/utils/app_config.dart';

class DynamicLink {
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  static Map dynamicArgs = {};
  static Future<Uri> createDynamicLink({
    @required String? type,
    @required String? route,
    @required String? itemData,
  }) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: AppConfig.firebaseLink,
      link: Uri.parse('${AppConfig.firebaseLink}$route?$type=$itemData'),
      androidParameters: AndroidParameters(
        packageName: AppConfig.packageName,
      ),
    );

    final ShortDynamicLink shortLink =
    await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    shortLink.shortUrl;
    return shortLink.shortUrl;
  }
  // static Future<Uri> createDynamicLink({@required String? type, @required String? route, @required String? itemData}) async {
  //   final DynamicLinkParameters parameters = DynamicLinkParameters(
  //     uriPrefix: AppConfig.firebaseLink,
  //     link: Uri.parse('${AppConfig.firebaseLink}$route?$type=$itemData'),
  //     androidParameters: AndroidParameters(
  //       packageName: AppConfig.packageName!,
  //     ),
  //   );
  //
  //   final link = await parameters.buildUrl();
  //   final ShortDynamicLink shortenedLink = await DynamicLinkParameters.shortenUrl(
  //     link,
  //     DynamicLinkParametersOptions(shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable),
  //   );
  //   return shortenedLink.shortUrl;
  // }

  static void initDynamicLinkData() async {
    // FirebaseDynamicLinks.getInitialLInk does a call to firebase to get us the real link because we have shortened it.
    var link = await FirebaseDynamicLinks.instance.getInitialLink();
    // This link may exist if the app was opened fresh so we'll want to handle it the same way onLink will.

    if (link != null) {
      handleLinkData(
        link,
        inKillMode: true,
      );
    }
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLink) {
      handleLinkData(dynamicLink);
    });
  }

  static Future<void> handleLinkData(PendingDynamicLinkData data, {bool inKillMode = false}) async {
    final Uri uri = data.link;
    String? encodedItemData;

    if (uri != null) {
      final dynamic queryParams = uri.queryParameters;
      if (queryParams.length > 0) {
        if (queryParams.containsKey('product-detail')) {
          encodedItemData = queryParams['product-detail'];
        } else if (queryParams.containsKey('register')) {
          encodedItemData = queryParams['register'];
        }
      }
      dev.log(encodedItemData!);
      // if (encodedItemData.isNotEmpty) {
      Map itemData = jsonDecode(encodedItemData);
      // }
      if (uri.path.toString().split('/').last != "register") {
        if (!inKillMode) {
          if (Get.currentRoute != '/ecommerce') {
            Get.until((route) => Get.currentRoute == '/ecommerce');
            Future.delayed(const Duration(milliseconds: 500), () {
              Get.toNamed(uri.path.toString().split('/').last, arguments: itemData);
            });
          } else {
            Get.toNamed(uri.path.toString().split('/').last, arguments: itemData);
          }
          // Get.toNamed(uri.path.toString().split('/').last, arguments: itemData);
        } else {
          Storage.set('dynamicLinkArg', itemData);
        }
      } else {
        if (Get.currentRoute == '/ecommerce') {
          Future.delayed(const Duration(milliseconds: 500), () {
            Get.toNamed(uri.path.toString().split('/').last, arguments: itemData);
          });
        }
      }
    }
  }
}
