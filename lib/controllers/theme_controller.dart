import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  // default -> light mode
  var isDarkMode = false.obs;

  void changeTheme(bool isDark) {
    isDarkMode.value = isDark;
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
