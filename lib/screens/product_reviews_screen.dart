import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../widget/theme.dart';

class ProductReviewsScreen extends StatefulWidget {
  const ProductReviewsScreen({Key? key}) : super(key: key);

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;

  // Sample product review data - 12 trending products with user reviews
  final List<Map<String, dynamic>> _productData = [
    {
      'id': '1',
      'productName': 'Wireless Bluetooth Earbuds Pro',
      'productImage':
          'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400',
      'reviewerName': 'Sarah Johnson',
      'reviewerAvatar':
          'https://images.unsplash.com/photo-1494790108755-2616b612b1e7?w=150',
      'rating': 5,
      'reviewText':
          'Amazing sound quality! These earbuds are perfect for workouts and daily commute. Battery life is outstanding - lasts all day without issues.',
      'videoUrl':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'likes': '2.3K',
      'comments': '156',
      'shares': '89',
      'price': '₹2,999',
      'originalPrice': '₹4,999',
    },
    {
      'id': '2',
      'productName': 'Smart Fitness Watch Series 5',
      'productImage':
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
      'reviewerName': 'Mike Chen',
      'reviewerAvatar':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      'rating': 4,
      'reviewText':
          'Great fitness tracking features! Heart rate monitoring is accurate. Only wish the battery lasted longer than 2 days.',
      'videoUrl':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'likes': '1.8K',
      'comments': '234',
      'shares': '67',
      'price': '₹12,999',
      'originalPrice': '₹18,999',
    },
    {
      'id': '3',
      'productName': 'Premium Coffee Maker Machine',
      'productImage':
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
      'reviewerName': 'Emma Wilson',
      'reviewerAvatar':
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
      'rating': 5,
      'reviewText':
          'Best coffee maker I\'ve ever owned! Makes barista-quality coffee at home. Easy to clean and very durable.',
      'videoUrl':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'likes': '3.1K',
      'comments': '89',
      'shares': '145',
      'price': '₹8,499',
      'originalPrice': '₹12,999',
    },
    {
      'id': '4',
      'productName': 'Organic Skincare Set',
      'productImage':
          'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=400',
      'reviewerName': 'Priya Sharma',
      'reviewerAvatar':
          'https://images.unsplash.com/photo-1489424731084-a5d8b219a5bb?w=150',
      'rating': 5,
      'reviewText':
          'My skin has never looked better! All natural ingredients, no harsh chemicals. Highly recommend for sensitive skin.',
      'videoUrl':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'likes': '2.7K',
      'comments': '312',
      'shares': '198',
      'price': '₹1,899',
      'originalPrice': '₹2,999',
    },
    {
      'id': '5',
      'productName': 'Gaming Mechanical Keyboard',
      'productImage':
          'https://images.unsplash.com/photo-1541140532154-b024d705b90a?w=400',
      'reviewerName': 'Alex Rodriguez',
      'reviewerAvatar':
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      'rating': 4,
      'reviewText':
          'Excellent build quality and RGB lighting is stunning. Keys feel premium but can be a bit loud for office use.',
      'videoUrl':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'likes': '1.5K',
      'comments': '78',
      'shares': '34',
      'price': '₹6,999',
      'originalPrice': '₹9,999',
    },
    {
      'id': '6',
      'productName': 'Yoga Mat Premium Quality',
      'productImage':
          'https://images.unsplash.com/photo-1588286840104-8957b019727f?w=400',
      'reviewerName': 'Lisa Thompson',
      'reviewerAvatar':
          'https://images.unsplash.com/photo-1494790108755-2616b612b1e7?w=150',
      'rating': 5,
      'reviewText':
          'Perfect grip and thickness! Non-slip surface works great even during hot yoga sessions. Easy to clean and carry.',
      'videoUrl':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'likes': '4.2K',
      'comments': '456',
      'shares': '289',
      'price': '₹1,299',
      'originalPrice': '₹2,199',
    },
    {
      'id': '7',
      'productName': 'Smartphone Camera Lens Kit',
      'productImage':
          'https://images.unsplash.com/photo-1512499617640-c74ae3a79d37?w=400',
      'reviewerName': 'David Kim',
      'reviewerAvatar':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      'rating': 4,
      'reviewText':
          'Great value for money! Macro and wide-angle lenses work well. Easy to attach and carry around for photography.',
      'videoUrl':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'likes': '3.8K',
      'comments': '201',
      'shares': '167',
      'price': '₹999',
      'originalPrice': '₹1,999',
    },
    {
      'id': '8',
      'productName': 'Air Purifier for Home',
      'productImage':
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
      'reviewerName': 'Jennifer Lee',
      'reviewerAvatar':
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
      'rating': 5,
      'reviewText':
          'Noticeable improvement in air quality! Quiet operation and the app control is very convenient. Worth every penny.',
      'videoUrl':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'likes': '2.9K',
      'comments': '145',
      'shares': '123',
      'price': '₹15,999',
      'originalPrice': '₹22,999',
    },
    {
      'id': '9',
      'productName': 'Wireless Charging Pad',
      'productImage':
          'https://images.unsplash.com/photo-1585792180666-f7347c490ee2?w=400',
      'reviewerName': 'Chris Brown',
      'reviewerAvatar':
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      'rating': 4,
      'reviewText':
          'Fast charging and sleek design. Works with my phone case on. LED indicator is helpful but could be dimmer at night.',
      'videoUrl':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'likes': '5.1K',
      'comments': '678',
      'shares': '345',
      'price': '₹1,499',
      'originalPrice': '₹2,499',
    },
    {
      'id': '10',
      'productName': 'Bluetooth Speaker Waterproof',
      'productImage':
          'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400',
      'reviewerName': 'Maria Garcia',
      'reviewerAvatar':
          'https://images.unsplash.com/photo-1489424731084-a5d8b219a5bb?w=150',
      'rating': 5,
      'reviewText':
          'Incredible sound quality and truly waterproof! Perfect for pool parties and outdoor adventures. Battery lasts 12+ hours.',
      'videoUrl':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'likes': '6.2K',
      'comments': '892',
      'shares': '456',
      'price': '₹3,999',
      'originalPrice': '₹6,999',
    },
    {
      'id': '11',
      'productName': 'LED Desk Lamp with USB Port',
      'productImage':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      'reviewerName': 'Robert Taylor',
      'reviewerAvatar':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      'rating': 4,
      'reviewText':
          'Great for late-night work sessions. Adjustable brightness levels and USB port is very convenient. Sturdy build quality.',
      'videoUrl':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'likes': '3.4K',
      'comments': '234',
      'shares': '178',
      'price': '₹2,299',
      'originalPrice': '₹3,499',
    },
    {
      'id': '12',
      'productName': 'Ergonomic Office Chair',
      'productImage':
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400',
      'reviewerName': 'Amanda White',
      'reviewerAvatar':
          'https://images.unsplash.com/photo-1494790108755-2616b612b1e7?w=150',
      'rating': 5,
      'reviewText':
          'Best investment for my home office! Excellent lumbar support and very comfortable for long hours. Easy assembly.',
      'videoUrl':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'likes': '2.1K',
      'comments': '167',
      'shares': '89',
      'price': '₹18,999',
      'originalPrice': '₹25,999',
    },
  ];

