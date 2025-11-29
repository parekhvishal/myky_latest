import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myky_clone/utils/en_extensions.dart';
import 'package:myky_clone/widget/network_image.dart';

class HomeSlider extends StatefulWidget {
  final List<dynamic>? bannerMedia; // Updated to accept your data structure

  const HomeSlider(
      {super.key, required this.bannerMedia}); // Require bannerMedia

  @override
  _HomeSliderState createState() => _HomeSliderState();
}

class _HomeSliderState extends State<HomeSlider> {
  int _currentIndex = 0; // Track active slide

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200.h,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        children: [
          widget.bannerMedia!.isEmpty // Use widget.bannerMedia
              ? SizedBox(
                  height: 160.h,
                  child: const Center(child: CircularProgressIndicator()),
                )
              : CarouselSlider(
                  options: CarouselOptions(
                    height: 160.h,
                    aspectRatio: 2.5,
                    viewportFraction: 0.95,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeFactor: 0.3,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index; // Update current index
                      });
                    },
                  ),
                  items: List.generate(
                    widget.bannerMedia!.length, // Use widget.bannerMedia
                    (index) {
                      return Builder(
                        builder: (BuildContext context) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: PNetworkImage(
                              widget.bannerMedia![index]['image'] ??
                                  '', // Use 'image' key
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
          10.heightBox,
        ],
      ),
    );
  }
}
