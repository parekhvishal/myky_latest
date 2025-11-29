// main_front_dashboard.dart
import 'dart:async';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:myky_clone/banner_ad_widget.dart';
import 'package:myky_clone/mlm/account/ProfileScreen.dart';
import 'package:myky_clone/services/auth.dart';
import 'package:myky_clone/slider.dart';
import 'package:myky_clone/utils/en_extensions.dart';
import 'package:myky_clone/widget/cash_giveaway.dart';
import 'package:myky_clone/widget/custom_text.dart';
import 'package:myky_clone/widget/qr_scanner.dart';
import 'package:unicons/unicons.dart';import 'package:url_launcher/url_launcher.dart';

// New package for confetti
import 'package:flutter_confetti/flutter_confetti.dart';

import 'mlm/wallet/wallet.dart';
import 'services/api.dart';
import 'shopping/recharge/recharge_page.dart';
import 'shopping/reward/reward.dart';
import 'widget/theme.dart';
import 'widget/winner_widget.dart';

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

  @override
  void initState() {
    super.initState();
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
          body: Column(
            children: [
              Expanded(
                child: _buildTabContent(), // Now has bounded height
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() {
    if (_selectedIndex == 0) {
      Get.dialog(Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                )
              ],
            ),
          ),
        ),
      ));
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
      barrierColor: Colors.black.withOpacity(0.85),
      enableDrag: false,
      builder: (context) => PendingRewardsBottomSheet(
        pendingRewards: pendingRewards,
        onRedeem: () {
          // when user redeems from the sheet
          Navigator.pop(context);
          setState(() => _selectedIndex = 5);
        },
      ),
    );
  }

  // MARK: - Tab Content Switcher
  Widget _buildTabContent() {
    // Show loading only on Home tab
    if (_selectedIndex == 0 && !_isHomeDataLoaded) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    List<Widget> tabs = [
      _buildHomeTab(), // 0
      _buildRechargeTab(), // 1
      _buildWalletTab(), // 2
      _buildProfileTab(), // 3
      // 4 - Shop (handled by navigation)
      Container(),
      _buildRewardTab(),
    ];

    Widget content = tabs[_selectedIndex];

    // Apply padding only to non-home tabs
    if (_selectedIndex != 0) {
      content = Padding(
        padding: const EdgeInsets.all(16.0),
        child: content,
      );
    }

    // Always wrap in SingleChildScrollView with Expanded parent
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Container(
        key: ValueKey<int>(_selectedIndex),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: _selectedIndex == 0
              ? content
              : ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        kBottomNavigationBarHeight -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(child: content),
                ),
        ),
      ),
    );
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
          _buildYoutubeSection(),
          const SizedBox(height: 16.0),
          _buildFeatureCards(),
          const WinnersWidget(),
          HomeSlider(bannerMedia: sliderImages),
          BannerAdWidget(
            adUnitId: 'ca-app-pub-7980318439455341/2126062629',
            adSize: AdSize.largeBanner,
            margin: EdgeInsets.symmetric(horizontal: 0.w, vertical: 12.h),
            showDebugInfo: true,
            useTestAds: true,
          ),
          socialMediaContainers(
            title: 'Instagram',
            imageUrl: 'https://cdn-icons-png.flaticon.com/512/2111/2111463.png',
            link: 'https://www.instagram.com/',
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
    return Container(
      height: 90,
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Main Rounded Bar Background
          Positioned(
            bottom: 15,
            left: 20,
            right: 90, // Space for red "Shop" button
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIconItem(0, UniconsLine.home, 'Home', colorPrimary),
                  _buildIconItem(
                      2, UniconsLine.wallet, 'Wallet', Colors.orange),
                  _buildIconItem(3, UniconsLine.user, 'Profile', Colors.red),
                  _buildIconItem(5, UniconsLine.gift, 'Reward', Colors.pink),
                ],
              ),
            ),
          ),
          // Red "Shop" Button (like Zomato)
          Positioned(
            bottom: 10,
            right: 15,
            child: GestureDetector(
              onTap: () => _onTabTapped(4),
              child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: colorPrimary,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: CustomText(
                    'Shop',
                    textColor: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconItem(
      int index, IconData icon, String label, Color activeColor) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isSelected ? 26 : 24,
              color: isSelected ? activeColor : Colors.black45,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected ? activeColor : Colors.black45,
              ),
            ),
          ],
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
  Widget socialMediaContainers(
      {required String title, required String imageUrl, required String link}) {
    void _launchURL(String url) async {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    }

    Widget modernSocialCard(
        {required String title,
        required String imageUrl,
        required String link,
        required Color brandColor}) {
      return GestureDetector(
        onTap: () => _launchURL(link),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: brandColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: brandColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: brandColor.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.network(
                  imageUrl,
                  height: 28,
                  width: 28,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.error_outline,
                    size: 28,
                    color: brandColor,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                title,
                style: TextStyle(
                  color: brandColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF667EEA),
                      Color(0xFF764BA2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.connect_without_contact_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Connect With Us',
                style: TextStyle(
                  color: const Color(0xFF1A1A1A),
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: modernSocialCard(
                  title: 'YouTube',
                  imageUrl:
                      'https://cdn-icons-png.flaticon.com/512/1384/1384060.png',
                  link: 'https://www.youtube.com/',
                  brandColor: const Color(0xFFFF0000),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: modernSocialCard(
                  title: 'Facebook',
                  imageUrl:
                      'https://cdn-icons-png.flaticon.com/512/733/733547.png',
                  link: 'https://www.facebook.com/',
                  brandColor: const Color(0xFF1877F2),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: modernSocialCard(
                  title: 'Instagram',
                  imageUrl:
                      'https://cdn-icons-png.flaticon.com/512/2111/2111463.png',
                  link: 'https://www.instagram.com/',
                  brandColor: const Color(0xFFE4405F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget reelVideoContainer(
      {required String thumbnailUrl,
      required String title,
      required VoidCallback onTap}) {
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
                offset: const Offset(2, 4))
          ],
          image: DecorationImage(
              image: NetworkImage(thumbnailUrl), fit: BoxFit.cover),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent
                    ]),
              ),
            ),
            Positioned(
              left: 10,
              bottom: 10,
              right: 10,
              child: Text(title,
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
                            blurRadius: 3)
                      ])),
            ),
            const Center(
                child: Icon(Icons.play_circle_fill_rounded,
                    color: Colors.white70, size: 60)),
          ],
        ),
      ),
    );
  }

  Widget _buildMykySymbol() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Center(
              child: Text('M',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorPrimary))),
        ),
        const SizedBox(width: 10),
        const Text('MYKY',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ],
    );
  }

  Widget _buildImageSliderWithMykySymbol() {
    List<String> imageUrls = [
      'assets/static-images/01.jpg',
      'assets/static-images/02.jpg',
      'assets/static-images/03.jpg',
      'assets/static-images/04.jpg',
      'assets/static-images/05.jpg',
      'assets/static-images/06.jpg',
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Stack(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height * 0.8,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
            ),
            items: imageUrls.map((url) {
              return Builder(builder: (context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      Image.asset(url,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.8,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: Center(
                                  child: Icon(Icons.image_not_supported,
                                      size: 50, color: Colors.grey[600])))),
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
                                colorPrimary.withOpacity(0.7),
                                colorPrimary.withOpacity(0.3),
                                Colors.transparent
                              ],
                              stops: [0.0, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              });
            }).toList(),
          ),
          Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              child: _buildMykySymbol()),
        ],
      ),
    );
  }

  String extractYouTubeVideoId(String embedUrl) {
    RegExp regExp =
        RegExp(r'youtube\.com\/embed\/([a-zA-Z0-9_-]+)', caseSensitive: false);
    final match = regExp.firstMatch(embedUrl);
    return match?.group(1) ?? 'dQw4w9WgXcQ';
  }

  Future<void> _openYouTubeVideo(String videoId) async {
    final youtubeAppUrl =
        Uri.parse('youtube://www.youtube.com/watch?v=$videoId');
    final youtubeWebUrl = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    try {
      if (await canLaunchUrl(youtubeAppUrl)) {
        await launchUrl(youtubeAppUrl);
      } else {
        await launchUrl(youtubeWebUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not open video.'), backgroundColor: Colors.red));
    }
  }

  Future<void> _openQRScanner() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      if (barcodeScanRes != '-1') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Scanned: $barcodeScanRes'),
            backgroundColor: Colors.green));
        _processScanResult(barcodeScanRes);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Scan failed.'), backgroundColor: Colors.red));
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Payment QR detected'),
        backgroundColor: colorPrimary));
  }

  Widget _buildScannerSection() => const QRScannerBox();

  Widget _buildFeatureCards() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Services',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              // shadows: [
              //   Shadow(
              //     color: Colors.white.withOpacity(0.4),
              //     offset: const Offset(-1, 2),
              //     blurRadius: 8,
              //   ),
              // ],
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildPremiumFeatureCard(
                  title: 'Nearby',
                  subtitle: 'Offline Stores',

                  // IMPROVED PURPLE-LAVENDER PALLETE
                  primaryColor: const Color(0xFF8A7CFF),
                  secondaryColor: const Color(0xFFB5A9FF),
                  iconBg: const Color(0xFFF4EEFF),

                  icon: Icons.store_mall_directory_rounded,
                  onTap: () => Get.toNamed('/nearby-offline-store'),

                  mainGradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 162, 157, 254), // Purple
                      Color.fromARGB(255, 248, 225, 254), // Lavender blend
                      Color.fromARGB(255, 255, 255, 255), // Very end white
                    ],
                    stops: [0.0, 0.8, 1.0],

                    // Purple covers more
                  ),


                ),

              ),
              SizedBox(width: 14.w),
              Expanded(
                  child: _buildPremiumFeatureCard(
                      title: 'Coins',
                      subtitle: 'Earn Rewards',
                      primaryColor: const Color(0xFFFF6B6B),
                      secondaryColor: const Color(0xFFFF8E8E),
                      icon: Icons.stars_rounded,
                      iconBg: const Color(0xFFFFE5E5),
                      mainGradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromARGB(200, 255, 85, 85),   // Softened red start
                          Color.fromARGB(255, 255, 170, 170), // Soft red tint
                          Color.fromARGB(255, 255, 245, 245), // Minimal white touch
                        ],
                        stops: [0.0, 0.85, 1.0],


                      ),
                      onTap: () {
                        Get.toNamed('/coin-wallet');
                      })),
            ],
          ),
          SizedBox(height: 14.h),
          Row(children: [
            Expanded(
              child: _buildPremiumFeatureCard(
                title: 'Map',
                subtitle: 'Directions',

                // MATCHED COLORS
                primaryColor: const Color(0xFF6ECFF6),
                secondaryColor: const Color(0xFF9DE3F9),
                iconBg: const Color(0xFFE8F9FF),

                icon: Icons.explore_rounded,

                mainGradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(230, 158, 234, 255), // Soft aqua
                    Color.fromARGB(255, 229, 248, 255), // Pale aqua blend
                    Color.fromARGB(255, 255, 255, 255), // End white
                  ],
                  stops: [0.0, 0.85, 1.0],
                ),

                onTap: () {
                  Get.toNamed('/near-me-store');
                },
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: _buildPremiumFeatureCard(
                title: 'Recharge',
                subtitle: 'Pay Bills',

                // MATCHED MINT GREEN COLORS
                primaryColor: const Color(0xFF6EDB8D),
                secondaryColor: const Color(0xFF9EEFC0),
                iconBg: const Color(0xFFEFFEF4),

                icon: Icons.phone_iphone_rounded,

                mainGradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(230, 199, 255, 204), // Soft mint
                    Color.fromARGB(255, 225, 255, 230), // Lighter mint blend
                    Color.fromARGB(255, 255, 255, 255), // End white
                  ],
                  stops: [0.0, 0.85, 1.0],
                ),

                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
            ),
          ]),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildPremiumFeatureCard({
    required String title,
    required String subtitle,
    required Color primaryColor,
    required Color secondaryColor,
    required IconData icon,
    required Color iconBg,
    required VoidCallback onTap,
    LinearGradient? mainGradient, // Custom main background gradient (optional)
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180.h,
        decoration: BoxDecoration(
          gradient: mainGradient ??
              LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  primaryColor.withOpacity(0.03),
                  secondaryColor.withOpacity(0.02),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Top accent bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
              ),
            ),
            // Decorative circles
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.03),
                      primaryColor.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      secondaryColor.withOpacity(0.02),
                      secondaryColor.withOpacity(0.06),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Main content
            Padding(
              padding: EdgeInsets.all(18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      // gradient: LinearGradient(
                      //   colors: [iconBg, iconBg.withOpacity(0.9)],
                      //   begin: Alignment.topLeft,
                      //   end: Alignment.bottomRight,
                      // ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: primaryColor, size: 32),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xFF1A1A1A),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: const Color(0xFF6B6B6B),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: primaryColor,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYoutubeSection() {
    List<Map<String, String>> videoData =
        youtubeVideos != null && youtubeVideos!.isNotEmpty
            ? youtubeVideos!.map((video) {
                String videoId = extractYouTubeVideoId(video['link']);
                return {
                  'thumbnail':
                      'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                  'title': 'How to Play - Tutorial ${video['id']}',
                  'videoId': videoId,
                };
              }).toList()
            : [
                {
                  'thumbnail':
                      'https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
                  'title': 'How to Play - Tutorial 1',
                  'videoId': 'dQw4w9WgXcQ'
                },
                {
                  'thumbnail':
                      'https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
                  'title': 'How to Play - Tutorial 2',
                  'videoId': 'dQw4w9WgXcQ'
                },
                {
                  'thumbnail':
                      'https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
                  'title': 'How to Play - Tutorial 3',
                  'videoId': 'dQw4w9WgXcQ'
                },
              ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Watch How to Play!',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
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
                            borderRadius: BorderRadius.circular(12)),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Image.network(video['thumbnail']!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey[300],
                                        child: Center(
                                            child: Icon(Icons.video_library,
                                                size: 40,
                                                color: Colors.grey[600])))),
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12)),
                                    color: Colors.black.withOpacity(0.3)),
                                child: Center(
                                    child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: const Icon(Icons.play_arrow,
                                            color: Colors.white, size: 30))),
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
        height: 180,
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
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withOpacity(0.6),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: isTop ? 8 : 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),

            // Subtle inner glow border (only for top card)
            if (isTop)
              Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
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
                      child: Text(
                        "👑",
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                ],
              ),
            ),

            // Subtle particle shine effect on top card
            if (isTop)
              Positioned.fill(
                child: IgnorePointer(
                  child: _CardShineOverlayCompact(),
                ),
              ),
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
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // height tuned to match your design
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.purple.shade900.withOpacity(0.97),
            Colors.black.withOpacity(1.0),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              child: Image.asset(
                "assets/images/bottom_sheet_bg.png",
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Foreground gradient overlay (adds premium depth)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.30),
                    Colors.black.withOpacity(0.60),
                    Colors.black.withOpacity(0.95),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // Existing floating particles
          const Positioned.fill(child: FloatingParticles()),

          // Subtle premium glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    Colors.pinkAccent.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ---- The rest of your content (close button, title, stack, button) ----
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 12.sp),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8.sp),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, -1),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                ),

                60.heightBox,

                // Premium "Pending Rewards" title
                Text(
                  "Pending Rewards",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    height: 1.1,
                    shadows: [
                      Shadow(
                        color: Colors.pinkAccent.withOpacity(0.7),
                        blurRadius: 30,
                        offset: const Offset(0, 6),
                      ),
                      Shadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                70.heightBox,

                // Stacked cards
                Expanded(
                  child: Center(
                    child: buildRewardStack(widget.pendingRewards),
                  ),
                ),

                30.heightBox,

                // Pulsing Redeem Button
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, __) {
                    return Transform.scale(
                      scale: 1.0 + 0.06 * sin(_pulseController.value * 6.28),
                      child: Container(
                        height: 56.h,
                        width: 220.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: [Colors.pink, Colors.pinkAccent],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pink.withOpacity(0.6 +
                                  0.1 * sin(_pulseController.value * 6.28)),
                              blurRadius: 25 +
                                  5 * sin(_pulseController.value * 6.28).abs(),
                              offset: const Offset(0, 8),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Confetti.launch(context,
                                options: const ConfettiOptions(
                                    particleCount: 80, spread: 90, y: 0.6));
                            // call parent's onRedeem after small delay so confetti is visible
                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              widget.onRedeem();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.card_giftcard_rounded, size: 24),
                              12.widthBox,
                              Text(
                                "Redeem Now",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                40.heightBox,
              ],
            ),
          )
        ],
      ),
    );
  }

  // ========================
