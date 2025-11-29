import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../services/api.dart';
import '../../../widget/paginated_list.dart';
import '../../../widget/theme.dart';

class RechargeSummary extends StatefulWidget {
  const RechargeSummary({Key? key}) : super(key: key);

  @override
  _RechargeSummaryState createState() => _RechargeSummaryState();
}

class _RechargeSummaryState extends State<RechargeSummary> {
  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      isPullToRefresh: true,
      appBarAction: [],
      pageTitle: "Recharge History",
      apiFuture: (int page) async {
        return Api.http.get('member/recharge?page=$page');
      },
      listItemBuilder: _rechargeOrderBuilder,
    );
  }

  Widget _rechargeOrderBuilder(dynamic rechargeOrder, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: boxDecoration(
        showShadow: true,
        bgColor: white_color,
        radius: 10.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 15,
            child: CircleAvatar(
              radius: 30.0,
              backgroundImage: AssetImage(logo),
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(
            flex: 85,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 75,
                      child: text(
                        "${rechargeOrder['operator']}",
                        maxLine: 3,
                        fontFamily: fontSemibold,
                      ),
                    ),
                    Expanded(
                      flex: 25,
                      child: text(
                        rechargeOrder['date'],
                        fontSize: 13.0,
                        textColor: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                if (rechargeOrder['circle'] != null)
                  text(
                    "Circle : ${rechargeOrder['circle']['name']}",
                    textColor: colorPrimary,
                    fontFamily: fontMedium,
                  ),
                SizedBox(height: 3.0),
                Row(
                  children: [
                    text(
                      rechargeOrder['number'],
                      fontFamily: fontMedium,
                    ),
                    SizedBox(width: 5.0),
                    text(
                      "(Type : ${rechargeOrder['type']})",
                      fontSize: textSizeSmall,
                      isLongText: true,
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(
                      "₹  ${rechargeOrder['totalPayable']} Your Order is",
                      textColor: rechargeOrder['status'] == "Failed" ? Colors.red : colorAccent,
                      fontFamily: fontMedium,
                    ),
                    SizedBox(width: 5),
                    text(
                      rechargeOrder['status'],
                      textColor: rechargeOrder['status'] == "Failed" ? Colors.red : colorAccent,
                      fontFamily: fontMedium,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(
                      color: Colors.black54,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      text(
                        "Service Charge : ₹ ${rechargeOrder['serviceCharge']}",
                        fontSize: textSizeSmall,
                        fontFamily: fontMedium,
                      ),
                      text(
                        "Amount : ₹ ${rechargeOrder['amount']}",
                        fontSize: textSizeSmall,
                        fontFamily: fontMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
