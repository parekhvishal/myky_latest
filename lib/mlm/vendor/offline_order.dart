import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart' hide white;
import 'package:unicons/unicons.dart';

import '../../../../utils/app_utils.dart';
import '../../services/api.dart';
import '../../widget/file_download_controller.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class OffLineOrders extends StatefulWidget {
  const OffLineOrders({super.key});

  @override
  OffLineOrdersState createState() => OffLineOrdersState();
}

class OffLineOrdersState extends State<OffLineOrders> {
  final GlobalKey<PaginatedListState> offlineOrderPaginatedListKey = GlobalKey();

  var invoiceUrl;

  Future getId(id) {
    return Api.http.get("member/vendor-invoice/invoice/$id").then((response) async {
      if (response.data['status']) {
        setState(() {
          invoiceUrl = response.data['invoiceUrl'];
        });
        FileDownloadCtrl().download(
          invoiceUrl,
          context,
        );
        // downloadCtrl.download(invoiceUrl, context);
      } else {
        AppUtils.showErrorSnackBar(response.data['message']);
      }
      return response.data;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    FileDownloadCtrl().dispose();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: 'Offline Orders',
      key: offlineOrderPaginatedListKey,
      isPullToRefresh: true,
      apiFuture: _fetchOrderListFromServer,
      listItemBuilder: _offLinOrderListBuilder,
      resetStateOnRefresh: true,
    );
  }

  Widget _offLinOrderListBuilder(dynamic item, int index) {
    return Card(
      child: Container(
        color: white,
        margin: EdgeInsets.only(bottom: 5),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      text(item['date'], fontSize: 14.0, fontweight: FontWeight.bold),
                      text(
                        item['orderNo'],
                        fontSize: 13.0,
                        isLongText: true,
                        textColor: colorPrimary,
                      ).onTap(() {
                        AppUtils.copyText(item['orderNo']);
                      }),
                    ],
                  ).expand(),
                  if (item['paymentStatus']['id'] == 3)
                    IconButton(
                      onPressed: () {
                        getId(item['id']);
                      },
                      icon: Icon(
                        UniconsLine.download_alt,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
              10.height,
              Row(
                children: [
                  text(
                    'Invoice :',
                    textColor: textColorSecondary,
                    fontSize: textSizeSMedium,
                  ),
                  10.width,
                  text(
                    '${item['invoiceNo']}',
                  ),
                ],
              ),
              10.height,
              Divider(
                height: 3,
                color: colorPrimary_light.withOpacity(0.5),
                thickness: 1.2,
              ),
              Row(
                children: [
                  text(
                    'Bill Amount :',
                    textColor: textColorSecondary,
                    fontSize: textSizeSMedium,
                  ),
                  10.width,
                  text(
                    '₹ ${item['amount']}',
                    textColor: green,
                  ),
                ],
              ),
              10.height,
              Divider(
                height: 3,
                color: colorPrimary_light.withOpacity(0.5),
                thickness: 1.2,
              ),
              Row(
                children: [
                  text(
                    'Point :',
                    textColor: textColorSecondary,
                    fontSize: textSizeSMedium,
                  ),
                  10.width,
                  text(
                    '${item['point']}',
                    textColor: green,
                  ),
                ],
              ),
              10.height,
              Divider(
                height: 3,
                color: colorPrimary_light.withOpacity(0.5),
                thickness: 1.2,
              ),
              Row(
                children: [
                  text(
                    'Payment Type :',
                    textColor: textColorSecondary,
                    fontSize: textSizeSMedium,
                  ),
                  10.width,
                  text(
                    item['paymentType'] != null ? '${item['paymentType']['name']}' : 'N/A',
                    textColor: item['paymentType'] != null
                        ? AppUtils.setStatusColor(item['paymentType']['name'])
                        : colorPrimary,
                  ),
                ],
              ),
              10.height,
              Divider(
                height: 3,
                color: colorPrimary_light.withOpacity(0.5),
                thickness: 1.2,
              ),
              Row(
                children: [
                  text(
                    'Myky Payment Status :',
                    textColor: textColorSecondary,
                    fontSize: textSizeSMedium,
                  ),
                  10.width,
                  text(
                    item['paymentStatus'] != null ? '${item['paymentStatus']['name']}' : 'N/A',
                    textColor: item['paymentStatus'] != null
                        ? AppUtils.setStatusColor(item['paymentStatus']['name'])
                        : colorPrimary,
                  ),
                ],
              ),
              10.height,
              Divider(
                height: 3,
                color: colorPrimary_light.withOpacity(0.5),
                thickness: 1.2,
              ),
              Row(
                children: [
                  text(
                    'Vendor Payment Status :',
                    textColor: textColorSecondary,
                    fontSize: textSizeSMedium,
                  ),
                  10.width,
                  text(
                    item['step2paymentStatus'] != null
                        ? '${item['step2paymentStatus']['name']}'
                        : 'N/A',
                    textColor: item['step2paymentStatus'] != null
                        ? AppUtils.setStatusColor(item['step2paymentStatus']['name'])
                        : colorPrimary,
                  ),
                ],
              ),
              if (item['resumeStatus'] == true) ...[
                10.height,
                Divider(
                  height: 3,
                  color: colorPrimary_light.withOpacity(0.5),
                  thickness: 1.2,
                ),
                Center(
                  child: CustomButton(
                    textContent: 'Resume',
                    onPressed: () {
                      Get.toNamed(
                        '/qr-view',
                        arguments: item,
                      )!
                          .then((value) {
                        offlineOrderPaginatedListKey.currentState!.refresh();
                      });
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future _fetchOrderListFromServer(int page) async {
    var response = await Api.http.get('shopping/offline-store?page=$page');
    return response;
  }
}
