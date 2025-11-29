import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../services/api.dart';
import '../../widget/paginated_list.dart';

class TopUpView extends StatefulWidget {
  @override
  _TopUpViewState createState() => _TopUpViewState();
}

class _TopUpViewState extends State<TopUpView> {
  GlobalKey<PaginatedListState> topUpGlobalKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      key: topUpGlobalKey,
      resetStateOnRefresh: true,
      pageTitle: 'TopUp View',
      apiFuture: (int page) async {
        return Api.http.get('member/top-ups?page=$page');
      },
      listItemBuilder: _topupViewBuilder,
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     Get.toNamed('/top-up-mlm');
      //   },
      //   label: text(
      //     'Create'.toUpperCase(),
      //     textColor: white,
      //     fontFamily: fontBold,
      //   ),
      //   icon: Icon(
      //     UniconsLine.plus,
      //     color: white,
      //   ),
      //   backgroundColor: colorPrimary,
      // ),
    );
  }

  Widget _topupViewBuilder(item, int index) {
    return Column(
      children: <Widget>[
        Card(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      item['createdAt'],
                      style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Divider(thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Invoice Number",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    Text(
                      item['invoiceNo'] ?? "N/A",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Pin",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    Text(
                      item['pin']['code'],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Package Name",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    Text(
                      item['package']['name'],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Package Amount",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    Text(
                      item['amount'],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "GST Amount",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    Text(
                      item['gstAmount'],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
