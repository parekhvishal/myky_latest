import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myky_clone/widget/theme.dart';

class WinnersWidget extends StatefulWidget {
  const WinnersWidget({super.key});

  @override
  State<WinnersWidget> createState() => _WinnersWidgetState();
}

class _WinnersWidgetState extends State<WinnersWidget> {
  final CarouselSliderControllerImpl _carouselController =
      CarouselSliderControllerImpl();
  int _currentIndex = 0;

  final List<Map<String, String>> winners = [
    {
      'flag': 'assets/images/winners/china.png',
      'name': 'Debande Esambi',
      'amount': '100,000',
      'tag': 'Daily Topper',
      'image': 'assets/images/winners/image3.jpg',
    },
    {
      'flag': 'assets/images/winners/india.png',
      'name': 'Muhammd Khalid',
      'amount': '500,000',
      'tag': 'Weekly Topper',
      'image': 'assets/images/winners/image1.jpeg',
    },
    {
      'flag': 'assets/images/winners/india.png',
      'name': 'Ravi Patel',
      'amount': '250,000',
      'tag': 'Monthly Topper',
      'image': 'assets/images/winners/image3.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 235.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Winners',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
          ),
          SizedBox(height: 12.h),
          CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: winners.length,
            itemBuilder: (context, index, realIndex) {
              final winner = winners[index];
              return WinnerCard(
                flagAsset: winner['flag']!,
                name: winner['name']!,
                amount: winner['amount']!,
                tag: winner['tag']!,
                imageAsset: winner['image']!,
              );
            },
            options: CarouselOptions(
              height: 120.h,
              autoPlay: true,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
          SizedBox(height: 8.h),
          Center(
            child: Text(
              winners[_currentIndex]['name']!,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Center(
            child: AnimatedSmoothIndicator(
              count: winners.length,
              activeIndex: _currentIndex,
            ),
          ),
        ],
      ),
    );
  }
}

class WinnerCard extends StatelessWidget {
  final String flagAsset;
  final String name;
  final String amount;
  final String tag;
  final String imageAsset;

  const WinnerCard({
    super.key,
    required this.flagAsset,
    required this.name,
    required this.amount,
    required this.tag,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colorPrimary, colorAccent]),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 12.h,
            left: 12.w,
            child: Row(
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40.h,
            left: 12.w,
            child: Text(
              'PRIZE',
              style: TextStyle(color: Colors.white70, fontSize: 13.sp),
            ),
          ),
          Positioned(
            bottom: 40.h,
            left: 12.w,
            child: Text(
              "Gold Coin",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 30.h,
            right: 25.w,
            child: CircleAvatar(
              radius: 35.r,
              backgroundImage: AssetImage(imageAsset),
            ),
          ),
          Positioned(
            top: 80
                .h, // Adjust this based on your layout, about 70.h (image top) + 70.r (image size) + 5.h (gap)
            right: 23.w, // Align with the image horizontally
            child: Container(
              width: 80.w,
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Center(
                child: Text(
                  tag,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedSmoothIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;

  const AnimatedSmoothIndicator({
    super.key,
    required this.count,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        bool isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          width: isActive ? 18.w : 6.w,
          height: isActive ? 8.w : 6.w,
          decoration: BoxDecoration(
            color: isActive ? colorPrimary : colorPrimary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
}
