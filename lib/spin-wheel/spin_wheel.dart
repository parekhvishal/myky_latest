// import 'dart:math';
// import 'dart:ui' as ui;
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:myky_clone/services/api.dart'; // adjust import paths
// import 'package:myky_clone/utils/app_utils.dart';

// class SpinWheelScreen extends StatefulWidget {
//   final List<dynamic> spinItems; // from API
//   final int spinId; // from spinList in reward.dart

//   const SpinWheelScreen({
//     Key? key,
//     required this.spinItems,
//     required this.spinId,
//   }) : super(key: key);

//   @override
//   _SpinWheelScreenState createState() => _SpinWheelScreenState();
// }

// class _SpinWheelScreenState extends State<SpinWheelScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//   double _randomEndAngle = 0.0;
//   String? _result;
//   bool isLoadingSpin = false;
//   List<ui.Image?> giftImages = []; // List for multiple images
//   Map<String, dynamic>? landedReward;

//   @override
//   void initState() {
//     super.initState();
//     _controller =
//         AnimationController(vsync: this, duration: const Duration(seconds: 5));
//     _animation = Tween<double>(begin: 0, end: 0).animate(_controller);

//     _loadGiftImages(); // Load all 6 gift assets
//   }

//   Future<void> _loadGiftImages() async {
//     final List<String> imagePaths = [
//       'assets/images/gift.png',
//       'assets/images/gift_1.png',
//       'assets/images/gift_2.png',
//       'assets/images/gift_3.png',
//       'assets/images/gift_4.png',
//       'assets/images/gift_5.png',
//     ];

//     final List<ui.Image?> loadedImages = List.filled(imagePaths.length, null);
//     for (int i = 0; i < imagePaths.length; i++) {
//       try {
//         final data = await rootBundle.load(imagePaths[i]);
//         final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
//         final frame = await codec.getNextFrame();
//         loadedImages[i] = frame.image;
//       } catch (e) {
//         print('Error loading ${imagePaths[i]}: $e');
//         loadedImages[i] = null;
//       }
//     }

//     if (mounted) {
//       setState(() {
//         giftImages = loadedImages;
//       });
//     }
//   }

//   void _spinWheel() {
//     if (widget.spinItems.isEmpty) return;
//     final random = Random();
//     final spins = random.nextInt(4) + 4; // 4–7 full spins
//     final offsetAngle = random.nextDouble() * 360.0;
//     _randomEndAngle = spins * 360.0 + offsetAngle;

//     print('🔄 Starting spin animation for 5s with spinId: ${widget.spinId}');

//     _controller.reset();
//     _animation = Tween<double>(begin: 0.0, end: _randomEndAngle).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
//     )..addStatusListener((status) {
//       if (status == AnimationStatus.completed) _showResult();
//     });
//     _controller.forward();
//   }

//   Future<void> _showResult() async {
//     // Calculate visual landing for fun (client-side random)
//     final sectionCount = widget.spinItems.length;
//     final sweepAngle = 2 * pi / sectionCount; // radians per segment

//     // Use the animation's final value (in degrees) and convert to radians
//     final finalDegrees = _animation.value % 360.0;
//     final rotation = finalDegrees * pi / 180.0; // rotation applied to the wheel (radians)

//     // Pointer is at the top: global angle = -pi/2
//     const pointerGlobalAngle = -pi / 2;

//     // Angle in wheel coordinate that is under the pointer:
//     // angleAtWheel = pointerGlobalAngle - rotation
//     double angleAtWheel = pointerGlobalAngle - rotation;

//     // Normalize to [0, 2*pi)
//     while (angleAtWheel < 0) angleAtWheel += 2 * pi;
//     while (angleAtWheel >= 2 * pi) angleAtWheel -= 2 * pi;

//     // The index is the floor of angle / sweepAngle
//     int index = (angleAtWheel / sweepAngle).floor() % sectionCount;

//     // Safety clamp (just in case)
//     if (index < 0) index = 0;
//     if (index >= sectionCount) index = sectionCount - 1;

