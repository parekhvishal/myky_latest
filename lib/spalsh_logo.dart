import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:video_player/video_player.dart';

import '../../services/api.dart';
import '../../services/auth.dart';
import '../../services/size_config.dart';
import '../../utils/app_config.dart';

class SplashLogo extends StatefulWidget {
  @override
  _SplashLogoState createState() => _SplashLogoState();
}

class _SplashLogoState extends State<SplashLogo> {
  late VideoPlayerController _controller;

  /// Splash control variables
  bool _minTimeCompleted = false;
  bool _navigationDone = false;
  String? _nextRoute;
  dynamic _arguments;

  @override
  void initState() {
    super.initState();
    _initVideo();
    _initApp(); // API starts immediately
    _startMinimumTimer(); // 3 sec timer
  }

  /// ===============================
  /// VIDEO INIT
  /// ===============================
  void _initVideo() {
    _controller = VideoPlayerController.asset("assets/video/mykyvideo.mp4")
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      });
  }

  /// ===============================
  /// MINIMUM SPLASH TIME (3 sec)
  /// ===============================
  void _startMinimumTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      _minTimeCompleted = true;
      _navigateIfReady();
    });
  }

  /// ===============================
  /// APP INIT (API + LOGIN FLOW)
  /// ===============================
  Future<void> _initApp() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String version = packageInfo.version;

      final res = await Api.httpWithoutLoader.get(
        'member/app-status?appVersion=$version',
      );

      String key = Platform.isAndroid ? 'android' : 'ios';

      /// Maintenance
      if (res.data[key]['maintenance'] == true) {
        _setNextRoute('/app-maintenance', {
          "message": res.data[key]['maintenanceMessage'],
        });
        return;
      }

      /// Update
      if (res.data[key]['update'] == true) {
        _setNextRoute('/app-update', {'updateAppUrl': AppConfig.playStoreUrl});
        return;
      }

      /// Login Flow
      if (Auth.check() == true) {
        _setNextRoute('/main-dashboard');
      } else if (Auth.isGuestLoggedIn == true && Auth.isMLMLoggedIn == false) {
        _setNextRoute('/ecommerce');
      } else {
        _setNextRoute('/login-mlm');
      }
    } catch (e) {
      /// If API fails → allow login
      _setNextRoute('/login-mlm');
    }
  }

  /// ===============================
  /// STORE NEXT ROUTE
  /// ===============================
  void _setNextRoute(String route, [dynamic args]) {
    _nextRoute = route;
    _arguments = args;
    _navigateIfReady();
  }

  /// ===============================
  /// NAVIGATE WHEN BOTH READY
  /// ===============================
  void _navigateIfReady() {
    if (_minTimeCompleted && _nextRoute != null && !_navigationDone) {
      _navigationDone = true;
      Get.offAllNamed(_nextRoute!, arguments: _arguments);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            : const SizedBox(),
      ),
    );
  }
}
