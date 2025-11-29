import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class PNetworkImage extends StatelessWidget {
  final String? image;
  final BoxFit? fit, errorFit;
  final double? width, height, errorWidth, errorHeight;
  final double borderRadius;
  bool isAutoSet = false;

  PNetworkImage(
    this.image, {
    Key? key,
    this.fit,
    this.height,
    this.width,
    this.errorWidth,
    this.errorHeight,
    this.errorFit,
    this.borderRadius = 0.0,
    this.isAutoSet = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: isAutoSet == true
          ? CachedNetworkImage(
              imageUrl: (image != null) ? image! : '',
              placeholder: (context, url) => _buildShimmerPlaceholder(),
              errorWidget: (context, url, error) => Image.asset(
                // imgDataNotFound,
                'assets/images/placeholder.png',
                fit: errorFit ?? BoxFit.cover,
                width: errorWidth ?? 100.w,
                height: errorHeight ?? 100.h,
              ),
              fit: fit,
            )
          : CachedNetworkImage(
              imageUrl: (image != null) ? image! : '',
              placeholder: (context, url) => _buildShimmerPlaceholder(),
              errorWidget: (context, url, error) => Image.asset(
                // imgDataNotFound,
                'assets/images/placeholder.png',
                fit: BoxFit.contain,
                width: errorWidth ?? 100.w,
                height: errorHeight ?? 100.h,
              ),
              fit: fit,
              width: width ?? 100.w,
              height: height ?? 100.h,
            ),
    );
  }

  Widget _buildShimmerPlaceholder({double? width, double? height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }
}
