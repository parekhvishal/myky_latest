import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:myky_clone/MainFrontDashboard.dart';
import 'package:myky_clone/services/api.dart';
import 'package:myky_clone/spin-wheel/rewards_controller.dart';
import 'package:myky_clone/spin-wheel/spin_result_screen.dart';
import 'package:myky_clone/utils/app_utils.dart';
import 'package:myky_clone/widget/theme.dart';

class SpinWheelScreen extends StatefulWidget {
  final List<dynamic> spinItems; // from API
  final int spinId; // from spinList in reward.dart

  const SpinWheelScreen({
    Key? key,
    required this.spinItems,
    required this.spinId,
  }) : super(key: key);

  @override
  _SpinWheelScreenState createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  double _randomEndAngle = 0.0;
  String? _result;

  bool isLoadingSpin = false;
  List<ui.Image?> giftImages = [];
  Map<String, dynamic>? landedReward;

  // 🎯 same pointer direction as your CRED UI
  static const double pointerDirection = -pi / 2;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animation = Tween<double>(begin: 0, end: 0).animate(_controller);

    _loadGiftImages();
  }

  Future<void> _loadGiftImages() async {
    final List<String> imagePaths = [
      'assets/images/gift.png',
      'assets/images/gift_1.png',
      'assets/images/gift_2.png',
      'assets/images/gift_3.png',
      'assets/images/gift_4.png',
      'assets/images/gift_5.png',
    ];

    final List<ui.Image?> loadedImages = List.filled(imagePaths.length, null);

    for (int i = 0; i < imagePaths.length; i++) {
      try {
        final data = await rootBundle.load(imagePaths[i]);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        loadedImages[i] = frame.image;
      } catch (e) {
        debugPrint('Error loading ${imagePaths[i]}: $e');
        loadedImages[i] = null;
      }
    }

    if (mounted) {
      setState(() {
        giftImages = loadedImages;
      });
    }
  }

  void _spinWheel() {
    if (widget.spinItems.isEmpty) return;

    final random = Random();
    final sectionCount = widget.spinItems.length;

    // Pick a random reward index
    final chosenIndex = random.nextInt(sectionCount);

    // how many full spins
    final spins = random.nextInt(4) + 4; // 4–7 full spins

    // each section angle (DEGREES)
    final sectionAngle = 360.0 / sectionCount;

    // stop in the middle of selected section
    final desiredMidAngle = (chosenIndex * sectionAngle) + (sectionAngle / 2);

    /// ✅ pointer is at TOP (-90°), so we want the chosen section center to come at -90°
    /// current rotation = 0 at start, so required target:
    /// finalRotationDeg = -90 - desiredMidAngle  (mod 360)
    double raw = (-90.0 - desiredMidAngle) % 360.0;
    if (raw < 0) raw += 360.0;

    // add small jitter (optional, keeps it still centered but looks natural)
    final jitter = (random.nextDouble() * 6.0) - 3.0; // -3° to +3°
    raw += jitter;

    _randomEndAngle = spins * 360.0 + raw;

    debugPrint(
      "🎯 chosenIndex=$chosenIndex desiredMidAngle=$desiredMidAngle raw=$raw end=$_randomEndAngle",
    );

    _controller.reset();
    _animation =
        Tween<double>(begin: 0.0, end: _randomEndAngle).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) _showResult();
        });

    _controller.forward();
  }

  // Future<void> _showResult() async {
  //   // ✅ Visual landing calculation (unchanged)
  //   final sectionCount = widget.spinItems.length;
  //   final sweepAngle = 2 * pi / sectionCount; // radians per segment

  //   final finalDegrees = _animation.value % 360.0;
  //   final rotation = finalDegrees * pi / 180.0;

  //   // pointer at top
  //   const pointerGlobalAngle = pointerDirection;

  //   double angleAtWheel = pointerGlobalAngle - rotation;

  //   while (angleAtWheel < 0) angleAtWheel += 2 * pi;
  //   while (angleAtWheel >= 2 * pi) angleAtWheel -= 2 * pi;

  //   int index = (angleAtWheel / sweepAngle).floor() % sectionCount;

  //   if (index < 0) index = 0;
  //   if (index >= sectionCount) index = sectionCount - 1;

  //   final visualReward = widget.spinItems[index];
  //   final visualAmount = visualReward['amount'].toString();

  //   debugPrint(
  //     '🎯 Visual landing: index $index, amount $visualAmount (ignored for real prize)',
  //   );

  //   setState(() {
  //     landedReward = visualReward;
  //   });

  //   // ✅ API call after spin stops (unchanged)
  //   debugPrint('📡 Calling POST API with spinId: ${widget.spinId}');
  //   setState(() => isLoadingSpin = true);

  //   try {
  //     final response = await Api.http.post('shopping/spin/${widget.spinId}');
  //     debugPrint('📡 API response: ${response.data}');

  //     if (response.data['success'] == true) {
  //       final wonAmount = response.data['won_amount']?.toString() ?? '0';

  //       debugPrint('✅ Won amount from server: $wonAmount');

  //       setState(() {
  //         _result = wonAmount;
  //         isLoadingSpin = false;
  //       });

  //       _showDialog(wonAmount);
  //     } else {
  //       final msg = response.data['message'] ?? 'Something went wrong';
  //       debugPrint('❌ API failed: $msg');
  //       setState(() => isLoadingSpin = false);
  //       AppUtils.showErrorSnackBar(msg);
  //     }
  //   } catch (error) {
  //     debugPrint('💥 API error: $error');
  //     setState(() => isLoadingSpin = false);
  //     AppUtils.showErrorSnackBar('Error: $error');
  //   }
  // }
  Future<void> _showResult() async {
    final sectionCount = widget.spinItems.length;
    final sweepAngle = 2 * pi / sectionCount;

    final finalDegrees = _animation.value % 360.0;
    final rotation = finalDegrees * pi / 180.0;

    const pointerGlobalAngle = pointerDirection;

    double angleAtWheel = pointerGlobalAngle - rotation;

    while (angleAtWheel < 0) angleAtWheel += 2 * pi;
    while (angleAtWheel >= 2 * pi) angleAtWheel -= 2 * pi;

    int index = (angleAtWheel / sweepAngle).floor() % sectionCount;

    if (index < 0) index = 0;
    if (index >= sectionCount) index = sectionCount - 1;

    final visualReward = widget.spinItems[index];
    final visualAmount = visualReward['amount'].toString();

    debugPrint('🎯 Result: $visualAmount');

    // ✅ Add reward to controller
    final rewardsController = Get.find<RewardsController>();
    rewardsController.addReward(double.parse(visualAmount));

    // ✅ Direct navigation to dashboard tab (SpinResultScreen)
    Get.offAll(
      () => MainFrontDashboard(),
      arguments: {"tab": 5, "fromSpin": true},
    );
  }

  // ✅ Dialog is unchanged (your existing one)
  void _showDialog(String amount) {
    final random = Random();

    final colors = [
      const Color(0xFFFFD700), // gold
      const Color(0xFF6C63FF), // app purple
      const Color(0xFF00E5FF),
      const Color(0xFFFF4081),
      const Color(0xFF69F0AE),
      Colors.white,
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final random = Random();

        /// Generate brand-style confetti
        final confetti = List.generate(35, (index) {
          return {
            "left": random.nextDouble(),
            "delay": random.nextDouble(),
            "size": 6 + random.nextDouble() * 10,
            "color": colors[random.nextInt(colors.length)],
          };
        });

        return WillPopScope(
          onWillPop: () async {
            final rewardsController = Get.find<RewardsController>();
            rewardsController.addReward(double.parse(amount));
            Get.off(() => SpinResultScreen());
            return false;
          },

          child: Stack(
            children: [
              /// ===== Confetti Layer =====
              ...confetti.map((c) {
                final delay = (c["delay"] ?? 0.0) as double;

                return TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: -0.1,
                    end: 1.0,
                  ), // smaller range = slower fall
                  duration: Duration(
                    milliseconds: (2500 + (delay * 1500)).round(),
                  ), // slower animation (2.5–4 sec)
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    final screen = MediaQuery.of(context).size;

                    double progress = value;

                    final leftBase = (c["left"] ?? 0.5) as double;
                    final dx = (c["dx"] ?? 0.0) as double;
                    final pieceSize = (c["size"] ?? 8.0) as double;
                    final color = (c["color"] ?? Colors.white) as Color;

                    // slower horizontal movement
                    double left =
                        screen.width * (leftBase + dx * progress * 0.5);

                    // slower vertical movement
                    double top = progress * screen.height;

                    return Positioned(
                      left: left,
                      top: top,
                      child: Opacity(
                        opacity: (1 - progress * 0.8).clamp(0.0, 1.0),
                        child: Transform.rotate(
                          angle: progress * 3.14, // slower rotation
                          child: Container(
                            width: pieceSize,
                            height: pieceSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.6),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),

              /// ===== Dialog =====
              Center(
                child: Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22.w,
                      vertical: 26.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22.r),
                      color: const Color(0xFF0B0E1A),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(color: primary.withOpacity(0.4)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// Glow circle
                        Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                primary.withOpacity(0.9),
                                primary.withOpacity(0.4),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.6),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.card_giftcard,
                            color: Colors.white,
                            size: 38.sp,
                          ),
                        ),

                        SizedBox(height: 18.h),

                        Text(
                          "Reward Unlocked!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        SizedBox(height: 6.h),

                        Text(
                          "You received cashback",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 14.sp,
                          ),
                        ),

                        SizedBox(height: 16.h),

                        /// Amount card
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.r),
                            color: Colors.white.withOpacity(0.05),
                            border: Border.all(color: primary.withOpacity(0.5)),
                          ),
                          child: Text(
                            "₹$amount",
                            style: TextStyle(
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        SizedBox(height: 22.h),

                        SizedBox(
                          width: double.infinity,
                          height: 48.h,
                          child: ElevatedButton(
                            onPressed: () {
                              final rewardsController =
                                  Get.find<RewardsController>();

                              rewardsController.addReward(double.parse(amount));

                              Get.offAll(
                                () => MainFrontDashboard(),
                                arguments: 5,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              "VIEW REWARDS",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // ✅ UI UPDATED HERE (CRED STYLE)
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final wheelSize = min(size.width, size.height) * 0.78;

    return Scaffold(
      backgroundColor: primary,
      extendBodyBehindAppBar: true,

      // ✅ CRED appbar image
      // appBar: PreferredSize(
      //   preferredSize: const Size.fromHeight(110),
      //   child: SafeArea(
      //     bottom: false,
      //     child: Image.asset("assets/logo/appbar.png", fit: BoxFit.cover),
      //   ),
      // ),
      body: Stack(
        children: [
          // rays background
          Positioned.fill(
            child: Image.asset(
              "assets/images/spin/rays.png",
              fit: BoxFit.cover,
            ),
          ),

          // main body
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "SPIN TO WIN",
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 70.h),

                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // wheel
                    GestureDetector(
                      onTap: _controller.isAnimating ? null : _spinWheel,
                      child: Container(
                        width: wheelSize,
                        height: wheelSize,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF060606),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.9),
                              blurRadius: 40,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            final radians = (_animation.value) * pi / 180;
                            return Transform.rotate(
                              angle: radians,
                              child: CustomPaint(
                                size: Size(wheelSize, wheelSize),
                                painter: CredStyleWheelPainter(
                                  items: widget.spinItems,
                                  giftImages: giftImages,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // pointer
                    Positioned(
                      top: -wheelSize * 0.3,
                      child: Transform.translate(
                        offset: Offset(0, wheelSize * 0.018),
                        child: Image.asset(
                          "assets/images/spin/pointer.png",
                          width: wheelSize * 0.18,
                        ),
                      ),
                    ),

                    // loading overlay
                    if (isLoadingSpin)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 42.w,
                              height: 42.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Color(0xFFFFD700),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 20.h),

                // spin button image
                GestureDetector(
                  onTap: _controller.isAnimating ? null : _spinWheel,
                  child: Container(
                    margin: EdgeInsets.only(top: 22.h),
                    child: Image.asset(
                      "assets/images/spin/spinButton.png",
                      height: 80.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // bottom gifts
          Positioned(
            left: -20,
            bottom: 0,
            child: Image.asset(
              "assets/images/spin/giftLeft.png",
              height: 120.h,
            ),
          ),
          Positioned(
            left: -10,
            bottom: -10,
            child: Image.asset(
              "assets/images/spin/giftLeft2.png",
              height: 120.h,
            ),
          ),
          Positioned(
            right: -10,
            bottom: -10,
            child: Image.asset(
              "assets/images/spin/giftRight.png",
              height: 120.h,
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ CRED STYLE WHEEL Painter (same style ring + bulbs + sectors)
class CredStyleWheelPainter extends CustomPainter {
  final List<dynamic> items;
  final List<ui.Image?> giftImages;

  CredStyleWheelPainter({required this.items, required this.giftImages});

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final sections = items.length;
    final sectionAngle = (2 * pi) / sections;

    // background black circle
    canvas.drawCircle(center, radius, Paint()..color = Colors.black);

    // metallic ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.085
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFF2B0), Color(0xFFF6CB48), Color(0xFFD9A837)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius * 0.92, ringPaint);

    // bulbs around ring
    final bulbPaint = Paint()..color = Colors.white;
    final glowPaint = Paint()..color = Colors.white24;

    const bulbCount = 36;
    for (int i = 0; i < bulbCount; i++) {
      final a = (2 * pi / bulbCount) * i;

      final dx = center.dx + (radius * 0.92) * cos(a);
      final dy = center.dy + (radius * 0.92) * sin(a);

      canvas.drawCircle(Offset(dx, dy), radius * 0.028, glowPaint);
      canvas.drawCircle(Offset(dx, dy), radius * 0.018, bulbPaint);
    }

    // sectors
    final sectorRect = Rect.fromCircle(center: center, radius: radius * 0.89);

    // your color pattern (same like cred)
    final sectorColors = [
      const Color(0xFF01E0D1),
      const Color(0xFF1346D2),
      const Color(0xFF07C3FB),
      const Color(0xFF0B2CA4),
      const Color(0xFF02D0C6),
      const Color(0xFF102F8F),
    ];

    for (int i = 0; i < sections; i++) {
      canvas.drawArc(
        sectorRect,
        i * sectionAngle,
        sectionAngle,
        true,
        Paint()..color = sectorColors[i % sectorColors.length],
      );
    }

    // separators
    final sepPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = 1;

    for (int i = 0; i < sections; i++) {
      final angle = i * sectionAngle;
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        ),
        sepPaint,
      );
    }

    // draw gifts or amount labels
    for (int i = 0; i < sections; i++) {
      final mid = (i * sectionAngle) + sectionAngle / 2;

      final x = center.dx + radius * 0.55 * cos(mid);
      final y = center.dy + radius * 0.55 * sin(mid);

      // try to draw gift image
      final imgIndex = giftImages.isNotEmpty ? (i % giftImages.length) : 0;
      final giftImage = giftImages.isNotEmpty ? giftImages[imgIndex] : null;

      if (giftImage != null) {
        canvas.save();
        canvas.translate(x, y);

        double rot = mid + pi / 2;
        if (rot > pi) rot -= 2 * pi;
        canvas.rotate(rot);

        const imageSize = 70.0;
        final imageOffset = Offset(-imageSize / 2, -imageSize / 2);

        canvas.drawImageRect(
          giftImage,
          Rect.fromLTWH(
            0,
            0,
            giftImage.width.toDouble(),
            giftImage.height.toDouble(),
          ),
          Rect.fromLTWH(imageOffset.dx, imageOffset.dy, imageSize, imageSize),
          Paint(),
        );

        canvas.restore();
      } else {
        // fallback amount text
        final text = items[i]['amount']?.toString() ?? '';
        canvas.save();
        canvas.translate(x, y);

        double rot = mid + pi / 2;
        if (rot > pi) rot -= 2 * pi;
        canvas.rotate(rot);

        final tp = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: radius * 0.2,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: radius * 0.62);

        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
        canvas.restore();
      }
    }

    // center hub
    final hubR = radius * 0.22;

    final hubGradient = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFF4B6), Color(0xFFF2C948), Color(0xFFD7A437)],
      ).createShader(Rect.fromCircle(center: center, radius: hubR));

    canvas.drawCircle(center, hubR, hubGradient);

    canvas.drawCircle(
      center,
      hubR * 0.78,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = hubR * 0.14
        ..color = Colors.white24,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
