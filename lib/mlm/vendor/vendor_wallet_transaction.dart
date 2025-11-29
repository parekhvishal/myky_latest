import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart' hide white;

import '../../../../services/api.dart';
import '../../../../widget/paginated_list.dart';
import '../../../../widget/theme.dart';

class VendorWalletTransactionOld extends StatefulWidget {
  const VendorWalletTransactionOld({Key? key}) : super(key: key);

  @override
  VendorWalletTransactionOldState createState() => VendorWalletTransactionOldState();
}

class VendorWalletTransactionOldState extends State<VendorWalletTransactionOld> {
  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: 'Vendor Wallet Transaction',
      isPullToRefresh: false,
      apiFuture: _fetchVendorWalletListFromServer,
      listItemBuilder: _vendorWalletListBuilder,
    );
  }

  Widget _vendorWalletListBuilder(dynamic item, int index) {
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
                  text(item['date'], fontSize: 14.0),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: item['type'] == 'Credit' ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: text(
                      item['type'],
                      textColor: white,
                      textAllCaps: true,
                      fontFamily: fontSemibold,
                      fontSize: textSizeSMedium,
                    ),
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
                    'Amount: ',
                    textColor: textColorSecondary,
                    fontSize: textSizeSMedium,
                  ),
                  10.width,
                  text(
                    '\₹ ${item['amount']}',
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
                    '\₹ ${item['companyCharge']}',
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
                    '\₹ ${item['gstAmount']}',
                    textColor: green,
                  ),
                ],
              ),
              Row(
                children: [
                  text(
                    'Payable Amount: ',
                    textColor: textColorSecondary,
                    fontSize: textSizeSMedium,
                  ),
                  10.width,
                  text(
                    '\₹ ${item['total']}',
                    textColor: green,
                  ),
                ],
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     text(
              //       'Remark: ',
              //       textColor: textColorSecondary,
              //       fontSize: textSizeSMedium,
              //     ),
              //     10.width,
              //     Expanded(
              //       child: text(
              //         item['remark'],
              //         textColor: green,
              //         isLongText: true,
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Future _fetchVendorWalletListFromServer(int page) async {
    var response = await Api.http.get('member/vendor-wallet-transaction?page=$page');
    return response;
  }
}