//     final visualReward = widget.spinItems[index];
//     final visualAmount = visualReward['amount'].toString();

//     print('🎯 Visual landing: index $index, amount $visualAmount (ignored for real prize)');

//     setState(() {
//       landedReward = visualReward;
//     });

//     // Now call the API automatically after spin stops
//     print('📡 Calling POST API with spinId: ${widget.spinId}');
//     setState(() => isLoadingSpin = true);
//     try {
//       final response = await Api.http.post('shopping/spin/${widget.spinId}');
//       print('📡 API response: ${response.data}');

//       // Handle the correct key (success)
//       if (response.data['success'] == true) {
//         final wonAmount = response.data['won_amount']?.toString() ?? '0';
//         print('✅ Won amount from server: $wonAmount');

//         setState(() {
//           _result = wonAmount;
//           isLoadingSpin = false;
//         });

//         print('🎉 Showing dialog with real amount: $wonAmount');
//         _showDialog(wonAmount);
//       } else {
//         final msg = response.data['message'] ?? 'Something went wrong';
//         print('❌ API failed: $msg');
//         setState(() => isLoadingSpin = false);
//         AppUtils.showErrorSnackBar(msg);
//       }
//     } catch (error) {
//       print('💥 API error: $error');
//       setState(() => isLoadingSpin = false);
//       AppUtils.showErrorSnackBar('Error: $error');
//     }
//   }

