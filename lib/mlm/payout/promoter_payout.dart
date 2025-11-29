import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class PromoterPayout extends StatefulWidget {
  const PromoterPayout({super.key});

  @override
  _PromoterPayoutState createState() => _PromoterPayoutState();
}

class _PromoterPayoutState extends State<PromoterPayout> {
  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: 'Promoter Payouts',
      apiFuture: (int page) async {
        return Api.http.get("member/promotor-payouts?page=$page");
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            text(
                              "Mobile Recharge Income (₹)",
                              fontFamily: fontBold,
                              fontweight: FontWeight.w600,
                              isLongText: true,
                            ),
                            SizedBox(height: 4),
                            text(
                              payout['mobileRechargeIncome'] ?? "N/A",
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
                              "DTH Recharge Income (₹)",
                              fontFamily: fontBold,
                              fontweight: FontWeight.w600,
                              isLongText: true,
                            ),
                            SizedBox(height: 4),
                            text(
                              payout['dthRechargeIncome'] ?? "N/A",
                              textColor: textColorSecondary,
                              isLongText: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Divider(height: 25),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: <Widget>[
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: <Widget>[
                  //         text(
                  //           "Gas Bill Income (₹)",
                  //           fontFamily: fontBold,
                  //           fontweight: FontWeight.w600,
                  //           isLongText: true,
                  //         ),
                  //         SizedBox(height: 4),
                  //         text(
                  //           payout['gasBillIncome'],
                  //           textColor: textColorSecondary,
                  //           isLongText: true,
                  //         ),
                  //       ],
                  //     ),
                  //     SizedBox(width: 10),
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.end,
                  //       children: <Widget>[
                  //         text(
                  //           "Electricity Bill Income (₹)",
                  //           fontFamily: fontBold,
                  //           fontweight: FontWeight.w600,
                  //           isLongText: true,
                  //         ),
                  //         SizedBox(height: 4),
                  //         text(
                  //           payout['electricityBillIncome'],
                  //           textColor: textColorSecondary,
                  //           isLongText: true,
                  //         ),
                  //       ],
                  //     ),
                  //   ],
                  // ),
                  Divider(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          text(
                            "Offline Store Income (₹)",
                            fontFamily: fontBold,
                            fontweight: FontWeight.w600,
                            isLongText: true,
                          ),
                          SizedBox(height: 4),
                          text(
                            payout['offlineStoreIncome'] ?? "N/A",
                            textColor: textColorSecondary,
                            isLongText: true,
                          ),
                        ],
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            text(
                              "Online Store Income (₹)",
                              fontFamily: fontBold,
                              fontweight: FontWeight.w600,
                              isCentered: true,
                              isLongText: true,
                            ),
                            SizedBox(height: 4),
                            text(
                              payout['onlineStoreIncome'] ?? "N/A",
                              textColor: textColorSecondary,
                              isLongText: true,
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
                            "Admin Credit (₹)",
                            fontFamily: fontBold,
                            fontweight: FontWeight.w600,
                            isLongText: true,
                          ),
                          SizedBox(height: 4),
                          text(
                            payout['adminCredit'] ?? "N/A",
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
                            "Admin Debit (₹)",
                            fontFamily: fontBold,
                            fontweight: FontWeight.w600,
                            isLongText: true,
                          ),
                          SizedBox(height: 4),
                          text(
                            payout['adminDebit'] ?? "N/A",
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
                    children: [
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
                            payout['amount'] ?? "N/A",
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
                            "Admin Charge (₹)",
                            fontFamily: fontBold,
                            isLongText: true,
                          ),
                          SizedBox(height: 4),
                          text(
                            payout['adminCharge'] ?? "N/A",
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          text(
                            "Gross Amount (₹)",
                            fontFamily: fontBold,
                            fontweight: FontWeight.w600,
                            isLongText: true,
                          ),
                          SizedBox(height: 4),
                          text(
                            payout['grossAmount'] ?? "N/A",
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
                            "TDS (₹)",
                            fontFamily: fontBold,
                            fontweight: FontWeight.w600,
                            isLongText: true,
                          ),
                          SizedBox(height: 4),
                          text(
                            payout['tds'] ?? "N/A",
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          text(
                            "Sales Profit (₹)",
                            fontFamily: fontBold,
                            fontweight: FontWeight.w600,
                            isLongText: true,
                          ),
                          SizedBox(height: 4),
                          text(
                            payout['salesProfitIncome'] ?? "N/A",
                            textColor: textColorSecondary,
                            isLongText: true,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          text(
                            "Payable Amount (₹)",
                            fontFamily: fontBold,
                            fontweight: FontWeight.w600,
                            isLongText: true,
                          ),
                          SizedBox(height: 4),
                          text(
                            payout['payableAmount'] ?? "N/A",
                            textColor: textColorSecondary,
                            isLongText: true,
                          ),
                        ],
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
