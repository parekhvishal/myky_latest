import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:myky_clone/utils/en_extensions.dart';
import 'package:myky_clone/widget/paginated_list.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:unicons/unicons.dart';

import '../../services/api.dart';
import '../../widget/custom_container.dart';
import '../../widget/network_image.dart';
import '../../widget/theme.dart';

class NearByOfflineStoreList extends StatefulWidget {
  const NearByOfflineStoreList({super.key});

  @override
  State<NearByOfflineStoreList> createState() => _NearByOfflineStoreListState();
}

class _NearByOfflineStoreListState extends State<NearByOfflineStoreList> {
  String? selectedCategoryID;
  GlobalKey<PaginatedListState> nearByOfflineStoreGlobalKey = GlobalKey();
  TextEditingController pinCodeController = TextEditingController();
  List vendorCategories = [];

  getCategories() async {
    await Api.http.get('member/vendor-category').then((response) {
      if (response.data['status'] == true) {
        setState(() {
          vendorCategories = response.data['vendorCategories'];
        });
      }
    });
  }

  @override
  void initState() {
    getCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Near By Offline Store"),
      ),
      backgroundColor: Colors.white,
      body: CustomContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vendorCategories.isNotEmpty) ...[
              buildDropdown(),
              15.heightBox,
            ],
            buildPincodeField(context),
            15.heightBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomButton(
                  textContent: 'Apply',
                  onPressed: () {
                    nearByOfflineStoreGlobalKey.currentState?.refresh();
                  },
                ),
                CustomButton(
                    textContent: 'Reset',
                    customColor: red,
                    onPressed: () {
                      setState(() {
                        selectedCategoryID = null;
                        pinCodeController.clear();
                      });
                      nearByOfflineStoreGlobalKey.currentState?.refresh();
                    }),
              ],
            ),
            15.heightBox,
            Expanded(
              child: PaginatedList(
                key: nearByOfflineStoreGlobalKey,
                resetStateOnRefresh: true,
                noDataTitle: 'Near By Offline Store List',
                apiFuture: (int page) async {
                  return Api.http.get(
                    'member/near-by-store?page=$page',
                    queryParameters: {
                      "categoryId": selectedCategoryID,
                      "pincode": pinCodeController.text,
                    },
                  );
                },
                listItemBuilder: _nearByOfflineStoreViewBuilder,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildDropdown() {
    return Container(
      padding: EdgeInsets.only(right: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: gray,
          width: 1.w,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2(
          isExpanded: true,
          hint: Text(
            "Select Category",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.black,
              fontFamily: fontMedium,
            ),
          ),
          items: vendorCategories
              .map((item) => DropdownMenuItem<String>(
                    value: item['id'].toString(),
                    child: Text(
                      item['name'],
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.black,
                        fontFamily: fontBold,
                      ),
                    ),
                  ))
              .toList(),
          value: selectedCategoryID,
          onChanged: (value) {
            setState(() {
              selectedCategoryID = value as String;
            });
          },
        ),
      ),
    );
  }

  Widget buildPincodeField(BuildContext context) {
    return formField(
      context,
      "Pincode",
      controller: pinCodeController,
      prefixIcon: UniconsLine.location_pin_alt,
      maxLength: 6,
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))],
      keyboardType: TextInputType.number,
      validator: (value) {
        if (pinCodeController.text.length < 6 &&
            pinCodeController.text.isNotEmpty) {
          return 'The Pincode must be 6 digit';
        } else {
          return null;
        }
      },
      onChanged: (value) {
        // validator.clearErrorsAt('pincode');
      },
    );
  }

  Widget _nearByOfflineStoreViewBuilder(item, int index) {
    double? discountPercentage;
    if (item['percentage'] != null && item['percentage'].isNotEmpty) {
      discountPercentage = double.tryParse(item['percentage']);
    }

    return Container(
      decoration: boxDecoration(radius: 12.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: PNetworkImage(
                  item['image'],
                  width: 100.sp,
                  height: 100.sp,
                  fit: BoxFit.cover,
                ),
              ).onTap(() {
                if (item['vendorShopImage'].length > 0) {
                  showAllImages(context, item['vendorShopImage']);
                }
              }),
              12.widthBox,
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 12.sp),
                      child: text(
                        item['vendorId'],
                        fontFamily: fontMedium,
                        textColor: colorPrimary,
                        fontSize: 16.sp,
                      ),
                    ),
                    4.heightBox,
                    text(
                      item['date'],
                      fontSize: 14.sp,
                      textColor: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ).paddingSymmetric(horizontal: 16.w, vertical: 12.h),
          const Divider(color: Colors.grey, thickness: 0.5, height: 1),
          Padding(
            padding: EdgeInsets.all(12.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StarWithPercentage(
                      percentage: discountPercentage,
                      size: 100.sp,  // Increased size for better visibility
                    ),
                  ],
                ),
                20.heightBox,
                rowHeading(
                  "Category Name",
                  item['categoryName'],
                ),
                8.heightBox,
                rowHeading(
                  "Vendor Name",
                  item['vendorName'],
                ),
                8.heightBox,
                rowHeading(
                  "Vendor Mobile",
                  item['vendorMobile'],
                ),
                8.heightBox,
                rowHeading(
                  "Shop Name",
                  item['shopName'],
                ),
                8.heightBox,
                // Star-shaped discount display
                rowHeading(
                  "Address",
                  '',
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.w, top: 4.h),
                  child: text(
                    item['address'],
                    fontSize: 15.sp,
                    textColor: Colors.black54,
                    isLongText: true,
                  ),
                ),
                8.heightBox,
                rowHeading(
                  "State",
                  item['state'],
                ),
                8.heightBox,
                rowHeading(
                  "City",
                  item['city'],
                ),
                8.heightBox,
                rowHeading(
                  "PIN Code",
                  item['pincode'].toString(),
                ),
                8.heightBox,
                rowHeading(
                  "GST No",
                  item['gstNo'],
                ),
                12.heightBox,
                Center(
                  child: CustomButton(
                    textContent: 'Direction',
                    onPressed: () async {
                      final availableMaps = await MapLauncher.installedMaps;
                      await availableMaps.first.showMarker(
                        coords: Coords(num.parse(item['latitude']).toDouble(),
                            num.parse(item['longitude']).toDouble()),
                        title: "${item['shopName']}",
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showAllImages(BuildContext context, List images) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          insetPadding: const EdgeInsets.all(24),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          backgroundColor: Colors.white,
          child: Container(
            width: double.infinity,
            decoration: boxDecoration(radius: 12.r),
            padding: EdgeInsets.all(8.sp),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 250.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(right: 12.w),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.network(
                            images[index]['fileName'],
                            fit: BoxFit.cover,
                            width: 250.w,
                            height: 250.h,
                          ),
                        ),
                      ).onTap(() {
                        Get.toNamed(
                          'image-preview',
                          arguments: images[index]['fileName'],
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Professional star badge for cashback offers
class StarWithPercentage extends StatelessWidget {
  final double? percentage;
  final double size;

  const StarWithPercentage({super.key, this.percentage, required this.size});

  Color _getStarColor() {
    if (percentage == null) return const Color(0xFF424242); // Dark grey
    if (percentage! <= 2.5) return const Color(0xFF4A148C); // Very dark purple
    if (percentage! <= 5.0) return const Color(0xFF0D47A1); // Very dark blue
    if (percentage! <= 8.0) return const Color(0xFF880E4F); // Very dark pink/red
    if (percentage! <= 12.5) return const Color(0xFFE65100); // Very dark orange
    if (percentage! <= 16.85) return const Color(0xFF004D40); // Very dark teal
    return const Color(0xFF1B5E20); // Very dark green
  }

  LinearGradient _getGradient() {
    Color baseColor = _getStarColor();
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        baseColor,
        baseColor.withOpacity(0.8),
      ],
    );
  }

  String _formatPercentage(double? percentage) {
    if (percentage == null) return "N/A";

    // Round to nearest whole number and display in star
    int roundedPercentage = percentage.round();
    return "${roundedPercentage}%";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Star shape with percentage and OFF text
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              // boxShadow: [
              //   BoxShadow(
              //     color: _getStarColor().withOpacity(0.3),
              //     blurRadius: 15,
              //     offset: const Offset(0, 5),
              //     spreadRadius: 2,
              //   ),
              // ],
              ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Star background with gradient - custom painted shape
              CustomPaint(
                size: Size(size, size),
                painter: StarBadgePainter(
                  color: _getStarColor(),
                  gradient: _getGradient(),
                ),
              ),
              // Content in center of star
              Container(
                width: size * 0.65,
                height: size * 0.65,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Percentage text with round circle background
                    Container(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _formatPercentage(percentage),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size * 0.30,  // Even bigger size for percentage text
                              fontWeight: FontWeight.w900,  // Extra bold for fat/wide appearance
                              letterSpacing: 2.0,  // Increased letter spacing for wider look
                              height: 0.85,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.7),
                                  offset: const Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size * 0.05),
                    // OFF text
                    Text(
                      "OFF",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size * 0.14,  // Slightly bigger for balance
                        fontWeight: FontWeight.w900,  // Extra bold for consistency
                        letterSpacing: 2.0,  // Increased letter spacing for wider look
                        height: 0.8,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.7),
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Extra Cashback text below the star
        SizedBox(height: size * 0.1),
        Text(
          "Extra Cashback",
          style: TextStyle(
            color: _getStarColor(),
            fontSize: size * 0.12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Custom painter for star shape
class StarBadgePainter extends CustomPainter {
  final Color color;
  final LinearGradient gradient;

  StarBadgePainter({required this.color, required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader =
          gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = _createStarPath(size);
    final shadowPath = _createStarPath(size);

    // Draw shadow slightly offset
    canvas.save();
    canvas.translate(3, 4);
    canvas.drawPath(shadowPath, shadowPaint);
    canvas.restore();

    // Draw star with gradient
    canvas.drawPath(path, paint);

    // Draw border
    canvas.drawPath(path, borderPaint);
  }

  Path _createStarPath(Size size) {
    const numberOfPoints = 8;
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    const step = 2 * pi / numberOfPoints;
    double outerRadius = radius * 0.95;
    double innerRadius = radius * 0.65;

    final path = Path();

    for (int i = 0; i < numberOfPoints * 2; i++) {
      final angle = i * step / 2 - pi / 2; // Start from top
      final currentRadius = i % 2 == 0 ? outerRadius : innerRadius;
      final x = center.dx + currentRadius * cos(angle);
      final y = center.dy + currentRadius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
