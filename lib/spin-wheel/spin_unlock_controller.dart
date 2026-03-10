import 'package:get/get.dart';

class SpinUnlockController extends GetxController {
  var unlockedIds = <int>[].obs;

  void unlock(int spinId) {
    if (!unlockedIds.contains(spinId)) {
      unlockedIds.add(spinId);
    }
  }

  bool isUnlocked(int spinId) {
    return unlockedIds.contains(spinId);
  }
}
