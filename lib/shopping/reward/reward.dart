import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myky_clone/services/api.dart';
import 'package:myky_clone/widget/theme.dart';
import '../../spin-wheel/spin_wheel.dart';
import '../../utils/app_utils.dart';

class Reward extends StatefulWidget {
  const Reward({super.key});

  @override
  State<Reward> createState() => _RewardState();
}

class _RewardState extends State<Reward> {
  List<dynamic> spinItems = [];
  List<dynamic> spinList = [];

  bool isLoadingList = false;
  bool isLoadingItems = false;

  @override
  void initState() {
    super.initState();
    getSpinItems();
    getSpinList();
  }

  Future<void> getSpinItems() async {
    try {
      setState(() => isLoadingItems = true);
      final response = await Api.http.get('shopping/spin-items');
      setState(() {
        spinItems = response.data['list'] ?? [];
        isLoadingItems = false;
      });
    } catch (e) {
      setState(() => isLoadingItems = false);
      debugPrint("getSpinItems error: $e");
    }
  }

  Future<void> getSpinList() async {
    try {
      setState(() => isLoadingList = true);
      final response = await Api.http.get('shopping/spin-list');
      setState(() {
        spinList = response.data['list'] ?? [];
        isLoadingList = false;
      });
    } catch (e) {
      setState(() => isLoadingList = false);
      debugPrint("getSpinList error: $e");
    }
  }

  Future<void> _redeemReward(int spinId) async {
    if (isLoadingItems) {
      AppUtils.showInfoSnackBar("Please wait, loading spin items...");
      return;
    }

    if (spinItems.isEmpty) {
      AppUtils.showErrorSnackBar("No spin items found. Try again later.");
      return;
    }

    debugPrint('➡️ Navigating to spin with spinId: $spinId');

    await Get.to(() => SpinWheelScreen(spinItems: spinItems, spinId: spinId));

    debugPrint('⬅️ Back from spin - refreshing spinList');
    getSpinList();
  }

  /// Locked tap => Start spin
  void _onLockedTap(dynamic item) {
    final bool isRedeemed = item['is_redeemed'] == 1;
    final int spinId = item['id'] ?? 0;

    if (isRedeemed) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Locked Reward"),
        content: const Text("You need to unlock this reward first."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _redeemReward(spinId); // ✅ start navigation
            },
            child: const Text("Unlock"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoadingList
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  /// Header (your custom top header row)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                "assets/images/logo copy.png",
                                height: 28,
                              ),
                              const SizedBox(width: 6),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined),
                                onPressed: () {},
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: Image.asset(
                                  profileImage,
                                  height: 34,
                                  width: 34,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// Title
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 6, bottom: 10),
                      child: Center(
                        child: Text(
                          "YOUR REWARDS",
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF0C2B87),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// Grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = spinList[index];
                        final bool isRedeemed = item['is_redeemed'] == 1;
                        final int spinId = item['id'] ?? 0;

                        /// ✅ REDEEMED CARD
                        if (isRedeemed) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                height: 181,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF00D4C8).withOpacity(0.3),
                                      const Color(0xFF00D4C8).withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  children: const [
                                    Spacer(),
                                    SizedBox(
                                      height: 28,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            size: 14,
                                            color: Color(0xFF0C58D7),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            "Redeemed",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF0C58D7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Positioned(
                                top: 4,
                                right: 4,
                                left: 4,
                                child: Container(
                                  height: 145,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4FBFF),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: const Color(0xFFBEE7F5),
                                      width: 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x11000000),
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.only(
                                    top: 10,
                                    left: 12,
                                    right: 12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.card_giftcard_rounded,
                                        color: Color(0xFF0C9ACB),
                                        size: 30,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Reward #$spinId",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          color: Color(0xFF001B48),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Redeemed on ${item['redeemed_at'] ?? 'N/A'}",
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0x88000000),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        /// 🔐 LOCKED CARD (tap → dialog → unlock → go spin wheel)
                        return GestureDetector(
                          onTap: () => _onLockedTap(item),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.asset(
                                    "assets/images/awards.png",
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                Positioned.fill(
                                  child: Container(
                                    color: const Color(
                                      0xFF0C1FB9,
                                    ).withOpacity(0.88),
                                  ),
                                ),

                                /// Blur for better look
                                Positioned.fill(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 2.0,
                                      sigmaY: 2.0,
                                    ),
                                    child: Container(color: Colors.transparent),
                                  ),
                                ),

                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.lock,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "Tap to Unlock",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }, childCount: spinList.length),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.92,
                          ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
      ),
    );
  }
}