//   void _showDialog(String amount) {
//     print('🪟 Dialog opened with amount: $amount');
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext dialogContext) {
//         final size = MediaQuery.of(context).size;

//         // Deterministic pseudo-random generator based on amount string
//         int _seed = amount.hashCode & 0x7fffffff;
//         int _nextSeed() {
//           _seed = (_seed * 1664525 + 1013904223) & 0x7fffffff;
//           return _seed;
//         }

//         double _randDouble() => _nextSeed() / 0x7fffffff;

//         // confetti specs
//         final confetti = List.generate(24, (i) {
//           return {
//             'x': 0.04 + _randDouble() * 0.92,
//             'dx': -0.28 + _randDouble() * 0.56,
//             'delay': 0.0 + _randDouble() * 0.6,
//             'rot': -2.6 + _randDouble() * 5.2,
//             'size': (8 + (_randDouble() * 20)).toDouble(),
//             'colorToggle': _randDouble(),
//           };
//         });

//         // Build confetti widgets (we will put them after the card to render in front)
//         final confettiWidgets = confetti.asMap().entries.map((entry) {
//           final idx = entry.key;
//           final spec = entry.value;

//           final delayMs = ((spec['delay'] as double) * 700).round();
//           final durMs = 850 + ((idx * 41) % 900);

//           final c = (spec['colorToggle'] as double) < 0.28
//               ? const Color(0xFFFFD700)
//               : (spec['colorToggle'] as double) < 0.56
//               ? const Color(0xFFEA4C89)
//               : (spec['colorToggle'] as double) < 0.78
//               ? const Color(0xFF4CE0D0)
//               : const Color(0xFF9AE66E);

//           return TweenAnimationBuilder<double>(
//             key: ValueKey('confetti_$idx${amount.hashCode}'),
//             tween: Tween(begin: -0.2, end: 1.25),
//             duration: Duration(milliseconds: durMs),
//             curve: Curves.easeIn,
//             builder: (cxt, v, child) {
//               double startOffset = (delayMs / durMs).clamp(0.0, 0.85);
//               double progress = ((v - startOffset) / (1 - startOffset)).clamp(0.0, 1.0);

//               final xFrac = (spec['x'] as double);
//               final dx = (spec['dx'] as double);
//               final currentX = (xFrac + dx * progress).clamp(0.02, 0.98);

//               final top = progress * (size.height + 160) - 160;
//               final rot = (spec['rot'] as double) * progress;
//               final opacity = (1.0 - progress).clamp(0.0, 1.0);

//               final pieceSize = (spec['size'] as double);

//               return Positioned(
//                 left: currentX * size.width,
//                 top: top,
//                 child: Opacity(
//                   opacity: opacity,
//                   child: Transform.rotate(
//                     angle: rot,
//                     child: Container(
//                       width: pieceSize,
//                       height: pieceSize * 0.6,
//                       decoration: BoxDecoration(
//                         color: c,
//                         borderRadius: BorderRadius.circular(2.r),
//                         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 4)],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         }).toList();

//         // Use StatefulBuilder to allow local looping animations by re-triggering builds
//         return Dialog(
//           insetPadding: EdgeInsets.zero, // cover full screen
//           backgroundColor: Colors.transparent,
//           child: StatefulBuilder(builder: (context, setState) {
//             // The dialog full screen stack
//             return Stack(
//               children: [
//                 // Fullscreen dark glamorous backdrop
//                 Positioned.fill(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [const Color(0xFF030406), const Color(0xFF071427)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                     ),
//                   ),
//                 ),

//                 // Large radial gold focus behind the card
//                 Positioned.fill(
//                   child: IgnorePointer(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         gradient: RadialGradient(
//                           center: const Alignment(0.0, -0.3),
//                           radius: 0.9,
//                           colors: [const Color(0xFFFFD700).withOpacity(0.16), Colors.transparent],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),

//                 // Center frosted glass card (totally new look)
//                 Center(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 28.h),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(28.r),
//                       child: BackdropFilter(
//                         filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
//                         child: Container(
//                           width: size.width,
//                           // full-bleed feel but with internal padding
//                           constraints: BoxConstraints(maxWidth: 820.w, maxHeight: size.height * 0.92),
//                           padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 26.h),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(28.r),
//                             gradient: LinearGradient(
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                               colors: [Colors.white.withOpacity(0.03), Colors.white.withOpacity(0.01)],
//                             ),
//                             border: Border.all(color: Colors.transparent, width: 0),
//                             boxShadow: [
//                               BoxShadow(color: Colors.black.withOpacity(0.62), blurRadius: 40, offset: Offset(0, 20)),
//                             ],
//                           ),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               SizedBox(height: 8.h),

//                               // Decorative top ornament (luxury stroke)
//                               Container(
//                                 width: 140.w,
//                                 height: 6.h,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12.r),
//                                   gradient: LinearGradient(
//                                     colors: [
//                                       const Color(0xFFFFD700),
//                                       const Color(0xFFFFF3C4),
//                                       const Color(0xFFFFD700),
//                                     ],
//                                     begin: Alignment.centerLeft,
//                                     end: Alignment.centerRight,
//                                   ),
//                                   boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.12), blurRadius: 14, spreadRadius: 2)],
//                                 ),
//                               ),

//                               SizedBox(height: 18.h),

//                               // Animated gift badge: bouncing loop using TweenAnimationBuilder on end -> setState retriggers for loop
//                               TweenAnimationBuilder<double>(
//                                 key: ValueKey('badge_bounce_${amount.hashCode}'),
//                                 tween: Tween(begin: 0.0, end: 1.0),
//                                 duration: const Duration(milliseconds: 650),
//                                 curve: Curves.easeOutBack,
//                                 onEnd: () {
//                                   // retrigger to continue loop with slight rhythm
//                                   Future.delayed(const Duration(milliseconds: 240), () {
//                                     setState(() {});
//                                   });
//                                 },
//                                 builder: (context, v, child) {
//                                   final scale = 0.82 + 0.3 * v; // 0.82 -> 1.12
//                                   final rotate = (v - 0.5) * 0.06;
//                                   final verticalShift = (1 - v) * 6.h;
//                                   return Transform.translate(
//                                     offset: Offset(0, verticalShift),
//                                     child: Transform.rotate(
//                                       angle: rotate,
//                                       child: Transform.scale(scale: scale, child: child),
//                                     ),
//                                   );
//                                 },
//                                 child: Container(
//                                   width: 60.w,
//                                   height: 60.w,
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     gradient: RadialGradient(
//                                       colors: [const Color(0xFFFFF9EA), const Color(0xFFFFE082)],
//                                     ),
//                                     boxShadow: [
//                                       BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.28), blurRadius: 30, spreadRadius: 3),
//                                       BoxShadow(color: Colors.black.withOpacity(0.28), blurRadius: 18, offset: Offset(0, 10)),
//                                     ],
//                                     border: Border.all(color: const Color(0xFFFFC700), width: 2.8.w),
//                                   ),
//                                   child: ClipOval(
//                                     child: Container(
//                                       // inner circle background to help the gift image pop
//                                       color: Colors.white.withOpacity(0.02),
//                                       child: Center(
//                                         child: ClipOval(
//                                           child: Image.asset(
//                                             'assets/images/gift_box.png',
//                                             width: double.infinity,
//                                             height: double.infinity,
//                                             fit: BoxFit.cover,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),

//                               SizedBox(height: 18.h),

//                               // PERFECT FIT heading
//                               LayoutBuilder(builder: (context, constraints) {
//                                 return ConstrainedBox(
//                                   constraints: BoxConstraints(maxWidth: constraints.maxWidth),
//                                   child: FittedBox(
//                                     fit: BoxFit.scaleDown,
//                                     alignment: Alignment.center,
//                                     child: Text(
//                                       'CONGRATULATIONS',
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                         fontSize: 38.sp,
//                                         fontWeight: FontWeight.w900,
//                                         color: Colors.white,
//                                         letterSpacing: 1.8,
//                                         shadows: [Shadow(color: Colors.black.withOpacity(0.6), blurRadius: 8, offset: Offset(0, 3))],
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               }),

