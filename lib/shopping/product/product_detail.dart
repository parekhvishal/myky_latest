import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'package:myky_clone/widget/custom_container.dart';
import 'package:nb_utils/nb_utils.dart' hide white;
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:unicons/unicons.dart';

import '../../../services/api.dart';
import '../../../services/auth.dart';
import '../../../utils/app_utils.dart';
import '../../../widget/customWidget.dart';
import '../../../widget/network_image.dart';
import '../../../widget/theme.dart';
import '../../services/CountCtl.dart';
import '../../services/cart_service.dart';
import '../../services/debouncer.dart';
import '../../services/dynamic_link.dart';
import '../../widget/guest_login_service.dart';

class ProductDetail extends StatefulWidget {
  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  Map? product;
  Map? productData;
  List? images;

  List? reviewData;

  Future? productFuture;

  num? sp;
  num? dp;
  num? mrp;
  num? discount;
  num? discountAmount;

  String? productName;
  String? referralCode;
  bool outOfStock = false;
  int? productId;
  static final _debouncer = Debouncer(milliseconds: 500);

  final BottomSheetService bottomSheetService = BottomSheetService();

  void showBottomSheet(BuildContext context, product) {
    bottomSheetService.showBottomSheet(context, product: product).then((value) {
      if (value != null && value) {
        _addProductToCart(Auth.check()! ? 1 : 2);
      }
    });
  }

  void initState() {
    product = Get.arguments;
    if (product!['type'] == 'cart') {
      productId = product!['data']['product']['id'];
      productName = product!['data']['product']['name'];
    } else if (product!['type'] == 'wishlist') {
      productId = product!['data']['productId'];
      productName = product!['data']['name'];
    } else {
      productId = product!['data']['id'];
      productName = product!['data']['name'];
    }

    productFuture = getData();
    super.initState();
  }

  _ProductDetailState() {
    Get.lazyPut(() => MLMCountCtl(cartCount), fenix: true);
  }

  int? productVariationId;

