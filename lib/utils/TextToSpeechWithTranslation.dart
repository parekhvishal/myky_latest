import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
// import 'package:volume_control/volume_control.dart';

import '../services/storage.dart';

class TextToSpeechWithTranslation {
  late FlutterTts flutterTts;
  String? language;
  List deviceLanguages = [];
  String? engine;
  double volume = 0.7;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;
  bool isPlaying = false;
  List<String> texts = [];
  late String lang;

  TextToSpeechWithTranslation({message}) {
    initTts();
  }

  initTts() async {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    _getDefaultEngine();

    deviceLanguages = await _getLanguages();

    flutterTts.setStartHandler(() {
      isPlaying = true;
      // ttsState = TtsState.playing;
    });

    flutterTts.setCompletionHandler(() {
      isPlaying = false;
      if (texts.length > 0) {
        texts.forEach((text) async {
          await speak(text);
        });
        texts = [];
      }

      // ttsState = TtsState.stopped;
    });

    flutterTts.setCancelHandler(() {
      // ttsState = TtsState.stopped;
    });

    flutterTts.setErrorHandler((msg) {
      // ttsState = TtsState.stopped;
    });

    // VolumeControl.setVolume(0.6);

    // await flutterTts.setLanguage('hi-IN');
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);
  }

  Future speak(msg) async {
    String userLang = await Storage.get('appLanguage');

    bool isLangAvailable = await flutterTts.isLanguageAvailable(userLang);
    if (isLangAvailable) {
      lang = userLang;
    } else {
      lang = 'en-IN';
    }
    await flutterTts.setLanguage(lang);
    final translator = GoogleTranslator();
    if (!isPlaying) {
      Translation output = await translator.translate(msg, from: 'en', to: '${lang.split('-').first}');
      await flutterTts.speak(output.text);
    } else {
      texts.add(msg);
    }
  }

  Future<dynamic> _getLanguages() => flutterTts.getLanguages;

  Future<dynamic> _getEngines() => flutterTts.getEngines;

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {}
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  void dispose() {
    flutterTts.stop();
  }
}
