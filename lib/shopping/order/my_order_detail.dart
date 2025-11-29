import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart' hide white;
import 'package:unicons/unicons.dart';

import '../../services/api.dart';
import '../../services/auth.dart';
import '../../utils/app_utils.dart';
import '../../widget/file_download_controller.dart';
import '../../widget/network_image.dart';
import '../../widget/theme.dart';

class MyOrderDetail extends StatefulWidget {
  @override
  _MyOrderDetailState createState() => _MyOrderDetailState();
}

class _MyOrderDetailState extends State<MyOrderDetail> {
  late int id;
  Map? orderData;
  late Future orderFuture;

  var invoiceUrl;
  String? invoiceId;

  List? returnTypes;

  @override
  void initState() {
    id = Get.arguments;
    orderFuture = orderDetails();
    super.initState();
  }

  @override
  void dispose() {
    FileDownloadCtrl().dispose();
    super.dispose();
  }

  Future orderDetails() {
    return Api.http.get("shopping/order/show/$id",
        queryParameters: {"user_type": Auth.check()! ? 1 : 2}).then((response) {
      setState(() {
        returnTypes = response.data['returnTypes'];
        orderData = response.data['order'];
      });
      return response.data;
    });
  }

  int? currStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Order Detail'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 8,
            ),
            Expanded(
              child: FutureBuilder(
                future: orderFuture,
                builder: (context, AsyncSnapshot? snapshot) {
                  if (!snapshot!.hasData) {
                    return Center();
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        _buildOrdersList(context),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 8.0),
            if (orderData != null) _buildPayment(context)
          ],
        ));
  }

  Widget _buildOrdersList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < orderData!['products'].length; i++)
          productDetail(orderData!['products'][i]),
      ],
    );
  }

  Widget productDetail(Map product) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      margin: EdgeInsets.only(
        bottom: 15,
        left: 15,
        right: 15,
      ),
      decoration: boxDecorationWithShadow(
        backgroundColor: Colors.white,
        borderRadius: BorderRadius.circular(8),
        blurRadius: 2,
        offset: const Offset(0, 5),
      ),
      // height: h(34),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order ID - ${product['subOrderNo']}',
            style: TextStyle(fontSize: 12, fontFamily: fontMedium, color: gray),
          ),
          10.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 100,
                child: Stack(
                  children: <Widget>[
                    if (product['url'] != null)
                      PNetworkImage(
                        product['url'],
                      ),
                  ],
                ),
              ),
              12.width,
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text(
                    product['name'] ?? '',
                    overflow: TextOverflow.ellipsis,
                    fontFamily: fontMedium,
                    fontSize: 15.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      text(
                        '\₹ ${product['selling_price']}',
                        textColor: colorPrimary,
                        fontFamily: fontMedium,
                        fontSize: 13.0,
                        fontweight: FontWeight.w600,
                      ),
                      SizedBox(width: 6),
                      text(
                        '\₹ ${product['mrp']}',
                        decoration: TextDecoration.lineThrough,
                        fontSize: 13.0,
                      )
                    ],
                  ),
                  text(
                    'Quantity' + ' : ' + product['quantity'].toString(),
                    fontSize: 13.0,
                  ),
                ],
              ).expand()
            ],
          ),
          10.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.black.withOpacity(0.6), width: 1)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Center(
                        child: Text(
                      'Delivery\n Status',
                      style: TextStyle(fontSize: 14.0),
                      textAlign: TextAlign.center,
                    )),
                    5.height,
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppUtils.setStatusColor(
                            product['deliveryStatus']['name']),
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: text(
                        product['deliveryStatus']['name'],
                        textColor: white,
                        textAllCaps: true,
                        fontFamily: fontSemibold,
                        fontSize: 9.0,
                      ),
                    ),
                  ],
                ),
              ).expand(),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                padding: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.black.withOpacity(0.6), width: 1)),
                child: Column(
                  children: [
                    Center(
                        child: Text(
                      'Payment\n Status',
                      style: TextStyle(fontSize: 14.0),
                      textAlign: TextAlign.center,
                    )),
                    5.height,
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppUtils.setStatusColor(
                            product['paymentStatus']['name']),
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: text(
                        product['paymentStatus']['name'],
                        textColor: white,
                        textAllCaps: true,
                        fontFamily: fontSemibold,
                        fontSize: 9.0,
                      ),
                    ),
                  ],
                ),
              ).expand(),
              Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.black.withOpacity(0.6), width: 1)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Order\nStatus',
                      style: TextStyle(fontSize: 14.0),
                      textAlign: TextAlign.center,
                    ),
                    5.height,
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            AppUtils.setStatusColor(product['status']['name']),
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: text(
                        product['status']['name'],
                        textColor: white,
                        textAllCaps: true,
                        fontFamily: fontSemibold,
                        fontSize: 9.0,
                      ),
                    ),
                  ],
                ),
              ).expand(),
            ],
          ),
          10.height,
          if (product['returnStatusDetail'] != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                text(
                  'Return Status :',
                  fontSize: 12.0,
                  textColor: gray,
                  fontFamily: fontMedium,
                  fontweight: FontWeight.w600,
                ),
                text(
                  product['returnStatusDetail']['name'],
                  fontSize: 12.0,
                  fontFamily: fontMedium,
                  textColor: AppUtils.setStatusColor(
                      product['returnStatusDetail']['name']),
                  fontweight: FontWeight.w600,
                ),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              text(
                'Product Code :',
                fontSize: 12.0,
                textColor: gray,
                fontFamily: fontMedium,
                fontweight: FontWeight.w600,
              ),
              text(
                '${product['sku']}',
                fontSize: 12.0,
                fontFamily: fontMedium,
                textColor: Colors.black,
                fontweight: FontWeight.w600,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              text(
                '${product['variationDetail']['type']} :',
                fontSize: 12.0,
                textColor: gray,
                fontFamily: fontMedium,
                fontweight: FontWeight.w600,
              ),
              text(
                '${product['variationDetail']['name']}',
                fontSize: 12.0,
                fontFamily: fontMedium,
                textColor: Colors.black,
                fontweight: FontWeight.w600,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              text(
                'Selling Price :',
                fontSize: 12.0,
                textColor: gray,
                fontFamily: fontMedium,
                fontweight: FontWeight.w600,
              ),
              text(
                '\₹ ${product['selling_price']}',
                fontSize: 12.0,
                fontFamily: fontMedium,
                textColor: Colors.black,
                fontweight: FontWeight.w600,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              text(
                'Taxable Amount :',
                fontSize: 12.0,
                textColor: gray,
                fontFamily: fontMedium,
                fontweight: FontWeight.w600,
              ),
              text(
                '\₹ ${product['taxableAmt']}',
                fontFamily: fontMedium,
                textColor: Colors.black,
                fontSize: 12.0,
                fontweight: FontWeight.w600,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              text(
                'GST Amount :',
                fontSize: 12.0,
                textColor: gray,
                fontFamily: fontMedium,
                fontweight: FontWeight.w600,
              ),
              text(
                ' \₹ ${product['gstAmt']}',
                fontFamily: fontMedium,
                fontSize: 12.0,
                textColor: Colors.black,
                fontweight: FontWeight.w600,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              text(
                'Delivery Charge :',
                fontSize: 12.0,
                textColor: gray,
                fontFamily: fontMedium,
                fontweight: FontWeight.w600,
              ),
              text(
                ' \₹ ${product['totalShipping']}',
                fontFamily: fontMedium,
                fontSize: 12.0,
                textColor: Colors.black,
                fontweight: FontWeight.w600,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              text(
                'Total : ',
                fontSize: 13.0,
                fontFamily: fontBold,
                fontweight: FontWeight.w600,
              ),
              text(
                '\₹ ${product['total']}',
                fontSize: 13.0,
                fontFamily: fontBold,
                fontweight: FontWeight.w600,
              ),
            ],
          ),
          4.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              text(
                'Total Coin Used : ',
                fontSize: 13.0,
                fontFamily: fontBold,
                fontweight: FontWeight.w600,
              ),
              text(
                '${product['totalCoinUsed']}',
                fontSize: 13.0,
                fontFamily: fontBold,
                fontweight: FontWeight.w600,
              ),
            ],
          ),
          4.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (product['paymentStatus']['id'] == 3)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: colorPrimary),
                  child: text(
                      product['inReviewList'] ? 'Edit Review' : 'Add Review',
                      textColor: Colors.white,
                      fontSize: 12.0),
                ).onTap(() {
                  Get.toNamed('/review-add', arguments: {
                    "editType": product['inReviewList'],
                    "product": product,
                  })!
                      .then((value) {
                    setState(() {
                      orderFuture = orderDetails();
                    });
                  });
                }),
              if (product['returnStatus'] != null && product['returnStatus'])
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: greenColor),
                  child:
                      text('Return', textColor: Colors.white, fontSize: 12.0),
                ).onTap(() {
                  Get.toNamed('/product-return', arguments: {
                    "returnTypes": returnTypes,
                    "orderID": product['orderProductId']
                  })!
                      .then((value) {
                    setState(() {
                      orderFuture = orderDetails();
                    });
                  });
                }),
              if (product['deliveryStatus']['id'] != 5 &&
                  product['paymentStatus']['id'] == 3 &&
                  product['status']['id'] != 3)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Color(0XFFf1556c)),
                  child: text('Cancel order',
                      textColor: Colors.white, fontSize: 12.0),
                ).onTap(() {
                  cancelPopUp(product);
                }),
            ],
          ),
          10.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (product['invoiceNumber'] != null)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: colorAccent),
                  child: Center(
                      child: text('Download Invoice',
                          textColor: Colors.white, fontSize: 12.0)),
                ).onTap(() {
                  getInvoiceUrl(product['orderProductId']);
                }),
              if (product['trackingUrl'] != null)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.lightBlue),
                  child: Center(
                      child: text('Track Order',
                          textColor: Colors.white, fontSize: 12.0)),
                ).onTap(() {
                  Get.toNamed('/track-shipment', arguments: product);
                  // launch(product['trackingUrl']);
                }),
            ],
          ),
        ],
      ),
    );
  }

  Future<dynamic> cancelPopUp(Map<dynamic, dynamic> product) {
    return Get.dialog(Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: text(
                  'Are you sure want to cancel ?',
                  isLongText: true,
                  fontFamily: fontBold,
                  textColor: colorPrimaryDark,
                ),
              ),
              SizedBox(height: 10),
              Divider(
                color: textColorSecondary,
                height: 1,
                thickness: 0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(
                        UniconsLine.multiply,
                        color: red,
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    child: VerticalDivider(
                      color: textColorSecondary,
                      width: 1,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        Api.http.post(
                            'shopping/order/cancel-order/${product['orderProductId']}',
                            data: {
                              "user_type": Auth.check()! ? 1 : 2
                            }).then((response) {
                          if (response.data['status']) {
                            setState(() {
                              orderFuture = orderDetails();
                            });
                            AppUtils.showSuccessSnackBar(
                                response.data['message']);
                          } else {
                            AppUtils.showErrorSnackBar(
                                response.data['message']);
                          }
                        });
                      },
                      child: Icon(
                        UniconsLine.check,
                        color: green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildPayment(context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: boxDecoration(
        radius: 0,
        showShadow: true,
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              text(
                "Total Amount : ",
                textColor: red,
                fontSize: textSizeLargeMedium,
              ),
              text(
                "\₹ " + orderData!['total'],
                textColor: redColor,
                fontSize: textSizeLargeMedium,
                fontFamily: fontSemibold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future getInvoiceUrl(int id) {
    return Api.http.get("shopping/order/order-invoice/$id", queryParameters: {
      "user_type": Auth.check()! ? 1 : 2
    }).then((response) async {
      if (response.data['status']) {
        invoiceUrl = response.data['url'];
        FileDownloadCtrl().download(
          invoiceUrl,
          context,
        );
      }
      return response.data;
    });
  }
}
