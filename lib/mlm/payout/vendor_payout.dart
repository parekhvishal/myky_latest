import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:unicons/unicons.dart';

import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class VendorPayout extends StatefulWidget {
  @override
  _VendorPayoutState createState() => _VendorPayoutState();
}

class _VendorPayoutState extends State<VendorPayout> {
  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: 'Vendor Payouts',
      apiFuture: (int page) async {
        return Api.http.get("member/vendor-payouts?page=$page");
      },
      listItemBuilder: _payoutBuilder,
      resetStateOnRefresh: true,
    );
  }

  Widget _payoutBuilder(dynamic payout, int index) {
    return Container(
      decoration: boxDecoration(
        showShadow: true,
        bgColor: white,
        radius: 10.0,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: 7.5,
        vertical: 7.5,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Icon(
                                UniconsLine.file,
                                color: colorPrimary,
                                size: textSizeXLarge,
                              ),
                            ),
                            SizedBox(width: w(4)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  text(
                                    payout['createdAt'],
                                    fontFamily: fontBold,
                                    isLongText: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          text(
                            "Amount (₹)",
                            fontFamily: fontBold,
                            fontweight: FontWeight.w600,
                            isLongText: true,
                          ),
                          SizedBox(height: 4),
                          text(
                            payout['amount'],
                            textColor: textColorSecondary,
                            isLongText: true,
                          ),
                        ],
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          text(
                            "PROFIT SHARED (₹)",
                            fontFamily: fontBold,
                            fontweight: FontWeight.w600,
                            isLongText: true,
                          ),
                          SizedBox(height: 4),
                          text(
                            payout['companyCharge'],
                            textColor: textColorSecondary,
                            isLongText: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            text(
                              "GST AMOUNT (₹)",
                              fontFamily: fontBold,
                              fontweight: FontWeight.w600,
                              isLongText: true,
                            ),
                            SizedBox(height: 4),
                            text(
                              payout['gstAmount'],
                              textColor: textColorSecondary,
                              isLongText: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            text(
                              "PAYABLE AMOUNT (₹)",
                              fontFamily: fontBold,
                              fontweight: FontWeight.w600,
                              isLongText: true,
                            ),
                            SizedBox(height: 4),
                            text(
                              payout['payableAmount'],
                              textColor: textColorSecondary,
                              isLongText: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 25),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
