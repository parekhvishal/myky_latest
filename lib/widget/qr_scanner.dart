import
'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:myky_clone/widget/theme.dart';

class QRScannerBox extends StatefulWidget {
  const QRScannerBox({super.key});

  @override
  State<QRScannerBox> createState() => _QRScannerBoxState();
}

class _QRScannerBoxState extends State<QRScannerBox> {
  bool _isScanning = false;
  final MobileScannerController _controller = MobileScannerController();

  void _toggleScanner() {
    setState(() => _isScanning = !_isScanning);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 55, 38, 207),
              Color.fromARGB(255, 65, 57, 227),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: _toggleScanner,
                  child: Container(
                    height: 240.h,
                    width: 240.w,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3135B0), Color(0xFF26277E)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: ClipRRect(
                      child: _isScanning
                          ? Stack(
                              children: [
                                MobileScanner(
                                  controller: _controller,
                                  onDetect: (capture) {
                                    final barcodes = capture.barcodes;
                                    if (barcodes.isNotEmpty) {
                                      final code =
                                          barcodes.first.rawValue ?? 'Unknown';
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Scanned: $code'),
                                        ),
                                      );
                                      setState(() => _isScanning = false);
                                    }
                                  },
                                ),
                              ],
                            )
                          : Stack(
                              children: [
                                // Background QR image
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: ClipRRect(
                                      child: Stack(
                                        children: [
                                          // Fake QR background image
                                          Center(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(20.r),
                                              child: Image.asset(
                                                'assets/images/qr-scanner.png',
                                                fit: BoxFit.contain,
                                                width: 250.w,
                                                height: 250.h,
                                                errorBuilder:
                                                    (context, error, stackTrace) {
                                                  return Container(
                                                    // width: 200.w,
                                                    // height: 200.w,
                                                    color: Colors.white
                                                        .withOpacity(0.1),
                                                    child: Icon(
                                                      Icons.qr_code,
                                                      size: 105.sp,
                                                      color: Colors.white
                                                          .withOpacity(0.3),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          // Overlay gradient to improve text visibility
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                    ),
                  ),
                ),
                if (_isScanning)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _toggleScanner,
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 15.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flash_on, color: Colors.greenAccent, size: 20.sp),
                SizedBox(width: 4.w),
                Text(
                  "Get cashback on scan & pay",
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget scannerCorner({
    bool isTop = true,
    bool isLeft = true,
    bool isRight = true,
  }) {
    return Transform.rotate(
      angle: (isTop ? 0 : 3.14 / 2) +
          (isLeft ? 0 : 3.14 / 2) +
          (isRight ? 0 : 3.14 / 2),
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.greenAccent, width: 3),
            left: BorderSide(color: Colors.greenAccent, width: 3),
          ),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(15)),
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140.w,
        height: 55.h,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 82, 81, 245),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 25.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedScanLine extends StatefulWidget {
  const AnimatedScanLine({super.key});

  @override
  State<AnimatedScanLine> createState() => _AnimatedScanLineState();
}

class _AnimatedScanLineState extends State<AnimatedScanLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _position = Tween<double>(begin: 0, end: 250.h).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _position,
      builder: (_, __) => Positioned(
        top: _position.value,
        left: 0,
        right: 0,
        //bottom: _position.value,
        child: Container(height: 2.h, color: Colors.redAccent),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Enhanced scanner corner with animation
class EnhancedScannerCorner extends StatefulWidget {
  final bool isTop;
  final bool isLeft;

  const EnhancedScannerCorner({
    Key? key,
    this.isTop = true,
    this.isLeft = true,
  }) : super(key: key);

  @override
  State<EnhancedScannerCorner> createState() => _EnhancedScannerCornerState();
}

class _EnhancedScannerCornerState extends State<EnhancedScannerCorner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, __) => Container(
        width: 30.w,
        height: 30.w,
        decoration: BoxDecoration(
          border: Border(
            top: widget.isTop
                ? BorderSide(
                    color: Colors.greenAccent.withOpacity(_opacity.value),
                    width: 3,
                  )
                : BorderSide.none,
            left: widget.isLeft
                ? BorderSide(
                    color: Colors.greenAccent.withOpacity(_opacity.value),
                    width: 3,
                  )
                : BorderSide.none,
            bottom: !widget.isTop
                ? BorderSide(
                    color: Colors.greenAccent.withOpacity(_opacity.value),
                    width: 3,
                  )
                : BorderSide.none,
            right: !widget.isLeft
                ? BorderSide(
                    color: Colors.greenAccent.withOpacity(_opacity.value),
                    width: 3,
                  )
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: widget.isTop && widget.isLeft
                ? Radius.circular(15)
                : Radius.zero,
            topRight: widget.isTop && !widget.isLeft
                ? Radius.circular(15)
                : Radius.zero,
            bottomLeft: !widget.isTop && widget.isLeft
                ? Radius.circular(15)
                : Radius.zero,
            bottomRight: !widget.isTop && !widget.isLeft
                ? Radius.circular(15)
                : Radius.zero,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Breathing animation for the entire scanner box
class BreathingAnimation extends StatefulWidget {
  const BreathingAnimation({Key? key}) : super(key: key);

  @override
  State<BreathingAnimation> createState() => _BreathingAnimationState();
}

class _BreathingAnimationState extends State<BreathingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(
        scale: _scale.value,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.greenAccent.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Pulsing overlay for scanning state
class PulsingOverlay extends StatefulWidget {
  const PulsingOverlay({Key? key}) : super(key: key);

  @override
  State<PulsingOverlay> createState() => _PulsingOverlayState();
}

class _PulsingOverlayState extends State<PulsingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.redAccent.withOpacity(_opacity.value),
            width: 2,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
