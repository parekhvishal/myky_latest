// import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart'; // import 'package:flutter_tts/flutter_tts.dart';
// import 'package:flutter_tts/flutter_tts_web.dart';
import 'package:get/get.dart';

import 'main.dart';
import 'services/storage.dart';
import 'utils/TextToSpeechWithTranslation.dart';

class PushNotificationManager {
  final sound = 'my.mp3';
  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 0.8;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;
  TextToSpeechWithTranslation? textToSpeechWithTranslation;

  Future init() async {
    textToSpeechWithTranslation = TextToSpeechWithTranslation();
    var initialzationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: initialzationSettingsAndroid);

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null && message.data.containsKey('page')) {
        routerName = message.data['page'];
        Get.toNamed(message.data['page']);
      }
    });

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      String userLang = await Storage.get('appLanguage');
      if (message.data['isAudio'] == "1") {
        textToSpeechWithTranslation!.speak(
          message.data['message'],
        );
      }

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              (message.data['isAudio'] == "1") ? 'no_sound' : channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon,
              playSound: (message.data['isAudio'] == "1") ? false : true,
            ),
          ),
          // payload: notification.payload,
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data.containsKey('page')) {
        routerName = message.data['page'];
        Get.toNamed(message.data['page']);
      }
    });
  }
}
