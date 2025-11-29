import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unicons/unicons.dart';

class MykyCoinsWidget extends StatefulWidget {
  final String coinBalance;
  final VoidCallback onTap;

  const MykyCoinsWidget({
    Key? key,
    required this.coinBalance,
    required this.onTap,
  }) : super(key: key);

  @override
  State<MykyCoinsWidget> createState() => _MykyCoinsWidgetState();
}

class _MykyCoinsWidgetState extends State<MykyCoinsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start the animation
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Colors.deepPurpleAccent,
              Colors.pinkAccent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.amber.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side - Coin and Balance
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      // Animated coin stack
                      Center(
                        child: Image.asset(
                          'assets/images/myky.png',
                          width: 50.w,
                          height: 50.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(width: 15.w),
                      // Balance and label
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.coinBalance,
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            'Myky Coins',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.9),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Right side - History button
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        UniconsLine.history,
                        size: 18.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'History',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
