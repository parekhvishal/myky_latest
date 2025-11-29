import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicons/unicons.dart';

import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class WithdrawalList extends StatefulWidget {
  @override
  _WithdrawalListState createState() => _WithdrawalListState();
}

class _WithdrawalListState extends State<WithdrawalList> {
  GlobalKey<PaginatedListState> withdrawalListKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      key: withdrawalListKey,
      resetStateOnRefresh: true,
      pageTitle: 'Withdrawal List',
      apiFuture: (int page) async {
        return Api.http.get("withdrawal-request?page=$page");
      },
      listItemBuilder: _upgradeTopUpsBuilder,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed('/withdrawal-request')!.then((value) => withdrawalListKey.currentState!.refresh());
        },
        label: text(
          'Request'.toUpperCase(),
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

  Widget _upgradeTopUpsBuilder(dynamic withdrawal, int index) {
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
                              UniconsLine.bolt,
                              color: colorPrimary,
                              size: textSizeXLarge,
                            ),
                            SizedBox(width: w(4)),
                            text(withdrawal['createdAt'], textColor: textColorSecondary, fontSize: textSizeSMedium),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: withdrawal['status']['id'] == 1
                              ? Colors.orange
                              : withdrawal['status']['id'] == 2
                                  ? Colors.green
                                  : Colors.red,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: text(
                          withdrawal['status']['name'],
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
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      text(
                        "Amount : ",
                        fontFamily: fontBold,
                      ),
                      SizedBox(width: 4),
                      text(
                        '₹ ${withdrawal['amount'].toString().replaceAll('null', 'N/A')}',
                        textColor: Colors.green,
                        fontFamily: fontBold,
                      ),
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
