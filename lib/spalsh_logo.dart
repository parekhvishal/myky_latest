import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:myky_clone/utils/app_config.dart';
import 'package:package_info/package_info.dart';
import 'package:video_player/video_player.dart';

import '../../services/api.dart';
import '../../services/auth.dart';
import '../../services/size_config.dart';

class SplashLogo extends StatefulWidget {
  @override
  _SplashLogoState createState() => _SplashLogoState();
}

class _SplashLogoState extends State<SplashLogo> with SingleTickerProviderStateMixin {
  final int splashDuration = 4;
  var _visible = true;

  // AnimationController? animationController;
  // Animation<double>? animation;

  AssetBundle? defaultAssetBundle;

  late VideoPlayerController _controller;

  startTime() async {
    Timer(Duration(seconds: splashDuration), () async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      String version = packageInfo.version;

      final storage = new FlutterSecureStorage();

      String? status;
      try {
        status = (await storage.read(key: 'isWellCome'))!;
      } catch (e) {
        storage.deleteAll();
      }

      await Api.httpWithoutLoader.get('member/app-status?appVersion=$version').then((res) {
        String key = Platform.isAndroid ? 'android' : 'ios';

        if (res.data[key]['maintenance']) {
          Get.offAllNamed('/app-maintenance', arguments: {
            "message": res.data[key]['maintenanceMessage'],
          });
        } else if (res.data[key]['update']) {
          Map sendData = {};

          if (res.data[key].containsKey('hardUpdate') && res.data[key]['hardUpdate']) {
            // App update from Play store
            sendData['updateAppUrl'] = AppConfig.playStoreUrl;
          } else if (res.data.containsKey('webUpdate')) {
            // App update from web link
            if (res.data['webUpdate']) {
              sendData['updateAppUrl'] = res.data['webUrl'] ?? '';
            } else {
              sendData['updateAppUrl'] = AppConfig.playStoreUrl;
            }
          }

          Get.offAllNamed(
            '/app-update',
            arguments: sendData,
          );
        } else {
          // Check if user is logged in
          if (Auth.check() == true) {
            // User is already logged in, go to MainDashboard
            Get.offAllNamed('/main-dashboard');
          } else if (Auth.isGuestLoggedIn == true && Auth.isMLMLoggedIn == false) {
            Get.offAllNamed('/ecommerce');
          }
          else {
            // User is not logged in, check language video status
            if (status == null) {
              Get.offAllNamed('/language-video');
            } else {
              // Show login screen first
              Get.offAllNamed('/login-mlm');
            }
          }
        }
      }, onError: (err) {});
    });
  }

  getVideo() {
    _controller = VideoPlayerController.asset("assets/video/mykyvideo.mp4")
      ..initialize().then((_) {
        _controller.play();
        // Ensure the first frame is shown after the video is initialized
        setState(() {});
      });
  }

  @override
  void initState() {
    super.initState();
    // animationController = AnimationController(
    //   vsync: this,
    //   duration: Duration(seconds: 3),
    // );
    // animation = CurvedAnimation(parent: animationController!, curve: Curves.easeOut);
    //
    // animation!.addListener(() => this.setState(() {}));
    // animationController!.forward();

    setState(() {
      _visible = !_visible;
    });
    startTime();
    getVideo();
  }

  @override
  void dispose() {
    super.dispose();
    // animationController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Material(
      child: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : Container(),
      ),
    );
  }
}
