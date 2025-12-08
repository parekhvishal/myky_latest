import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:myky_clone/services/api.dart';
import 'package:myky_clone/widget/custom_text.dart';
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
  bool isLoading = false;
  bool isLoadingSpin = false;

  @override
  void initState() {
    super.initState();
    getSpinList();
    getSpinItems();
  }

  Future<void> getSpinItems() async {
    try {
      setState(() => isLoadingSpin = true);
      final response = await Api.http.get('shopping/spin-items');
      setState(() {
        spinItems = response.data['list'] ?? [];
        isLoadingSpin = false;
      });
      print('spinItems = $spinItems');
    } catch (e) {
      print('error = $e');
      setState(() => isLoadingSpin = false);
    }
  }

  Future<void> getSpinList() async {
    try {
      setState(() => isLoading = true);
      final response = await Api.http.get('shopping/spin-list');
      setState(() {
        spinList = response.data['list'] ?? [];
        isLoading = false;
      });
      print('cardSpinList = $spinList');
    } catch (e) {
      print('error = $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _redeemReward(int spinId) async {
    if (isLoadingSpin) {
      AppUtils.showInfoSnackBar("Please wait, loading spin items...");
      return;
    }

    if (spinItems.isEmpty) {
      AppUtils.showErrorSnackBar("No spin items found. Try again later.");
      return;
    }
    print('➡️ Navigating to spin with spinId: $spinId');
    await Get.to(() => SpinWheelScreen(spinItems: spinItems, spinId: spinId));
    print('⬅️ Back from spin - refreshing spinList');
    // After spin, refresh list
    getSpinList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // const Color(0xfff7f4ff),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: CustomText(
          'Your Rewards',
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
          textColor: Colors.black87,
        )
      ),
      body: isLoading
          ?  Center(child: emptyWidget(context, 'assets/images/no_data_found.png', 'No Data Found', ''))
          : GridView.builder(
            itemCount: spinList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final item = spinList[index];
              final bool isRedeemed = item['is_redeemed'] == 1;
              final int spinId = item['id'];

              return GestureDetector(
                onTap: isRedeemed
                    ? null
                    : () {
                  _redeemReward(spinId);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.deepPurple
                    //         .withOpacity(isRedeemed ? 0.25 : 0.1),
                    //     blurRadius: isRedeemed ? 18 : 10,
                    //     offset: const Offset(0, 6),
                    //   ),
                    // ],
                    border: Border.all(
                      width: 1.5,
                      color: isRedeemed
                          ? Colors.deepPurpleAccent.withOpacity(0.6)
                          : Colors.black12,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Background image
                        Image.asset(
                          'assets/images/reward.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),

                        // Frosted blur for unredeemed
                        if (!isRedeemed)
                          BackdropFilter(
                            filter:
                            ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.5),
                                    Colors.black.withOpacity(0.15)
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),

                        // Locked state
                        if (!isRedeemed)
                          Positioned.fill(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_rounded,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 34.sp),
                                SizedBox(height: 10.h),
                                CustomText(
                                  'Tap to Unlock',
                                  fontSize: 14.sp,
                                  textColor: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  shadows: const [
                                    Shadow(
                                        blurRadius: 6,
                                        color: Colors.black38)
                                  ],
                                ),
                              ],
                            ),
                          ),

                        // Redeemed card
                        if (isRedeemed)
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.deepPurpleAccent.withOpacity(0.95),
                                  Colors.deepPurple.shade800
                                      .withOpacity(0.98)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(14.w),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      width: 36.r,
                                      height: 36.r,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(3.r), // Creates inner white border effect
                                        child: ClipOval(
                                          child: Image.asset(
                                            'assets/images/launcher/icon.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  CustomText(
                                    "Reward #$spinId",
                                    fontSize: 17.sp,
                                    textColor: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  SizedBox(height: 4.h),
                                  CustomText(
                                    "Redeemed on ${item['redeemed_at'] ?? 'N/A'}",
                                    fontSize: 12.sp,
                                    textColor:
                                    Colors.white.withOpacity(0.9),
                                  ),
                                  SizedBox(height: 10.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.4),
                                          Colors.white.withOpacity(0.1),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius:
                                      BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                            Icons.check_circle_rounded,
                                            size: 14,
                                            color: Colors.white),
                                        SizedBox(width: 5.w),
                                        CustomText(
                                          'Redeemed',
                                          fontSize: 11.sp,
                                          textColor: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }
}