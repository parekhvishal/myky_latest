import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart' hide white;

import '../../../widget/customWidget.dart';
import '../../services/api.dart';
import '../../services/auth.dart';
import '../../utils/app_utils.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  int? totalItems;
  String? orderType;

  @override
  void initState() {
    orderType = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: orderType == null
          ? AppBar(
              title: text(
                'Orders'.toUpperCase(),
                fontweight: FontWeight.bold,
              ),
              actions: [
                buildMLMCart(context),
              ],
            )
          : null,
      body: PaginatedList(
        pageTitle: 'Orders',
        resetStateOnRefresh: true,
        isPullToRefresh: true,
        apiFuture: _fetchOrderListFromServer,
        listItemBuilder: _orderListBuilder,
        listWithoutAppbar: orderType == null ? true : false,
      ),
    );
  }

  Widget _orderListBuilder(dynamic item, int index) {
    return InkWell(
      onTap: () {
        Get.toNamed('/my-order-detail', arguments: item['id']);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: EdgeInsets.only(bottom: 0, top: 15, left: 16, right: 16),
        decoration: boxDecorationWithShadow(
          backgroundColor: white,
          borderRadius: BorderRadius.circular(12),
          blurRadius: 2,
          offset: const Offset(0, 5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            text(
              item['orderNo'],
              fontFamily: fontBold,
              isLongText: true,
            ),
            10.height,

            text(item['date'], fontSize: 14.0),
            10.height,
            text(
              "Status",
              fontFamily: fontBold,
              isLongText: true,
            ),
            10.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                        'Payment\n Type',
                        style: TextStyle(fontSize: 14.0),
                        textAlign: TextAlign.center,
                      )),
                      5.height,
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppUtils.setStatusColor(
                              item['paymentType']['name']),
                          // color: item['paymentType']['id'] == 1 ? Colors.cyan : Colors.green,
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        child: text(
                          item['paymentType']['name'],
                          textColor: white,
                          textAllCaps: true,
                          fontFamily: fontSemibold,
                          fontSize: 11.0,
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
                        'Payment\nStatus',
                        style: TextStyle(fontSize: 14.0),
                        textAlign: TextAlign.center,
                      ),
                      5.height,
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppUtils.setStatusColor(
                              item['paymentStatus']['name']),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        child: text(
                          item['paymentStatus']['name'],
                          textColor: white,
                          textAllCaps: true,
                          fontFamily: fontSemibold,
                          fontSize: 11.0,
                        ),
                      ),
                    ],
                  ),
                ).expand(),
              ],
            ),
            // Divider(
            //   height: 3,
            //   color: colorPrimary_light.withOpacity(0.5),
            //   thickness: 1.2,
            // ),
            10.height,

            text(
              "Total",
              fontFamily: fontBold,
              isLongText: true,
            ),
            3.height,

            row_order_detail('Total Items : ', '${item['totalItems']}'),
            row_order_detail('Total Quantity : ', '${item['totalQuantity']}'),
            row_order_detail('Total MRP : ', '₹ ${item['totalMrp']}'),
            row_order_detail('Total Coin Used : ', '${item['totalCoinUsed']}'),
            row_order_detail(
                'Total Selling Price : ', '₹ ${item['totalSellingPrice']}'),
            row_order_detail(
                'Total Taxable Amount : ', '₹ ${item['taxableAmt']}'),
            row_order_detail(
              'Total GST : ',
              '₹ ${item['totalGst']}',
            ),
            row_order_detail(
              'Delivery Charge : ',
              '₹ ${item['totalShipping']}',
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              height: 1,
              color: Colors.black.withOpacity(0.6),
            ),
            row_order_detail('Total Amount : ', '₹ ${item['total']}'),
          ],
        ),
      ),
    );
  }

  Row row_order_detail(String title, String result) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        text(
          title,
          textColor: textColorSecondary,
          fontSize: textSizeSMedium,
        ),
        10.width,
        text(
          result,
          textColor: green,
        ),
      ],
    );
  }

  Future _fetchOrderListFromServer(int page) async {
    var response = await Api.http.get('shopping/order?page=$page',
        queryParameters: {"user_type": Auth.check()! ? 1 : 2});
    return response;
  }
}
