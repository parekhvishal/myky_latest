import
'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:myky_clone/utils/app_utils.dart';
import 'package:myky_clone/utils/en_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../services/validator_x.dart';
import '../../../widget/theme.dart';
import '../../services/api.dart';
import '../../services/auth.dart';
import '../../services/size_config.dart';
import '../../services/upi_apps_service.dart';
import '../../widget/installed_app_list.dart';

class QRView extends StatefulWidget {
  const QRView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewState();
}

class _QRViewState extends State<QRView> with TickerProviderStateMixin {
  final _qrCodeFormKey = GlobalKey<FormState>();
  ValidatorX validator = ValidatorX();

  bool isActive = false;

  int? buySellSelection = 1;
  num? vendorId;
  num? vendorPercentage;

  void selectPostType(int? value) {
    buySellSelection = value;
  }

  final TextEditingController vendorShopNameController =
      TextEditingController();
  final TextEditingController _vendorCodeController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();

  String? qrData;
  Map? mapData, orderData = {};
  num? paymentToMyKy, totalPayment;
  num? percentToMyKy, gstPercentage;
  num? remaining;
  bool? step1, step2;

  var currentStep = 1.obs;
  var isFirstStepCompleted = false.obs;

  void nextStep() {
    if (currentStep.value < 1) {
      currentStep.value++;
    }
  }

  late UPIAppService appService;
  List<Map<String, String>> installedApps = [];

  @override
  void initState() {
    if (Get.previousRoute != '/off-line-orders') {
      qrData = Get.arguments;
      if (qrData != null) {
        mapData = json.decode(qrData!);
        print('**Map data : $mapData');
        vendorShopNameController.text = mapData!['name'].toString();
        _vendorCodeController.text = mapData!['code'].toString();
        vendorPercentage = num.parse(mapData!['percentage']);
        vendorId = mapData!['id'];
        fetchUserDetail(vendorID: vendorId);
      }
    } else {
      orderData = Get.arguments;
      print('##Map data : $orderData');
      vendorShopNameController.text = orderData!['vendorName'].toString();
      _vendorCodeController.text = orderData!['vendorCode'].toString();
      vendorId = orderData!['vendorId'];
      _totalController.text =
          orderData!['amount'] != null ? orderData!['amount'].toString() : '';

      fetchUserDetail(
        orderID: orderData!['id'],
        vendorID: vendorId,
        isFromOfflineOrder: true,
      );
    }
    appService = Get.find<UPIAppService>();
    installedApps = appService.getInstalledApps();

    super.initState();
  }

