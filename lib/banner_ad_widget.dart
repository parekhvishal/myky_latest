// lib/widgets/banner_ad_widget.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:myky_clone/utils/app_config.dart';
import 'package:myky_clone/widget/theme.dart';

class BannerAdWidget extends StatefulWidget {
  final String adUnitId;
  final AdSize adSize;
  final EdgeInsets? margin;
  final bool showLoadingIndicator;
  final bool showDebugInfo;
  final bool useTestAds;

  const BannerAdWidget({
    super.key,
    required this.adUnitId,
    this.adSize = AdSize.banner,
    this.margin,
    this.showLoadingIndicator = true,
    this.showDebugInfo = false,
    this.useTestAds = false,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  int _retryCount = 0;
  static const int maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    // Determine which ad unit ID to use
    String adUnitId = widget.adUnitId;

    // Use test ad unit ID in debug mode or when explicitly requested
    if (widget.useTestAds || (kDebugMode && AppConfig.appDebugMode == true)) {
      adUnitId = "ca-app-pub-3940256099942544/6300978111";

      debugPrint('Using test banner ad unit ID: $adUnitId');
    } else {
      debugPrint('Using production banner ad unit ID: $adUnitId');
    }

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: widget.adSize,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          debugPrint('Banner ad loaded successfully: $adUnitId');
          if (mounted) {
            setState(() {
              _isLoaded = true;
              _isLoading = false;
              _hasError = false;
              _errorMessage = null;
              _retryCount = 0;
            });
          }
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint(
              'Banner ad failed to load (attempt ${_retryCount + 1}/$maxRetries): $error');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isLoaded = false;
              _isLoading = false;
              _hasError = true;
              _errorMessage = 'Error ${error.code}: ${error.message}';
            });

            // Retry with exponential backoff if we haven't exceeded max retries
            if (_retryCount < maxRetries) {
              final retryDelay =
                  Duration(seconds: (5 * (_retryCount + 1)).clamp(5, 30));
              debugPrint(
                  'Retrying banner ad load after ${retryDelay.inSeconds} seconds...');

              Future.delayed(retryDelay, () {
                if (mounted && !_isLoaded) {
                  _retryCount++;
                  _loadBannerAd();
                }
              });
            } else {
              debugPrint('Max retries exceeded for banner ad. Giving up.');
            }
          }
        },
        onAdOpened: (Ad ad) {
          debugPrint('Banner ad opened');
        },
        onAdClosed: (Ad ad) {
          debugPrint('Banner ad closed');
        },
        onAdImpression: (Ad ad) {
          debugPrint('Banner ad impression recorded');
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show debug error information in debug mode
    if (_hasError && !_isLoading) {
      if (widget.showDebugInfo ||
          (kDebugMode && AppConfig.appDebugMode == true)) {
        return Container(
          margin: widget.margin ?? EdgeInsets.symmetric(vertical: 8.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 20.w,
              ),
              SizedBox(height: 4.h),
              Text(
                'Ad Failed to Load',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: 4.h),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.red.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: 4.h),
              Text(
                'Retries: $_retryCount/$maxRetries',
                style: TextStyle(
                  fontSize: 9.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }
      // Don't show anything in production if ad failed to load
      return const SizedBox.shrink();
    }

    if (_isLoading && widget.showLoadingIndicator) {
      return Container(
        margin: widget.margin ?? EdgeInsets.symmetric(vertical: 8.h),
        height: widget.adSize.height.toDouble(),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colorPrimary),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Loading ad...',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin ?? EdgeInsets.symmetric(vertical: 8.h),
      height: widget.adSize.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
