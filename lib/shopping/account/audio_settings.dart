import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api.dart';
import '../../services/auth.dart';
import '../../utils/app_utils.dart';
import '../../widget/theme.dart';
import 'package:nb_utils/nb_utils.dart';

class AudioSettings extends StatefulWidget {
  const AudioSettings({Key? key}) : super(key: key);

  @override
  _AudioSettingsState createState() => _AudioSettingsState();
}

class _AudioSettingsState extends State<AudioSettings> {
  late bool isSwitched;

  @override
  void initState() {
    setupSwitchConfiguration();
    fetchCurrentSettings();
    super.initState();
  }

  setupSwitchConfiguration() {
    setState(() {
      if (Auth.isAudio == 1) {
        isSwitched = true;
      } else {
        isSwitched = false;
      }
    });
  }

  void toggleSwitch(bool value) {
    setState(() {
      isSwitched = !isSwitched;
    });
    Api.httpWithoutLoader.post('member/audio-settings', data: {
      'is_audio': (isSwitched) ? 1 : 2,
    }).then((response) {
      if (response.data['status']) {
        Get.back();
        Auth.setAudioSetting(
          audio: (isSwitched) ? 1 : 2,
        );
        AppUtils.showSuccessSnackBar('Your Settings has been saved successfully');
      } else {
        AppUtils.showErrorSnackBar(response.data['message']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Audio Settings',
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            10.height,
            text(
              'Change Your Settings Here...',
              textColor: colorAccent,
              fontFamily: fontBold,
              fontSize: textSizeNormal,
              maxLine: 2,
            ),
            25.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                text(
                  'Your current Setting',
                  fontFamily: fontMedium,
                  fontSize: textSizeLargeMedium,
                ),
                Transform.scale(
                  scale: 1.5,
                  child: Switch(
                    onChanged: toggleSwitch,
                    value: isSwitched,
                    activeColor: colorPrimary,
                    activeTrackColor: colorPrimary.withOpacity(0.45),
                    inactiveThumbColor: Colors.grey[500],
                    inactiveTrackColor: Colors.grey[300],
                  ),
                ),
              ],
            ),
            15.height,
            // text(
            //   '$textValue',
            // )
          ],
        ),
      ),
    );
  }

  void fetchCurrentSettings() {
    Api.httpWithoutLoader.get('member/profile/get-audio-setting').then((response) async {
      if (response.data['status']) {
        await Auth.setAudioSetting(audio: response.data['audioStatus']);
        setupSwitchConfiguration();
      }
    });
  }
}