//                               SizedBox(height: 18.h),

//                               // NEW attractive won-amount card with little animation and label
//                               TweenAnimationBuilder<double>(
//                                 tween: Tween(begin: 0.8, end: 1.0),
//                                 duration: const Duration(milliseconds: 520),
//                                 curve: Curves.easeOut,
//                                 builder: (context, v, child) {
//                                   return Transform.scale(
//                                     scale: v,
//                                     child: child,
//                                   );
//                                 },
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 18.h),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(18.r),
//                                     gradient: LinearGradient(
//                                       begin: Alignment.topLeft,
//                                       end: Alignment.bottomRight,
//                                       colors: [const Color(0xFFFFFBEE).withOpacity(0.12), const Color(0xFFFFF2D8).withOpacity(0.06)],
//                                     ),
//                                     border: Border.all(color: const Color(0xFFFFD700), width: 1.4.w),
//                                     boxShadow: [
//                                       BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.08), blurRadius: 26, spreadRadius: 2),
//                                     ],
//                                   ),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       // small badge icon on the left
//                                       Container(
//                                         width: 35.w,
//                                         height: 35.w,
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           gradient: LinearGradient(colors: [const Color(0xFFFFF8E1), const Color(0xFFFFE082)]),
//                                           border: Border.all(color: const Color(0xFFFFC55A), width: 1.w),
//                                           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6)],
//                                         ),
//                                         child: Center(
//                                           child: Image.asset('assets/images/myky.png', width: 28.w, height: 28.w, fit: BoxFit.contain),
//                                         ),
//                                       ),

//                                       // SizedBox(width: 12.w),

