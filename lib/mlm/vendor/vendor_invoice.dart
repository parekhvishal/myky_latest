import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart' hide white;
import 'package:unicons/unicons.dart';

import '../../../../services/api.dart';
import '../../../../utils/app_utils.dart';
import '../../../../widget/paginated_list.dart';
import '../../../../widget/theme.dart';
import '../../widget/file_download_controller.dart';

class VendorInvoice extends StatefulWidget {
  const VendorInvoice({Key? key}) : super(key: key);

  @override
  _VendorInvoiceState createState() => _VendorInvoiceState();
}

class _VendorInvoiceState extends State<VendorInvoice> {
  // DownloadCtrl downloadCtrl = DownloadCtrl();

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

  Future getGstId(id) {
    return Api.http.get("member/vendor-invoice/gst-invoice/$id").then((response) async {
      if (response.data['status']) {
        setState(() {
          invoiceUrl = response.data['gstInvoiceUrl'];
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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: 'Vendor Invoice',
      isPullToRefresh: false,
      apiFuture: _fetchVendorInvoiceListFromServer,
      listItemBuilder: _vendorInvoiceListBuilder,
      resetStateOnRefresh: true,
    );
  }

  Widget _vendorInvoiceListBuilder(dynamic item, int index) {
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
                      text(item['date'], fontSize: 14.0),
                    ],
                  ),
                  Row(
                    children: [
                      // Column(
                      //   children: [
                      //     text('Invoice', fontSize: 13.0),
                      //     IconButton(
                      //       onPressed: () {
                      //         getId(item['id']);
                      //       },
                      //       constraints: BoxConstraints(),
                      //       icon: Icon(
                      //         UniconsLine.download_alt,
                      //         color: Colors.black54,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(width: 20.0),
                      Column(
                        children: [
                          text('GST Invoice', fontSize: 13.0),
                          IconButton(
                            onPressed: () {
                              getGstId(item['id']);
                            },
                            constraints: BoxConstraints(),
                            icon: Icon(
                              UniconsLine.download_alt,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  text(
                    'Member Id: ',
                    textColor: textColorSecondary,
                    fontSize: textSizeSMedium,
                  ),
                  10.width,
                  text(
                    '${item['memberId']}',
                    textColor: green,
                  ),
                ],
              ),
              Row(
                children: [
                  text(
                    'Member Name: ',
                    textColor: textColorSecondary,
                    fontSize: textSizeSMedium,
                  ),
                  10.width,
                  text(
                    '${item['memberName']}',
                    textColor: green,
                  ),
                ],
              ),
              Row(
                children: [
                  text(
                    'Member Mobile: ',
                    textColor: textColorSecondary,
                    fontSize: textSizeSMedium,
                  ),
                  10.width,
                  text(
                    '${item['memberMobile']}',
                    textColor: green,
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text(
                    'Order No: ',
                    textColor: textColorSecondary,
                    fontSize: textSizeSMedium,
                  ),
                  10.width,
                  Expanded(
                    child: text(
                      '${item['orderNo']}',
                      textColor: green,
                      isLongText: true,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  text(
                    'Invoice No: ',
                    textColor: textColorSecondary,
                    fontSize: textSizeSMedium,
                  ),
                  10.width,
                  text(
                    '${item['invoiceNo']}',
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
                    'Bill Amount: ',
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
              Row(
                children: [
                  text(
                    'Profit Shared: ',
                    textColor: textColorSecondary,
                    fontSize: textSizeSMedium,
                  ),
                  10.width,
                  text(
                    '₹ ${item['companyCharge']}',
                    textColor: green,
                  ),
                ],
              ),
              Row(
                children: [
                  text(
                    'GST Amount: ',
                    textColor: textColorSecondary,
                    fontSize: textSizeSMedium,
                  ),
                  10.width,
                  text(
                    '₹ ${item['gstAmount']}',
                    textColor: green,
                  ),
                ],
              ),
              Row(
                children: [
                  text(
                    'Payable  Amount: ',
                    textColor: textColorSecondary,
                    fontSize: textSizeSMedium,
                  ),
                  10.width,
                  text(
                    '₹ ${item['total']}',
                    textColor: green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _fetchVendorInvoiceListFromServer(int page) async {
    var response = await Api.http.get('member/vendor-invoice?page=$page');
    return response;
  }
}
