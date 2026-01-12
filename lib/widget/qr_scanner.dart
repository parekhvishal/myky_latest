import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:myky_clone/widget/theme.dart';

class QrScannerBox extends StatefulWidget {
  const QrScannerBox({super.key});

  @override
  State<QrScannerBox> createState() => _QrScannerBoxState();
}

class _QrScannerBoxState extends State<QrScannerBox> {
  bool _isScanning = false;
  final MobileScannerController _controller = MobileScannerController();

  void _toggleScanner() {
    setState(() => _isScanning = !_isScanning);
  }

  void _onDetect(BarcodeCapture capture) {
    final barcodes = capture.barcodes;

    if (barcodes.isNotEmpty) {
      final code = barcodes.first.rawValue ?? "Unknown";

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Scanned: $code")));

      setState(() => _isScanning = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget qrScanner() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20),
      child: Container(
        width: 350,
        height: 330,
        padding: EdgeInsets.only(
          top: 30.r,
          right: 20.r,
          //bottom: 15.r,
          left: 20.r,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEAF9FF), Color(0xFFCFF2F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ✅ Scanner Area
            GestureDetector(
              onTap: _toggleScanner,
              child: Stack(
                children: [
                  Container(
                    height: 210.h,
                    width: 210.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: _isScanning
                          ? MobileScanner(
                              controller: _controller,
                              onDetect: _onDetect,
                            )
                          : Image.asset(
                              "assets/images/qrcode.gif",
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),

                  /// ✅ Close Button when scanning
                  if (_isScanning)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _toggleScanner,
                        child: Container(
                          padding: EdgeInsets.all(5.r),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 18.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            /// ✅ Cashback Text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("⚡", style: TextStyle(fontSize: 14.sp)),
                SizedBox(width: 6.w),
                Text(
                  "Get cashback on scan & pay",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.sp,
                    fontFamily: fontPoppinsMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return qrScanner();
  }
}
