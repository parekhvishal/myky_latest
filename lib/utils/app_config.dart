import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String environment =
      String.fromEnvironment('ENV', defaultValue: 'stage');

  static Future init() async {
    if (environment == 'stage') {
      await dotenv.load(fileName: '.env.stage');
    }

    if (environment == 'live') {
      await dotenv.load(fileName: '.env.live');
    }

    if (environment == 'local') {
      await dotenv.load(fileName: '.env.local');
    }
  }

  static String get apiBaseUrl => dotenv.env['API_BASE_URL']!;

  static String get shoppingApiBaseUrl => dotenv.env['ECOM_API_BASE_URL']!;

  static bool get appDebugMode => environment != 'live';

  static String get appName => dotenv.env['APP_NAME']!;

  static String get webUpdateUrl => dotenv.env['WEB_UPDATE_URL']!;

  static String get firebaseLink => dotenv.env['FIREBASELINK']!;

  static String get packageName => dotenv.env['PACKAGE']!;

  static String get playStoreUrl => dotenv.env['PLAYSTORE_URL']!;

  static String get getCoinName => dotenv.env['COIN_NAME']!;

  static String get getCoinNameWithCoin => "${dotenv.env['COIN_NAME']!} Coin";
}
