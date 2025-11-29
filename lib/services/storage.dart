import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static Future<dynamic> get(String key) async {
    SharedPreferences storage = await SharedPreferences.getInstance();

    dynamic value = storage.get(key);

    if (value != null) {
      value = jsonDecode(value);
    }

    return value;
  }

  static Future<bool> set(String key, dynamic value) async {
    SharedPreferences storage = await SharedPreferences.getInstance();

    return await storage.setString(key, jsonEncode(value));
  }

  static Future<bool> delete(String key) async {
    SharedPreferences storage = await SharedPreferences.getInstance();

    return await storage.remove(key);
  }

  static Future<bool> clear() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    return storage.clear();
  }
}