//                                       // Big amount + tiny label stacked
//                                       Column(
//                                         crossAxisAlignment: CrossAxisAlignment.center,
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         children: [
//                                           // label
//                                           Text(
//                                             'YOU WON',
//                                             style: TextStyle(fontSize: 12.sp, color: Colors.white70, fontWeight: FontWeight.w700),
//                                           ),

//                                           SizedBox(height: 6.h),

//                                           // big animated amount number (with subtle gradient text via ShaderMask)
//                                           ShaderMask(
//                                             shaderCallback: (bounds) {
//                                               return LinearGradient(
//                                                 colors: [const Color(0xFFFFD700), const Color(0xFFFFE9A6)],
//                                               ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
//                                             },
//                                             child: Text(
//                                               amount,
//                                               style: TextStyle(
//                                                 fontSize: 30.sp,
//                                                 fontWeight: FontWeight.w900,
//                                                 color: Colors.white, // will be masked by shader
//                                                 shadows: [
//                                                   Shadow(color: Colors.black.withOpacity(0.35), blurRadius: 6, offset: Offset(0, 3)),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),

//                                       // SizedBox(width: 14.w),
//                                       //
//                                       // // little sparkle icon to the right
//                                       // Container(
//                                       //   width: 34.w,
//                                       //   height: 34.w,
//                                       //   decoration: BoxDecoration(
//                                       //     shape: BoxShape.circle,
//                                       //     gradient: LinearGradient(colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.6)]),
//                                       //   ),
//                                       //   child: Center(child: Icon(Icons.star, size: 18.sp, color: const Color(0xFFFFC700))),
//                                       // ),
//                                     ],
//                                   ),
//                                 ),
//                               ),

//                               SizedBox(height: 22.h),

//                               // Primary CTA
//                               SizedBox(
//                                 width: double.infinity,
//                                 height: 56.h,
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     print('🚀 GREAT tapped - closing dialog and returning to reward');
//                                     Get.back(); // Close dialog
//                                     Get.back(); // Go back to reward page
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color(0xFFFFD700),
//                                     foregroundColor: Colors.black,
//                                     padding: EdgeInsets.symmetric(vertical: 12.h),
//                                     elevation: 14,
//                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
//                                     shadowColor: const Color(0xFFFFD700).withOpacity(0.36),
//                                   ),
//                                   child: Text('GREAT!', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, letterSpacing: 0.6)),
//                                 ),
//                               ),

//                               SizedBox(height: 12.h),

//                               Text('Reward added to your account.', style: TextStyle(fontSize: 12.sp, color: Colors.white54)),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),

//                 // Confetti in FRONT of the dialog -> placed after the card in the Stack
//                 ...confettiWidgets,
//               ],
//             );
//           }),
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final items = widget.spinItems;

//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: RadialGradient(
//             center: Alignment.center,
//             radius: 1.2,
//             colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F0F23)],
//           ),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 '🎡 Spin to Win!',
//                 style: TextStyle(
//                   fontSize: 26.sp,
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFFFFD700),
//                 ),
//               ),
//               SizedBox(height: 30.h),
//               Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   Container(
//                     width: 350.w,
//                     height: 350.w,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                           color: const Color(0xFFFFD700), width: 6.w),
//                     ),
//                     child: AnimatedBuilder(
//                       animation: _animation,
//                       builder: (context, child) {
//                         final radians = (_animation.value) * pi / 180;
//                         return Transform.rotate(
//                           angle: radians,
//                           child: CustomPaint(
//                             painter: DynamicWheelPainter(
//                               items: items,
//                               giftImages: giftImages, // Pass list
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   Positioned(
//                     top: 30.h,
//                     child: CustomPaint(
//                       size: Size(30.w, 30.h),
//                       painter: PointerPainter(),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 40.h),
//               ElevatedButton(
//                 onPressed: _controller.isAnimating ? null : _spinWheel,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFFFD700),
//                   foregroundColor: Colors.white,
//                   padding:
//                   EdgeInsets.symmetric(horizontal: 50.w, vertical: 16.h),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(35.r)),
//                 ),
//                 child: Text(
//                   'SPIN THE WHEEL',
//                   style: TextStyle(
//                     fontSize: 18.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// 🎨 Wheel Painter — cycles through 6 gift images
// class DynamicWheelPainter extends CustomPainter {
//   final List<dynamic> items;
//   final List<ui.Image?> giftImages; // List of images

//   DynamicWheelPainter({required this.items, required this.giftImages});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2;
//     final sectionCount = items.length;
//     final sweepAngle = (2 * pi) / sectionCount;

//     for (int i = 0; i < sectionCount; i++) {
//       final startAngle = i * sweepAngle;
//       final paint = Paint()
//         ..shader = LinearGradient(
//           colors: [
//             Colors.primaries[i % Colors.primaries.length].shade400,
//             Colors.primaries[i % Colors.primaries.length].shade700,
//           ],
//         ).createShader(Rect.fromCircle(center: center, radius: radius))
//         ..style = PaintingStyle.fill;

//       // Segment fill
//       canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
//           startAngle, sweepAngle, true, paint);

//       // Cycle through gift images
//       final imgIndex = i % giftImages.length;
//       final giftImage = giftImages[imgIndex];
//       if (giftImage != null) {
//         final angle = startAngle + sweepAngle / 2;
//         final textX = center.dx + (radius / 2) * cos(angle);
//         final textY = center.dy + (radius / 2) * sin(angle);

//         canvas.save();
//         canvas.translate(textX, textY);
//         canvas.rotate(angle + pi / 2);

//         const imageSize = 70.0;
//         final imageOffset = Offset(-imageSize / 2, -imageSize / 2);
//         canvas.drawImageRect(
//           giftImage,
//           Rect.fromLTWH(
//               0, 0, giftImage.width.toDouble(), giftImage.height.toDouble()),
//           Rect.fromLTWH(imageOffset.dx, imageOffset.dy, imageSize, imageSize),
//           Paint(),
//         );

//         canvas.restore();
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }

