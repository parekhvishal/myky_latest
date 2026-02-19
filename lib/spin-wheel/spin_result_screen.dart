import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:myky_clone/spin-wheel/rewards_controller.dart';
import 'package:myky_clone/widget/theme.dart';

import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SpinResultScreen extends StatefulWidget {
  final bool fromSpin;

  const SpinResultScreen({Key? key, this.fromSpin = false}) : super(key: key);

  @override
  State<SpinResultScreen> createState() => _SpinResultScreenState();
}

class _SpinResultScreenState extends State<SpinResultScreen> {
  final RewardsController controller = Get.find();
  final GlobalKey _shareKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    if (widget.fromSpin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showConfetti();
      });
    }
  }

  final double redeemed = 0.0;

  final double onTheWay = 0.0;

  Future<void> _shareScreenshot() async {
    try {
      RenderRepaintBoundary boundary =
          _shareKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/reward.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'I just won cashback on Super Rewards! 🎉');
    } catch (e) {
      debugPrint("Share error: $e");
    }
  }

  void _showConfetti() {
    final overlay = Overlay.of(context);
    final random = Random();

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.yellow,
    ];

    final entries = List.generate(40, (index) {
      return OverlayEntry(
        builder: (context) {
          final delay = random.nextDouble();
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: -0.1, end: 2),
            duration: Duration(milliseconds: (2500 + delay * 1500).toInt()),
            builder: (context, value, child) {
              final size = MediaQuery.of(context).size;

              return Positioned(
                left: size.width * random.nextDouble(),
                top: value * size.height,
                child: Opacity(
                  opacity: (1 - value).clamp(0.0, 1.0),
                  child: Container(
                    width: 8 + random.nextDouble() * 6,
                    height: 8 + random.nextDouble() * 6,
                    decoration: BoxDecoration(
                      color: colors[random.nextInt(colors.length)],
                      shape: BoxShape.rectangle,
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    });

    for (var e in entries) {
      overlay.insert(e);
    }

    Future.delayed(const Duration(seconds: 3), () {
      for (var e in entries) {
        e.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// ===== SAME APP BAR AS REWARD =====
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        toolbarHeight: 56,
        titleSpacing: 20,
        automaticallyImplyLeading: false,
        title: Image.asset(
          "assets/images/myky_new_logo_1.png",
          height: 28,
          width: 88,
        ),
      ),

      body: SafeArea(
        child: RepaintBoundary(
          key: _shareKey,
          child: Obx(() {
            double totalAmount = controller.totalAmount;
            double redeemable = totalAmount - redeemed - onTheWay;
            double lastAmount = controller.lastAmount;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),

                  /// Page Title
                  Center(
                    child: Text(
                      "YOUR REWARDS",
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: Color(0xFF0C2B87),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  /// ===== TOTAL CARD (Myky Blue Style) =====
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0C58D7), Color(0xFF0C2B87)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.25),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "₹${totalAmount.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 38.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "Lifetime cashback",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15.sp,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        _rowLight("Redeemed", redeemed),
                        SizedBox(height: 8.h),
                        _rowLight("On the way", onTheWay),
                        SizedBox(height: 8.h),
                        _rowLight("Redeemable", redeemable),
                      ],
                    ),
                  ),

                  SizedBox(height: 30.h),

                  /// ===== Last Spin =====
                  Text(
                    "Last Spin Reward",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 10.h),

                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: Color(0xFFFFB800),
                          size: 26.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            "You won from spin",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Text(
                          "₹${lastAmount.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0C58D7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 25.h),

                  /// ===== History =====
                  Text(
                    "Spin History",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 10.h),

                  Obx(() {
                    if (controller.rewards.isEmpty) {
                      return Text(
                        "No spins yet",
                        style: TextStyle(color: Colors.black45),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: controller.rewards.length,
                      itemBuilder: (context, index) {
                        final reward = controller.rewards[index];

                        return Container(
                          margin: EdgeInsets.only(bottom: 10.h),
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Spin ${controller.rewards.length - index}",
                                style: TextStyle(color: Colors.black54),
                              ),
                              Text(
                                "₹${reward.amount.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: Color(0xFF0C58D7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),

                  SizedBox(height: 30.h),

                  /// Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _shareScreenshot,
                        icon: Icon(Icons.share),
                        label: Text("SHARE"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Color(0xFFE5E7EB)),
                          padding: EdgeInsets.symmetric(
                            horizontal: 26.w,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      ElevatedButton(
                        onPressed: () {
                          Get.back();
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0C58D7),
                          padding: EdgeInsets.symmetric(
                            horizontal: 26.w,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text("DONE", style: TextStyle(color: white)),
                      ),
                    ],
                  ),

                  SizedBox(height: 30.h),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _rowLight(String title, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.white70, fontSize: 14.sp),
        ),
        Text(
          "₹${amount.toStringAsFixed(2)}",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
