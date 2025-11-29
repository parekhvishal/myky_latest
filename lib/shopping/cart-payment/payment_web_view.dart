import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widget/confirmation_dialog.dart';
import '../../widget/theme.dart';

class PaymentWebView extends StatefulWidget {
  @override
  _PaymentWebViewState createState() => new _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  String url = "";
  double progress = 0;

  @override
  void initState() {
    url = Get.arguments;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        showExitPaymentDialog();
        return Future.value(false);
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(url: WebUri(url)),
                initialUserScripts: UnmodifiableListView<UserScript>([]),
                onWebViewCreated: (controller) async {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) async {
                  this.url = url.toString();
                  if (Get.previousRoute == '/payments') {
                    if (this.url.contains('app-payment-process')) {
                      Get.back(result: url!.queryParameters);
                    }
                  } else if (this.url.contains('offline-payment-process')) {
                    Get.back(result: url!.queryParameters);
                  } else {
                    if (this.url.contains('app-recharge-payment-process')) {
                      Get.back(result: url!.queryParameters);
                    }
                  }
                },
                onLoadStop: (controller, url) async {
                  this.url = url.toString();
                },
                onProgressChanged: (controller, progress) {
                  setState(() {
                    this.progress = progress / 100;
                  });
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  var uri = navigationAction.request.url!;

                  if (uri.scheme == "upi") {
                    if (await canLaunch(uri.toString())) {
                      await launch(uri.toString());
                      return NavigationActionPolicy.CANCEL;
                    }
                  }
                  return NavigationActionPolicy.ALLOW;
                },
              ),
              progress < 1.0
                  ? LinearProgressIndicator(
                      value: progress,
                      color: colorPrimary,
                      backgroundColor: colorAccent,
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  void showExitPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: "Are you sure want to exit payment process?",
        onPositiveClick: () {
          Get.back();
          Get.back();
        },
      ),
    );
  }
}
