import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/app_utils.dart';
import 'api.dart';
import 'auth.dart';

class Cart extends GetxService {
  RxList cartItems = [].obs;
  static Cart get instance => Get.find();
  RxInt cartCount = 0.obs;
  // int get totalItems => cartItems.length;

  Cart() {
    fetchCartList();
  }

  Future add(BuildContext context, String productID, int userType,
      {bool isMessageShow = false, bool isBuyNow = false}) async {
    await Api.httpWithoutLoader.post('shopping/cart/add',
        data: {'product_price_id': productID, 'qty': 1, 'user_type': userType}).then((response) {
      if (response.data['status']) {
        HapticFeedback.heavyImpact();
        List products = response.data['cart']['products'];
        updateCart(products);
        if (isMessageShow == true) {
          toasty(
            context,
            response.data['message'],
            bgColor: greenColor,
            textColor: white,
          );
        }
        if (isBuyNow == true) {
          Get.toNamed('/cart');
        }
      } else {
        AppUtils.showErrorSnackBar(response.data['message']);
      }
    });
  }

  Future remove(BuildContext context, String productID, int userType) async {
    await Api.httpWithoutLoader.post('shopping/cart/remove',
        data: {'product_price_id': productID, 'user_type': userType}).then((response) {
      if (response.data['status']) {
        List products = response.data['cart']['products'];
        updateCart(products);
        HapticFeedback.heavyImpact();
        toasty(
          context,
          response.data['message'],
          bgColor: greenColor,
          textColor: white,
        );
      } else {
        AppUtils.showErrorSnackBar(response.data['message']);
      }
    });
  }

  void updateCart(List<dynamic> products) {
    cartItems = RxList.from(products);
    cartCount.value = cartItems.length;
  }

  Future refresh() {
    return Future.value();
  }

  Future addQuantity({required int productID}) {
    return Future.value();
  }

  Future subtractQuantity(BuildContext context, String productID, int userType) async {
    await Api.httpWithoutLoader.post('shopping/cart/subtract',
        data: {'product_price_id': productID, 'qty': 1, 'user_type': userType}).then((response) {
      if (response.data['status']) {
        List products = response.data['cart']['products'];
        updateCart(products);
        HapticFeedback.heavyImpact();
      } else {
        AppUtils.showErrorSnackBar(response.data['message']);
      }
    });
  }

  void fetchCartList() {
    if (Auth.check()! || Auth.isGuestLoggedIn!) {
      Api.httpWithoutLoader.get('shopping/cart',
          queryParameters: {"user_type": Auth.check()! ? 1 : 2}).then((response) {
        if (response.data['status']) {
          List products = response.data['cart']['products'];
          updateCart(products);
        }
      });
    }
  }

  void reset() {
    cartItems = [].obs;
    cartCount = 0.obs;
  }
}
