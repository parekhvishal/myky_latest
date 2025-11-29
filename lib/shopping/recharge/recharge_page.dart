import 'package:flutter/material.dart';
import 'package:myky_clone/utils/app_utils.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../services/api.dart';
import '../../../widget/theme.dart';

class Recharge extends StatefulWidget {
  const Recharge({Key? key}) : super(key: key);

  @override
  _RechargeState createState() => _RechargeState();
}

class _RechargeState extends State<Recharge> {
  List prepaidOperator = [];
  List postpaidOperator = [];
  List dthOperator = [];
  List electricityOperator = [];
  List gasOperators = [];
  List circles = [];

  final List<Map> services = [
    {
      'name': 'Mobile Recharge',
      'icon': 'assets/images/mobile.png',
      'page': 'mobile',
      'bgColor': 0xFF8D7AEE,
    },
    {
      'name': 'DTH Recharge',
      'icon': 'assets/images/dth.png',
      'page': "dth",
      'bgColor': 0xFFF369B7,
    },
    // {
    //   'name': 'Electricity Bill',
    //   'icon': 'assets/images/electricity.png',
    //   'page': "electricity",
    //   'bgColor': 0xFF00BCD5,
    // },
    // {
    //   'name': 'Gas Bill',
    //   'icon': 'assets/images/gas.png',
    //   'page': "gas",
    //   'bgColor': 0xFFef5350,
    // },
  ];

  Future? operatorFuture;

  Future<Map> getOperator() {
    return Api.http.get("member/recharge/operator").then((response) {
      return response.data;
    });
  }

  @override
  void initState() {
    operatorFuture = getOperator();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Recharge & Bill Payment'.toUpperCase(),
        ),
      ),
      body: FutureBuilder(
        future: operatorFuture,
        builder: (context, AsyncSnapshot? snapshot) {
          if (!snapshot!.hasData) {
            return Center();
          }

          prepaidOperator = snapshot.data['prepaidOperator'];
          postpaidOperator = snapshot.data['postpaidOperator'];
          circles = snapshot.data['circles'];
          dthOperator = snapshot.data['dthOperator'];
          electricityOperator = snapshot.data['electricityOperator'];
          gasOperators = snapshot.data['gasOperators'];

          return _buildServicesGrid(context);
        },
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          decoration: boxDecoration(
            showShadow: false,
            bgColor: whiteColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                shrinkWrap: true,
                primary: true,
                children: services.map((Map category) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              AppUtils.showErrorSnackBar('Coming soon');

                              // service not working so don't remove code

                              // String? route;
                              // setState(() {
                              //   route = category['page'].toString();
                              // });
                              // if (route == 'mobile') {
                              //   Get.toNamed("/mobile-recharge", arguments: {
                              //     "prepaid": prepaidOperator,
                              //     "postpaid": postpaidOperator,
                              //     "circles": circles,
                              //   });
                              // } else if (route == 'dth') {
                              //   Get.toNamed(
                              //     "/dth-recharge",
                              //     arguments: dthOperator,
                              //   );
                              // } else if (route == 'electricity') {
                              //   Get.toNamed(
                              //     "/electricity-bill",
                              //     arguments: electricityOperator,
                              //   );
                              // } else if (route == 'gas') {
                              //   Get.toNamed(
                              //     "/gas-cylinder",
                              //     arguments: gasOperators,
                              //   );
                              // }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Color(category['bgColor']),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Image.asset(
                                category['icon'],
                                color: Colors.white,
                                fit: BoxFit.contain,
                              ),
                              height: 80,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Expanded(
                            child: text(
                              category['name'],
                              fontFamily: fontMedium,
                              isLongText: true,
                              fontSize: textSizeSMedium,
                            ),
                          )
                        ],
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        // service not working so don't remove code

        // Align(
        //   alignment: Alignment.bottomCenter,
        //   child: Container(
        //     alignment: Alignment.centerLeft,
        //     decoration: BoxDecoration(
        //       color: Colors.green.shade100,
        //     ),
        //     padding: EdgeInsets.symmetric(horizontal: 20.0),
        //     height: h(7.0),
        //     width: w(99.99),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         text(
        //           'Recharge History',
        //           fontFamily: fontSemibold,
        //           textColor: greenColor,
        //         ),
        //         Icon(
        //           UniconsLine.angle_double_right,
        //           color: greenColor,
        //         ),
        //       ],
        //     ),
        //   ).onClick(() {
        //     Get.toNamed('/recharge-summary');
        //   }),
        // ),
      ],
    );
  }
}
