import 'package:get/get.dart';

class CountCtl extends GetxController {
  var count = 0;

  static CountCtl get to => Get.find();

  CountCtl(int count) {
    this.count = count;
    update();
  }

  void increment() {
    count++;
    update();
  }

  void decrement() {
    count--;
    update();
  }

  void resetCount() {
    count = 0;
    update();
  }
}

class MLMCountCtl extends GetxController {
  static MLMCountCtl get to => Get.find();

  int countMLM = 0;

  MLMCountCtl(int count) {
    this.countMLM = count;
  }

  changeCount(int newCount) {
    this.countMLM = newCount;
  }

  operation({String? operationToPerform}) {
    operationToPerform == "add" ? this.countMLM++ : this.countMLM--;
  }

  mlmRest() {
    this.countMLM = 0;
  }
}

// class MLMCountCtl extends GetxController {
//   static MLMCountCtl get to => Get.find();
//
//   var countMLM = 0;
//
//   MLMCountCtl(int count) {
//     this.countMLM = count;
//   }
//
//   changeCount(int newCount) {
//     this.countMLM = newCount;
//   }
//
//   operation({String? operationToPerform}) {
//     operationToPerform == "add" ? this.countMLM++ : this.countMLM--;
//   }
//
//   mlmRest() {
//     this.countMLM = 0;
//   }
// }

// class MLMCountCtl extends GetxController {
//   static MLMCountCtl get to => Get.find();
//
//   var countMLM = 0;
//
//   MLMCountCtl(int count) {
//     this.countMLM = count;
//     update();
//   }
//
//   void increment() {
//     countMLM++;
//     update();
//   }
//
//   void decrement() {
//     countMLM--;
//     update();
//   }
//
//   void resetCount() {
//     countMLM = 0;
//     update();
//   }
//
//
// }
