import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class BankingPartner extends StatefulWidget {
  @override
  _BankingPartnerState createState() => _BankingPartnerState();
}

class _BankingPartnerState extends State<BankingPartner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaginatedList(
        pageTitle: 'Banking Partner',
        noDataTitle: 'Banking Partner',
        apiFuture: (int page) async {
          return Api.http.get("member/bank/index?page=$page");
        },
        listItemBuilder: _bankDetailsBuilder,
        resetStateOnRefresh: true,
      ),
    );
  }

  Widget _bankDetailsBuilder(dynamic bank, int index) {
    return Container(
      width: w(80),
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
                            Icon(
                              Icons.domain,
                              color: colorPrimary,
                              size: textSizeXLarge,
                            ),
                            SizedBox(width: w(2)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  text(
                                    bank['name'],
                                    fontFamily: fontBold,
                                  ),
                                  // text(
                                  //   bank['branchName'],
                                  //   textColor: textColorSecondary,
                                  //   fontSize: textSizeSMedium,
                                  //   isLongText: true,
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Container(
                      //   padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      //   decoration: BoxDecoration(
                      //     color: Colors.green,
                      //     borderRadius: BorderRadius.all(
                      //       Radius.circular(5),
                      //     ),
                      //   ),
                      //   child: text(
                      //     bank['acType'],
                      //     textColor: white,
                      //     textAllCaps: true,
                      //     fontFamily: fontSemibold,
                      //     fontSize: textSizeSMedium,
                      //   ),
                      // )
                    ],
                  ),
                  // Divider(height: 25),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: <Widget>[
                  //     Expanded(
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.center,
                  //         children: <Widget>[
                  //           text(
                  //             "Account Holder Name",
                  //             fontFamily: fontBold,
                  //           ),
                  //           SizedBox(height: 4),
                  //           text(
                  //             bank['acHolderName'],
                  //             textColor: textColorSecondary,
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(height: 10),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: <Widget>[
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: <Widget>[
                  //         text(
                  //           "A/C No",
                  //           fontFamily: fontBold,
                  //         ),
                  //         SizedBox(height: 4),
                  //         text(
                  //           bank['acNumber'],
                  //           textColor: textColorSecondary,
                  //         ),
                  //       ],
                  //     ),
                  //     SizedBox(width: 10),
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.end,
                  //       children: <Widget>[
                  //         Align(
                  //           child: text(
                  //             "IFSC",
                  //             fontFamily: fontBold,
                  //           ),
                  //         ),
                  //         SizedBox(height: 4),
                  //         text(
                  //           bank['ifsc'],
                  //           textColor: textColorSecondary,
                  //         ),
                  //       ],
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(height: 10),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: <Widget>[
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: <Widget>[
                  //         text(
                  //           "UPI Id",
                  //           fontFamily: fontBold,
                  //         ),
                  //         SizedBox(height: 4),
                  //         text(
                  //           bank['upi'] ?? "--",
                  //           textColor: textColorSecondary,
                  //         ),
                  //       ],
                  //     ),
                  //     SizedBox(width: 10),
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.end,
                  //       children: <Widget>[
                  //         Align(
                  //           child: text(
                  //             "QR Code",
                  //             fontFamily: fontBold,
                  //           ),
                  //         ),
                  //         SizedBox(height: 4),
                  //         bank['qrImage'] != ''
                  //             ? PNetworkImage(
                  //                 bank['qrImage'],
                  //                 width: 80,
                  //                 height: 80,
                  //                 fit: BoxFit.contain,
                  //               )
                  //             : Image.asset(
                  //                 'assets/images/no_image.png',
                  //                 width: 80,
                  //                 height: 80,
                  //                 fit: BoxFit.contain,
                  //               ),
                  //       ],
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
