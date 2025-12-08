import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:myky_clone/mlm/reports/reports.dart';
import 'package:myky_clone/utils/app_utils.dart';
import 'package:myky_clone/utils/en_extensions.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/auth.dart';
import '../../../services/size_config.dart';
import '../../services/api.dart';
import '../../widget/BottomNavigationBar.dart';
import '../../widget/file_download_controller.dart';
import '../../widget/theme.dart';
import '../app_drawer.dart';
import '../wallet/wallet.dart';
import 'components/day_wise_downline.dart';
import 'components/last_7_days_earning_graph.dart';
import 'components/myky_coins_widget.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    indexController.close();
    FileDownloadCtrl().dispose();
    super.dispose();
  }

  PageController pageController = PageController(initialPage: 0);
  StreamController<int> indexController = StreamController<int>.broadcast();

  late double width;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          indexController.add(index);
        },
        controller: pageController,
        children: [
          const MainDashboard(),
          Wallet(),
          Reports(),
        ],
      ),
      bottomNavigationBar: StreamBuilder<Object>(
        stream: indexController.stream,
        builder: (context, snapshot) {
          int? cIndex = snapshot.data as int?;
          return CurvedNavigationBar(
            currentIndex: cIndex,
            backgroundColor: app_background,
            color: Colors.white,
            initialIndex: 0,
            items: const <Widget>[
              Icon(UniconsLine.home),
              Icon(UniconsLine.wallet),
              Icon(UniconsLine.file),
            ],
            onTap: (int value) {
              indexController.add(value);
              pageController.jumpToPage(value);
            },
          );
        },
      ),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  _MainDashboardState createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late double width;
  late SharedPreferences preferences;

  late Future<Map> _future;

  bool themeSwitch = false, isShow = false;
  bool? vendorKycStatus;
  String? vendorKycMessage;

  late Map mlmDashboard;
  Map promotorStatusData = {};

  Uint8List? _bytesImage;

  String invoiceUrl = '';
  String idCard = '';

  // DownloadCtrl downloadCtrl = DownloadCtrl();

  Future<Map> getDashboard() {
    return Api.http.get("member/dashboard").then((response) {
      setState(() {
        mlmDashboard = response.data;
        Auth.setVendor(isVendor: mlmDashboard['member']['isVendor']);
        Auth.setMemberId(memberId: mlmDashboard['member']['MemberId']);
        if (mlmDashboard['member']['isVendorLastPendingOrder'] != null &&
            mlmDashboard['member']['isVendorLastPendingOrder'] == true) {
          showAmountPopup(context, mlmDashboard['member']);
        }
        _bytesImage = const Base64Decoder()
            .convert(mlmDashboard['member']['qrCodeImage']);
      });
      return response.data;
    });
  }

  Future<Map> getPromotorStatus() {
    return Api.http.get("member/promotor-request/show").then((response) {
      setState(() {
        promotorStatusData = response.data;
        if (promotorStatusData['promotorStatus']['id'] == 2) {
          callInvoiceApi();
        }
      });
      return response.data;
    });
  }

  callInvoiceApi() async {
    await Api.http
        .get(
            "member/promotor-request/promotor-invoice/${promotorStatusData['id']}")
        .then((response) {
      invoiceUrl = response.data['url'] ?? "";
    });
  }

  callIdCard() async {
    await Api.http.get("member/promotor-request/id-card").then((response) {
      setState(() {
        idCard = response.data['url'] ?? "";
        print('IdCard : $idCard');
      });
    });
  }

  void kycDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
          ),
          title: text(
            "${vendorKycMessage}",
            isLongText: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  isShow = true;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future scanQR() async {
    dynamic barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', false, ScanMode.QR);

      if (barcodeScanRes != '-1') {
        if (isJson(barcodeScanRes) == true) {
          Get.toNamed('/qr-view', arguments: barcodeScanRes);
        } else {
          if (barcodeScanRes.isNotEmpty &&
              barcodeScanRes.contains('https://myky-')) {
            launchUrl(Uri.parse(barcodeScanRes));
          } else {
            AppUtils.showErrorSnackBar('Not a valid MYKY QR');
          }
        }
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
  }

  @override
  void initState() {
    _future = getDashboard();
    getPromotorStatus();
    // callIdCard();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: SafeArea(
        child: AppDrawer(),
      ),
      appBar: AppBar(
        elevation: 2.0,
        title: GestureDetector(
          onTap: () {
            setState(() {
              _future = getDashboard();
            });
          },
          child: const Text('Dashboard'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          IconButton(
            icon: Image.asset('assets/images/location_new.png'),
            onPressed: () {
              Get.toNamed('/near-me-store');
            },
          ),
          // IconButton(
          //   icon: const Icon(Icons.power_settings_new_outlined),
          //   onPressed: () {
          //     Get.dialog(Dialog(
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(24),
          //       ),
          //       insetPadding: const EdgeInsets.all(25),
          //       clipBehavior: Clip.antiAliasWithSaveLayer,
          //       child: Material(
          //         child: Container(
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             shape: BoxShape.rectangle,
          //             borderRadius: BorderRadius.circular(16),
          //             boxShadow: const [
          //               BoxShadow(
          //                 color: Colors.black26,
          //                 blurRadius: 10.0,
          //                 offset: Offset(0.0, 10.0),
          //               ),
          //             ],
          //           ),
          //           width: MediaQuery.of(context).size.width,
          //           child: Column(
          //             mainAxisSize:
          //                 MainAxisSize.min, // To make the card compact
          //             children: <Widget>[
          //               const SizedBox(height: 24),
          //               Container(
          //                 width: 45,
          //                 height: 45,
          //                 decoration: const BoxDecoration(
          //                     shape: BoxShape.circle, color: green),
          //                 child: const Icon(
          //                   Icons.power_settings_new_rounded,
          //                   color: Colors.white,
          //                 ),
          //               ),
          //               const SizedBox(height: 24),
          //               text(
          //                 'Are you sure you want to logout ?',
          //                 textColor: textColorPrimary,
          //                 fontFamily: fontBold,
          //                 fontSize: textSizeLargeMedium,
          //                 isCentered: true,
          //                 isLongText: true,
          //               ),
          //               Row(
          //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
          //                 children: [
          //                   TextButton(
          //                     onPressed: () => Navigator.pop(context),
          //                     child: text(
          //                       'No',
          //                       fontSize: textSizeLargeMedium,
          //                       fontFamily: fontBold,
          //                       textColor: green,
          //                     ),
          //                   ),
          //                   TextButton(
          //                     onPressed: () => logoutUser(),
          //                     child: text(
          //                       'Yes',
          //                       fontSize: textSizeLargeMedium,
          //                       fontFamily: fontBold,
          //                       textColor: red,
          //                     ),
          //                   ),
          //                 ],
          //               )
          //             ],
          //           ),
          //         ),
          //       ),
          //     ));
          //     // showDialog(
          //     //   context: context,
          //     //   builder: (BuildContext context) => logoutBox(context),
          //     // );
          //   },
          // ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState!.openEndDrawer();
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot? snapshot) {
          if (!snapshot!.hasData) {
            return const Center();
          }
          Map dashboardDetail = snapshot.data;
          List bankDetail = snapshot.data['bankDetails'];
          List vendorShopImages = dashboardDetail['member']['vendorShopImage'];

          return Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.topCenter,
                height: width,
                color: Colors.black,
                child: Container(
                  alignment: Alignment.center,
                  height: 150,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/myky_header_img.jpeg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    40.heightBox,
                    Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.only(top: 100),
                          padding: const EdgeInsets.only(top: 60),
                          alignment: Alignment.topCenter,
                          decoration: const BoxDecoration(
                            color: app_background,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              // CustomButton(
                              //     textContent: 'Near By Offline Store',
                              //     onPressed: () {
                              //       Get.toNamed('/nearby-offline-store');
                              //     }).paddingSymmetric(horizontal: 10),
                              _memberInfo(context, dashboardDetail),

                              8.heightBox,

                              GestureDetector(
                                onTap: () {
                                  HapticFeedback
                                      .heavyImpact(); // Adds haptic feedback
                                  Get.toNamed('/nearby-offline-store');
                                  // if (kDebugMode) {
                                  //   showAmountPopup(context);
                                  // }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Colors.deepPurpleAccent,
                                        Colors.pinkAccent,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        offset: Offset(4, 4),
                                        blurRadius: 10,
                                      ),
                                      BoxShadow(
                                        color: Colors.white10,
                                        offset: Offset(-4, -4),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 30),
                                    child: Center(
                                      child: Text(
                                        "Nearby offline store",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ).paddingSymmetric(horizontal: 10),
                              8.heightBox,
                              if (dashboardDetail['offlineOrderResumeStatus'] !=
                                      null &&
                                  dashboardDetail[
                                      'offlineOrderResumeStatus']) ...[
                                8.heightBox,
                                CustomButton(
                                    textContent: 'Complete your payment',
                                    onPressed: () {
                                      Get.toNamed('/off-line-orders')!
                                          .then((value) {
                                        _future = getDashboard();
                                      });
                                    }).paddingSymmetric(horizontal: 10),
                              ],
                              8.heightBox,
                              _qrCodeScan(context, dashboardDetail),

                              // if (dashboardDetail['member']['isPromotor'] ==
                              //         true &&
                              //     dashboardDetail['member']['memberStatus'] ==
                              //         "Active") ...[
                              //   16.heightBox,
                              //   CustomButton(
                              //       textContent: 'Create Vendor',
                              //       customColor: Colors.deepPurpleAccent,
                              //       onPressed: () {
                              //         Get.toNamed('/register-vendor')!
                              //             .then((value) {
                              //           _future = getDashboard();
                              //         });
                              //       }).paddingSymmetric(horizontal: 10),
                              // ],
                              8.heightBox,

                              if (vendorShopImages.isNotEmpty) ...[
                                10.heightBox,
                                Container(
                                  height: 150.h,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: vendorShopImages.length,
                                    padding: EdgeInsets.only(left: 15.w),
                                    itemBuilder: (context, i) {
                                      return Container(
                                        margin: EdgeInsets.only(right: 12.w),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                          child: Image.network(
                                            vendorShopImages[i]['fileName'],
                                            fit: BoxFit.contain,
                                            width: 230.w,
                                            height: 150.h,
                                          ),
                                        ),
                                      ).onTap(() {
                                        Get.toNamed(
                                          'image-preview',
                                          arguments: vendorShopImages[i]
                                              ['fileName'],
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ],
                              8.heightBox,
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: MykyCoinsWidget(
                                  coinBalance:
                                      dashboardDetail['coinWalletBalance']
                                          .toString(),
                                  onTap: () {
                                    Get.toNamed('/coin-wallet');
                                  },
                                ),
                              ),
                              5.heightBox,
                              _memberAbout(context, dashboardDetail),
                              _blockArea(context, dashboardDetail),
                              16.heightBox,
                              _referralLink(context, dashboardDetail),

                              if (bankDetail.length > 0) ...[
                                16.heightBox,
                                _buildBankDetail(context, bankDetail),
                              ],
                              16.heightBox,
                              // _dayWiseEarning(),
                              16.heightBox,
                              // _dayWiseDownLine(),
                              // SizedBox(height: 30),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 50,
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                              dashboardDetail['member']['profileImageUrl'],
                            ),
                            radius: 45,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _memberAbout(BuildContext context, Map dashboardDetail) {
    return Container(
      margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
      decoration: boxDecoration(
        radius: 10,
        showShadow: true,
      ),
      child: Column(
        children: <Widget>[
          ExpansionTile(
            title: text(
              "Member Info",
              fontFamily: fontSemibold,
              fontSize: textSizeLargeMedium,
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 5.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    rowHeading(
                      'Full Name : ',
                      dashboardDetail['member']['name'],
                    ),
                    const SizedBox(height: 10.0),
                    rowHeading(
                      'Mobile : ',
                      dashboardDetail['member']['mobile'],
                    ),
                    const SizedBox(height: 10.0),
                    rowHeading(
                      'Whatsapp Number : ',
                      dashboardDetail['member']['whatsappNo'] != null
                          ? dashboardDetail['member']['whatsappNo']
                          : "--",
                    ),
                    const SizedBox(height: 10.0),
                    rowHeading(
                      'Email : ',
                      dashboardDetail['member']['email'] != null
                          ? dashboardDetail['member']['email']
                          : "--",
                    ),
                    const SizedBox(height: 10.0),
                    rowHeading(
                      'Account Status : ',
                      dashboardDetail['member']['memberStatus'],
                    ),
                    const SizedBox(height: 10.0),
                    rowHeading(
                      'KYC Status : ',
                      dashboardDetail['member']['kycStatus'],
                    ),
                    if (Auth.isVendor() == true) ...[
                      const SizedBox(height: 10.0),
                      rowHeading(
                        'Shop Name : ',
                        dashboardDetail['member']['shopName'] != null
                            ? dashboardDetail['member']['shopName']
                            : "--",
                      ),
                      const SizedBox(height: 10.0),
                      rowHeading(
                        'Category Name : ',
                        dashboardDetail['member']['category'] != null &&
                                dashboardDetail['member']['category'] != ""
                            ? dashboardDetail['member']['category']
                            : "--",
                      ),
                      const SizedBox(height: 10.0),
                      rowHeading(
                        'Sub-Category Name : ',
                        dashboardDetail['member']['subCategory'] != null &&
                                dashboardDetail['member']['subCategory'] != ""
                            ? dashboardDetail['member']['subCategory']
                            : "--",
                      ),
                    ],
                    const SizedBox(height: 10.0),
                    rowHeading(
                      'Registration Date : ',
                      dashboardDetail['member']['regDate'],
                    ),
                    const SizedBox(height: 10.0),
                    rowHeading(
                      'Activation Date : ',
                      dashboardDetail['member']['actDate'] ?? "--",
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _memberInfo(BuildContext context, Map dashboardDetail) {
    return Column(
      children: [
        text(
          dashboardDetail['member']['name'],
          textColor: textColorPrimary,
          fontFamily: fontMedium,
          fontSize: textSizeNormal,
        ),
        text(
          dashboardDetail['member']['code'],
          fontSize: textSizeLargeMedium,
        ),
      ],
    );
  }

  Widget _buildBankDetail(BuildContext context, List bank) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 16),
              child: text(
                'Banking Partners',
                fontSize: textSizeLargeMedium,
                fontFamily: fontBold,
                textColor: textColorPrimary,
              ),
            ),
            GestureDetector(
              child: text('View All').marginOnly(right: 16),
              onTap: () {
                Get.toNamed('/banking-partner');
              },
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          height: h(10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: bank.length <= 5 ? bank.length : 5,
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                width: w(80),
                decoration: boxDecoration(
                  showShadow: true,
                  bgColor: Colors.white,
                  radius: 10.0,
                ),
                margin: EdgeInsets.only(
                  left: index == 0 ? 15 : 7.5,
                  right: (bank.length) - 1 == index ? 15 : 7.5,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.domain,
                                        color: colorPrimary,
                                        size: textSizeXLarge,
                                      ),
                                      SizedBox(width: w(2)),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            text(
                                              bank[index]['name'],
                                              fontFamily: fontBold,
                                              isLongText: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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
            },
          ),
        ),
      ],
    );
  }

  Widget _blockArea(BuildContext context, Map dashboardDetail) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed('/off-line-orders');
                  },
                  child: _buildBlocks(
                    "Total month purchase done / Total month purchase required",
                    Colors.indigo.withOpacity(1.0),
                    "${dashboardDetail['member']['currentMonthPurchase']} / ${dashboardDetail['member']['purchaseRequire']}",
                    icon: UniconsLine.wallet,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed('/wallet');
                  },
                  child: _buildBlocks(
                    "Wallet Rewards",
                    Colors.amber.withOpacity(1.0),
                    dashboardDetail['walletBalance'].toString(),
                    icon: UniconsLine.wallet,
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _goToIncomeTab(argument: 'myDirects');
                  },
                  child: _buildBlocks(
                    "My\nFriends",
                    Colors.deepOrange.withOpacity(1.0),
                    dashboardDetail['myDirects'].toString(),
                    icon: UniconsLine.arrows_merge,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: <Widget>[
              if (dashboardDetail['member']['isPromotor'] == false)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (dashboardDetail['pendingWalletBalance']
                              .toString()
                              .toInt() >
                          0) {
                        AppUtils.showErrorSnackBar(
                            'To receive this wallet amount, please upgrade to Promoter');
                      }
                    },
                    child: _buildBlocks(
                      "Pending\nWallet Balance",
                      Colors.indigo.withOpacity(1.0),
                      dashboardDetail['pendingWalletBalance'].toString(),
                      icon: UniconsLine.wallet,
                    ),
                  ),
                ),
              if (Auth.user()!['code'] == "100001") ...[
                const SizedBox(width: 16.0),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _goToIncomeTab(argument: 'myDownLine');
                    },
                    child: _buildBlocks(
                      "My\nPatrons",
                      Colors.pink.withOpacity(1.0),
                      dashboardDetail['myDownLine'].toString(),
                      icon: UniconsLine.trees,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed('/orders');
                  },
                  child: _buildBlocks(
                    "Total\nOrders",
                    Colors.indigoAccent.withOpacity(1.0),
                    dashboardDetail['totalOrders'].toString(),
                    icon: UniconsLine.shopping_cart,
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed('/payout');
                  },
                  child: _buildBlocks(
                    "Total\nPayout",
                    Colors.cyan.withOpacity(1.0),
                    dashboardDetail['totalPayout'].toString(),
                    icon: UniconsLine.coins,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed('/wallet');
                  },
                  child: _buildBlocks(
                    "Total \nRewards",
                    Colors.pink.withOpacity(1.0),
                    dashboardDetail['totalEarning'].toString(),
                    icon: UniconsLine.coins,
                  ),
                ),
              ),
            ],
          ),
          if (Auth.isVendor() == true) ...[
            const SizedBox(height: 16.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed('/vendor-wallet-transaction');
                    },
                    child: _buildBlocks(
                      "Vendor Wallet",
                      Colors.indigoAccent.withOpacity(1.0),
                      dashboardDetail['vendorWallet'].toString(),
                      icon: UniconsLine.shopping_cart,
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _goToIncomeTab(argument: 'sales');
                    },
                    child: _buildBlocks(
                      "Vendor Total Sale",
                      Colors.cyan.withOpacity(1.0),
                      dashboardDetail['vendorTotalSales'].toString(),
                      icon: UniconsLine.coins,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
          ]
        ],
      ),
    );
  }

  Widget _buildBlocks(String label, Color color, dynamic count,
      {IconData? icon, bool isIcon = true}) {
    return Container(
      height: 118.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.6),
          width: 3.w,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Count/Value
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A202C),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6.h),
            // Label with icon
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF718096),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (icon != null)
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Icon(
                      icon,
                      size: 16.sp,
                      color: color,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void logoutUser() async {
    await Auth.logout();

    Get.offAllNamed('/login-mlm');
  }

  void _goToIncomeTab({String? argument}) {
    Get.toNamed('/reports', arguments: argument)!.then((value) {
      setState(() {
        // _futureBuild();
      });
    });
  }

  Widget _referralLink(BuildContext context, Map dashboardDetail) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: boxDecoration(radius: 10, showShadow: true),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            text(
              'Your Referral Link',
              fontSize: textSizeLargeMedium,
              fontFamily: fontBold,
              textColor: textColorPrimary,
            ),
            10.heightBox,
            TextField(
              readOnly: true,
              onChanged: (String value) {},
              cursorColor: Colors.deepOrange,
              decoration: InputDecoration(
                hintText: dashboardDetail['refLink'],
                hintStyle: TextStyle(fontSize: 14.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 13,
                ),
                suffixIcon: Row(
                  children: [
                    15.widthBox,
                    Text(
                      dashboardDetail['refLink'].toString(),
                      // "https://www.google.co.in/",
                      style: TextStyle(
                        color: colorPrimary,
                        fontSize: 15.sp,
                        fontFamily: fontMedium,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ).expand(flex: 75),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.content_copy,
                          size: 20.sp,
                          color: colorPrimary,
                        ).onTap(
                          () {
                            Clipboard.setData(
                              ClipboardData(text: dashboardDetail['refLink']),
                            );
                            GetBar(
                              duration: const Duration(seconds: 5),
                              message: 'Referral Link copied to clipboard',
                              backgroundColor: colorPrimary,
                            ).show();
                          },
                        ),
                        15.widthBox,
                        Icon(
                          UniconsLine.share_alt,
                          size: 20.sp,
                          color: colorAccent,
                        ).onTap(() {
                          _shareLinkWIthImage(
                              // "https://stage.myky.co.in/storage/65/5.jpg",
                              // "Refer & Save with Myky! 🌟Invite your friends to Myky and both of you win!When your friend makes their first purchase, they get 50% off, and as a thank-you, you'll also receive 50% off on your next order.\n 🎉Start referring and enjoy amazing savings! 🚀\nLet me know if you need any modifications!",
                              dashboardDetail['referralImage'],
                              dashboardDetail['referralDescription'],
                              dashboardDetail['refLink']);
                          // String link = dashboardDetail['refLink'];
                          // if (link.isNotEmpty) {
                          //   Share.share(dashboardDetail['refLink']);
                          // }
                          // Share.share(UserInfoWidgets.userData['webReferralLink']);
                        }),
                        15.widthBox,
                      ],
                    ).expand(flex: 25),
                  ],
                ),
                // Row(
                //   mainAxisSize: MainAxisSize.min,
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     ElevatedButton.icon(
                //       onPressed: () {
                //         Clipboard.setData(
                //           ClipboardData(text: dashboardDetail['refLink']),
                //         );
                //         GetBar(
                //           duration: Duration(seconds: 5),
                //           message: 'Referral Link copied to clipboard',
                //           backgroundColor: colorPrimary,
                //         ).show();
                //       },
                //       icon: Icon(
                //         Icons.content_copy,
                //         size: 18,
                //         color: Colors.white,
                //       ),
                //       label: Text('COPY', style: TextStyle(color: Colors.white)),
                //       style: ElevatedButton.styleFrom(
                //         primary: colorPrimary,
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.only(
                //             topRight: Radius.circular(10),
                //             bottomRight: Radius.circular(10),
                //           ),
                //           side: BorderSide(
                //             color: colorPrimary,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qrCodeScan(BuildContext context, Map dashboardDetail) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (dashboardDetail['member']['qrCodeImage'] != null &&
            dashboardDetail['member']['qrCodeImage'] != "")
          Expanded(
            child: Container(
              decoration: boxDecoration(radius: 10, showShadow: true),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    IconButton(
                      iconSize: 35,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.memory(
                                  _bytesImage!,
                                  height: 300,
                                  width: 300,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: text(
                                        'Close',
                                        fontSize: 18.0,
                                      ),
                                    ),
                                    if (dashboardDetail['qrCodeUrl'] != "")
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () {
                                            FileDownloadCtrl().download(
                                              dashboardDetail['qrCodeUrl']!,
                                              context,
                                            );
                                          },
                                          child: text(
                                            'Download',
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        UniconsLine.qrcode_scan,
                      ),
                    ),
                    text(
                      "View QR Code",
                      fontSize: 12.0,
                      fontweight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ),
          ),
        10.widthBox,
        Expanded(
            child: Container(
          decoration: boxDecoration(radius: 10, showShadow: true),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  iconSize: 35,
                  onPressed: () {
                    scanQR();
                  },
                  icon: const Icon(
                    UniconsLine.qrcode_scan,
                  ),
                ),
                FittedBox(
                  child: text(
                    "Scan Only MYKY QR Code",
                    fontSize: 12.0,
                    fontweight: FontWeight.w600,
                    textColor: redColor,
                    maxLine: 1,
                    isCentered: true,
                    isLongText: true,
                  ),
                ),
              ],
            ),
          ),
        )
            //     .onTap(() {
            //   Get.toNamed(
            //     '/qr-view',
            //     arguments: json.encode(
            //       {"id": 1, "code": "100001", "name": "Vendor First Nk"},
            //     ),
            //   );
            // }),
            ),
      ],
    ).marginSymmetric(horizontal: 10.w);
  }

  // _dayWiseEarning() {
  //   return DayWiseEarningGraph(
  //     title: 'Last 7 Days Rewards Graph',
  //     dayWiseEarning: mlmDashboard['dayWiseEarnings'],
  //   );
  // }

  // _dayWiseDownLine() {
  //   return DayWiseDownLineGraph(
  //     title: 'Last 7 Days Patron Members',
  //     dayWiseDownLine: mlmDashboard['dayWiseDownline'],
  //   );
  // }

  // Method to check if the string is a JSON
  static bool isJson(String str) {
    try {
      json.decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  _shareLinkWIthImage(String url, String? text, String? link) async {
    Directory tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/promotion.jpeg';

    await Dio().download(url, path);
    Share.shareFiles([path],
        text: "$text\n\n"
            "$link\n");

    return path;
  }

  void showAmountPopup(BuildContext context, data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            clipBehavior:
                Clip.none, // Allows close button to be outside the dialog
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Payment Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Total Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Amount:",
                            style: TextStyle(fontSize: 16)),
                        Text(data['vendorTotalOrderAmount'].toString(),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(),

                    // Discount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Discount:", style: TextStyle(fontSize: 16)),
                        Text(data['vendortotalDiscount'].toString(),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                      ],
                    ),
                    const Divider(),

                    // Vendor Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Vendor Amount:",
                            style: TextStyle(fontSize: 16)),
                        Text(
                          data['vendortotalAmount'].toString(),
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Close Button Positioned at Top Right Outside the Box
              Positioned(
                top: -10,
                right: -10,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorPrimary,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