  Future fetchUserDetail(
      {num? orderID,
      var vendorID,
      bool isBackFromPayment = false,
      bool isFromOfflineOrder = false}) async {
    String url = orderID != null && isFromOfflineOrder == true
        ? 'shopping/offline-store/calculation/$orderID?vendor_id=$vendorId'
        : "shopping/offline-store/calculation?vendor_id=$vendorId";
    await Api.http.get(url).then((response) {
      if (response.data['status']) {
        percentToMyKy = num.parse(response.data['percentage'].toString());
        gstPercentage = response.data['gstPercentage'];
        step1 = response.data['step1'];
        step2 = response.data['step2'];
        orderData = response.data;
        if (orderData!['offlineStoreOrder'] != null &&
            orderData!['offlineStoreOrder']['amount'] != null) {
          calculateValues(orderData!['offlineStoreOrder']['amount']);
        }
        if (isBackFromPayment == true) {
          step1 == true
              ? AppUtils.showSuccessSnackBar(response.data['message'])
              : AppUtils.showErrorSnackBar(response.data['message']);
        }
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Payment'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _qrCodeFormKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                floatingInput(
                  'Vendor Shop Name',
                  controller: vendorShopNameController,
                  readonly: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))
                  ],
                  validator: validator.add(
                    key: 'name',
                    rules: [
                      ValidatorX.mandatory(
                          message: "Vendor shop name field is required"),
                    ],
                  ),
                  onChanged: (value) {
                    validator.clearErrorsAt('name');
                  },
                ),
                const SizedBox(height: 10.0),
                floatingInput(
                  'Vendor ID',
                  controller: _vendorCodeController,
                  readonly: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))
                  ],
                  validator: validator.add(
                    key: 'code',
                    rules: [
                      ValidatorX.mandatory(
                          message: "Vendor id field is required"),
                    ],
                  ),
                  onChanged: (value) {
                    validator.clearErrorsAt('code');
                  },
                ),
                TextFormField(
                  controller: _totalController,
                  readOnly: step1 != null && step1 == true ? true : false,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: validator.add(
                    key: 'total',
                    rules: [
                      ValidatorX.mandatory(
                          message: "Total amount field is required"),
                      ValidatorX.custom((value, {key}) {
                        if (double.parse(value!) < 1) {
                          return 'Total amount must be at least 1';
                        }
                        return null;
                      })
                    ],
                  ),
                  onChanged: (value) {
                    validator.clearErrorsAt('total');
                    if (value.isNotEmpty) {
                      calculateValues(value);
                    } else {
                      totalPayment = null;
                      remaining = null;
                      setState(() {});
                    }
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'^[0.]|[- ,]')),
                    DecimalTextInputFormatter(decimalRange: 2),
                  ],
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: colorPrimary,
                    fontFamily: fontBold,
                  ),
                  cursorColor: colorPrimary,
                  decoration: InputDecoration(
                    labelText: "Total Amount",
                    isDense: true,
                    labelStyle: TextStyle(
                      fontSize: 16.sp,
                      color: textColorPrimary.withOpacity(0.7),
                      fontFamily: fontMedium,
                    ),
                    enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black12)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: colorPrimary)),
                  ),
                ),
                const SizedBox(height: 10.0),
                if (orderData!.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 15.h,
                      horizontal: 12.w,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: colorPrimary.withOpacity(0.1),
                      border: Border.all(
                        color: colorPrimary,
                        width: 0.4.w,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 32.sp,
                          width: 32.sp,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Icon(
                            Icons.credit_card,
                            color: colorPrimary,
                            size: 20.sp,
                          ),
                        ),
                        12.widthBox,
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    text(
                                      "Share To Customers Savings Wallet",
                                      fontSize: 13.0,
                                      fontweight: FontWeight.w600,
                                      textColor: black,
                                      maxLine: 2,
                                    ),
                                    text(
                                      totalPayment != null
                                          ? "₹ ${totalPayment!.toStringAsFixed(2)}"
                                          : "₹ 0",
                                      fontSize: 15.0,
                                      textColor: black,
                                    ),
                                  ],
                                ).expand(),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 6.h,
                                    horizontal: 8.w,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.r),
                                    color: Colors.white,
                                  ),
                                  child: text(
                                    orderData!['paymentStatus'] != null &&
                                            orderData!['paymentStatus']['id'] !=
                                                4
                                        ? orderData!['paymentStatus']['name']
                                        : "Pending",
                                    fontSize: 12.sp,
                                    fontFamily: fontBold,
                                    fontweight: FontWeight.w800,
                                    textColor: orderData!['paymentStatus'] !=
                                                null &&
                                            orderData!['paymentStatus']['id'] !=
                                                4
                                        ? AppUtils.setStatusColor(
                                            orderData!['paymentStatus']['name'])
                                        : Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                            8.heightBox,
                            if (step1 != null && step1 == false)
                              SizedBox(
                                width: 100.w,
                                child: Opacity(
                                  opacity: _totalController.text.isNotEmpty
                                      ? 1
                                      : 0.5,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Handle the payment process here
                                      // If payment is successful, move to the next step
                                      if (_totalController.text.isNotEmpty) {
                                        if (vendorPercentage == 1) {
                                          if (_totalController.text
                                                  .toDouble() >=
                                              300) {
                                            confirmPayment();
                                          } else {
                                            AppUtils.showErrorSnackBar(
                                                'Please enter greater than 300');
                                          }
                                        } else {
                                          if (totalPayment != null &&
                                              totalPayment! >= 1) {
                                            confirmPayment();
                                          } else {
                                            AppUtils.showErrorSnackBar(
                                                'Payable amount must be greater than 1');
                                          }
                                        }
                                      } else {
                                        AppUtils.showErrorSnackBar(
                                            'Please enter amount');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                    ),
                                    child: text(
                                      'Pay',
                                      textColor: whiteColor,
                                      fontFamily: fontBold,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ).expand(),
                      ],
                    ),
                  ),
                2.heightBox,
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 65.h,
                        width: 2.w,
                        color: gray.withOpacity(0.2),
                      ),
                      Container(
                        height: 25.sp,
                        width: 25.sp,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: gray.withOpacity(0.8),
                        ),
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Icon(
                            Icons.chevron_left,
                            size: 20.sp,
                            color: Colors.black,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                2.heightBox,
                AbsorbPointer(
                  absorbing: step1 == true ? false : true,
                  child: Opacity(
                    opacity: step1 == true ? 1 : 0.4,
                    child: Container(
                      padding: EdgeInsets.all(12.sp),
                      margin: EdgeInsets.only(bottom: 15.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: gray.withOpacity(0.2),
                        border: Border.all(
                          color: gray,
                          width: 0.4.w,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 32.sp,
                            width: 32.sp,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Icon(
                              Icons.wallet,
                              color: colorPrimary,
                              size: 20.sp,
                            ),
                          ),
                          12.widthBox,
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      text(
                                        "Pay Remaining Amount to Vendor  ",
                                        fontSize: 13.sp,
                                        fontweight: FontWeight.w600,
                                        maxLine: 2,
                                        textColor: black,
                                      ),
                                      text(
                                        remaining != null
                                            ? "₹ ${remaining!.toStringAsFixed(2)}"
                                            : "₹ 0",
                                        fontSize: 28.sp,
                                        textColor: colorPrimary,
                                        fontFamily: fontBold,
                                        fontweight: FontWeight.w800,
                                      ),
                                    ],
                                  ).expand(),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 6.h,
                                      horizontal: 8.w,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.r),
                                      color: Colors.white,
                                    ),
                                    child: text(
                                      step2 != null && step2 == true
                                          ? "Success"
                                          : "Pending",
                                      fontSize: 12.sp,
                                      fontFamily: fontMedium,
                                      textColor: step2 != null && step2 == true
                                          ? greenColor
                                          : Colors.amber,
                                    ),
                                  ),
                                ],
                              ),
                              12.heightBox,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 6.h),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.r),
                                      color: isActive == false
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.white,
                                      border: Border.all(
                                        color: isActive == false
                                            ? Colors.green.withOpacity(0.2)
                                            : gray,
                                        width: 0.4.w,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Icon(
                                          Icons.currency_rupee,
                                          size: 16.sp,
                                          color: gray,
                                        ),
                                        4.widthBox,
                                        text(
                                          "Cash",
                                          fontSize: 14.sp,
                                          fontFamily: fontBold,
                                          textColor: isActive == false
                                              ? Colors.green
                                              : gray,
                                        ),
                                      ],
                                    ),
                                  ).onTap(() {
                                    setState(() {
                                      isActive = false;
                                    });
                                  }).expand(),
                                  12.widthBox,
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 6.h),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.r),
                                      color: isActive == true
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.white,
                                      border: Border.all(
                                        color: isActive == true
                                            ? Colors.green.withOpacity(0.2)
                                            : gray,
                                        width: 0.4.w,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Icon(
                                          Icons.money,
                                          size: 16.sp,
                                          color: gray,
                                        ),
                                        4.widthBox,
                                        text(
                                          "Online",
                                          fontSize: 14.sp,
                                          fontFamily: fontBold,
                                          textColor: isActive == true
                                              ? Colors.green
                                              : gray,
                                        ),
                                      ],
                                    ),
                                  ).onTap(() async {
                                    setState(() {
                                      isActive = true;
                                    });
                                  }).expand(),
                                ],
                              ).marginOnly(right: 50.w),
                              if (isActive == true &&
                                  installedApps.isNotEmpty) ...[
                                10.heightBox,
                                InstalledAppList(installedApps: installedApps)
                              ],
                            ],
                          ).expand(),
                        ],
                      ),
                    ),
                  ),
                ),
                if (step1 == true && step2 == false)
                  CustomButton(
                      textContent: 'Paid',
                      onPressed: () {
                        Map sendData = {
                          'id': orderData!['offlineStoreOrder']['id'],
                          'pay_by': isActive == true ? 2 : 1,
                        };
                        Api.http
                            .post('shopping/offline-store/step2',
                                data: sendData)
                            .then((response) async {
                          if (response.data['status']) {
                            step2 = true;
                            setState(() {});
                            // AppUtils.showSuccessSnackBar(
                            //     response.data['message']);
                            // Future.delayed(
                            //     const Duration(seconds: 3), () => Get.back());
                            await rewardDialog(response.data['discount'],
                                response.data['coin']);
                            Timer(const Duration(seconds: 3), () {
                              double rating = 5;
                              showModalBottomSheet(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                context: context,
                                isDismissible: false,
                                builder: (BuildContext context) {
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return Container(
                                        height: h(30.0),
                                        color: Colors.transparent,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            children: [
                                              text(
                                                'Rate this vendor',
                                                fontSize: 17.0,
                                                fontweight: FontWeight.w600,
                                              ),
                                              const SizedBox(height: 10.0),
                                              Center(
                                                child: RatingBar(
                                                    itemSize: 40,
                                                    initialRating: rating,
                                                    glowColor:
                                                        Colors.transparent,
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: false,
                                                    itemCount: 5,
                                                    ratingWidget: RatingWidget(
                                                        full: Icon(
                                                          Icons.star,
                                                          size: 5.sp,
                                                          color: Colors.orange,
                                                        ),
                                                        half: Icon(
                                                          Icons.star,
                                                          size: 5.sp,
                                                          color: Colors.orange,
                                                        ),
                                                        empty: Icon(
                                                          Icons.star_border,
                                                          size: 5.sp,
                                                          color: gray,
                                                        )),
                                                    onRatingUpdate: (value) {
                                                      setState(() {
                                                        rating = value;
                                                      });
                                                    }),
                                              ),
                                              20.heightBox,
                                              CustomButton(
                                                textContent: 'Submit',
                                                onPressed: () {
                                                  Map sendData = {
                                                    "vendor_id": vendorId ??
                                                        mapData!['id'],
                                                    'rating': rating,
                                                    'member_id':
                                                        Auth.memberId(),
                                                  };
                                                  if (rating > 0) {
                                                    Api.http
                                                        .post(
                                                            'shopping/vendor-review/store',
                                                            data: sendData)
                                                        .then((response) {
                                                      GetBar(
                                                        backgroundColor:
                                                            response.data[
                                                                    'status']
                                                                ? Colors.green
                                                                : Colors.red,
                                                        duration:
                                                            const Duration(
                                                                seconds: 3),
                                                        message: response
                                                            .data['message'],
                                                      ).show();

                                                      if (response
                                                          .data['status']) {
                                                        Timer(
                                                            const Duration(
                                                                seconds: 3),
                                                            () {
                                                          Get.offAllNamed(
                                                              '/ecommerce');
                                                          Get.toNamed(
                                                              '/dashboard');
                                                        });
                                                      }
                                                    }).catchError(
                                                      (error) {
                                                        if (error.response
                                                                .statusCode ==
                                                            422) {
                                                          validator.setErrors(
                                                              error.response
                                                                      .data[
                                                                  'errors']);
                                                        }
                                                      },
                                                    );
                                                  } else {
                                                    AppUtils.showErrorSnackBar(
                                                        "Select Rating");
                                                  }
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            });
                          } else {
                            AppUtils.showErrorSnackBar(
                                response.data['message']);
                          }
                        }).catchError((error) {
                          if (error.response.statusCode == 401 ||
                              error.response.statusCode == 403) {
                            AppUtils.showErrorSnackBar(
                                error.response.data['message']);
                          }
                        });
                      })
              ],
            ),
          ),
        ),
      ),
    );
  }

  rewardDialog(var discount, var coin) {
    print('Discount: ₹$discount');
    print('Coin: $coin');
    return Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        backgroundColor: Colors.white,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.grey.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Giftbox Image
                  Image.asset(
                    'assets/images/giftbox.png',
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 15),
                  // Reward Title
                  Text(
                    "Congratulations!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Discount Text
                  Text(
                    "You won ₹$discount",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.green.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Myky Coin Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/myky.png',
                        height: 30,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "+ ₹$coin Myky Coins",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colorPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Achieved Text
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "🎉 Achieved",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Woohoo Text
                  Text(
                    "Woohoo! Keep Winning!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Claim Button
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                    ),
                    child: const Text(
                      "Claim Reward",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Close Button
            Positioned(
              right: -10,
              top: -10,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade200,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.grey.shade800,
                  ),
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container waitingContainer() {
    return Container(
      height: 40.sp,
      padding: EdgeInsets.all(5.sp),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: colorPrimary, // Border color
            width: 0.2, // Border width
          ),
        ),
      ),
    );
  }

  calculateValues(String value) {
    if (value.isNotEmpty) {
      double total = double.tryParse(value) ?? 0;
      if (total >= 1) {
        setState(() {
          paymentToMyKy = total * percentToMyKy! / 100;
          gstPercentage = paymentToMyKy! * 0.18;
          totalPayment = paymentToMyKy! + gstPercentage!;
          remaining = total - totalPayment!;
        });
      } else {
        setState(() {
          totalPayment = null;
          remaining = null;
        });
      }
    } else {
      setState(() {
        totalPayment = null;
        remaining = null;
      });
    }
  }

  void confirmPayment() {
    if (_qrCodeFormKey.currentState!.validate()) {
      FocusScope.of(context).requestFocus(FocusNode());

      Map sendData = {
        'vendor_id': vendorId ?? mapData!['id'],
        'total': _totalController.text,
      };

      Api.http
          .post('shopping/offline-store/store', data: sendData)
          .then((response) async {
        if (response.data['status']) {
          print('**response.data : ${response.data}');
          Get.toNamed(
            '/payment-web-view',
            arguments: response.data['webPaymentUrl'],
          )?.then((value) {
            print('**Value : $value');
            if (value != null) {
              fetchUserDetail(
                orderID: response.data['order']['id'],
                vendorID: response.data['order']['vendor_id'],
                isBackFromPayment: true,
                isFromOfflineOrder: true,
              );
            }
          });
        }
      }).catchError((error) {
        if (error.response.statusCode == 401 ||
            error.response.statusCode == 403) {
          AppUtils.showErrorSnackBar(error.response.data['message']);
        }
        if (error.response.statusCode == 422) {
          setState(() {
            validator.setErrors(error.response.data['errors']);
          });
        }
      });
    }
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({required this.decimalRange});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text;

    // Allow empty input
    if (newText.isEmpty) {
      return newValue;
    }

    // Prevent input starting with a dot
    if (newText.startsWith('.')) {
      return oldValue;
    }

    // Split the input by the decimal point
    final parts = newText.split('.');

    // Prevent more than one decimal point
    if (parts.length > 2) {
      return oldValue;
    }

    // Limit the number of decimal places
    if (parts.length == 2 && parts[1].length > decimalRange) {
      return oldValue;
    }

    // Prevent leading zeros unless followed by a decimal point
    if (newText.length > 1 &&
        newText.startsWith('0') &&
        !newText.startsWith('0.')) {
      return oldValue;
    }

    return newValue;
  }
}
