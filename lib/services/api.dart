import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/app_config.dart';
import 'auth.dart';

class Api {
  static final random = new Random();

  static bool showLoader = true;
  static bool isBaseUrl = true;

  static Dio get httpWithoutLoader {
    showLoader = false;
    return http;
  }

  static Dio get httpWithoutBaseUrl {
    isBaseUrl = false;

    return http;
  }

  static Dio get http {
    Dio dio = new Dio();

    dio.options.baseUrl = AppConfig.apiBaseUrl;
    // if (isBaseUrl) dio.options.baseUrl = DotEnv.env['API_BASE_URL']!;

    String? token = Auth.isGuest()! ? Auth.guestToken() : Auth.token();
    dio.options.headers['Authorization'] = 'Bearer $token';
    dio.options.headers['Accept'] = 'application/json';

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, handler) async {
          if (showLoader) showLoading();

          return handler.next(options);
        },
        onResponse: (response, handler) async {
          hideLoading();

          showLoader = true;
          isBaseUrl = true;

          return handler.next(response);
        },
        onError: (DioError error, handler) async {
          if (showLoader) hideLoading();

          showLoader = true;

          if (error.error.runtimeType == SocketException) {
            Get.offAllNamed('/no-internet');
          } else if (token != null && error.response!.statusCode == 401) {
            if (isBaseUrl) {
              // await Auth.logout();
              // Get.offAllNamed("/login");
            }
          } else if (error.response!.statusCode == 503) {
            Get.offAllNamed("app-maintenance");
          } else if (error.response!.statusCode! >= 500) {
            if (isBaseUrl) Get.offAllNamed("/something-went-wrong");
          } else if (error.response!.statusCode == 302) {}
          isBaseUrl = true;

          return handler.next(error);
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        responseBody: true,
        requestHeader: true,
        requestBody: true,
      ),
    );

    return dio;
  }

  static void hideLoading() {
    if (Get.isDialogOpen!) {
      Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
    }
  }

  static void showLoading() {
    if (!Get.isDialogOpen! && showLoader) {
      Widget progressIndicator = CupertinoActivityIndicator(radius: 20);
      if (Platform.isAndroid) {
        progressIndicator = CircularProgressIndicator();
      }

      Get.dialog(
        WillPopScope(
          onWillPop: () => Future.value(false),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        barrierDismissible: false,
      );
    }
  }
}
