// main_front_dashboard.dart
import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
// New package for confetti
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:myky_clone/banner_ad_widget.dart';
import 'package:myky_clone/mlm/account/ProfileScreen.dart';
import 'package:myky_clone/services/auth.dart';
import 'package:myky_clone/spin-wheel/spin_result_screen.dart';
import 'package:myky_clone/utils/en_extensions.dart';
import 'package:myky_clone/widget/cash_giveaway.dart';
import 'package:myky_clone/widget/custom_text.dart';
import 'package:myky_clone/widget/qr_scanner.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'mlm/wallet/wallet.dart';
import 'services/api.dart';
import 'shopping/recharge/recharge_page.dart';
import 'shopping/reward/reward.dart';
import 'widget/theme.dart';

class MainFrontDashboard extends StatefulWidget {
  @override
  _MainFrontDashboardState createState() => _MainFrontDashboardState();
}

class _MainFrontDashboardState extends State<MainFrontDashboard> {
  int _selectedIndex = 0;
  late Future<Map> _future;
  Map dashboardData = {};
  List spinList = [], pendingRewards = [];
  List? sliderImages = [];
  List? youtubeVideos = [];
  bool _isHomeDataLoaded = false;
  bool _hasShownRewardDialog = false; // Prevents showing multiple times
  bool fromSpin = false;
  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null) {
      if (args is Map) {
        _selectedIndex = args["tab"] ?? 0;
        fromSpin = args["fromSpin"] ?? false;
      } else if (args is int) {
        _selectedIndex = args;
      }
    }
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // white icons
        statusBarBrightness: Brightness.dark,
      ),
    );
    _future = getMainDashboard();
    getSpinList();
  }

  Future<Map> getMainDashboard() async {
    try {
      final response = await Api.http.get("shopping/main-dashboard");
      setState(() {
        dashboardData = response.data ?? {};
        sliderImages = response.data['list']['bannerMedia'] ?? [];
        youtubeVideos = response.data['list']['youtubeVideo'] ?? [];
        _isHomeDataLoaded = true;
      });
      print('Main Dashboard API Response: ${response.data}');
      return response.data ?? {};
    } catch (error) {
      print('Error fetching main dashboard: $error');
      setState(() => _isHomeDataLoaded = true);
      return {};
    }
  }

  Future<void> getSpinList() async {
    print('called rewards');
    try {
      final response = await Api.http.get('shopping/spin-list');

      final newSpinList = response.data['list'] ?? [];
      final newPendingRewards = newSpinList.where((item) {
        return item['is_redeemed'] == 0;
      }).toList();

      setState(() {
        spinList = newSpinList;
        pendingRewards = newPendingRewards;
      });

      print("Pending Rewards = ${pendingRewards.length}");

      // Show dialog only if: on Home tab + has 5+ pending + not shown before
      if (_selectedIndex == 0 &&
          pendingRewards.length >= 5 &&
          !_hasShownRewardDialog &&
          mounted) {
        _hasShownRewardDialog = true;
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) _showPendingRewardsBottomSheet();
        });
      }
    } catch (e) {
      print("error = $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return scaffoldBackgroundImage(
      // customBgImage: bg,
      fit: BoxFit.cover,
      child: WillPopScope(
        onWillPop: () => _onWillPop(),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: _buildTabContent(),
          bottomNavigationBar: SafeArea(
            top: false,
            child: _buildBottomNavigationBar(),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() {
    if (_selectedIndex == 0) {
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.all(25),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Material(
            child: Container(
              decoration: new BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0.0, 10.0),
                  ),
                ],
              ),
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min, // To make the card compact
                children: <Widget>[
                  const SizedBox(height: 24),
                  text(
                    'Are you sure?\n Do you want to exit an App',
                    textColor: textColorPrimary,
                    fontFamily: fontBold,
                    fontSize: textSizeLargeMedium,
                    isCentered: true,
                    isLongText: true,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: text(
                          'No',
                          fontSize: textSizeLargeMedium,
                          fontFamily: fontBold,
                          textColor: green,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          SystemNavigator.pop();
                        },
                        child: text(
                          'Yes',
                          fontSize: textSizeLargeMedium,
                          fontFamily: fontBold,
                          textColor: red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      setState(() {
        _selectedIndex = 0;
      });
    }

    return Future.value(false);
  }

  // -------------------------
  // UPDATED: showModalBottomSheet that now opens the new PendingRewardsBottomSheet
  // -------------------------
  void _showPendingRewardsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent, // important
      enableDrag: true,
      builder: (context) => PendingRewardsBottomSheet(
        pendingRewards: pendingRewards,
        onRedeem: () {
          Navigator.pop(context);
          Get.to(() => const Reward());
        },
      ),
    );
  }

  // MARK: - Tab Content Switcher
  Widget _buildTabContent() {
    if (_selectedIndex == 0 && !_isHomeDataLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();

      case 1:
        return const Recharge();

      case 2:
        return Wallet();

      case 3:
        return ProfileScreen();

      case 5:
        final screen = SpinResultScreen(fromSpin: fromSpin);
        fromSpin = false; // ← VERY IMPORTANT (one-time use)
        return screen;

      default:
        return const SizedBox();
    }
  }

  // MARK: - Tab 0: Home
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildImageSliderWithMykySymbol(),
          // 16.heightBox,
          // Container(padding: EdgeInsets.all(10), color:Colors.red,child: Text('Logout'),).onTap((){
          //   logoutUser();
          // }),
          16.heightBox,
          _buildScannerSection(),
          _buildHowToPaySection(),
          // _buildYoutubeSection(),
          // const SizedBox(height: 16.0),
          _buildFeatureCards(),
          _buildWinnersSection(),
          //
          _buildOnlineProducts(),
          BannerAdWidget(
            adUnitId: 'ca-app-pub-7980318439455341/2126062629',
            adSize: AdSize.largeBanner,
            margin: EdgeInsets.symmetric(horizontal: 0.w, vertical: 12.h),
            showDebugInfo: true,
            useTestAds: true,
          ),
          peopleLove(),
          socialMediaContainers(
            heading: "Connect With Us",
            items: const [
              SocialItem(
                label: "YouTube",
                svgAssetPath: "assets/images/svg/youtube.svg",
                link: "https://www.youtube.com/",
              ),
              SocialItem(
                label: "Facebook",
                svgAssetPath: "assets/images/svg/facebook.svg",
                link: "https://www.facebook.com/",
              ),
              SocialItem(
                label: "Instagram",
                svgAssetPath: "assets/images/svg/instagram.svg",
                link: "https://www.instagram.com/",
              ),
            ],
          ),
          const FreeCashGiveaway(),
        ],
      ),
    );
  }

  void logoutUser() async {
    await Auth.logout();

    Get.offAllNamed('/login-mlm');
  }

  // MARK: - Tab 1: Recharge
  Widget _buildRechargeTab() {
    return const Recharge();
  }

  // MARK: - Tab 2: Wallet (Replace with your real wallet screen)
  Widget _buildWalletTab() {
    return Wallet();
  }

  // MARK: - Tab 4: Profile (Replace with your real profile screen)
  Widget _buildProfileTab() {
    return ProfileScreen(); // or your profile widget
  }

  Widget _buildRewardTab() {
    return const Reward(); // Replace with your actual Reward screen
  }

  // MARK: - Modern Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          /// ✅ LEFT: Blue pill with 4 icons
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF00089E),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIconItem(0, UniconsLine.home),
                  _buildIconItem(2, UniconsLine.wallet),
                  _buildIconItem(3, UniconsLine.user),
                  _buildIconItem(5, UniconsLine.gift),
                ],
              ),
            ),
          ),

          // const SizedBox(width: 10),

          /// ✅ RIGHT: Green shop tab (separate container)
          GestureDetector(
            onTap: () => _onTabTapped(4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 50,
              width: 95,
              decoration: BoxDecoration(
                color: _selectedIndex == 4
                    ? Colors.black
                    : const Color(0xFF2EE6C5),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    UniconsLine.store,
                    color: _selectedIndex == 4 ? Colors.white : Colors.black,
                    size: 22,
                  ),
                  const SizedBox(width: 4),
                  CustomText(
                    'Shop',
                    textColor: _selectedIndex == 4
                        ? Colors.white
                        : Colors.black,
                    fontFamily: fontPoppinsMedium,
                    fontSize: 16.sp,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconItem(int index, IconData icon) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(8),
        // decoration: BoxDecoration(
        //   color: isSelected ? Colors.white : Colors.transparent,
        //   borderRadius: BorderRadius.circular(8),
        // ),
        child: Icon(
          icon,
          size: 24,
          color: isSelected ? const Color(0xFF2EE6C5) : Colors.white,
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    if (index == 4) {
      Get.toNamed('/ecommerce');
      return;
    }

    if (index == 0 && _selectedIndex == 5) {
      getSpinList(); // Refresh when returning
      _hasShownRewardDialog = false; // Allow dialog again if new rewards
    }

    if (index == 5) {
      getSpinList();
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  // MARK: - Rest of your existing methods (unchanged)
  Widget socialMediaContainers({
    required String heading,
    required List<SocialItem> items,
  }) {
    Future<void> _launchURL(String url) async {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    }

    return Column(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading.toUpperCase(),
          style: TextStyle(
            fontFamily: fontPoppinsMedium,
            fontSize: 20.sp,
            color: const Color(0xFF000115),
          ),
        ),

        SizedBox(height: 18),

        /// ✅ Dynamic row for SVG icons
        Container(
          margin: EdgeInsets.only(bottom: 20),
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.map((item) {
              return GestureDetector(
                onTap: () => _launchURL(item.link),
                child: Column(
                  children: [
                    Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF2F4FF),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          item.svgAssetPath,
                          width: 22.w,
                          height: 16.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14.sp,

                        fontFamily: fontPoppinsMedium,
                        color: const Color(0xFF000115),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget reelVideoContainer({
    required String thumbnailUrl,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 280,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
          image: DecorationImage(
            image: NetworkImage(thumbnailUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
            ),
            Positioned(
              left: 10,
              bottom: 10,
              right: 10,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      offset: Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
            const Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.white70,
                size: 60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMykySymbol() {
    final user = Auth.user();
    final profileImage = user?['profileImage'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// LEFT: Logo
        Image.asset("assets/images/logo copy.png", height: 28),

        /// RIGHT: Notification + Profile
        Row(
          children: [
            /// Notification Icon
            GestureDetector(
              onTap: () {
                Get.toNamed('/notifications'); // change route if needed
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),

            const SizedBox(width: 10),

            /// Profile Image
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 3; // Profile tab
                });
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                backgroundImage: profileImage != null
                    ? NetworkImage(profileImage)
                    : const AssetImage("assets/images/no_image.png")
                          as ImageProvider,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageSliderWithMykySymbol() {
    // જો sliderImages ખાલી હોય તો placeholder બતાવો
    if (sliderImages == null || sliderImages!.isEmpty) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        color: Colors.grey[300],
        child: const Center(
          child: Text(
            'No banners available',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: Stack(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height * 0.8,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4), // થોડું વધુ સમય આપો
              autoPlayCurve: Curves.easeInOut,
            ),
            items: sliderImages!.map((banner) {
              // banner એ Map છે → 'image' key થી URL લો
              final String imageUrl = banner['image']?.toString() ?? '';

              return Builder(
                builder: (context) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Network Image with good error & loading handling
                      Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: Icon(
                                Icons.broken_image_rounded,
                                size: 60,
                                color: Colors.white70,
                              ),
                            ),
                          );
                        },
                      ),

                      // Gradient overlay
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(
                                  0.35,
                                ), // subtle dark for readability
                                Colors.black.withOpacity(0.15),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }).toList(),
          ),

          // Myky symbol & profile
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 20,
            right: 20,
            child: _buildMykySymbol(),
          ),
        ],
      ),
    );
  }

  String extractYouTubeVideoId(String embedUrl) {
    RegExp regExp = RegExp(
      r'youtube\.com\/embed\/([a-zA-Z0-9_-]+)',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(embedUrl);
    return match?.group(1) ?? 'dQw4w9WgXcQ';
  }

  Future<void> _openYouTubeVideo(String videoId) async {
    final youtubeAppUrl = Uri.parse(
      'youtube://www.youtube.com/watch?v=$videoId',
    );
    final youtubeWebUrl = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    try {
      if (await canLaunchUrl(youtubeAppUrl)) {
        await launchUrl(youtubeAppUrl);
      } else {
        await launchUrl(youtubeWebUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open video.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openQRScanner() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
      );
      if (barcodeScanRes != '-1') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scanned: $barcodeScanRes'),
            backgroundColor: Colors.green,
          ),
        );
        _processScanResult(barcodeScanRes);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scan failed.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _processScanResult(String scanResult) {
    print('Scanned: $scanResult');
    if (scanResult.startsWith('http')) {
      _openUrl(scanResult);
    } else if (scanResult.contains('upi://')) {
      _processPaymentQR(scanResult);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri))
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _processPaymentQR(String upiString) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Payment QR detected'),
        backgroundColor: colorPrimary,
      ),
    );
  }

  Widget _buildScannerSection() => QrScannerBox();
  Widget _buildHowToPaySection() {
    final List<String> images = [
      "assets/images/img1.jpg",
      "assets/images/img2.jpg",
      "assets/images/img2.jpg",
    ];
    return Column(
      children: [
        Text(
          "HOW TO PAY",
          style: TextStyle(
            fontSize: 20,

            color: Colors.black,
            fontFamily: fontPoppinsMedium,
          ),
        ),
        SizedBox(height: 10),
        CarouselSlider(
          items: images.map((path) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                path,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            );
          }).toList(),
          options: CarouselOptions(
            height: 220,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.88,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeFactor: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCards() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Services'.toUpperCase(),
            style: TextStyle(
              color: Color(0XFF000115),
              fontSize: 20.sp,
              fontFamily: fontPoppinsMedium,
            ),
          ),
          //  SizedBox(height: 16.h),

          /// ✅ OFFER GRID UI (like your OfferGrid code)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Left side - Flex 3
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildOfferTile(
                        height: 170.h,

                        imagePath: "assets/images/grid/offlineStore1.png",
                        fit: BoxFit.cover,
                        onTap: () => Get.toNamed('/nearby-offline-store'),
                      ),
                      SizedBox(height: 10.h),
                      _buildOfferTile(
                        height: 70.h,

                        imagePath: "assets/images/grid/map2.png",
                        fit: BoxFit.cover,
                        onTap: () => Get.toNamed('/near-me-store'),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 12.w),

                /// Right side - Flex 2
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildOfferTile(
                        height: 120.h,

                        imagePath: "assets/images/grid/coins2.png",
                        fit: BoxFit.cover,
                        onTap: () => Get.toNamed('/coin-wallet'),
                      ),
                      SizedBox(height: 10.h),
                      _buildOfferTile(
                        height: 120.h,

                        imagePath: "assets/images/grid/recharge2.png",
                        fit: BoxFit.cover,
                        onTap: () {
                          setState(() {
                            _selectedIndex = 1;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferTile({
    required double height,
    required String imagePath,
    required BoxFit fit,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(102, 0, 0, 0),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Image.asset(
            imagePath,
            width: double.infinity,
            height: double.infinity,
            fit: fit,
          ),
        ),
      ),
    );
  }

  Widget _buildWinnersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Winners".toUpperCase(),
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF000115),
              fontFamily: fontPoppinsMedium,
            ),
          ),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Image.asset("assets/images/winners3.jpg"),
          ),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Image.asset("assets/images/winners2.jpg"),
          ),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Image.asset("assets/images/winners1.jpg"),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineProducts() {
    return Column(
      children: [
        Text(
          "Online Products".toUpperCase(),
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF000115),
            fontFamily: fontPoppinsMedium,
          ),
        ),
        SizedBox(height: 10),
        Image.asset("assets/images/luxury.png", fit: BoxFit.cover),
      ],
    );
  }

  Widget peopleLove() {
    final List<Map<String, String>> people = const [
      {"image": "assets/images/grid/p1.jpg", "name": "Maneesh Apte"},
      {"image": "assets/images/grid/p2.jpg", "name": "Samantha Lee"},
      {"image": "assets/images/grid/p3.jpg", "name": "Rohit Verma"},
      {"image": "assets/images/grid/p2.jpg", "name": "Andrea Collins"},
      {"image": "assets/images/grid/p1.jpg", "name": "Daniel Cruz"},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ------------------ TITLE ------------------
          const Text(
            "WHY PEOPLE LOVE MYKY",
            style: TextStyle(
              fontSize: 20,
              fontFamily: fontPoppinsMedium,
              color: Color(0xFF000115),
            ),
          ),

          const SizedBox(height: 14),

          // ------------------ HORIZONTAL SCROLL CAROUSEL ------------------
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: people.length, // add more cards if needed
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final person = people[index];
                return _LoveCard(
                  image: person["image"]!,
                  name: person["name"]!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYoutubeSection() {
    List<Map<String, String>> videoData =
        youtubeVideos != null && youtubeVideos!.isNotEmpty
        ? youtubeVideos!.map((video) {
            String videoId = extractYouTubeVideoId(
              (video['link'] ?? '').toString(),
            );
            return {
              'thumbnail': 'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
              'title': 'How to Play - Tutorial ${video['id']}',
              'videoId': videoId,
            };
          }).toList()
        : [
            {
              'thumbnail':
                  'https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
              'title': 'How to Play - Tutorial 1',
              'videoId': 'dQw4w9WgXcQ',
            },
            {
              'thumbnail':
                  'https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
              'title': 'How to Play - Tutorial 2',
              'videoId': 'dQw4w9WgXcQ',
            },
            {
              'thumbnail':
                  'https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
              'title': 'How to Play - Tutorial 3',
              'videoId': 'dQw4w9WgXcQ',
            },
          ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Watch How to Play!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 180,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: videoData.map((video) {
                  return Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 15),
                    child: GestureDetector(
                      onTap: () => _openYouTubeVideo(video['videoId']!),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Image.network(
                                  video['thumbnail']!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey[300],
                                    child: Center(
                                      child: Icon(
                                        Icons.video_library,
                                        size: 40,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  color: Colors.black.withOpacity(0.3),
                                ),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final String id;
  final int rank;
  final int reversedIndex;
  final List<Color> gradient;
  final VoidCallback onTapTop;

  const _RewardCard({
    Key? key,
    required this.id,
    required this.rank,
    required this.reversedIndex,
    required this.gradient,
    required this.onTapTop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTop = reversedIndex == 0;

    return GestureDetector(
      onTap: isTop ? onTapTop : null,
      child: Container(
        width: 320,
        height: 250,
        child: Stack(
          children: [
            // Premium Glassmorphic Card
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
              ),
            ),

            // Subtle inner glow border (only for top card)
            if (isTop)
              Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),

            // Glass overlay effect
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                backgroundBlendMode: BlendMode.overlay,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.transparent,
                    Colors.black.withOpacity(0.15),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),

            // Content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Reward #",
                          style: TextStyle(
                            fontSize: rank == 1 ? 28 : 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.1,
                          ),
                        ),
                        TextSpan(
                          text: id,
                          style: TextStyle(
                            fontSize: rank == 1 ? 42 : 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: rank == 1 ? 2 : 1,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.6),
                                offset: const Offset(0, 2),
                                blurRadius: 8,
                              ),
                              Shadow(
                                color: Colors.white.withOpacity(0.6),
                                offset: const Offset(0, 0),
                                blurRadius: rank == 1 ? 16 : 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Winner crown for 1st place
                  if (rank == 1)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text("👑", style: TextStyle(fontSize: 32)),
                    ),
                ],
              ),
            ),

            // Subtle particle shine effect on top card
          ],
        ),
      ),
    );
  }
}

// PendingRewardsBottomSheet (Stateful for animation & particle controllers)
class PendingRewardsBottomSheet extends StatefulWidget {
  final List pendingRewards;
  final VoidCallback onRedeem;

  const PendingRewardsBottomSheet({
    Key? key,
    required this.pendingRewards,
    required this.onRedeem,
  }) : super(key: key);

  @override
  State<PendingRewardsBottomSheet> createState() =>
      _PendingRewardsBottomSheetState();
}

class _PendingRewardsBottomSheetState extends State<PendingRewardsBottomSheet>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rewardNumber = widget.pendingRewards.isNotEmpty
        ? widget.pendingRewards.first['id']
        : 0;

    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // ===== BLUR BACKGROUND =====
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),
          ),
        ),

        // ===== BOTTOM POPUP =====
        Align(
          alignment: Alignment.bottomCenter,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutBack, // spring effect
            tween: Tween(begin: 1.0, end: 0.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, value * 220),
                child: child,
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ================= MAIN CONTAINER =================
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 40,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const Text(
                          "PENDING REWARDS",
                          style: TextStyle(
                            fontSize: 22,
                            fontFamily: fontLexendMedium,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ===== STACKED REWARD (FIXED) =====
                        // ===== PRODUCTION STACKED REWARDS =====
                        SizedBox(
                          height: 300,
                          width: double.infinity,
                          child: buildRewardStack(widget.pendingRewards),
                        ),

                        const SizedBox(height: 22),

                        // ===== BUTTON WITH PULSE =====
                        _PulsingRedeemButton(onTap: widget.onRedeem),
                      ],
                    ),
                  ),

                  // ===== CLOSE BUTTON =====
                  Positioned(
                    right: 0,
                    left: 0,
                    top: -70, // negative to move outside
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent.withOpacity(0.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
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
    );
  }

  // ========================
  // TOP-LEVEL FUNCTION
  // ========================
  Widget buildRewardStack(List rewards) {
    final topFive = (rewards ?? []).take(5).toList();

    final List<List<Color>> gradients = [
      [Color(0xFFFFD9D9), Color(0xFFFFB3B3)], // pink
      [Color(0xFFD9F4EA), Color(0xFFB2EBD9)], // green
      [Color(0xFFFFF3CC), Color(0xFFFFE699)], // yellow
      [Color(0xFFE3D9FF), Color(0xFFCBB8FF)], // purple
      [Color(0xFF00089E), Color(0xFF00089E)], // blue (top)
    ];

    return SizedBox(
      width: double.infinity,
      height: 250,
      child: Center(
        child: SizedBox(
          width: 300,
          height: 250,
          child: Stack(
            clipBehavior: Clip.none,
            children: List.generate(topFive.length, (index) {
              final reward = topFive[index];
              final id = reward['id'];
              final rank = index + 1;

              // Reverse order → last reward on top
              final reversedIndex = topFive.length - 1 - index;

              // IMPORTANT: negative offset (moves stack upward)
              final double offsetY = reversedIndex * 18.0;

              // Slight scale for depth
              final double scale = 1.0 - (reversedIndex * 0.05);
              final double opacity = 1.0 - (reversedIndex * 0.12);

              return Positioned(
                top: -offsetY, // ← THIS creates the top-visible stack
                left: 0,
                right: 0,
                child: TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400 + index * 120),
                  curve: Curves.easeOut,
                  tween: Tween(begin: 0.9, end: scale),
                  builder: (context, animValue, child) {
                    return Transform.scale(
                      scale: animValue,
                      child: Opacity(
                        opacity: opacity.clamp(0.6, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: _RewardCard(
                    id: id.toString(),
                    rank: rank,
                    reversedIndex: reversedIndex,
                    gradient: gradients[index % gradients.length],
                    onTapTop: () {
                      Confetti.launch(
                        context,
                        options: const ConfettiOptions(
                          particleCount: 60,
                          spread: 70,
                          y: 0.6,
                        ),
                      );

                      Future.delayed(const Duration(milliseconds: 300), () {
                        Navigator.pop(context);
                      });
                    },
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _PulsingRedeemButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PulsingRedeemButton({required this.onTap});

  @override
  State<_PulsingRedeemButton> createState() => _PulsingRedeemButtonState();
}

class _PulsingRedeemButtonState extends State<_PulsingRedeemButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1 + (_controller.value * 0.04);

        return Transform.scale(
          scale: scale,
          child: SizedBox(
            height: 50,
            width: 300,
            child: ElevatedButton.icon(
              onPressed: widget.onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4C8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(42),
                ),
                elevation: 8,
              ),
              icon: const Icon(
                Icons.card_giftcard,
                color: Color(0xFF000115),
                size: 25,
              ),
              label: const Text(
                "REDEEM NOW",
                style: TextStyle(
                  fontFamily: fontLexendMedium,
                  fontSize: 16,
                  color: Color(0xFF000115),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Simple Floating Particles implementation
class FloatingParticles extends StatefulWidget {
  const FloatingParticles({Key? key}) : super(key: key);

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final Random _rand = Random();
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(28, (i) {
      return _Particle(
        dx: _rand.nextDouble(),
        dy: _rand.nextDouble(),
        size: 2.0 + _rand.nextDouble() * 5,
        speed: 0.2 + _rand.nextDouble() * 0.8,
        sway: 8 + _rand.nextDouble() * 16,
        opacity: 0.15 + _rand.nextDouble() * 0.35,
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(_particles, _controller.value),
          child: Container(),
        );
      },
    );
  }
}

class _Particle {
  double dx; // 0..1 relative
  double dy; // 0..1 relative
  double size;
  double speed;
  double sway;
  double opacity;

  _Particle({
    required this.dx,
    required this.dy,
    required this.size,
    required this.speed,
    required this.sway,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;

  _ParticlePainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint();
    for (var i = 0; i < particles.length; i++) {
      final particle = particles[i];
      final double x =
          (particle.dx * size.width) + sin((t * 2 * pi) + i) * particle.sway;
      final double y =
          ((particle.dy + (t * particle.speed)) % 1.0) * size.height;
      p.color = Colors.pinkAccent.withOpacity(particle.opacity);
      canvas.drawCircle(Offset(x, y), particle.size, p);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}

// Card shine overlay
class _CardShineOverlayCompact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 5),
      tween: Tween(begin: -1.2, end: 1.4),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Soft moving highlight
              Transform.translate(
                offset: Offset(value * 380, value * 60 - 80),
                child: Transform.rotate(
                  angle: -0.25,
                  child: Container(
                    width: 120,
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.35),
                          Colors.white.withOpacity(0.0),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      onEnd: () {
        Future.microtask(() {
          if (WidgetsBinding.instance != null) {}
        });
      },
    );
  }
}

class _LoveCard extends StatelessWidget {
  final String image;
  final String name;

  const _LoveCard({required this.image, required this.name});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 115,
      height: 150,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(child: Image.asset(image, fit: BoxFit.cover)),

            // bottom overlay bar
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.65),
                    ],
                  ),
                ),
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SocialItem {
  final String label;
  final String svgAssetPath;
  final String link;

  const SocialItem({
    required this.label,
    required this.svgAssetPath,
    required this.link,
  });
}
