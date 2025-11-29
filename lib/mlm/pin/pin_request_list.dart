import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicons/unicons.dart';

import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class PinRequestList extends StatefulWidget {
  @override
  _PinRequestListState createState() => _PinRequestListState();
}

class _PinRequestListState extends State<PinRequestList> {
  GlobalKey<PaginatedListState> pinRequestPaginatedListKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      key: pinRequestPaginatedListKey,
      pageTitle: 'Pin Requests',
      resetStateOnRefresh: true,
      apiFuture: (int page) async {
        return Api.http.get("member/pin-requests?page=$page");
      },
      listItemBuilder: _pinRequestBuilder,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed('/pin-request')!.then((value) => pinRequestPaginatedListKey.currentState!.refresh());
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

  Widget _pinRequestBuilder(dynamic pinRequest, int index) {
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
                                  text(
                                    pinRequest['package'],
                                    fontFamily: fontBold,
                                    isLongText: true,
                                  ),
                                  text(
                                    pinRequest['createdAt'],
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
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorAccent,
                          borderRadius: BorderRadius.all(
                            Radius.circular(25),
                          ),
                        ),
                        child: text(
                          pinRequest['noPins'].toString(),
                          textColor: white,
                          textAllCaps: true,
                          fontFamily: fontSemibold,
                          fontSize: textSizeSMedium,
                        ),
                      ),
                      SizedBox(width: w(2)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: pinRequest['status'] == "Pending"
                              ? Colors.orange
                              : pinRequest['status'] == "Approved"
                                  ? Colors.green
                                  : Colors.red,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: text(
                          pinRequest['status'],
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
                            "Bank",
                            fontFamily: fontBold,
                          ),
                          SizedBox(height: 4),
                          text(
                            pinRequest['bank'] ?? 'N/A',
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
                              "Ref No",
                              fontFamily: fontBold,
                            ),
                          ),
                          SizedBox(height: 4),
                          text(
                            pinRequest['referenceNo'] ?? 'N/A',
                            textColor: green,
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
                            "Payment Mode",
                            fontFamily: fontBold,
                          ),
                          SizedBox(height: 4),
                          text(
                            pinRequest['paymentMode'] ?? 'N/A',
                            textColor: colorPrimary,
                            fontFamily: fontBold,
                          ),
                        ],
                      ),
                      SizedBox(width: 10),
                      Column(
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
                            pinRequest['depositDate'] ?? 'N/A',
                            textColor: textColorSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Get.toNamed(
                            '/photo-zoom',
                            arguments: {'url': pinRequest['receipt']},
                          );
                        },
                        child: text('View Receipt'),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