  List<VideoPlayerController> _controllers = [];
  List<bool> _initialized = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeVideos();

    // Set status bar to transparent for immersive experience
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _initializeVideos() async {
    _controllers = [];
    _initialized = List.filled(_productData.length, false);

    // Initialize first 3 product review videos for better performance
    for (int i = 0; i < _productData.length; i++) {
      try {
        // Use the product's demo video URL
        final controller = VideoPlayerController.network(
          _productData[i]['videoUrl'],
        );

        _controllers.add(controller);

        if (i < 3) {
          await controller.initialize();
          _initialized[i] = true;

          if (i == 0) {
            controller.play();
            controller.setLooping(true);
          }
        }
      } catch (e) {
        print('Error initializing product review video $i: $e');
        // Add a dummy controller for failed videos
        _controllers.add(VideoPlayerController.network(''));
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeVideoAt(int index) async {
    if (index < _controllers.length && !_initialized[index]) {
      try {
        await _controllers[index].initialize();
        if (mounted) {
          setState(() {
            _initialized[index] = true;
          });
        }
      } catch (e) {
        print('Error initializing video at index $index: $e');
      }
    }
  }

  void _onPageChanged(int index) {
    if (_currentIndex < _controllers.length && _initialized[_currentIndex]) {
      _controllers[_currentIndex].pause();
    }

    _currentIndex = index;

    if (index < _controllers.length) {
      if (_initialized[index]) {
        _controllers[index].play();
        _controllers[index].setLooping(true);
      } else {
        _initializeVideoAt(index).then((_) {
          if (_initialized[index]) {
            _controllers[index].play();
            _controllers[index].setLooping(true);
          }
        });
      }

      // Preload next videos
      for (int i = index + 1; i <= index + 2 && i < _controllers.length; i++) {
        if (!_initialized[i]) {
          _initializeVideoAt(i);
        }
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? _buildLoadingScreen()
          : Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  onPageChanged: _onPageChanged,
                  itemCount: _productData.length,
                  itemBuilder: (context, index) {
                    return _buildProductReviewItem(index);
                  },
                ),
                _buildTopBar(),
              ],
            ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorPrimary),
              strokeWidth: 3,
            ),
            SizedBox(height: 20.h),
            Text(
              'Loading Product Reviews...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontFamily: fontMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: Container(
        height: 60.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
            Spacer(),
            Text(
              'Product Reviews',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontFamily: fontSemibold,
                fontWeight: FontWeight.w600,
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductReviewItem(int index) {
    final productInfo = _productData[index];
    final isInitialized = index < _initialized.length && _initialized[index];

    return Column(
      children: [
        // Video Section - 80% of screen
        Expanded(
          flex: 80,
          child: Container(
            width: double.infinity,
            color: Colors.black,
            child: isInitialized
                ? GestureDetector(
                    onTap: () {
                      if (_controllers[index].value.isPlaying) {
                        _controllers[index].pause();
                      } else {
                        _controllers[index].play();
                      }
                    },
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _controllers[index].value.aspectRatio,
                        child: VideoPlayer(_controllers[index]),
                      ),
                    ),
                  )
                : _buildVideoPlaceholder(),
          ),
        ),

        // Product Info Card Section - 20% of screen
        Expanded(
          flex: 20,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: _buildCompactProductInfoCard(productInfo),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorPrimary),
              strokeWidth: 2,
            ),
            SizedBox(height: 16.h),
            Text(
              'Loading video...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactProductInfoCard(Map<String, dynamic> productInfo) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name and Rating Row
          Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  productInfo['productImage'] ?? '',
                  width: 50.w,
                  height: 50.w,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50.w,
                      height: 50.w,
                      color: Colors.grey[300],
                      child: Icon(Icons.shopping_bag,
                          color: Colors.grey[600], size: 20.sp),
                    );
                  },
                ),
              ),
              SizedBox(width: 12.w),
              // Product Name and Rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productInfo['productName'] ?? 'Product Name',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontFamily: fontSemibold,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    // Star Rating and Price
                    Row(
                      children: [
                        ...List.generate(5, (starIndex) {
                          return Icon(
                            starIndex < (productInfo['rating'] ?? 0)
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.orange,
                            size: 14.sp,
                          );
                        }),
                        SizedBox(width: 8.w),
                        Text(
                          '${productInfo['rating'] ?? 0}.0',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12.sp,
                            fontFamily: fontMedium,
                          ),
                        ),
                        Spacer(),
                        Text(
                          productInfo['price'] ?? '₹0',
                          style: TextStyle(
                            color: colorPrimary,
                            fontSize: 16.sp,
                            fontFamily: fontBold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Reviewer Info and Review Text
          Row(
            children: [
              CircleAvatar(
                radius: 12.r,
                backgroundImage: NetworkImage(
                  productInfo['reviewerAvatar'] ?? '',
                ),
                backgroundColor: Colors.grey[300],
              ),
              SizedBox(width: 8.w),
              Text(
                productInfo['reviewerName'] ?? 'Anonymous',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.sp,
                  fontFamily: fontSemibold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Verified',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 10.sp,
                    fontFamily: fontMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Review Text
          Text(
            productInfo['reviewText'] ?? 'No review available',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14.sp,
              fontFamily: fontRegular,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
