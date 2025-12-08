import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:myky_clone/utils/en_extensions.dart';
import 'package:nb_utils/nb_utils.dart' hide log, white;
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/CountCtl.dart';
import '../../../services/auth.dart';
import '../../../widget/customWidget.dart';
import '../../../widget/product_widget.dart';
import '../../services/api.dart';
import '../../services/cart_service.dart';
import '../../services/dynamic_link.dart';
import '../../services/extension.dart';
import '../../services/size_config.dart';
import '../../services/storage.dart';
import '../../utils/app_utils.dart';
import '../../widget/guest_login_service.dart';
import '../../widget/theme.dart';
import '../services/announcement_service.dart';
import '../widget/network_image.dart';
import '../widget/shiny_title.dart';
import 'account/my_account.dart';
import 'category/category.dart';
import 'filter/filter_page.dart';
import 'order/my_orders.dart';
import 'recharge/recharge_page.dart';

class HomeECommerce extends StatefulWidget {
  @override
  _HomeECommerceState createState() => _HomeECommerceState();
}

class _HomeECommerceState extends State<HomeECommerce> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PageController? _pageController;
  final BottomSheetService bottomSheetService = BottomSheetService();

  // ScrollController for FAB animation
  final ScrollController _scrollController = ScrollController();
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _widgetOptions = [
      Ecommerce(
        switchTabCallback: (taskBlockIndex) {
          _onItemTapped(taskBlockIndex!);
        },
        scrollController: _scrollController, // Pass scroll controller
      ),
      Category(),
      MyOrders(),
      const Recharge(),
      const MyAccount(),
    ];
    _pageController = PageController(initialPage: _selectedIndex);

    // Listen to scroll events
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final scrollDirection = _scrollController.position.userScrollDirection;

      if (scrollDirection == ScrollDirection.forward) {
        // Scrolling up - expand FAB
        if (!_isExpanded) {
          setState(() {
            _isExpanded = true;
          });
        }
      } else if (scrollDirection == ScrollDirection.reverse) {
        // Scrolling down - shrink FAB
        if (_isExpanded) {
          setState(() {
            _isExpanded = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void showBottomSheet(BuildContext context, index) {
    bottomSheetService.showBottomSheet(context).then((value) {
      if (value != null && value) {
        setState(() {
          Cart.instance.fetchCartList();
          _selectedIndex = 0;
        });
      }
    });
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
                // SizedBox(height: 15),
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

  int _selectedIndex = 0;
  List<Widget> tabPages = [];

  static List<Widget> _widgetOptions = <Widget>[];

  void _onItemTapped(int index) {
    if (index == 2) {
      onSelectBehaviour(index);
    } else if (index == 3 && !Auth.check()!) {
      AppUtils.redirect('/login-mlm', callWhileBack: () {
        Get.offAllNamed('ecommerce');
      });
    } else if (index == 4) {
      onSelectBehaviour(index);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Method to check if the string is a JSON
  static bool isJson(String str) {
    try {
      json.decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  // QR scanning method (same as dashboard.dart)
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

  void onSelectBehaviour(int index) {
    if (Auth.check()! || Auth.isGuestLoggedIn!) {
      setState(() {
        _selectedIndex = index;
      });
    } else {
      Get.bottomSheet(
        StatefulBuilder(builder: (BuildContext context,
            void Function(void Function()) setDialogState) {
          return Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20.0),
                  topLeft: Radius.circular(20.0)),
              color: white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 12,
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: const Icon(
                      UniconsLine.times_circle,
                      color: Colors.grey,
                    ).onTap(() {
                      Get.back();
                    }),
                  ),
                  20.height,
                  AppButton(
                    shapeBorder:
                        RoundedRectangleBorder(borderRadius: radius(10)),
                    elevation: 30,
                    width: double.infinity,
                    color: const Color(0xff9afdcd),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                    onTap: () {
                      Get.back();
                      showBottomSheet(context, index);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(UniconsLine.user),
                            10.width,
                            const Text(
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
                    shapeBorder:
                        RoundedRectangleBorder(borderRadius: radius(10)),
                    elevation: 30,
                    width: double.infinity,
                    color: const Color(0xff6153d3),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    onTap: () {
                      Get.back();
                      AppUtils.redirect(
                        'login-mlm',
                        callWhileBackWithValue: (value) {
                          setState(() {
                            Cart.instance.fetchCartList();

                            _selectedIndex = 0;
                          });
                        },
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              UniconsLine.user_arrows,
                              color: Colors.white,
                            ),
                            10.width,
                            const Text(
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // final bool shouldShowExitDialog = Get.arguments != null && Get.arguments == true;
        final bool shouldShowExitDialog= Auth.isMLMLoggedIn == false && Auth.isGuestLoggedIn == true ? true : false;
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }

        if (shouldShowExitDialog) {
          return await _onWillPop(); // assuming this returns bool (true = exit, false = stay)
        } else {
          return true;
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xffF8FAFC),
        body: tabPages.isEmpty
            ? _widgetOptions.elementAt(_selectedIndex)
            : tabPages.elementAt(_selectedIndex),
        floatingActionButton: _selectedIndex == 0 && Auth.check()!
            ? Container(
                margin: const EdgeInsets.only(bottom: 5),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _isExpanded
                      ? FloatingActionButton.extended(
                          onPressed: () {
                            scanQR();
                          },
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          elevation: 12.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          icon: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              UniconsLine.qrcode_scan,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          label: const Text(
                            'Scan & Pay',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        )
                      : FloatingActionButton(
                          onPressed: () {
                            scanQR();
                          },
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          elevation: 12.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              UniconsLine.qrcode_scan,
                              size: 22,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildTabItem(
                  index: 0,
                  iconImage: UniconsLine.home,
                  label: 'Home',
                  image: 'assets/images/home_tab_logo.png',
                ),
                buildTabItem(
                  index: 1,
                  iconImage: 'assets/images/tab/menu.png',
                  selectedIconImage: 'assets/images/tab/menu_solid.png',
                  label: 'Category',
                ),
                buildTabItem(
                  index: 2,
                  iconImage: 'assets/images/tab/cart.png',
                  selectedIconImage: 'assets/images/tab/cart_solid.png',
                  label: 'Orders',
                ),
                buildTabItem(
                  index: 3,
                  iconImage: 'assets/images/tab/wallet.png',
                  selectedIconImage: 'assets/images/tab/wallet_solid.png',
                  label: 'Recharge',
                ),
                buildTabItem(
                  index: 4,
                  iconImage: 'assets/images/tab/user.png',
                  selectedIconImage: 'assets/images/tab/user_solid.png',
                  label: 'Account',
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTabItem({index, iconImage, label, image, selectedIconImage}) {
    bool isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () {
        _onItemTapped(index);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6366F1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: (image == null)
                  ? Container(
                      height: 24,
                      width: 24,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              isSelected ? selectedIconImage : iconImage),
                          colorFilter: ColorFilter.mode(
                            isSelected ? Colors.white : Colors.grey.shade600,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      height: 24,
                      width: 24,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(image),
                          colorFilter: ColorFilter.mode(
                            isSelected ? Colors.white : Colors.grey.shade600,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: isSelected ? 12 : 10,
                fontFamily: isSelected ? fontBold : fontMedium,
                color:
                    isSelected ? const Color(0xFF6366F1) : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                overflow: TextOverflow.ellipsis,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class Ecommerce extends StatefulWidget {
  final Function(
    int? taskBlockIndex,
  )? switchTabCallback;
  final ScrollController? scrollController;

  Ecommerce({Key? key, this.switchTabCallback, this.scrollController})
      : super(key: key);

  @override
  _EcommerceState createState() => _EcommerceState();
}

class _EcommerceState extends State<Ecommerce> {
  String? referralLink;

  String? referralMessage;

  _EcommerceState() {
    Get.lazyPut(() => MLMCountCtl(cartCount), fenix: true);
  }

  ValueNotifier<Map?> _notifier = ValueNotifier(null);
  SharedPreferences? preferences;
  List categories = [
    // {
    //   "id": 0,
    //   "name": "Category",
    //   "prefix": "",
    //   "url": "",
    //   "subCategory": [],
    // }
  ];
  List categoryData = [];

  List? advertisement = [];
  List? priceStore = [];
  List? bestSeller = [];
  List? trendingNow = [];
  List bestSellersId = [];
  List? webSitePopUps = [];
  Map? filterData;
  late Map dashboardDetails;
  GlobalKey<_HomeECommerceState> homeKey = GlobalKey();
  Image? imageLogo;

  // Widget? productWidget;

  late Future _future;
  ScrollController? controller;
  bool? isAfterPurchase;

  List<Widget> mainWidgetList = [];

  Future<Map> getDashboard(bool? isOnDashboard) {
    return Api.http.get("shopping/dashboard").then((response) async {
      setState(() {
        response.data['list']['bestSeller'].map((seller) {
          bestSellersId.add(seller['id']);
        }).toList();
        webSitePopUps = response.data['list']['websitePopups'];
        Auth.setVendor(isVendor: response.data['isVendor']);
        Auth.setAudioSetting(
          audio: (response.data['isAudio'] != null &&
                  response.data['isAudio'] != '')
              ? response.data['isAudio']
              : 1,
        );
        cartCount = response.data['list']['cartCount'] != null
            ? response.data['list']['cartCount']
            : 0;
      });
      AppUtils.videoSize = response.data['videoSize'];
      referralMessage = response.data['referralMsg'];
      isAfterPurchase = await Storage.get('isAfterPurchase');
      checkForDynamicLinkArguments();
      if (isOnDashboard! && mounted)
        AnnouncementService.instance
            .checkForAnnouncementPopUp(context, webSitePopUps!);
      if (isAfterPurchase != null &&
          isAfterPurchase == true &&
          Auth.isGuestLoggedIn! &&
          Auth.userGuest()!['sponsorCode'] != null) {
        String sendData = jsonEncode({
          "type": "register",
          "data": {
            "referralCode": Auth.userGuest()!['sponsorCode'] != null
                ? Auth.userGuest()!['sponsorCode']
                : "",
          },
        });
        await DynamicLink.createDynamicLink(
                type: "register", itemData: sendData, route: 'register-mlm')
            .then((shortLink) async {
          referralLink = shortLink.toString();
        });
        await Storage.delete('isAfterPurchase');

        if (Get.isDialogOpen! == false)
          await afterPurchasePopup(referralLink, referralMessage);
      }

      return response.data;
    });
  }

  @override
  void didChangeDependencies() {
    precacheImage(imageLogo!.image, context);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    imageLogo = Image.asset(
      "assets/images/home_ecom_header_logo-min.png",
      width: w(25),
      gaplessPlayback: true,
      color: Colors.white,
    );

    Cart.instance.fetchCartList();
    _future = getDashboard(true);
    super.initState();
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, AsyncSnapshot? snapshot) {
        if (!snapshot!.hasData) {
          return const Center();
        }
        dashboardDetails = snapshot.data['list'];
        categoryData = snapshot.data['list']['categories'];
        if (categories.length == 0)
          categories.insertAll(0, snapshot.data['list']['categories']);

        advertisement = snapshot.data['list']['advertisementBanner'];
        priceStore = snapshot.data['list']['priceStore'];
        bestSeller = snapshot.data['list']['bestSeller'];
        trendingNow = snapshot.data['list']['trendingNow'];

        categories.map((category) {
          if (category['id'] == 0) {
            category['url'] = dashboardDetails['categoryImage'];
          }
          return category;
        }).toList();

        mainWidgetList = [
          SliverFixedExtentList(
            itemExtent: 140.0,
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return topBarWidget();
              },
              childCount: 1,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                buildAdvertisement(context),
                const SizedBox(height: 20),
                categoryList(),
              ],
            ),
          ),
          if (bestSeller!.length > 0)
            SliverToBoxAdapter(
              child: buildBestSeller(context),
            ),
          if (trendingNow!.length > 0)
            SliverToBoxAdapter(
              child: buildTrendingNow(context),
            ),
          if (priceStore!.length > 0)
            SliverToBoxAdapter(
              child: buildPrice(context),
            ),
          // SliverAppBar(
          //   automaticallyImplyLeading: false,
          //   backgroundColor: const Color(0xffF5F8FA),
          //   flexibleSpace: FilterPage(filterData: (data) {
          //     setState(() {
          //       filterData = data;
          //     });
          //   }),
          //   pinned: true,
          // ),
          // SliverToBoxAdapter(
          //   child: SizedBox(
          //     height: MediaQuery.of(context).size.height * 0.8,
          //     child: ProductWidget(
          //       isFilter: false,
          //       productFilters: filterData,
          //     ),
          //   ),
          // ),
        ];

        return SafeArea(
          child: CustomScrollView(
            controller: widget.scrollController,
            slivers: mainWidgetList,
            shrinkWrap: true,
          ),
        );
      },
    );
  }

  Widget topBarWidget() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 10.sp),
              child: Row(
                children: [
                  if(Auth.isGuestLoggedIn == true && Auth.isMLMLoggedIn == true)
                 ...[ Icon(
                    Icons.arrow_back,
                    size: 22.sp,
                  ).onTap(() {
                    Get.back();
                  }),
                  10.widthBox,],
                  Text(
                    'Shop',
                    style: TextStyle(
                      fontFamily: fontSemibold,
                      fontSize: 18.sp,
                      height: 1.0.h,
                    ),
                  ),

                  // Logo
                  // GestureDetector(
                  //   onTap: () async {
                  //     setState(() {
                  //       _future = getDashboard(false);
                  //     });
                  //   },
                  //   child: Container(
                  //     padding: const EdgeInsets.all(4),
                  //     decoration: BoxDecoration(
                  //       gradient: LinearGradient(
                  //         colors: [
                  //           const Color(0xFF6366F1),
                  //           const Color(0xFF8B5CF6),
                  //           const Color(0xFFA855F7),
                  //         ],
                  //         begin: Alignment.topLeft,
                  //         end: Alignment.bottomRight,
                  //       ),
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //     child: Image.asset(
                  //       "assets/images/home_ecom_header_logo-min.png",
                  //       width: 28,
                  //       height: 28,
                  //       gaplessPlayback: true,
                  //       color: Colors.white,
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(width: 8),
                  // Welcome text - takes remaining space
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Text(
                        //   'Welcome back!',
                        //   style: TextStyle(
                        //     color: Colors.black,
                        //     fontSize: 10,
                        //     fontFamily: fontRegular,
                        //   ),
                        // ),
                        // Text(
                        //   dashboardDetails != null &&
                        //           dashboardDetails['name'] != ""
                        //       ? (dashboardDetails['name'].length > 12
                        //           ? '${dashboardDetails['name'].substring(0, 12)}...'
                        //           : dashboardDetails['name'])
                        //       : "User",
                        //   style: TextStyle(
                        //     color: colorPrimary,
                        //     fontSize: 13,
                        //     fontFamily: fontBold,
                        //     fontWeight: FontWeight.w600,
                        //   ),
                        //   overflow: TextOverflow.ellipsis,
                        //   maxLines: 1,
                        // ),
                      ],
                    ),
                  ),
                  // Icons - fixed width
                  _buildHeaderIcon(buildWishList(context)),
                  const SizedBox(width: 4),
                  _buildHeaderIcon(buildNotification(context)),
                  const SizedBox(width: 4),
                  _buildHeaderIcon(buildMLMCart(context, isHomePage: true)),
                ],
              ),
            ),
            // Search field in header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: searchWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(Widget icon) {
    return Container(
      width: 40,
      height: 40,
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     colors: [
      //       Colors.white.withOpacity(0.25),
      //       Colors.white.withOpacity(0.15),
      //     ],
      //     begin: Alignment.topLeft,
      //     end: Alignment.bottomRight,
      //   ),
      //   borderRadius: BorderRadius.circular(12),
      //   border: Border.all(
      //     color: Colors.white.withOpacity(0.4),
      //     width: 1,
      //   ),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.1),
      //       spreadRadius: 0,
      //       blurRadius: 8,
      //       offset: const Offset(0, 2),
      //     ),
      //   ],
      // ),
      child: Center(
        child: IconTheme(
          data: const IconThemeData(
            color: Colors.black,
            size: 20,
          ),
          child: icon,
        ),
      ),
    );
  }

  Widget searchWidget() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search Icon
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(UniconsLine.search,
                color: textColorSecondary, size: 18.sp),
          ),
          // Search Field
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: TextFormField(
                onTap: () {
                  Get.toNamed('search-page');
                },
                readOnly: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: "Search for products, brands & more...",
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontFamily: fontRegular,
                    color: Colors.grey.shade500,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                ),
              ),
            ),
          ),
          // Action Icons
          Container(
            height: 28,
            width: 1,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          GestureDetector(
            onTap: () {
              // Add mic functionality if needed
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Icon(
                UniconsLine.microphone,
                color: Colors.grey.shade600,
                size: 16,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Add camera/barcode scanner
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Icon(
                UniconsLine.camera,
                color: Colors.grey.shade600,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryList() {
    if (categories.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipPath(
          // clipper: MovieTicketClipper(), // same clipper style as reference
          child: SizedBox(
            height: h(15),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _buildCategoryItem(categories[index], index);
              },
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildCategoryItem(data, index) {
    var width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        if (data['id'] == 0) {
          widget.switchTabCallback!(1);
          Category();
        } else {
          Get.toNamed('/sub-category', arguments: data);
        }
      },
      child: SizedBox(
        width: width * 0.22,
        child: Column(
          children: [
            // circular category image
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                padding: EdgeInsets.all(10.sp),
                margin: EdgeInsets.only(right: 6.w),
                decoration: const BoxDecoration(
                  // gradient: LinearGradient(
                  //   colors: [
                  //     const Color(0xFF6366F1).withOpacity(0.08),
                  //     const Color(0xFF8B5CF6).withOpacity(0.08),
                  //   ],
                  //   begin: Alignment.topLeft,
                  //   end: Alignment.bottomRight,
                  // ),
                  shape: BoxShape.circle,
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: const Color(0xFF6366F1).withOpacity(0.12),
                  //     blurRadius: 8,
                  //     offset: const Offset(0, 4),
                  //   ),
                  // ],
                ),
                child: CircleAvatar(
                  child: PNetworkImage(
                    data['url'],
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              data['name'],
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> afterPurchasePopup(referralLink, referralMessage) {
    final replacedWidgets = <InlineSpan>[];

    final parts = referralMessage.split("%link");
    for (var i = 0; i < parts.length; i++) {
      replacedWidgets.add(TextSpan(text: parts[i]));
      if (i < parts.length - 1) {
        replacedWidgets.add(WidgetSpan(
          child: Text(
            referralLink,
            style: const TextStyle(
                color: blue,
                decoration: TextDecoration.underline,
                fontFamily: fontBold),
          ).onTap(() async {
            Get.back();
            await Auth.logoutGuest();
            launch(referralLink);
          }), // Use your custom link widget here
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
        ));
      }
    }
    return showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(30.sp),
        child: SingleChildScrollView(
          child: Material(
            borderRadius: BorderRadius.circular(25.r),
            child: Container(
              padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(
                      -0.5,
                      0.7,
                    ),
                    blurRadius: 1.0,
                    spreadRadius: 1.0,
                  ), //BoxShadow
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Center(
                          child: text(
                            'Join as a member',
                            fontFamily: fontBold,
                            fontSize: 22.sp,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: RichText(
                            text: TextSpan(
                              children: replacedWidgets,
                              style: TextStyle(
                                  fontSize: 14.sp, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -25.h,
                    right: -20.w,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        width: 30.sp,
                        height: 30.sp,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            // stops: [0.5, 0.9],
                            colors: [Colors.black, grey],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(
                                -0.5,
                                0.7,
                              ),
                              blurRadius: 1.0,
                              spreadRadius: 1.0,
                            ), //BoxShadow
                          ],
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 20.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAdvertisement(context) {
    var width = MediaQuery.of(context).size.width;
    return (advertisement != null && advertisement!.length > 0)
        ? Container(
            // color: Colors.red,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced carousel
                Container(
                  height: h(20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: h(20),
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 4),
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 1000),
                        autoPlayCurve: Curves.easeInOutCubic,
                        pauseAutoPlayOnTouch: true,
                        viewportFraction: 1.0,
                        enlargeCenterPage: false,
                        enableInfiniteScroll: true,
                        scrollDirection: Axis.horizontal,
                      ),
                      items: advertisement!.asMap().entries.map((entry) {
                        int index = entry.key;
                        var item = entry.value;

                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 0,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0),
                                child: Stack(
                                  children: [
                                    // Main image
                                    PNetworkImage(
                                      item['image'],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                    // Premium gradient overlay
                                    // Container(
                                    //   decoration: BoxDecoration(
                                    //     gradient: LinearGradient(
                                    //       colors: [
                                    //         Colors.transparent,
                                    //         Colors.black.withOpacity(0.1),
                                    //         Colors.black.withOpacity(0.4),
                                    //       ],
                                    //       begin: Alignment.topCenter,
                                    //       end: Alignment.bottomCenter,
                                    //       stops: const [0.0, 0.7, 1.0],
                                    //     ),
                                    //   ),
                                    // ),
                                    // // Modern indicator dots
                                    // Positioned(
                                    //   bottom: 16,
                                    //   left: 0,
                                    //   right: 0,
                                    //   child: Row(
                                    //     mainAxisAlignment:
                                    //         MainAxisAlignment.center,
                                    //     children: advertisement!
                                    //         .asMap()
                                    //         .entries
                                    //         .map((dotEntry) {
                                    //       return Container(
                                    //         width: index == dotEntry.key ? 24 : 8,
                                    //         height: 8,
                                    //         margin: const EdgeInsets.symmetric(
                                    //             horizontal: 2),
                                    //         decoration: BoxDecoration(
                                    //           borderRadius:
                                    //               BorderRadius.circular(4),
                                    //           color: index == dotEntry.key
                                    //               ? Colors.white
                                    //               : Colors.white.withOpacity(0.4),
                                    //           boxShadow: index == dotEntry.key
                                    //               ? [
                                    //                   BoxShadow(
                                    //                     color: Colors.white
                                    //                         .withOpacity(0.3),
                                    //                     spreadRadius: 0,
                                    //                     blurRadius: 4,
                                    //                     offset:
                                    //                         const Offset(0, 2),
                                    //                   ),
                                    //                 ]
                                    //               : [],
                                    //         ),
                                    //       );
                                    //     }).toList(),
                                    //   ),
                                    // ),
                                    // // Premium corner badge
                                    // Positioned(
                                    //   top: 16,
                                    //   right: 16,
                                    //   child: Container(
                                    //     padding: const EdgeInsets.symmetric(
                                    //         horizontal: 8, vertical: 4),
                                    //     decoration: BoxDecoration(
                                    //       color: const Color(0xFF6366F1)
                                    //           .withOpacity(0.9),
                                    //       borderRadius: BorderRadius.circular(12),
                                    //       boxShadow: [
                                    //         BoxShadow(
                                    //           color: const Color(0xFF6366F1)
                                    //               .withOpacity(0.3),
                                    //           spreadRadius: 0,
                                    //           blurRadius: 8,
                                    //           offset: const Offset(0, 2),
                                    //         ),
                                    //       ],
                                    //     ),
                                    //     child: Row(
                                    //       mainAxisSize: MainAxisSize.min,
                                    //       children: [
                                    //         const Icon(
                                    //           Icons.local_fire_department,
                                    //           size: 12,
                                    //           color: Colors.white,
                                    //         ),
                                    //         const SizedBox(width: 4),
                                    //         Text(
                                    //           'HOT',
                                    //           style: TextStyle(
                                    //             fontSize: 10,
                                    //             fontFamily: fontBold,
                                    //             color: Colors.white,
                                    //             fontWeight: FontWeight.w600,
                                    //           ),
                                    //         ),
                                    //       ],
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();
  }

  Widget buildBestSeller(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              const SizedBox(width: 8),
              ShinyTitle(
                text: 'Best Sellers',
                fontSize: 20.sp,
              ),
              8.widthBox,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 12,
                      color: Color(0xFFFF6B35),
                    ),
                    SizedBox(width: 2),
                    Text(
                      'HOT',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: fontBold,
                        color: Color(0xFFFF6B35),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
          8.heightBox,

          // Best seller items (Horizontal Scrollable Grid)
          SizedBox(
            height: 180.h,
            child: bestSeller == null || bestSeller!.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: 0, vertical: 10.h),
                    scrollDirection: Axis.horizontal,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 0,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: bestSeller!.length,
                    itemBuilder: (_, int index) {
                      final product = bestSeller![index];

                      return InkWell(
                        radius: 20.r,
                        onTap: () {
                          print('id = $bestSellersId');
                          Get.toNamed("/best-seller-page", arguments: {
                            "category": bestSellersId,
                            "bestSeller": true,
                          });
                        },
                        child: Container(
                          width: 180.w,
                          decoration: boxContain(
                            borderColor: grey.withOpacity(0.3),
                            radius: 20.r,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                // color: Colors.red,
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(top: 5.h),
                                child: PNetworkImage(
                                  product['url'] ?? '',
                                  width: 110.sp,
                                  height: 110.sp,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              5.heightBox,
                              Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4.w, vertical: 2.h),
                                margin: EdgeInsets.only(top: 0.h, left: 6.w),
                                child: Text(
                                  product['name'] ?? '--',
                                  style: TextStyle(
                                    fontFamily: fontSemibold,
                                    fontSize: 12.sp,
                                    // overflow: TextOverflow.ellipsis,
                                  ),
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
      ),
    );
  }

  Widget buildTrendingNow(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              const SizedBox(width: 8),
              ShinyTitle(
                text: 'Trending Now',
                fontSize: 20.sp,
              ),
              8.widthBox,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      UniconsLine.bolt_alt,
                      size: 12,
                      color: Color(0xFFE91E63),
                    ),
                    SizedBox(width: 2),
                    Text(
                      'TRENDING',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: fontBold,
                        color: Color(0xFFE91E63),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
          8.heightBox,

          // Trending Now Items (Horizontal Scrollable Grid)
          SizedBox(
            height: 180.h,
            child: trendingNow == null || trendingNow!.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10.h),
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 10,
                crossAxisSpacing: 0,
                childAspectRatio: 1.3,
              ),
              itemCount: trendingNow!.length,
              itemBuilder: (_, int index) {
                final product = trendingNow![index];

                return InkWell(
                  borderRadius: BorderRadius.circular(20.r),
                  onTap: () {
                    Get.toNamed("/trending-list",
                        arguments: trendingNow![index]);
                  },
                  child: Container(
                    width: 180.w,
                    decoration: boxContain(
                      borderColor: grey.withOpacity(0.3),
                      radius: 20.r,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: 5.h),
                          child: PNetworkImage(
                            product['url'] ?? '',
                            width: 90.sp,
                            height: 90.sp,
                            fit: BoxFit.cover,
                          ),
                        ),
                        5.heightBox,
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 2.h),
                          margin: EdgeInsets.only(top: 0.h, left: 6.w),
                          child: Text(
                            product['name'] ?? '--',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: fontSemibold,
                              fontSize: 12.sp,

                              // overflow: TextOverflow.ellipsis,
                            ),
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
      ),
    );
  }

  Widget buildNewlyLaunchedSection() {
    final List<Map<String, dynamic>> dummyProducts = [
      {
        'name': 'Smart Watch',
        'imageUrl': 'https://via.placeholder.com/150',
        'mrp': '2999',
        'dp': '1999',
      },
      {
        'name': 'Bluetooth Headphones',
        'imageUrl': 'https://via.placeholder.com/150',
        'mrp': '2499',
        'dp': '1499',
      },
      {
        'name': 'Fitness Band',
        'imageUrl': 'https://via.placeholder.com/150',
        'mrp': '1999',
        'dp': '1299',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ShinyTitle(text: 'Newly Launched', fontSize: 22.sp),
          SizedBox(height: 10.h),
          Column(
            children: <Widget>[
              SizedBox(
                height: 190.h,
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10.h),
                  scrollDirection: Axis.horizontal,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 0,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: dummyProducts.length,
                  itemBuilder: (_, int index) {
                    final product = dummyProducts[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(20.r),
                      onTap: () {
                        debugPrint("Tapped on ${product['name']}");
                      },
                      child: Container(
                        width: 180.w,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 5.h),
                              alignment: Alignment.center,
                              child: PNetworkImage(
                                product['imageUrl'] ?? '',
                                width: 110.sp,
                                height: 110.sp,
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4.w, vertical: 2.h),
                              margin: EdgeInsets.only(top: 0.h, left: 6.w),
                              child: Text(
                                product['name'] ?? '',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "₹ ${product['mrp']}",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10.sp,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  "₹ ${product['dp']}",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPrice(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              ShinyTitle(
                text: 'Shop by Price',
                // style: TextStyle(
                fontSize: 18.sp,
                //   fontFamily: fontBold,
                //   fontWeight: FontWeight.w700,
                //   color: Colors.black87,
                // ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${priceStore!.length} Ranges',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: fontMedium,
                    color: const Color(0xFF6366F1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Price items - Vertical Grid Layout
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: priceStore!.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Get.toNamed("/product-list", arguments: {
                    'price': [priceStore![index]['id']],
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.1),
                        const Color(0xFF8B5CF6).withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Price icon with background
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF6366F1),
                              const Color(0xFF8B5CF6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                              spreadRadius: 0,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.currency_rupee,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Label
                      Text(
                        'Under ${formatPriceText(priceStore![index]['name'])}',
                        // Add ₹, if necessary
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: fontMedium,
                          color: const Color(0xFF6366F1),
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String formatPriceText(String text) {
    // Extract only numbers and decimals (remove ₹, commas, etc.)
    final number = double.tryParse(text.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (number == null) return text;

    if (number >= 1000) {
      double value = number / 1000;

      // Truncate to 2 decimals without rounding
      String formatted =
          value.toStringAsFixed(3); // 3 for safety before truncating
      if (formatted.contains('.')) {
        formatted = formatted.substring(0, formatted.indexOf('.') + 3);
      }

      // Remove unnecessary trailing zeros (e.g., 1.00k → 1k)
      formatted = formatted.replaceAll(RegExp(r'\.?0+$'), '');

      return '${formatted}k';
    } else {
      return text;
    }
  }

  Future checkForDynamicLinkArguments() async {
    Future.delayed(const Duration(milliseconds: 250), () async {
      var dynamicArg = await Storage.get('dynamicLinkArg');
      // toast('dynnamic $dynamicArg');
      if (dynamicArg != null) {
        Get.toNamed('/product-detail', arguments: dynamicArg);
        Storage.delete('dynamicLinkArg');
      }
    });
  }
}
