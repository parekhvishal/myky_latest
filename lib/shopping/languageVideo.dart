import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../services/api.dart';
import '../../services/auth.dart';
import '../../services/extension.dart';
import '../../services/size_config.dart';
import '../../services/storage.dart';
import '../../utils/app_utils.dart';
import '../../widget/theme.dart';

class LanguageVideo extends StatefulWidget {
  const LanguageVideo({Key? key}) : super(key: key);

  @override
  _LanguageVideoState createState() => _LanguageVideoState();
}

class _LanguageVideoState extends State<LanguageVideo> {
  List languageVideo = [];
  late Future _future;
  String language = '';
  String? userLang;
  bool fromSettings = false;

  Future<Map> getVideo() {
    return Api.http.get("shopping/introductory-video").then((response) {
      return response.data;
    });
  }

  @override
  void initState() {
    if (Get.arguments != null) {
      fromSettings = Get.arguments;
      Storage.get('appLanguage').then((value) {
        userLang = value;
      });
    }
    _future = getVideo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: white,
      body: FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot? snapshot) {
          if (!snapshot!.hasData) {
            return Center();
          }
          languageVideo = snapshot.data['list']['data'];

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                text(
                  '${fromSettings ? 'Change' : 'Choose'} your language',
                  textAllCaps: true,
                  fontFamily: fontBold,
                ),
                20.height,
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    for (int i = 0; i < languageVideo.length; i++)
                      _languageVideoBuilder(i),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _languageVideoBuilder(i) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 15,
      ),
      child: GestureDetector(
        onTap: () {
          Auth.setLanguage(language: languageVideo[i]['code']);
          if (!fromSettings) {
            if (languageVideo[i]['link'] != null) {
              Get.to(() => VideoWatch(languageData: languageVideo[i]));
            } else {
              Get.snackbar(
                'Error',
                'Video not found',
                backgroundColor: Colors.red,
                colorText: Colors.white,
                duration: Duration(seconds: 3),
              );
            }
          } else {
            Get.back();
            AppUtils.showSuccessSnackBar('Language changed successfully.');
          }
        },
        child: Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [
                Colors.purple.shade700,
                colorPrimary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.shade300.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
                offset: Offset(2, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            languageVideo[i]['language'],
            style: TextStyle(
              fontFamily: fontBold,
              fontSize: 14.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class VideoWatch extends StatefulWidget {
  final Map? languageData;

  const VideoWatch({Key? key, this.languageData}) : super(key: key);

  @override
  _VideoWatchState createState() => _VideoWatchState();
}

class _VideoWatchState extends State<VideoWatch> {
  late YoutubePlayerController _controller;

  String? youtubeLink;

  @override
  void initState() {
    WakelockPlus.enable();

    setState(() {
      youtubeLink = widget.languageData!['link']
          .split('embed/')
          .sublist(1)
          .join('embed/')
          .trim();
      _controller = YoutubePlayerController(
        flags: YoutubePlayerFlags(
          forceHD: true,
          autoPlay: true,
          controlsVisibleAtStart: true,
        ),
        // initialVideoId: "geKLYcY6KWk",
        initialVideoId: youtubeLink!,
      );
    });

    super.initState();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _controller.dispose();
    super.dispose();
  }

  setData(String key, String value) async {
    final storage = new FlutterSecureStorage();
    await storage.write(key: key, value: value);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            elevation: 2.0,
            title: Text(widget.languageData!['language']),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ClipRRect(
                      child: player,
                      // borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            height: h(8.0),
            decoration: BoxDecoration(
              color: colorAccent,
            ),
            child: Center(
              child: text(
                'Continue',
                textColor: white,
                fontFamily: fontBold,
                fontSize: textSizeLargeMedium,
                textAllCaps: true,
              ),
            ).onClick(() {
              setData('isWellCome', 'true');
              Get.offAllNamed('/login-mlm');
            }),
          ),
        );
      },
    );
  }
}
