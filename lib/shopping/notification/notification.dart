import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../services/auth.dart';

import '../../../services/api.dart';
import '../../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class Notification extends StatefulWidget {
  const Notification({Key? key}) : super(key: key);

  @override
  _NotificationState createState() => _NotificationState();
}

class _NotificationState extends State<Notification> {
  GlobalKey<PaginatedListState> notificationGlobalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      key: notificationGlobalKey,
      pageTitle: 'Notification',
      isPullToRefresh: false,
      apiFuture: (int page) async {
        return Api.http.get("shopping/notification?page=$page", queryParameters: {"user_type": Auth.check()! ? 1 : 2});
      },
      listItemBuilder: notificationItemBuilder,
      listWithoutAppbar: false,
    );
  }

  Widget notificationItemBuilder(notification, int index) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(
                      notification['title'],
                      fontweight: FontWeight.w600,
                    ),
                    text(notification['createdAt'], fontSize: 10.0),
                  ],
                ),
                if (notification['status'] != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: notification['status']['id'] == 1 ? Colors.green : Colors.red,
                    ),
                    child: text('₹ ${notification['amount'] ?? 'N/A'}', textColor: Colors.white),
                  )
              ],
            ),
            SizedBox(height: 10.0),
            text(
              notification['body'],
              isLongText: true,
            ),
          ],
        ),
      ),
    );
  }
}
