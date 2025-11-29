import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/api.dart';
import '../../../widget/paginated_list.dart';
import '../../../widget/theme.dart';

class SupportList extends StatefulWidget {
  @override
  _SupportListState createState() => _SupportListState();
}

class _SupportListState extends State<SupportList> {
  GlobalKey<PaginatedListState> supportChatKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      appBarAction: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              supportChatKey.currentState!.refresh();
            },
            child: Icon(
              Icons.refresh,
            ),
          ),
        ),
      ],
      key: supportChatKey,
      pageTitle: 'Support',
      apiFuture: (int page) async {
        return Api.http.get('member/support-tickets?page=$page');
      },
      listItemBuilder: _supportListBuilder,
      isDescription: false,
      resetStateOnRefresh: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/ticket-create')!.then((value) => supportChatKey.currentState!.refresh());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _supportListBuilder(item, int index) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('support-chat', arguments: item)!
            .then((value) => supportChatKey.currentState!.refresh());
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(item['date']),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: item['status']['id'] == 1 ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: text(
                      item['status']['name'],
                      textColor: white,
                      textAllCaps: true,
                      fontFamily: fontSemibold,
                      fontSize: textSizeSMedium,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 75,
                    child: Text(
                      item['subject'],
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  if (item['status']['unreadCount'] > 0)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      child: text(
                        item['status']['unreadCount'].toString(),
                        textColor: white,
                        textAllCaps: true,
                        fontFamily: fontSemibold,
                        fontSize: textSizeSMedium,
                      ),
                    ),
                ],
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: <Widget>[
              //     Align(
              //       alignment: Alignment.topLeft,
              //       child: Text(
              //         item['subject'],
              //         style: TextStyle(
              //           color: Colors.black54,
              //           fontWeight: FontWeight.w400,
              //           fontSize: 20,
              //         ),
              //       ),
              //     ),
              //     if (item['status']['unreadCount'] > 0)
              //       Container(
              //         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              //         decoration: BoxDecoration(
              //           color: Colors.red,
              //           borderRadius: BorderRadius.all(
              //             Radius.circular(5),
              //           ),
              //         ),
              //         child: text(
              //           item['status']['unreadCount'].toString(),
              //           textColor: white,
              //           textAllCaps: true,
              //           fontFamily: fontSemibold,
              //           fontSize: textSizeSMedium,
              //         ),
              //       ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
