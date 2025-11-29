import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api.dart';
import 'package:nb_utils/src/extensions/int_extensions.dart';

class RechargeThanks extends StatefulWidget {
  const RechargeThanks({Key? key}) : super(key: key);

  @override
  _RechargeThanksState createState() => _RechargeThanksState();
}

class _RechargeThanksState extends State<RechargeThanks> {
  var thanksResData;

  var orderId;

  @override
  void initState() {
    super.initState();
    orderId = Get.arguments;
  }

  Future thanksApi() async {
    return Api.http.get('member/recharge/thanks/$orderId');
    // return Api.http.get('member/recharge/thanks/133');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: thanksApi(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If we got an error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${snapshot.error} occurred',
                style: TextStyle(fontSize: 18),
              ),
            );

            // if we got our data
          } else if (snapshot.hasData) {
            // Extracting data from snapshot object
            thanksResData = jsonDecode(snapshot.data.toString());
            return Scaffold(
              backgroundColor: Color(0xfff0f0f0),
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: thanksResData!['rechargeOrder']['messageLabel'] ? Colors.green : Colors.red,
                elevation: 0,
              ),
              body: WillPopScope(
                onWillPop: () {
                  Get.offAllNamed('/ecommerce');
                  return Future.value();
                },
                child: SafeArea(
                  child: ListView(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            height: 300,
                            color: thanksResData!['rechargeOrder']['messageLabel'] ? Colors.green : Colors.red,
                          ),
                          Column(
                            children: <Widget>[
                              Container(
                                  height: 90,
                                  margin: EdgeInsets.only(top: 60),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      thanksResData!['rechargeOrder']['messageLabel'] ? Icons.check_circle : Icons.clear,
                                      size: 90.0,
                                      color: thanksResData!['rechargeOrder']['messageLabel'] ? Colors.green : Colors.red,
                                    ),
                                  )),
                              Padding(
                                padding: EdgeInsets.all(4),
                              ),
                              Text(
                                "Recharge " + thanksResData!['rechargeOrder']['paymentStatusText'],
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                              Padding(
                                padding: EdgeInsets.all(4),
                              ),
                              Text(
                                "₹ " + thanksResData!['rechargeOrder']['total'].toString(),
                                style: TextStyle(
                                  fontSize: 30.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                padding: EdgeInsets.all(10),
                                child: Card(
                                  child: Container(
                                    padding: EdgeInsets.all(15),
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          child: Column(
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    thanksResData!['rechargeOrder']['recharge_type']['status'],
                                                    style: TextStyle(
                                                      color: Colors.black87,
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5.0,
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(
//                                              "9033581259",
                                                    thanksResData!['rechargeOrder']['mobile'],
                                                    style: TextStyle(
                                                      color: Colors.black87,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  // Text(
                                                  //   "₹ " + thanksResData!['rechargeOrder']['order']['amount'].toString(),
                                                  //   style: TextStyle(
                                                  //     color: Colors.black87,
                                                  //     fontWeight: FontWeight.w500,
                                                  //     fontSize: 20,
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10.0,
                                              ),
                                              // if (thanksResData!['order']['smartcard_id'] != null)
                                              //   Row(
                                              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              //     children: <Widget>[
                                              //       Text(
                                              //         "Smartcard Discount",
                                              //         style: TextStyle(
                                              //           fontWeight: FontWeight.w400,
                                              //           fontSize: 18,
                                              //         ),
                                              //       ),
                                              //       Text(
                                              //         "- ₹ " + thanksResData!['order']['smartcard_discount'].toString(),
                                              //         style: TextStyle(
                                              //           color: Colors.green,
                                              //           fontWeight: FontWeight.w500,
                                              //           fontSize: 20,
                                              //         ),
                                              //       ),
                                              //     ],
                                              //   ),
                                              SizedBox(
                                                height: 10.0,
                                              ),
                                              SizedBox(
                                                height: 10.0,
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    "Amount",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  Text(
//                                              "₹ 350",
                                                    "₹ " + thanksResData!['rechargeOrder']['order']['amount'].toString(),
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              10.height,
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    "Service Charge",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  Text(
//                                              "₹ 350",
                                                    "₹ " + thanksResData!['rechargeOrder']['order']['service_charge'].toString(),
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              10.height,
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    "Total",
                                                    style: TextStyle(
                                                      color: Colors.redAccent,
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 22,
                                                    ),
                                                  ),
                                                  Text(
//                                              "₹ 350",
                                                    "₹ " + thanksResData!['rechargeOrder']['total'].toString(),
                                                    style: TextStyle(
                                                      color: Colors.redAccent,
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 22,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }
        return Material(child: Container());
      },
    );
  }
}
