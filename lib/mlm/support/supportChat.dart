import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../services/api.dart';
import '../../../services/size_config.dart';
import '../../../widget/paginated_list.dart';
import '../../../widget/theme.dart';

class SupportChat extends StatefulWidget {
  @override
  _SupportChatState createState() => _SupportChatState();
}

class _SupportChatState extends State<SupportChat> {
  GlobalKey<PaginatedListState> supportChatPaginatedListKey = GlobalKey();

  Map? chatDetails;

  TextEditingController _sendMessageController = TextEditingController();
  List messages = [];
  Map? ticketStatus;

  @override
  void initState() {
    chatDetails = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf8f8f8),
      appBar: AppBar(
        title: Text("Support Chat"),
      ),
      body: PaginatedList(
        key: supportChatPaginatedListKey,
        apiFuture: (int page) async {
          return Api.http.post(
            'member/support-tickets/detail/?page=$page',
            data: {"ticket_id": chatDetails!['ticketId']},
          ).then((res) {
            if (res.data['status']) {
              ticketStatus = res.data['ticketStatus'];
              if (messages.length == 0 || page == 1) {
                messages = [];
              }
            }
            return res;
          });
        },
        listItemBuilder: _buildBroadcastDetail,
        listItemGetter: (item) {
          messages.add(item);
          Future.delayed(Duration.zero, () async {
            setState(() {});
          });

          return item;
        },
        resetStateOnRefresh: true,
        isPullToRefresh: false,
        isReverse: true,
      ),
      bottomSheet: ticketStatus != null && ticketStatus!['status'] == 1
          ? Container(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: 5),
                      margin: EdgeInsets.only(bottom: 10, left: 15, right: 5),
                      decoration: boxDecoration(
                        radius: 5,
                        showShadow: true,
                        bgColor: Colors.white60,
                      ),
                      child: TextFormField(
                        inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^ '))],
                        maxLines: 15,
                        controller: _sendMessageController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type your message',
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 12, bottom: 15, top: 10),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: colorPrimary,
                      child: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 15,
                        ),
                        onPressed: () {
                          if (_sendMessageController.text.isNotEmpty && _sendMessageController.text.trim().length > 0) {
                            FocusScope.of(context).requestFocus(FocusNode());

                            Map sendData = {"message": _sendMessageController.text, "id": chatDetails!['ticketId']};
                            Api.http.post('member/support-tickets/store', data: sendData).then((response) {
                              if (response.data['status']) {
                                _sendMessageController.clear();
                                supportChatPaginatedListKey.currentState!.refresh();
                              }
                            }).catchError((error) {});
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (ticketStatus != null)
                  Expanded(
                    child: Container(
                      color: Colors.red,
                      padding: EdgeInsets.all(9),
                      child: Text(
                        ticketStatus!['statusMessage'],
                        style: TextStyle(
                          fontSize: textSizeLargeMedium,
                          color: white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildBroadcastDetail(detail, int index) {
    return Column(
      children: <Widget>[
        if (index + 1 == messages.length ||
            (index + 1 != 0 &&
                DateTime.now().difference(DateTime.parse(detail['newDate'])).inDays != DateTime.now().difference(DateTime.parse(messages[index + 1]['newDate'])).inDays))
          Container(
            height: h(7),
            child: Align(
              alignment: Alignment.center,
              child: Bubble(
                margin: BubbleEdges.only(top: 10),
                alignment: Alignment.center,
                nip: BubbleNip.no,
                color: primary.withOpacity(0.6),
                child: Text(
                  DateTime.now().difference(DateTime.parse(detail['newDate'])).inDays == 0
                      ? ("Today")
                      : DateTime.now().difference(DateTime.parse(detail['newDate'])).inDays == 1
                          ? ("Yesterday")
                          : detail['date'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: white,
                    fontSize: 11.0,
                  ),
                ),
              ),
            ),
          ),
        Align(
          alignment: detail['user']['isAdmin'] ? Alignment.topLeft : Alignment(1, 0),
          // alignment: Alignment(1, 0),
          child: sendMessageWidget(msg: detail['message'], time: detail['time'], isAdmin: detail['user']['isAdmin']),
        ),
        if (index == 0) SizedBox(height: 60),
      ],
    );
  }

  Widget _customBubble({String? time, String? message, bool? isAdmin}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(3.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(blurRadius: .5, spreadRadius: 1.0, color: Colors.black.withOpacity(.12))],
            color: isAdmin! ? colorPrimary : white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(5.0),
              bottomLeft: Radius.circular(10.0),
              bottomRight: Radius.circular(5.0),
            ),
          ),
          child: Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 70.0),
                child: text(
                  message!,
                  isLongText: true,
                  textColor: isAdmin ? Colors.black : textColorSecondary,
                ),
              ),
              Positioned(
                bottom: 0.0,
                right: 0.0,
                child: Row(
                  children: <Widget>[
                    text(
                      time!,
                      textColor: isAdmin ? Colors.black : textColorSecondary,
                      fontSize: 10.0,
                      isLongText: true,
                    ),
                    SizedBox(width: 3.0),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget sendMessageWidget({
    String? msg,
    String? time,
    bool? isAdmin,
  }) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0, left: 10.0, top: 4.0, bottom: 4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: _customBubble(
            message: msg,
            time: time,
            isAdmin: isAdmin,
          ),
        ),
      ),
    );
  }
}
