import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Response;
import 'package:unicons/unicons.dart';

import '../../services/auth.dart';

class NoInternet extends StatefulWidget {
  @override
  _NoInternetState createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> {
  Future<bool> _onWillPop() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Text(
          'Are you sure you want to exit an app?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'No',
            ),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: Text(
              'Yes',
            ),
          ),
        ],
      ),
    );

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Center(
          child: Container(
            color: Colors.white,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    UniconsLine.wifi_slash,
                    color: Theme.of(context).primaryColor,
                    size: 50,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "No Internet Connection",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 20),
                MaterialButton(
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    (new Dio()).head('https://google.com').then(
                      (value) {
                        if (Auth.check()!) {
                          Get.offAllNamed('ecommerce');
                        }
                      },
                    ).catchError(
                      (error) {
                        GetBar(
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 3),
                          message: 'Your internet is still not working. Please try again later.',
                        ).show();
                      },
                    );
                  },
                  child: Text(
                    'Check Again',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
