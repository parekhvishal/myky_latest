import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import '../../widget/theme.dart';
import 'package:nb_utils/src/extensions/widget_extensions.dart';

class PlanScreen extends StatefulWidget {
  final Map data;

  PlanScreen(this.data);

  @override
  _PlanScreenState createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final Color primaryColor = Colors.blue;

  final Color bgColor = Color(0xffF9E0E3);

  final Color secondaryColor = Color(0xff324558);

  Response? rechargePlans;

  @override
  void initState() {
    super.initState();
    populateList();
  }

  Widget planItem(Map res) {
    return Card(
      child: Container(
        padding: EdgeInsets.only(top: 0, bottom: 15, left: 15, right: 15),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      text('Plan Details')
//                            Text('Col'),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorAccent,
                          ),
                          onPressed: () {},
                          child: Text('₹ ${res['recharge_amount']}'),
                        )
                    ],
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Talktime',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.0),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        res['recharge_talktime'],
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Validity',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(res['recharge_validity'] + '\n'),
                    ],
                  ),
                ),
              ],
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Description : ',
                    style: TextStyle(
                      fontSize: textSizeMedium,
                      color: colorPrimary,
                      fontFamily: fontSemibold,
                    ),
                  ),
                  TextSpan(
                    text: res['recharge_desc'],
                    style: TextStyle(
                      fontSize: textSizeSMedium,
                      color: textColorSecondary,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ).onTap(() {
      Get.back(result: res);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: DefaultTabController(
        initialIndex: 0,
        length: widget.data['categories']!.length,
        child: Theme(
          data: ThemeData(
            primaryColor: primaryColor,
            appBarTheme: AppBarTheme(
              color: Colors.white,
              titleTextStyle: TextStyle(
                color: secondaryColor,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
              iconTheme: IconThemeData(color: secondaryColor),
              actionsIconTheme: IconThemeData(
                color: secondaryColor,
              ),
            ),
          ),
          child: Scaffold(
            backgroundColor: Color(0xFFCACACA),
            appBar: AppBar(
              centerTitle: true,
              title: Text('Recharge Plans'),
              bottom: TabBar(
                isScrollable: true,
                labelColor: colorAccent,
                indicatorColor: colorAccent,
                unselectedLabelColor: secondaryColor,
                tabs: <Widget>[
                  for (var res in widget.data['categories'])
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(res['name']),
                    ),
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                for (var res in widget.data['categories'])
                  ListView.builder(
                    itemBuilder: (context, index) {
                      return planItem(res['items'][index]);
                    },
                    itemCount: res['items'].length,
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void populateList() {
    for (var category in widget.data['categories']) {
      List temp = widget.data['newplans'].where((element) => element['recharge_category'] == category['recharge_category']).toList();
      category['items'] = temp;
    }
    log(widget.data.toString());
  }
}
