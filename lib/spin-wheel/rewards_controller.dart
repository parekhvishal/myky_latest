import 'package:get/get.dart';

class SpinReward {
  final double amount;
  final DateTime date;

  SpinReward({required this.amount, required this.date});
}

class RewardsController extends GetxController {
  /// List of all spins
  var rewards = <SpinReward>[].obs;

  /// Total lifetime cashback
  double get totalAmount => rewards.fold(0.0, (sum, item) => sum + item.amount);

  /// Add new spin reward
  void addReward(double amount) {
    rewards.insert(0, SpinReward(amount: amount, date: DateTime.now()));
  }

  /// Last spin amount
  double get lastAmount => rewards.isNotEmpty ? rewards.first.amount : 0.0;
}