  Future<Map> getData() {
    return Api.http.get("shopping/product/show/$productId", queryParameters: {
      "user_type": Auth.check()!
          ? 1
          : Auth.isGuest()!
              ? 2
              : null
    }).then((response) {
      if (response.data['status']) {
        setState(() {
          productData = response.data['products'];
          sp = num.parse(productData!['selling_price'].toString());
          dp = num.parse(productData!['dp'].toString());
          mrp = num.parse(productData!['mrp'].toString());
          discount = num.parse(productData!['discount'].toString());
          discountAmount = num.parse(productData!['discountAmount'].toString());
          productData!['variation'].map((variation) {
            variation.putIfAbsent('isSelected', () => false);
          }).toList();
        });
      }
      return response.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productName ?? ""),
        actions: [
          Container(
            width: 35.sp,
            height: 35.sp,
            decoration: BoxDecoration(
              color: const Color(0xFF658D28).withOpacity(0.1),
              border: Border.all(
                color: const Color(0xFF658D28).withOpacity(0.1),
                width: 0.6,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF658D28).withOpacity(0.04),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              constraints: const BoxConstraints(maxWidth: 35),
              onPressed: () {
                Get.toNamed('/search-page');
              },
              icon: Icon(
                UniconsLine.search,
                size: 18.sp,
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          buildWishList(context),
          const SizedBox(width: 10.0),
          buildMLMCart(context),
          const SizedBox(width: 10.0),
        ],
      ),
      body: CustomContainer(
        child: FutureBuilder(
          future: productFuture,
          builder: (context, AsyncSnapshot? snapshot) {
            if (!snapshot!.hasData) {
              return const Center();
            }
            if (productData != null) {
              images = snapshot.data['products']['images'];
            }

            return (snapshot.data['status'])
                ? _buildPageContent(context)
                : Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset("assets/images/results.png"),
                        const SizedBox(height: 20),
                        text("No Product Found", fontSize: textSizeLarge),
                      ],
                    ),
                  );
          },
        ),
      ),
      bottomNavigationBar: productData != null
          ? _buildProductBuyCard(context, productData)
          : const SizedBox.shrink(),
    );
  }

  Widget _buildPageContent(context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _buildProductSliderCard(context),
          _buildProductDetailsCard(context),
          _buildProductVariationCard(context),
          if (productData!['description'] != null)
            _buildProductDescriptionCard(context),
          _buildProductReviewsCard(context),
          20.height,
        ],
      ),
    );
  }

  Widget _buildProductSliderCard(context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
          decoration: boxContain(
            borderColor: grey.withOpacity(0.3),
            showShadow: true
          ),
          width: double.infinity,
          height: 350.h,
          child: CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              pauseAutoPlayOnTouch: true,
              viewportFraction: 1.0,
              aspectRatio: 0.8,
            ),
            items: images!.map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: PNetworkImage(
                      i['fileName'],
                      fit: BoxFit.contain,
                      errorFit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                },
              );
            }).toList(),
          ),
        )
      ],
    );
  }

  Widget _buildProductDetailsCard(context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
      decoration: boxContain(
        borderColor: grey.withOpacity(0.3),
        showShadow: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          text(
            productData!['name'],
            textColor: colorPrimaryDark,
            fontSize: textSizeLargeMedium,
            fontFamily: fontSemibold,
            isLongText: true,
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 10,
                child: text(
                  "Product code: ${productData!['sku']}",
                  fontSize: 12.0,
                  isLongText: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: [
                  text(
                    '\₹ ${sp!.toStringAsFixed(2)}',
                    textColor: colorPrimary,
                    fontFamily: fontMedium,
                    fontSize: 19.0,
                    fontweight: FontWeight.w600,
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        text(
                          '\₹ ${mrp!.toStringAsFixed(2)}',
                          decoration: TextDecoration.lineThrough,
                          fontSize: 13.0,
                        ),
                        // SizedBox(width: 5),
                        // text(
                        //   '$discount% off',
                        //   textColor: colorAccent,
                        //   fontFamily: fontMedium,
                        //   fontSize: 14.0,
                        //   fontweight: FontWeight.w600,
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
              if (Auth.check()!)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: green,
                  ),
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.share,
                        size: 15,
                        color: white,
                      ),
                      5.width,
                      text('Share & Earn', textColor: white),
                    ],
                  ),
                ).onTap(() {
                  productData!['rating'] = [];
                  String sendData = jsonEncode({
                    "type": "productList",
                    "data": {
                      "id": productData!['id'],
                      "name": productData!['name'],
                      "referralCode": productData!['code'],
                    },
                  });
                  DynamicLink.createDynamicLink(
                          type: "product-detail",
                          itemData: sendData,
                          route: 'product-detail')
                      .then((shortLink) async {
                    _shareNetworkImage(productData!['images'][0]['fileName'],
                        shortLink.toString());
                  });
                }),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              text(
                '\₹ ${discountAmount!.toStringAsFixed(2)} discount',
                fontSize: 12.0,
                fontFamily: fontSemibold,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Container(
                child: Row(
                  children: [
                    text(
                      double.parse(productData!['averageRating'].toString())
                          .toStringAsFixed(1),
                      textColor: Colors.white,
                      fontweight: FontWeight.w600,
                      fontSize: 13.0,
                    ),
                    const SizedBox(width: 2.0),
                    const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 12,
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
                decoration: BoxDecoration(
                  color: colorPrimary,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 1.0, horizontal: 10.0),
              ),
              const SizedBox(width: 10.0),
              text(
                '${productData!['ratingCount']} Ratings',
                fontSize: 12.0,
                fontFamily: fontSemibold,
              ),
            ],
          ),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }

  Widget _buildProductVariationCard(context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration: boxContain(
        // radius: 0,
        showShadow: true,
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: text(
              "Select Variation",
              fontFamily: fontSemibold,
            ),
          ),
          const SizedBox(height: 5.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int i = 0; i < productData!['variation'].length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: productData!['variation'][i]['isSelected']
                          ? [
                        BoxShadow(
                          color: colorPrimary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                          : [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ChoiceChip(
                      elevation: 0,
                      labelPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      label: Text(
                        productData!['variation'][i]['variationDetail']['name'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: fontSemibold,
                          fontSize: 14.sp,
                          letterSpacing: 0.2,
                          color: productData!['variation'][i]['isSelected']
                              ? Colors.black
                              : Colors.black87,
                        ),
                      ),
                      backgroundColor: Colors.white,
                      selected: productData!['variation'][i]['isSelected'],
                      selectedColor: Colors.transparent, // handled by gradient below
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: productData!['variation'][i]['isSelected']
                              ? Colors.transparent
                              : Colors.grey.withOpacity(0.3),
                          width: 1.2,
                        ),
                      ),
                      avatar: productData!['variation'][i]['isSelected']
                          ? const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.white,
                      )
                          : null,
                      // Custom gradient background for selected state
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      selectedShadowColor: colorPrimary.withOpacity(0.3),
                      onSelected: (bool selected) {
                        setState(() {
                          for (var variation in productData!['variation']) {
                            variation['isSelected'] =
                                variation['id'] == productData!['variation'][i]['id'];
                          }

                          final v = productData!['variation'][i];
                          productVariationId = v['id'];
                          sp = num.parse(v['selling_price'].toString());
                          dp = num.parse(v['dp'].toString());
                          mrp = num.parse(v['mrp'].toString());
                          discount = num.parse(v['discount'].toString());
                          discountAmount = num.parse(v['discountAmount'].toString());
                          outOfStock = v['outOfStock'];
                        });
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

  Widget _buildProductDescriptionCard(context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      decoration: boxContain(
        showShadow: true,
      ),
      width: double.infinity,
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: colorPrimary,
          initiallyExpanded: true,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: text(
              "Product Details",
              fontFamily: fontSemibold,
            ),
          ),
          children: [
            const SizedBox(height: 5.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Html(
                data: productData!['description'],
                style: {
                  "h4": Style(
                    color: Colors.black,
                    fontSize: FontSize(16.sp),
                    fontFamily: fontRegular,
                  ),
                  "p": Style(
                    color: Colors.black,
                    fontSize: FontSize(12.sp),
                    fontFamily: fontRegular,
                  ),
                },
              ),
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }

  Widget _buildProductReviewsCard(context) {
    num? rating;
    rating = double.parse(productData!['averageRating'].toString()).toDouble();
    return Container(
      decoration: boxDecoration(
        radius: 10,
        showShadow: true,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: text(
              "Product Rating & Reviews",
              fontFamily: fontSemibold,
            ),
          ),
          const SizedBox(height: 5.0),
          Container(
            height: 140.0,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          text(
                            rating.toStringAsFixed(1).toString(),
                            fontSize: 35.0,
                            fontweight: FontWeight.w600,
                            fontFamily: fontSemibold,
                            textColor: colorAccent,
                          ),
                          Icon(
                            Icons.star,
                            color: colorAccent,
                            size: 20,
                          ),
                        ],
                      ),
                      text(
                        "${productData!['ratingCount'].toString()}  Ratings",
                        fontSize: 13.0,
                        fontFamily: fontSemibold,
                        textColor: Colors.grey,
                      ),
                      const SizedBox(height: 2),
                      text(
                        "${productData!['reviewCount'].toString()}  Reviews",
                        fontSize: 13.0,
                        fontFamily: fontSemibold,
                        textColor: Colors.grey,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: ListView.builder(
                    itemCount: productData!['rating'].length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          text(
                            productData!['rating'][index]['name'].toString(),
                            fontSize: 11.0,
                            fontFamily: fontSemibold,
                            textColor: productData!['rating'][index]['id'] ==
                                        5 ||
                                    productData!['rating'][index]['id'] == 4
                                ? green
                                : productData!['rating'][index]['id'] == 3 ||
                                        productData!['rating'][index]['id'] == 2
                                    ? colorAccent
                                    : red,
                          ).expand(flex: 1),
                          // SizedBox(width: 10.0),
                          LinearPercentIndicator(
                            lineHeight: 4.0,
                            percent: productData!['rating'][index]
                                    ['ratingCount'] /
                                100,
                            linearStrokeCap: LinearStrokeCap.roundAll,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            progressColor: Colors.red,
                          ).expand(flex: 2),
                          const SizedBox(width: 10.0),
                          text(
                            productData!['rating'][index]['ratingCount']
                                .toString(),
                            fontSize: 14.0,
                            fontweight: FontWeight.w600,
                            fontFamily: fontSemibold,
                            textColor: Colors.grey,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // const Divider(height: 2),
          if (productData!['review'].length > 0) ...[
            Container(
              height: 150,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: ListView.builder(
                itemCount: productData!['review'].length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 18.0,
                          backgroundImage: NetworkImage(
                            productData!['review'][index]['profileImage'],
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  text(
                                    productData!['review'][index]['name'],
                                    fontFamily: fontMedium,
                                  ).expand(),
                                  Container(
                                    child: Row(
                                      children: [
                                        text(
                                          productData!['review'][index]
                                                  ['rating']
                                              .toString(),
                                          textColor: Colors.white,
                                          fontweight: FontWeight.w600,
                                          fontSize: 16.0,
                                        ),
                                        const SizedBox(width: 2.0),
                                        const Icon(
                                          Icons.star,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorPrimary,
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 1.0, horizontal: 10.0),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4.0),
                              text(
                                productData!['review'][index]['review'],
                                isLongText: true,
                                textColor: gray,
                                fontSize: 14.0,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Divider(height: 2),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  text(
                    'View All Reviews',
                    // textAllCaps: true,
                    textColor: colorAccent,
                    fontFamily: fontBold,
                    fontweight: FontWeight.w600,
                    fontSize: 14.0,
                  ),
                ],
              ).onTap(() {
                Get.toNamed('review-list', arguments: productData!['id']);
              }),
            )
          ],
        ],
      ),
    );
  }

  Widget _buildProductBuyCard(context, productData) {
    return Container(
      height: 80,
      padding: const EdgeInsets.only(right: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Container(
                  width: 35.sp,
                  height: 35.sp,
                  decoration: BoxDecoration(
                    color: const Color(0xFF658D28).withOpacity(0.1),
                    border: Border.all(
                      color: const Color(0xFF658D28).withOpacity(0.1),
                      width: 0.6,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF658D28).withOpacity(0.04),
                        blurRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: LikeButton(
                      size: 20, // slightly smaller so it fits nicely inside 35.sp
                      isLiked: productData!['wishList']['inWishList'],
                      onTap: (bool isLiked) async {
                        bool isStatus = false;
                        if (Auth.check()! || Auth.isGuestLoggedIn!) {
                          if (isLiked) {
                            await Api.http.delete(
                                'shopping/wishlist/delete/${productData!['id']}',
                                queryParameters: {
                                  "user_type": Auth.check()! ? 1 : 2,
                                }).then((response) {
                              if (response.data['status']) {
                                isStatus = response.data['status'];
                              } else {
                                GetBar(
                                  message: response.data['message'],
                                  duration: const Duration(seconds: 5),
                                  backgroundColor: Colors.red,
                                ).show();
                              }
                            }).catchError((err) {
                              GetBar(
                                message: err.response.data['message'],
                                duration: const Duration(seconds: 5),
                                backgroundColor: Colors.red,
                              ).show();
                            });
                          } else {
                            await Api.http.post('shopping/wishlist/store', data: {
                              "product_id": productData!['id'],
                              "user_type": Auth.check()! ? 1 : 2,
                            }).then((response) {
                              isStatus = response.data['status'];
                            }).catchError((err) {
                              if (err.response.statusCode == 401) {
                                Get.offNamed('/login-mlm');
                              } else {
                                AppUtils.showErrorSnackBar(
                                    err.response.data['message']);
                              }
                            });
                          }
                        } else {
                          // login logic (kept as-is)
                        }
                        return isStatus ? !isLiked : isLiked;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                text(fontSize: 12.sp,
                  'Wishlist',
                  fontFamily: fontLight,
                ),
              ],
            ),
          ).expand(flex: 4),

          // if (Auth.check()!)
          // Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 12),
          //   child: GestureDetector(
          //     onTap: () {
          //
          //     },
          //     child: Column(
          //       children: [
          //         Icon(
          //           UniconsLine.share_alt,
          //           size: 25,
          //           color: Colors.grey,
          //         ),
          //         SizedBox(height: 2.0),
          //         text(
          //           'Share',
          //           fontFamily: fontLight,
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          const SizedBox(
            width: 30.0,
          ),
          GestureDetector(
            onTap: () async {
              // AppUtils.showErrorSnackBar('E-commerce coming soon');
              if (Auth.check()! || Auth.isGuestLoggedIn!) {
                _debouncer.run(() async {
                  if (outOfStock == false) {
                    if (productVariationId != null) {
                      await Cart.instance.add(
                        context,
                        productVariationId.toString(),
                        Auth.check()! ? 1 : 2,
                        isBuyNow: true,
                      );
                    } else {
                      AppUtils.showErrorSnackBar('First select the variation');
                    }
                  }
                });
              } else {
                if (outOfStock == false) {
                  if (productVariationId != null) {
                    Get.bottomSheet(
                      StatefulBuilder(builder: (BuildContext context,
                          void Function(void Function()) setDialogState) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20.0),
                                topLeft: Radius.circular(20.0)),
                            color: white,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 18, vertical: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 12,
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Icon(
                                    UniconsLine.times_circle,
                                    color: Colors.grey,
                                  ).onTap(() {
                                    Get.back();
                                  }),
                                ),
                                20.height,
                                AppButton(
                                  shapeBorder: RoundedRectangleBorder(
                                      borderRadius: radius(10)),
                                  elevation: 30,
                                  width: double.infinity,
                                  color: const Color(0xff9afdcd),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 20,
                                  ),
                                  onTap: () {
                                    Get.back();
                                    showBottomSheet(context, product);
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(UniconsLine.user),
                                          10.width,
                                          Text(
                                            'Login as a guest',
                                            style: TextStyle(
                                              fontFamily: fontBold,
                                              color: black,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Icon(Icons.chevron_right_rounded),
                                    ],
                                  ),
                                ),
                                20.height,
                                AppButton(
                                  shapeBorder: RoundedRectangleBorder(
                                      borderRadius: radius(10)),
                                  elevation: 30,
                                  width: double.infinity,
                                  color: const Color(0xff6153d3),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 20),
                                  onTap: () {
                                    Get.back();
                                    AppUtils.redirect('login-mlm',
                                        callWhileBack: () {
                                      setState(() {});
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            UniconsLine.user_arrows,
                                            color: Colors.white,
                                          ),
                                          10.width,
                                          Text(
                                            'Login as a myky member',
                                            style: TextStyle(
                                              fontFamily: fontBold,
                                              color: white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                                20.height,
                              ],
                            ),
                          ),
                        );
                      }),
                    );
                  } else {
                    AppUtils.showErrorSnackBar('First select the variation');
                  }
                }
              }
            },
            child: Container(
              height: 50,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: outOfStock ? Colors.red : colorPrimary,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                outOfStock ? 'Out Of Stock' : 'Add to Cart',
                style: boldTextStyle(color: white_color),
              ),
            ),
          ).expand(flex: 6),
        ],
      ),
    );
  }

  void _addProductToCart(int userType) {
    Api.http.post('shopping/cart/add', data: {
      'product_price_id': productVariationId,
      'qty': 1,
      'user_type': userType
    }).then((response) {
      if (response.data['status']) {
        AppUtils.showSuccessSnackBar('Added to cart successfully');
        MLMCountCtl.to.operation(operationToPerform: "add");
        Future.delayed(const Duration(seconds: 1), () {
          AppUtils.redirect('/cart', callWhileBack: () {
            setState(() {});
          });
        });
      } else {
        AppUtils.showErrorSnackBar(response.data['message']);
      }
    });
  }

  _shareNetworkImage(String url, String? text) async {
    Directory tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/myky.jpeg';

    await Dio().download(url, path);
    Share.shareFiles([path],
        text: "Shop now on MYKY!\n $text\n\n"
            "Referral Code : ${Auth.user()!['code']}\n");

    return path;
  }
}