// /// Pointer at top
// class PointerPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = const Color(0xFFFFD700);
//     final path = Path()
//       ..moveTo(size.width / 2, 0)
//       ..lineTo(0, size.height)
//       ..lineTo(size.width, size.height)
//       ..close();
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }

import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:myky_clone/services/api.dart';
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

  Future<void> _showResult() async {
    // ✅ Visual landing calculation (unchanged)
    final sectionCount = widget.spinItems.length;
    final sweepAngle = 2 * pi / sectionCount; // radians per segment

    final finalDegrees = _animation.value % 360.0;
    final rotation = finalDegrees * pi / 180.0;

    // pointer at top
    const pointerGlobalAngle = pointerDirection;

    double angleAtWheel = pointerGlobalAngle - rotation;

    while (angleAtWheel < 0) angleAtWheel += 2 * pi;
    while (angleAtWheel >= 2 * pi) angleAtWheel -= 2 * pi;

    int index = (angleAtWheel / sweepAngle).floor() % sectionCount;

    if (index < 0) index = 0;
    if (index >= sectionCount) index = sectionCount - 1;

    final visualReward = widget.spinItems[index];
    final visualAmount = visualReward['amount'].toString();

    debugPrint(
      '🎯 Visual landing: index $index, amount $visualAmount (ignored for real prize)',
    );

    setState(() {
      landedReward = visualReward;
    });

    // ✅ API call after spin stops (unchanged)
    debugPrint('📡 Calling POST API with spinId: ${widget.spinId}');
    setState(() => isLoadingSpin = true);

    try {
      final response = await Api.http.post('shopping/spin/${widget.spinId}');
      debugPrint('📡 API response: ${response.data}');

      if (response.data['success'] == true) {
        final wonAmount = response.data['won_amount']?.toString() ?? '0';

        debugPrint('✅ Won amount from server: $wonAmount');

        setState(() {
          _result = wonAmount;
          isLoadingSpin = false;
        });

        _showDialog(wonAmount);
      } else {
        final msg = response.data['message'] ?? 'Something went wrong';
        debugPrint('❌ API failed: $msg');
        setState(() => isLoadingSpin = false);
        AppUtils.showErrorSnackBar(msg);
      }
    } catch (error) {
      debugPrint('💥 API error: $error');
      setState(() => isLoadingSpin = false);
      AppUtils.showErrorSnackBar('Error: $error');
    }
  }

  // ✅ Dialog is unchanged (your existing one)
  void _showDialog(String amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final size = MediaQuery.of(context).size;

        int _seed = amount.hashCode & 0x7fffffff;
        int _nextSeed() {
          _seed = (_seed * 1664525 + 1013904223) & 0x7fffffff;
          return _seed;
        }

        double _randDouble() => _nextSeed() / 0x7fffffff;

        final confetti = List.generate(24, (i) {
          return {
            'x': 0.04 + _randDouble() * 0.92,
            'dx': -0.28 + _randDouble() * 0.56,
            'delay': 0.0 + _randDouble() * 0.6,
            'rot': -2.6 + _randDouble() * 5.2,
            'size': (8 + (_randDouble() * 20)).toDouble(),
            'colorToggle': _randDouble(),
          };
        });

        final confettiWidgets = confetti.asMap().entries.map((entry) {
          final idx = entry.key;
          final spec = entry.value;

          final delayMs = ((spec['delay'] as double) * 700).round();
          final durMs = 850 + ((idx * 41) % 900);

          final c = (spec['colorToggle'] as double) < 0.28
              ? const Color(0xFFFFD700)
              : (spec['colorToggle'] as double) < 0.56
              ? const Color(0xFFEA4C89)
              : (spec['colorToggle'] as double) < 0.78
              ? const Color(0xFF4CE0D0)
              : const Color(0xFF9AE66E);

          return TweenAnimationBuilder<double>(
            key: ValueKey('confetti_$idx${amount.hashCode}'),
            tween: Tween(begin: -0.2, end: 1.25),
            duration: Duration(milliseconds: durMs),
            curve: Curves.easeIn,
            builder: (cxt, v, child) {
              double startOffset = (delayMs / durMs).clamp(0.0, 0.85);
              double progress = ((v - startOffset) / (1 - startOffset)).clamp(
                0.0,
                1.0,
              );

              final xFrac = (spec['x'] as double);
              final dx = (spec['dx'] as double);
              final currentX = (xFrac + dx * progress).clamp(0.02, 0.98);

              final top = progress * (size.height + 160) - 160;
              final rot = (spec['rot'] as double) * progress;
              final opacity = (1.0 - progress).clamp(0.0, 1.0);

              final pieceSize = (spec['size'] as double);

              return Positioned(
                left: currentX * size.width,
                top: top,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.rotate(
                    angle: rot,
                    child: Container(
                      width: pieceSize,
                      height: pieceSize * 0.6,
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(2.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.22),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }).toList();

        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF030406), Color(0xFF071427)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0.0, -0.3),
                            radius: 0.9,
                            colors: [
                              const Color(0xFFFFD700).withOpacity(0.16),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 28.h,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28.r),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                          child: Container(
                            width: size.width,
                            constraints: BoxConstraints(
                              maxWidth: 820.w,
                              maxHeight: size.height * 0.92,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 28.w,
                              vertical: 26.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28.r),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.03),
                                  Colors.white.withOpacity(0.01),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.62),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 8.h),
                                Container(
                                  width: 140.w,
                                  height: 6.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFD700),
                                        Color(0xFFFFF3C4),
                                        Color(0xFFFFD700),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 18.h),
                                Container(
                                  width: 60.w,
                                  height: 60.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const RadialGradient(
                                      colors: [
                                        Color(0xFFFFF9EA),
                                        Color(0xFFFFE082),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: const Color(0xFFFFC700),
                                      width: 2.8.w,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/gift_box.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 18.h),
                                Text(
                                  'CONGRATULATIONS',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 30.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.6,
                                  ),
                                ),
                                SizedBox(height: 18.h),
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                        colors: [
                                          Color(0xFFFFD700),
                                          Color(0xFFFFE9A6),
                                        ],
                                      ).createShader(bounds),
                                  child: Text(
                                    amount,
                                    style: TextStyle(
                                      fontSize: 34.sp,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 22.h),
                                SizedBox(
                                  width: double.infinity,
                                  height: 56.h,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Get.back();
                                      Get.back();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFD700),
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          14.r,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'GREAT!',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'Reward added to your account.',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ...confettiWidgets,
                ],
              );
            },
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
