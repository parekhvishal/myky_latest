import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import '../../services/auth.dart';
import '../../utils/app_utils.dart';
import '../../widget/network_image.dart';
import 'package:nb_utils/nb_utils.dart' hide white;

import '../../services/api.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class MyReturnOrders extends StatefulWidget {
  @override
  _MyReturnOrdersState createState() => _MyReturnOrdersState();
}

class _MyReturnOrdersState extends State<MyReturnOrders> {
  int? totalItems;
  String? orderType;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaginatedList(
        pageTitle: 'Return Orders',
        resetStateOnRefresh: true,
        isPullToRefresh: true,
        apiFuture: _fetchOrderListFromServer,
        listItemBuilder: _orderListBuilder,
        // listWithoutAppbar: orderType == null ? true : false,
      ),
    );
  }

  Widget _orderListBuilder(dynamic item, int index) {
    return InkWell(
      onTap: () {
        // Get.toNamed('/my-order-detail', arguments: item['id']);
      },
      child: Container(
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
            text(
              item['createdAt'],
              isLongText: true,
              fontSize: 13.0,
            ),
            10.height,
            text(
              item['subOrderNo'],
              isLongText: true,
              fontSize: 13.0,
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
                      if (item['url'] != null)
                        PNetworkImage(
                          item['url'],
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
                      item['name'] ?? '',
                      overflow: TextOverflow.ellipsis,
                      fontFamily: fontMedium,
                      fontSize: 15.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        text(
                          '\₹ ${item['selling_price']}',
                          textColor: colorPrimary,
                          fontFamily: fontMedium,
                          fontSize: 13.0,
                          fontweight: FontWeight.w600,
                        ),
                        SizedBox(width: 6),
                        text(
                          '\₹ ${item['mrp']}',
                          decoration: TextDecoration.lineThrough,
                          fontSize: 13.0,
                        )
                      ],
                    ),
                    text(
                      'Quantity' + ' : ' + item['quantity'].toString(),
                      fontSize: 13.0,
                    ),
                  ],
                ).expand()
              ],
            ),
            10.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black.withOpacity(0.6), width: 1)),
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
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppUtils.setStatusColor(item['deliveryStatus']['name']),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        child: text(
                          item['deliveryStatus']['name'],
                          textColor: white,
                          textAllCaps: true,
                          fontFamily: fontSemibold,
                          fontSize: 9.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black.withOpacity(0.6), width: 1)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Center(
                          child: Text(
                        'Return\n Status',
                        style: TextStyle(fontSize: 14.0),
                        textAlign: TextAlign.center,
                      )),
                      5.height,
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppUtils.setStatusColor(item['returnStatusDetail']['name']),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        child: text(
                          item['returnStatusDetail']['name'],
                          textColor: white,
                          textAllCaps: true,
                          fontFamily: fontSemibold,
                          fontSize: 9.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            10.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                text(
                  '${item['variationDetail']['type']} :',
                  fontSize: 12.0,
                  textColor: gray,
                  fontFamily: fontMedium,
                  fontweight: FontWeight.w600,
                ),
                text(
                  '${item['variationDetail']['name']}',
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
                  '\₹ ${item['selling_price']}',
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
                  '\₹ ${item['taxableAmt']}',
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
                  ' \₹ ${item['gstAmt']}',
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
                  '\₹ ${item['totalShipping']}',
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
                  '\₹ ${item['total']}',
                  fontSize: 13.0,
                  fontFamily: fontBold,
                  fontweight: FontWeight.w600,
                ),
              ],
            ),
            if (item['returnRejectReason'] != null) ...[
              10.height,
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  text(
                    'Reject Reason : ',
                    fontSize: 13.0,
                    fontFamily: fontBold,
                    fontweight: FontWeight.w600,
                  ),
                  Flexible(
                    child: text(
                      '${item['returnRejectReason']}',
                      fontSize: 13.0,
                      isLongText: true,
                    ),
                  ),
                ],
              ),
            ],
            10.height,
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: greenColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: text(
                  'View',
                  textColor: white,
                  textAllCaps: true,
                  fontFamily: fontSemibold,
                  fontSize: 13.0,
                ),
              ).onTap(() {
                Get.toNamed('/view-return-order', arguments: item);
              }),
            ),
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
    var response = await Api.http.get('shopping/return-order?page=$page', queryParameters: {"user_type": Auth.check()! ? 1 : 2});
    return response;
  }
}
