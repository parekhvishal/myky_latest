import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicons/unicons.dart';

import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class FundRequestView extends StatefulWidget {
  @override
  _FundRequestViewState createState() => _FundRequestViewState();
}

class _FundRequestViewState extends State<FundRequestView> {
  GlobalKey<PaginatedListState> fundRequestPaginatedListKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      appBarAction: <Widget>[],
      pageTitle: 'Fund Requests',
      apiFuture: (int page) async {
        return Api.http.get("member/fund-request?page=$page");
      },
      listItemBuilder: _fundRequestBuilder,
      key: fundRequestPaginatedListKey,
      resetStateOnRefresh: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed('/fund-request')!.then((value) => fundRequestPaginatedListKey.currentState!.refresh());
        },
        label: text(
          'Create'.toUpperCase(),
          textColor: white,
          fontFamily: fontBold,
        ),
        icon: Icon(
          UniconsLine.plus,
          color: white,
        ),
        backgroundColor: colorPrimary,
      ),
    );
  }

  Widget _fundRequestBuilder(dynamic fundRequest, int index) {
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
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Icon(
                                UniconsLine.slack,
                                color: colorPrimary,
                                size: textSizeXLarge,
                              ),
                            ),
                            SizedBox(width: w(4)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // text(
                                  //   fundRequest['package'],
                                  //   fontFamily: fontBold,
                                  //   isLongText: true,
                                  // ),
                                  text(
                                    fundRequest['date'],
                                    textColor: textColorSecondary,
                                    fontSize: textSizeSMedium,
                                    isLongText: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Container(
                      //   padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      //   decoration: BoxDecoration(
                      //     color: colorAccent,
                      //     borderRadius: BorderRadius.all(
                      //       Radius.circular(25),
                      //     ),
                      //   ),
                      //   child: text(
                      //     fundRequest['noPins'].toString(),
                      //     textColor: white,
                      //     textAllCaps: true,
                      //     fontFamily: fontSemibold,
                      //     fontSize: textSizeSMedium,
                      //   ),
                      // ),
                      SizedBox(width: w(2)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: fundRequest['status'] == "Pending"
                              ? Colors.orange
                              : fundRequest['status'] == "Approved"
                                  ? Colors.green
                                  : Colors.red,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: text(
                          fundRequest['status']['name'],
                          textColor: white,
                          textAllCaps: true,
                          fontFamily: fontSemibold,
                          fontSize: textSizeMedium,
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
                            "Amount",
                            fontFamily: fontBold,
                          ),
                          SizedBox(height: 4),
                          text(
                            fundRequest['amount'],
                            textColor: green,
                          ),
                        ],
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          text(
                            "Payment Mode",
                            fontFamily: fontBold,
                          ),
                          SizedBox(height: 4),
                          text(
                            fundRequest['paymentMode']['name'],
                            textColor: textColorSecondary,
                          ),
                        ],
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Align(
                            child: text(
                              "Reference No",
                              fontFamily: fontBold,
                            ),
                          ),
                          SizedBox(height: 4),
                          text(
                            fundRequest['referenceNo'].toString(),
                            textColor: green,
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
                              "Bank",
                              fontFamily: fontBold,
                            ),
                            SizedBox(height: 4),
                            text(fundRequest['bank'], textColor: textColorSecondary, isLongText: true),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Align(
                              child: text(
                                "Deposit Date",
                                fontFamily: fontBold,
                              ),
                            ),
                            SizedBox(height: 4),
                            text(
                              fundRequest['depositDate'],
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
                    children: [
                      if (fundRequest['payBy'] == 'Online')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            text(
                              "Payment Status",
                              fontFamily: fontBold,
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: fundRequest['status']['name'] == "Pending"
                                    ? Colors.orange
                                    : fundRequest['status']['name'] == "Approved"
                                        ? Colors.green
                                        : Colors.red,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: text(
                                fundRequest['status']['name'],
                                textColor: white,
                                textAllCaps: true,
                                fontFamily: fontSemibold,
                                fontSize: textSizeMedium,
                              ),
                            ),
                          ],
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(
                                '/photo-zoom',
                                arguments: {
                                  // 'url': "https://mlm-scm-services-staging.s3.amazonaws.com/38/0966e0b7-e8c7-462b-9990-59f89bf59c98.png",
                                  'url': fundRequest['receipt'],
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                color: Colors.green,
                              ),
                              child: text(
                                "View Receipt".toUpperCase(),
                                textColor: white,
                                textAllCaps: true,
                                fontFamily: fontSemibold,
                                fontSize: textSizeSMedium,
                              ),
                            ),
                          ),
                        ],
                      )
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