// TOP-LEVEL FUNCTION
// ========================
  Widget buildRewardStack(List rewards) {
    final topFive = (rewards ?? []).take(5).toList();

    final List<List<Color>> gradients = [
      [Color(0xFF9C27B0), Color(0xFFE91E63)],
      [Color(0xFFFF5E3A), Color(0xFFFF8A65)],
      [Color(0xFF00D4AA), Color(0xFF00F5A0)],
      [Color(0xFF448AFF), Color(0xFF2979FF)],
      [Color(0xFFFFD700), Color(0xFFFFEA80)],
    ];

    return Center(
      child: SizedBox(
        width: 340,
        height: 220,
        child: Stack(
          clipBehavior: Clip.none,
          children: List.generate(topFive.length, (index) {
            final reward = topFive[index];
            final id = reward['id'];
            final rank = index + 1;

            final reversedIndex = topFive.length - 1 - index;
            final double offsetY = reversedIndex * 22.0;
            final double scale = 1.0 - (reversedIndex * 0.06);
            final double opacity = 1.0 - (reversedIndex * 0.12);

            return Positioned(
              top: -offsetY,
              left: 0,
              right: 0,
              child: TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 600 + (index * 150)),
                curve: Curves.easeOutQuint,
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, animValue, child) {
                  return Transform.scale(
                    scale: 0.8 + (animValue * (scale - 0.8)),
                    child: Opacity(
                      opacity: animValue * opacity.clamp(0.6, 1.0),
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
                      options: ConfettiOptions(
                        particleCount: 60,
                        spread: 70,
                        y: 0.6,
                      ),
                    );

                    // navigate to rewards page
                    Future.delayed(Duration(milliseconds: 300), () {
                      Navigator.pop(context);
                      // cannot use setState here in bottom sheet
                    });
                  },
                ),
              ),
            );
          }),
        ),
      ),
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

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat();
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

  _Particle(
      {required this.dx,
      required this.dy,
      required this.size,
      required this.speed,
      required this.sway,
      required this.opacity});
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
