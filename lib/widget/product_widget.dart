import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../widget/theme.dart';
import '../../services/api.dart';
import '../../widget/network_image.dart';
import '../../widget/paginated_grid.dart';
import '../services/auth.dart';
import '../shopping/filter/filter_page.dart';

class ProductWidget extends StatefulWidget {
  final productFilters;
  final bool isFilter;

  const ProductWidget({Key? key, this.productFilters, this.isFilter = true})
      : super(key: key);

  @override
  _ProductWidgetState createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  GlobalKey<PaginatedGridState> _productPageListKey = GlobalKey();
  Map? previousFilters;
  Map? filterData;

  @override
  void initState() {
    previousFilters = widget.productFilters;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ProductWidget oldWidget) {
    if (widget.productFilters != null) {
      _productPageListKey.currentState!.refreshData();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (previousFilters != widget.productFilters) {
      _productPageListKey.currentState!.refreshData();
      previousFilters = widget.productFilters;
    }
    return Column(
      children: [
        if (widget.isFilter) ...{
          FilterPage(filterData: (data) {
            setState(() {
              filterData = data;
            });
            _productPageListKey.currentState!.refreshData();
          }),
        },
        SizedBox(height: 15.h),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 14.w),
            child: PaginatedGrid(
              noDataTitle: 'Product List',
              key: _productPageListKey,
              scrollPhysics: AlwaysScrollableScrollPhysics(),
              apiFuture: (int page) async {
                return widget.isFilter
                    ? Api.http.post(
                        'shopping/product?page=$page',
                        data: sendData(),
                      )
                    : Api.httpWithoutLoader.post(
                        'shopping/product?page=$page',
                        data: sendData(),
                      );
              },
              listItemBuilder: gridItemBuilderProductOfferBox,
              resetStateOnRefresh: true,
            ),
          ),
        ),
      ],
    );
  }

  refreshData() {
    _productPageListKey.currentState!.refreshData();
  }

  Map<String, dynamic> sendData() {
    return filterData != null
        ? {
            "sortBy_id":
                filterData!.containsKey('sort') ? filterData!['sort'] : 0,
            "category_id": filterData!['filter']['categories'].length > 0
                ? filterData!['filter']['categories']
                : null,
            "gender_id": filterData!['filter']['gender'].length > 0
                ? filterData!['filter']['gender']
                : null,
            "price_id": filterData!['filter']['price'].length > 0
                ? filterData!['filter']['price']
                : null,
            "rating_id": filterData!['filter']['ratings'].length > 0
                ? filterData!['filter']['ratings']
                : null,
            "discount_id": filterData!['filter']['discount'].length > 0
                ? filterData!['filter']['discount']
                : null,
            "user_type": Auth.check()!
                ? 1
                : Auth.isGuest()!
                    ? 2
                    : null
          }
        : widget.productFilters != null
            ? {
                "sortBy_id": widget.productFilters!.containsKey('sort')
                    ? widget.productFilters!['sort']
                    : 0,
                "category_id": widget.productFilters!.containsKey('category')
                    ? widget.productFilters!['category']
                    : widget.productFilters!.containsKey('filter')
                        ? widget.productFilters!['filter']['categories']
                        : null,
                "gender_id": widget.productFilters!.containsKey('gender')
                    ? widget.productFilters!['gender']
                    : widget.productFilters!.containsKey('filter')
                        ? widget.productFilters!['filter']['gender']
                        : null,
                "price_id": widget.productFilters!.containsKey('price')
                    ? widget.productFilters!['price']
                    : widget.productFilters!.containsKey('filter')
                        ? widget.productFilters!['filter']['price']
                        : null,
                "rating_id": widget.productFilters!.containsKey('filter')
                    ? (widget.productFilters!['filter']['ratings'].length > 0
                        ? widget.productFilters!['filter']['ratings']
                        : null)
                    : null,
                "discount_id": widget.productFilters!.containsKey('filter')
                    ? (widget.productFilters!['filter']['discount'].length > 0
                        ? widget.productFilters!['filter']['discount']
                        : null)
                    : null,
                "user_type": Auth.check()!
                    ? 1
                    : Auth.isGuest()!
                        ? 2
                        : null
              }
            : {
                "sortBy_id": null,
                "category_id": null,
                "gender_id": null,
                "price_id": null,
                "rating_id": null,
                "discount_id": null,
                "user_type": Auth.check()!
                    ? 1
                    : Auth.isGuest()!
                        ? 2
                        : null
              };
  }

  Widget gridItemBuilderProductOfferBox(itemData, int index) {
    final total = 0; // keep structure consistent, though not used
    final int crossAxisCount = 2; // must match PaginatedGrid crossAxisCount
    final bool isFirstColumn = (index % crossAxisCount) == 0;
    final bool isLastColumn = (index % crossAxisCount) == (crossAxisCount - 1);
    final int nRows = (total / crossAxisCount).ceil();
    final int rowIndex = (index / crossAxisCount).floor();
    final bool isLastRow = rowIndex == (nRows - 1);

    BorderSide side = BorderSide(color: Colors.grey.withOpacity(0.3), width: 0.8);

    return InkWell(
      onTap: () {
        Get.toNamed('/product-detail',
            arguments: {"type": "productList", "data": itemData});
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: side,
            left: side,
            right: isLastColumn ? side : BorderSide.none,
            bottom: isLastRow ? side : BorderSide.none,
          ),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.zero,
                    child: PNetworkImage(
                      itemData['url'],
                      fit: BoxFit.cover,
                      height: 160.sp,
                      width: 160.sp,
                    ),
                  ),
                ),
                // discount tag (kept from original)
                if (itemData!['discountAmount'] != null &&
                    itemData!['discountAmount'] > 0)
                  Positioned(
                    bottom: 8.h,
                    left: 8.w,
                    child: Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.8),
                            Colors.white.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/discount.png',
                            width: 12.w,
                            color: Colors.green,
                          ),
                          SizedBox(width: 4.w),
                          text(
                            '${itemData!['discountAmount']} OFF',
                            textColor: Colors.green,
                            fontSize: 12.0,
                            fontFamily: fontSemibold,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  text(
                    itemData['name'],
                    fontSize: 14.sp,
                    maxLine: 1,
                    fontFamily: fontSemibold,
                    overflow: TextOverflow.ellipsis,
                    textColor: Colors.black,
                  ),
                  8.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      text(
                        '₹${itemData!['mrp']}',
                        decoration: TextDecoration.lineThrough,
                        textColor: Colors.grey.shade500,
                        fontSize: 14.sp,
                      ),
                      10.width,
                      text(
                        '₹${itemData!['selling_price']}',
                        fontFamily: fontBold,
                        fontSize: 16.sp,
                        textColor: const Color(0xFF658D28),
                      ),
                    ],
                  ),
                  6.height,
                  if (itemData!['ratingCount'] > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              text(
                                double.parse(
                                    itemData!['averageRating'].toString())
                                    .toStringAsFixed(1),
                                textColor: Colors.white,
                                fontFamily: fontSemibold,
                                fontSize: 12.sp,
                              ),
                              SizedBox(width: 2.w),
                              Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 12.sp,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 6.w),
                        text(
                          '${itemData!['ratingCount']} Ratings',
                          fontFamily: fontRegular,
                          textColor: Colors.grey.shade600,
                          fontSize: 12.sp,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
