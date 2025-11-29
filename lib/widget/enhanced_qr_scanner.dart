import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class EnhancedQRScannerBox extends StatefulWidget {
  const EnhancedQRScannerBox({super.key});

  @override
  State<EnhancedQRScannerBox> createState() => _EnhancedQRScannerBoxState();
}

class _EnhancedQRScannerBoxState extends State<EnhancedQRScannerBox>
    with TickerProviderStateMixin {
  bool _isScanning = false;
  final MobileScannerController _controller = MobileScannerController();
  
  late AnimationController _sparkleController;
  late AnimationController _pulseController;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _sparkleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.linear),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _pulseController.dispose();
    _controller.dispose();
    super.dispose();
  }

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
              Color(0xFF2E3192), // Deep blue
              Color(0xFF1A237E), // Darker blue
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E3192).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: _toggleScanner,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          height: 280.h,
                          width: 280.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF1A237E),
                                Color(0xFF0D47A1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _isScanning
                                ? _buildScannerView()
                                : _buildQRCodeDisplay(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_isScanning)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _toggleScanner,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
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

  Widget _buildScannerView() {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            final barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final code = barcodes.first.rawValue ?? 'Unknown';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Scanned: $code'),
                  backgroundColor: Colors.green,
                ),
              );
              setState(() => _isScanning = false);
            }
          },
        ),
        _buildScannerOverlay(),
      ],
    );
  }

  Widget _buildQRCodeDisplay() {
    return Stack(
      children: [
        // Beautiful QR Code background with animated elements
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1A237E),
                Color(0xFF283593),
                Color(0xFF3949AB),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CustomPaint(
            painter: QRCodePainter(),
            child: Container(),
          ),
        ),
        
        // Animated sparkles
        AnimatedBuilder(
          animation: _sparkleAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: SparklePainter(_sparkleAnimation.value),
              child: Container(),
            );
          },
        ),

        // Corner brackets
        Positioned(
          top: 20,
          left: 20,
          child: _buildCornerBracket(true, true),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: _buildCornerBracket(true, false),
        ),
        Positioned(
          bottom: 60,
          left: 20,
          child: _buildCornerBracket(false, true),
        ),
        Positioned(
          bottom: 60,
          right: 20,
          child: _buildCornerBracket(false, false),
        ),

        // "Tap to scan" text
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                "Tap to scan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCornerBracket(bool isTop, bool isLeft) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            border: Border(
              top: isTop
                  ? BorderSide(
                      color: const Color(0xFF4ECDC4).withOpacity(_pulseAnimation.value),
                      width: 3,
                    )
                  : BorderSide.none,
              left: isLeft
                  ? BorderSide(
                      color: const Color(0xFF4ECDC4).withOpacity(_pulseAnimation.value),
                      width: 3,
                    )
                  : BorderSide.none,
              bottom: !isTop
                  ? BorderSide(
                      color: const Color(0xFF4ECDC4).withOpacity(_pulseAnimation.value),
                      width: 3,
                    )
                  : BorderSide.none,
              right: !isLeft
                  ? BorderSide(
                      color: const Color(0xFF4ECDC4).withOpacity(_pulseAnimation.value),
                      width: 3,
                    )
                  : BorderSide.none,
            ),
            borderRadius: BorderRadius.only(
              topLeft: isTop && isLeft ? const Radius.circular(8) : Radius.zero,
              topRight: isTop && !isLeft ? const Radius.circular(8) : Radius.zero,
              bottomLeft: !isTop && isLeft ? const Radius.circular(8) : Radius.zero,
              bottomRight: !isTop && !isLeft ? const Radius.circular(8) : Radius.zero,
            ),
          ),
        );
      },
    );
  }

  Widget _buildScannerOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.8),
          width: 2,
        ),
      ),
    );
  }
}

// Custom painter for QR code pattern
class QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4ECDC4).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final cellSize = size.width / 15;

    // Draw QR-like pattern
    for (int i = 0; i < 15; i++) {
      for (int j = 0; j < 15; j++) {
        if (_shouldDrawCell(i, j)) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                i * cellSize + cellSize * 0.1,
                j * cellSize + cellSize * 0.1,
                cellSize * 0.8,
                cellSize * 0.8,
              ),
              const Radius.circular(2),
            ),
            paint,
          );
        }
      }
    }

    // Draw large corner squares
    _drawCornerSquare(canvas, 2, 2, cellSize, paint);
    _drawCornerSquare(canvas, 11, 2, cellSize, paint);
    _drawCornerSquare(canvas, 2, 11, cellSize, paint);
  }

  bool _shouldDrawCell(int i, int j) {
    // Create QR-like pattern
    return (i + j) % 3 == 0 || 
           (i * j) % 7 == 0 || 
           ((i - 7) * (i - 7) + (j - 7) * (j - 7)) < 16;
  }

  void _drawCornerSquare(Canvas canvas, int x, int y, double cellSize, Paint paint) {
    // Outer square
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x * cellSize, y * cellSize, cellSize * 3, cellSize * 3),
        const Radius.circular(4),
      ),
      paint,
    );
    
    // Inner square
    final innerPaint = Paint()
      ..color = const Color(0xFF1A237E)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x * cellSize + cellSize * 0.5, 
          y * cellSize + cellSize * 0.5, 
          cellSize * 2, 
          cellSize * 2
        ),
        const Radius.circular(2),
      ),
      innerPaint,
    );

    // Center dot
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x * cellSize + cellSize * 1.25, 
          y * cellSize + cellSize * 1.25, 
          cellSize * 0.5, 
          cellSize * 0.5
        ),
        const Radius.circular(1),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for sparkle effects
class SparklePainter extends CustomPainter {
  final double animationValue;

  SparklePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Draw sparkles at different positions
    final sparkles = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.7, size.height * 0.8),
      Offset(size.width * 0.3, size.height * 0.7),
      Offset(size.width * 0.5, size.height * 0.4),
      Offset(size.width * 0.9, size.height * 0.6),
    ];

    for (int i = 0; i < sparkles.length; i++) {
      final sparkleOffset = (animationValue + i * 0.2) % 1.0;
      final opacity = (1.0 - (sparkleOffset * 2 - 1).abs()).clamp(0.0, 1.0);
      
      paint.color = Colors.white.withOpacity(opacity * 0.8);
      
      _drawSparkle(canvas, sparkles[i], paint, sparkleOffset * 4);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, Paint paint, double size) {
    // Draw four-pointed star
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size * 0.3, center.dy - size * 0.3);
    path.lineTo(center.dx + size, center.dy);
    path.lineTo(center.dx + size * 0.3, center.dy + size * 0.3);
    path.lineTo(center.dx, center.dy + size);
    path.lineTo(center.dx - size * 0.3, center.dy + size * 0.3);
    path.lineTo(center.dx - size, center.dy);
    path.lineTo(center.dx - size * 0.3, center.dy - size * 0.3);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SparklePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}