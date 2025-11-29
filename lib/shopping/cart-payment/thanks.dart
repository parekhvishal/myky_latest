import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth.dart';
import '../../services/cart_service.dart';
import '../../services/storage.dart';
import 'package:nb_utils/nb_utils.dart' hide white;
import 'package:unicons/unicons.dart';

import '../../services/api.dart';
import '../../widget/network_image.dart';
import '../../widget/theme.dart';

class Thanks extends StatefulWidget {
  @override
  _ThanksState createState() => _ThanksState();
}

class _ThanksState extends State<Thanks> {
  Future? _future;
  int? orderId;
  Timer? timer;
  int? paymentStatus;

  late Map thanksOrderDetail;

  @override
  void initState() {
    super.initState();
    orderId = Get.arguments;
    _future = getThanks();
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) => getThanks());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future getThanks() {
    return Api.httpWithoutLoader.get('shopping/shipping/thanks/$orderId', queryParameters: {"user_type": Auth.check()! ? 1 : 2}).then((response) {
      if (response.data['status']) {
        setState(() {
          paymentStatus = response.data['order']['paymentStatus'];
          if (paymentStatus == 3) {
            timer!.cancel();
          }
        });
      }
      return response.data;
    });
  }

  Future<bool> willPop() {
    return Future.delayed(Duration.zero).then((value) {
      gotoHome();
      return true;
    });
  }

  gotoHome() {
    Cart.instance.reset();
    Storage.set('isAfterPurchase', true);
    Get.offAllNamed('/ecommerce');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: willPop,
      child: Scaffold(
        body: FutureBuilder(
          future: _future,
          builder: (context, AsyncSnapshot? snapshot) {
            if (!snapshot!.hasData) {
              return Center();
            } else {
              thanksOrderDetail = snapshot.data['order'];
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _thanksBlock(context, thanksOrderDetail),
                    _cartTotals(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      child: CustomButton(
                        textContent: "Home",
                        onPressed: () => gotoHome(),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _thanksBlock(BuildContext context, Map thanksOrderDetail) {
    return Stack(children: <Widget>[
      Container(
        width: double.infinity,
        height: 300,
        color: thanksOrderDetail['messageLabel'] == 1
            ? green
            : thanksOrderDetail['messageLabel'] == 2
                ? orange
                : red,
      ),
      Positioned(
        right: 10,
        top: 40,
        child: GestureDetector(
          onTap: () => gotoHome(),
          child: Icon(
            Icons.close,
            color: white,
          ),
        ),
      ),
      Column(
        children: <Widget>[
          Container(
            height: 90,
            margin: EdgeInsets.only(top: 60),
            child: CircleAvatar(
              backgroundColor: thanksOrderDetail['messageLabel'] == 1
                  ? green
                  : thanksOrderDetail['messageLabel'] == 2
                      ? orange
                      : red,
              radius: 50,
              child: Icon(
                thanksOrderDetail['messageLabel'] == 1
                    ? UniconsLine.check_circle
                    : thanksOrderDetail['messageLabel'] == 2
                        ? UniconsLine.exclamation_circle
                        : UniconsLine.times_circle,
                size: 70.0,
                color: white,
              ),
            ),
          ),
          if (thanksOrderDetail['orderMessageLabel'] != null)
            text(
              thanksOrderDetail['orderMessageLabel'],
              textColor: white,
              fontFamily: fontBold,
              fontSize: textSizeLargeMedium,
              isCentered: true,
              maxLine: 3,
            ),
          if (thanksOrderDetail['message'] != null)
            text(
              '${thanksOrderDetail['message']}',
              maxLine: 3,
              textColor: white,
              fontFamily: fontRegular,
              fontSize: textSizeSmall,
            ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Column(
              children: <Widget>[
                for (Map data in thanksOrderDetail['product']) cartItems(data, context),
              ],
            ),
          ),
        ],
      ),
    ]);
  }

  Widget cartItems(item, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 10,
        top: 10,
        right: 10,
      ),
      decoration: boxDecoration(
        radius: 10,
        showShadow: false,
      ),
      height: 165,
      child: Row(
        children: <Widget>[
          Container(
            width: 120,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                PNetworkImage(
                  item['url'],
                ),
              ],
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: text(
                          item['name'],
                          overflow: TextOverflow.ellipsis,
                          maxLine: 2,
                          fontFamily: fontRegular,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      text(
                        '\₹ ${item['selling_price']}',
                        fontSize: textSizeLargeMedium,
                        fontFamily: fontMedium,
                        textColor: colorPrimaryDark,
                      ),
                    ],
                  ),
                  Flexible(
                    child: text(
                      'Qty : ${item['quantity']}',
                      fontSize: textSizeSMedium,
                      // textColor: green,
                    ),
                  ),
                  Flexible(
                    child: text(
                      '${item['variationDetail']['type']} : ${item['variationDetail']['name']}',
                      fontSize: textSizeSMedium,
                      // textColor: green,
                    ),
                  ),
                  Flexible(
                    child: text(
                      'Total : ${item['totalDp']}',
                      fontSize: textSizeSMedium,
                      // textColor: green,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _cartTotals() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: boxDecoration(
        radius: 10,
        showShadow: true,
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              text(
                "Sub Total",
              ),
              text(
                "\₹ ${thanksOrderDetail['grandTotal']}",
              ),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              text("Delivery Charge"),
              text(
                "\₹ ${thanksOrderDetail['totalShipping']}",
              ),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              text(
                "Total Amount",
                textColor: red,
                fontSize: textSizeLargeMedium,
              ),
              text(
                "\₹ ${thanksOrderDetail['total']}",
                textColor: red,
                fontSize: textSizeLargeMedium,
                fontFamily: fontSemibold,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
