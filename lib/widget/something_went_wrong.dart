import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widget/theme.dart';

class SomethingWentWrong extends StatefulWidget {
  const SomethingWentWrong({Key? key}) : super(key: key);

  @override
  _SomethingWentWrongState createState() => _SomethingWentWrongState();
}

class _SomethingWentWrongState extends State<SomethingWentWrong> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Get.offAllNamed('/ecommerce');
        return Future.value();
      },
      child: Scaffold(
        body: Container(
          color: white,
          constraints: BoxConstraints(maxWidth: 500.0),
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Image.asset(
                'assets/images/something-wrong.png',
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fitWidth,
              ),
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomButton(
                        textContent: 'Back Home',
                        onPressed: () {
                          Get.offAllNamed('/ecommerce');
                        },
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
