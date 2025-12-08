// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:myky_clone/utils/app_config.dart';
import 'package:nb_utils/nb_utils.dart';

import 'push_notification.dart';
import 'services/auth.dart';
import 'services/cart_service.dart';
import 'services/dynamic_link.dart';
import 'services/router.dart';
import 'services/upi_apps_service.dart';
import 'utils/TextToSpeechWithTranslation.dart';
import 'widget/theme.dart';

String? routerName;
late FlutterTts flutterTts;
String? language;
String? engine;
double volume = 0.8;
double pitch = 1.0;
double rate = 0.5;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // toast('${message.data['isAudio']}');
  // toast('${message.data['isAudio'] == "1"}');
  // toast('${message.data['isAudio'].runtimeType}');
  toast('${message.data}');
  toast('${message.notification}');
  RemoteNotification? notification = message.notification;
  TextToSpeechWithTranslation textToSpeechWithTranslation =
      TextToSpeechWithTranslation();
  if (message.data['isAudio'] == "1") {
    textToSpeechWithTranslation.speak(
      message.data['message'],
    );
  }
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'my_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await FlutterDownloader.initialize();
  await AppConfig.init();
  await Auth.initialize();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await PushNotificationManager().init();
  DynamicLink.initDynamicLinkData();

  Get.put<Cart>(Cart());
  await Get.putAsync(() => UPIAppService().init());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    useInheritedMediaQuery: true,
    builder: (BuildContext context, Widget? child) {
      return GetMaterialApp(
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        title: AppConfig.appName,
        theme: buildThemeData(),
        getPages: AppRouter.pages,
        defaultTransition: Transition.leftToRightWithFade,
        routingCallback: (routing) async {},
      );
    },
  ));
}
