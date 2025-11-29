import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import '../../widget/theme.dart';
import 'package:nb_utils/src/extensions/widget_extensions.dart';

class DTHPlanScreen extends StatefulWidget {
  final Map data;

  DTHPlanScreen(this.data);

  @override
  _DTHPlanScreenState createState() => _DTHPlanScreenState();
}

class _DTHPlanScreenState extends State<DTHPlanScreen> {
  final Color primaryColor = Colors.blue;

  final Color bgColor = Color(0xffF9E0E3);

  final Color secondaryColor = Color(0xff324558);

  Response? rechargePlans;

  @override
  void initState() {
    super.initState();
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
    return Scaffold(
      appBar: AppBar(title: text('DTH Plans')),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return planItem(widget.data['newplans'][index]);
        },
        itemCount: widget.data['newplans'].length,
      ),
    );
  }
}
