import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart' hide white;
import 'package:unicons/unicons.dart';

import '../../../services/validator_x.dart';
import '../../services/api.dart';
import '../../services/auth.dart';
import '../../utils/app_utils.dart';
import '../../widget/network_image.dart';
import '../../widget/theme.dart';

class Payments extends StatefulWidget {
  @override
  _PaymentsState createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  final _addressFormKey = GlobalKey<FormState>();
  List? cartProducts = [];
  List? payByList = [];
  var totalBv, amount, total, convenienceFee, useCoin;
  // final flutterWebViewPlugin = FlutterWebviewPlugin();

  // late Razorpay razorpay;
  int? orderId;
  String? uniqueId;

  ValidatorX validator = ValidatorX();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();

  List? citiesData;
  Map? stateData;
  String? cityId;
  String? myStateSelection;
  String? myCitySelection;
  String? myPaymentSelection = "2";

  Future getProfileData() async {
    Api.http.get('member/profile').then((response) async {
      setState(() {
        _nameController.text =
            response.data['name'] != null ? response.data['name'] : "";
        _phoneController.text =
            response.data['phone'] != null ? response.data['phone'] : "";
        _emailController.text =
            response.data['email'] != null ? response.data['email'] : "";
        _addressController.text =
            response.data['address'] != null ? response.data['address'] : "";
        _pinCodeController.text = response.data['pincode'] != null
            ? response.data['pincode'].toString()
            : "";

        if (response.data['state'] != null)
          myStateSelection = response.data['state']['id'].toString();
        if (response.data['city'] != null) {
          cityId = response.data['city']['id'].toString();
          getCity(myStateSelection!, isLoad: true);
        }
      });
    });
  }

  @override
  void initState() {
    if (Auth.check()!) getProfileData();

    _fetchShippingInformation(Auth.check()! ? 1 : 2);

    super.initState();
    getState();
    // if (kDebugMode) {
    //   _nameController.text = "Vishal";
    //   _phoneController.text = "9924256396";
    //   _emailController.text = "a@gmail.com";
    //   _addressController.text = "Vadodara";
    //   _pinCodeController.text = "390006";
    // }
  }

  Widget _stateDropdown() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: DropdownButtonFormField<String>(
        isDense: true,
        isExpanded: true,
        validator: (String? value) {
          if (myStateSelection == null || myStateSelection!.isEmpty) {
            return "Please select state";
          }
          return null;
        },
        hint: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                UniconsLine.map_pin_alt,
                color: textColorSecondary,
                size: 20,
              ),
              SizedBox(
                width: 10,
              ),
              text('Select State',
                  fontSize: textSizeMedium, textColor: textColorSecondary),
            ],
          ),
        ),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: white, width: 0.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: white, width: 0.0),
          ),
          border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black12)),
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          // hintText: 'Select State',
          filled: true,
          fillColor: Color(0xFFf7f7f7),
          hintStyle:
              TextStyle(fontSize: textSizeMedium, color: textColorSecondary),
        ),
        value: myStateSelection,
        iconSize: 20,
        elevation: 16,
        onChanged: (String? newValue) {
          myCitySelection = null;
          citiesData = [];
          getCity(newValue!);
          validator.clearErrorsAt('state_id');
          setState(() {
            myStateSelection = newValue;
          });
          _fetchShippingInformation(Auth.check()! ? 1 : 2,
              myStateSelection: myStateSelection);
        },
        items: stateData!['states'].map<DropdownMenuItem<String>>((state) {
          return DropdownMenuItem<String>(
            value: state['id'].toString(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                children: [
                  Icon(
                    UniconsLine.map_pin_alt,
                    color: textColorSecondary,
                    size: 20,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    state['name'].toString(),
                    style: TextStyle(
                      fontSize: textSizeLargeMedium,
                      color: colorPrimaryDark,
                      fontFamily: fontRegular,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _cityDropdown() {
    return Padding(
      padding: const EdgeInsets.only(left: 2.0, right: 2, bottom: 10),
      child: DropdownButtonFormField<String>(
        isDense: true,
        isExpanded: true,
        validator: (String? value) {
          if (myCitySelection == null || myCitySelection!.isEmpty) {
            return "Please select city";
          }
          return null;
        },
        hint: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                UniconsLine.map_pin_alt,
                color: textColorSecondary,
                size: 20,
              ),
              SizedBox(
                width: 10,
              ),
              text('Select City',
                  fontSize: textSizeMedium, textColor: textColorSecondary),
            ],
          ),
        ),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: white, width: 0.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: white, width: 0.0),
          ),
          border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black12)),
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          filled: true,
          fillColor: Color(0xFFf7f7f7),
          // hintText: 'Select City',
          hintStyle: TextStyle(fontSize: textSizeMedium, color: Colors.black),
        ),
        value: myCitySelection,
        iconSize: 20,
        elevation: 16,
        onChanged: (String? newValue) {
          validator.clearErrorsAt('city_id');
          setState(() {
            myCitySelection = newValue!;
          });
        },
        items: citiesData!.map<DropdownMenuItem<String>>((city) {
          return DropdownMenuItem<String>(
            value: city['id'].toString(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    UniconsLine.map_pin_alt,
                    color: textColorSecondary,
                    size: 20,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    city['name'].toString(),
                    style: TextStyle(
                      fontSize: textSizeLargeMedium,
                      color: colorPrimaryDark,
                      fontFamily: fontRegular,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void getCity(String newValue, {bool isLoad = false}) {
    Api.http.get('shopping/cities/$newValue').then((value) {
      setState(() {
        citiesData = value.data['cities'];
        if (isLoad) myCitySelection = cityId.toString();
      });
    });
  }

  void getState() {
    Api.http.get('shopping/states').then((response) {
      setState(() {
        stateData = response.data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment')),
      body: (cartProducts != null && cartProducts!.length > 0)
          ? ListView(
              children: <Widget>[
                _buildProductDetail(context),
                _buildPayment(context),
                _buildAddress(context),
              ],
            )
          : Container(),
      bottomNavigationBar: (cartProducts != null && cartProducts!.length > 0)
          ? _buildProceedCard(context)
          : Container(),
    );
  }

  Widget _buildProductDetail(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, top: 10, right: 10),
      decoration: boxDecoration(
        radius: 10,
        showShadow: true,
      ),
      child: Column(
        children: <Widget>[
          Container(
              child: Column(
            children: <Widget>[
              ExpansionTile(
                title: text(
                  "Shopping Items",
                  fontFamily: fontSemibold,
                  fontSize: textSizeLargeMedium,
                ),
                children: <Widget>[
                  for (Map cartItem in cartProducts!)
                    if (cartItem.isNotEmpty) _buildCartItem(cartItem),
                ],
              ),
            ],
          ))
        ],
      ),
    );
  }

  Widget _buildCartItem(Map cartItem) {
    return Container(
      height: 110,
      child: Row(
        children: <Widget>[
          Container(
            width: 120,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                PNetworkImage(
                  cartItem['imageUrl'],
                ),
              ],
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: text(
                          cartItem['product']['name'],
                          overflow: TextOverflow.ellipsis,
                          maxLine: 2,
                          fontFamily: fontRegular,
                          fontSize: textSizeMedium,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: <Widget>[
                      text(
                        '\₹ ${cartItem['selling_price']}',
                        fontSize: textSizeLargeMedium,
                        fontFamily: fontMedium,
                        textColor: colorPrimaryDark,
                      ),
                    ],
                  ),
                  text(
                    'Qty : ${cartItem['selected_qty']}',
                    fontSize: textSizeSMedium,
                    textColor: green,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayment(context) {
    return Container(
      margin: EdgeInsets.only(left: 10, top: 10, right: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: boxDecoration(
        radius: 10,
        showShadow: true,
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              text(
                "Sub Total",
              ),
              text(
                "\₹ ${amount.toStringAsFixed(2)}",
              ),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text("Delivery Charge"),
                  text(
                    "(It might be differ on state)",
                    fontSize: 11.sp,
                    textColor: blue,
                  ),
                ],
              ),
              text(
                "\₹ ${convenienceFee.toStringAsFixed(2)}",
              ),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              text(
                "By using coin",
                textColor: goldenRod,
                fontSize: textSizeLargeMedium,
              ),
              text(
                "${useCoin.toStringAsFixed(2)}",
                textColor: goldenRod,
                fontSize: textSizeLargeMedium,
                fontFamily: fontSemibold,
              ),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              text(
                "Total Amount",
                textColor: green,
                fontSize: textSizeLargeMedium,
              ),
              text(
                "\₹ ${total.toStringAsFixed(2)}",
                textColor: green,
                fontSize: textSizeLargeMedium,
                fontFamily: fontSemibold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddress(context) {
    return Container(
      margin: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: boxDecoration(
        radius: 10,
        showShadow: true,
      ),
      child: Form(
        key: _addressFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: text(
                'Address',
                textColor: Colors.black,
                fontSize: 18.0,
                fontweight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10.0),
            formField(
              context,
              'Name',
              prefixIcon: UniconsLine.user,
              controller: _nameController,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'^[ -.,]'))
              ],
              validator: validator.add(
                key: 'name',
                rules: [
                  ValidatorX.mandatory(message: "Name field is required"),
                ],
              ),
              onChanged: (value) {
                validator.clearErrorsAt('name');
              },
            ),
            SizedBox(height: 10.0),
            formField(
              context,
              'Mobile',
              prefixIcon: UniconsLine.phone,
              controller: _phoneController,
              maxLength: 10,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'^[0-5 -.,]|[-., ]'))
              ],
              validator: validator.add(
                key: 'phone',
                rules: [
                  ValidatorX.mandatory(message: "Mobile field is required"),
                  ValidatorX.minLength(
                    length: 10,
                    message: 'Mobile number must be at least 10 digit long',
                  )
                ],
              ),
              onChanged: (value) {
                validator.clearErrorsAt('phone');
              },
            ),
            SizedBox(height: 10.0),
            formField(
              context,
              'Email',
              prefixIcon: UniconsLine.mailbox,
              controller: _emailController,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'[ -,]'))
              ],
              validator: validator.add(
                key: 'email',
                // rules: [],
              ),
              onChanged: (value) {
                validator.clearErrorsAt('email');
              },
            ),
            SizedBox(height: 10.0),
            formField(
              context,
              'Address',
              prefixIcon: UniconsLine.home,
              controller: _addressController,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'^[ ]'))
              ],
              validator: validator.add(
                key: 'address',
                rules: [
                  ValidatorX.mandatory(message: "Address field is required"),
                ],
              ),
              onChanged: (value) {
                validator.clearErrorsAt('address');
              },
            ),
            SizedBox(height: 10.0),
            if (stateData != null) _stateDropdown(),
            SizedBox(height: 10),
            if (citiesData != null) _cityDropdown(),
            formField(
              context,
              'Pincode',
              prefixIcon: UniconsLine.location_pin_alt,
              controller: _pinCodeController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))
              ],
              validator: validator.add(
                key: 'pincode',
                rules: [
                  ValidatorX.mandatory(message: "Pincode field is required"),
                ],
              ),
              onChanged: (value) {
                validator.clearErrorsAt('pincode');
              },
            ),
            SizedBox(height: 10.0),
            paymentMethodDropDown(),
            SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }

  Widget paymentMethodDropDown() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: DropdownButtonFormField<String>(
        isDense: true,
        isExpanded: true,
        validator: validator.add(
          key: 'payment_type',
          rules: [
            ValidatorX.mandatory(message: "Select your payment method"),
          ],
        ),
        hint: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            children: [
              Icon(
                UniconsLine.transaction,
                color: textColorSecondary,
                size: 20,
              ),
              SizedBox(
                width: 10,
              ),
              text('Select Payment Method',
                  fontSize: textSizeMedium, textColor: textColorSecondary),
            ],
          ),
        ),
        value: myPaymentSelection,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: white, width: 0.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: white, width: 0.0),
          ),
          border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black12)),
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          // hintText: 'Select State',
          filled: true,
          fillColor: Color(0xFFf7f7f7),
          hintStyle: TextStyle(fontSize: textSizeMedium, color: Colors.black),
        ),
        onChanged: (String? newValue) {
          validator.clearErrorsAt('payment_type');
          setState(() {
            myPaymentSelection = newValue!;
          });
        },
        items: payByList!.map<DropdownMenuItem<String>>((paymentMode) {
          return DropdownMenuItem<String>(
            value: paymentMode['id'].toString(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    UniconsLine.transaction,
                    color: textColorSecondary,
                    size: 20,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    paymentMode['name'],
                    style: TextStyle(
                      fontSize: textSizeLargeMedium,
                      color: colorPrimaryDark,
                      fontFamily: fontRegular,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProceedCard(context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        color: colorAccent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          text(
            "\₹ ${total.toStringAsFixed(2)}",
            fontSize: textSizeLargeMedium,
            textColor: white,
            fontFamily: fontBold,
          ),
          MaterialButton(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            onPressed: () {
              if (_addressFormKey.currentState!.validate()) {
                FocusScope.of(context).requestFocus(FocusNode());
                _confirmOrder();
              }
            },
            color: colorPrimary,
            textColor: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  text(
                    'Pay',
                    fontSize: textSizeLargeMedium,
                    textColor: white,
                    fontFamily: fontBold,
                  ),
                  // 5.width,
                  // Icon(
                  //   Icons.arrow_forward_ios,
                  //   color: white,
                  //   size: 16,
                  // )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _fetchShippingInformation(int userType, {String? myStateSelection}) {
    Api.http.get('shopping/shipping', queryParameters: {
      "user_type": userType,
      "stateId": myStateSelection,
    }).then((response) {
      if (response.data['status']) {
        setState(() {
          cartProducts = response.data['data']['cartDetails']['products'];
          payByList = response.data['data']['payBy'];
          if (response.data['data']['cartDetails']['totalDp'] != null) {
            amount = num.parse(response.data['data']['cartDetails']
                    ['totalSellingPrice']
                .toString());
          } else {
            amount = num.parse('0');
          }
          if (response.data['data']['cartDetails']['totalShipping'] != null) {
            convenienceFee = num.parse(response.data['data']['cartDetails']
                    ['totalShipping']
                .toString());
          } else {
            convenienceFee = num.parse('0');
          }
          if (response.data['data']['cartDetails']['totalCharge'] != null) {
            total = num.parse(
                response.data['data']['cartDetails']['totalCharge'].toString());
          } else {
            total = num.parse('0');
          }
          if (response.data['data']['cartDetails']['coinAmount'] != null) {
            useCoin = num.parse(
                response.data['data']['cartDetails']['coinAmount'].toString());
          } else {
            useCoin = num.parse('0');
          }
        });
        int outOfStockCount = 0;
        cartProducts!.forEach((product) {
          if (product['outOfStock']) {
            outOfStockCount++;
          }
        });
        if (outOfStockCount > 0) {
          AppUtils.showErrorSnackBar(
              'One or more item from your cart has been out of stock');
          Future.delayed(Duration(seconds: 3), () {
            Get.back();
            Get.back(result: false);
          });
        }
      }
    });
  }

  void _confirmOrder() {
    Map sendData = {
      "name": _nameController.text,
      "phone": _phoneController.text,
      "email": _emailController.text,
      "address": _addressController.text,
      "state_id": myStateSelection,
      "city_id": myCitySelection,
      "pincode": _pinCodeController.text,
      "payment_type": myPaymentSelection,
      "user_type": Auth.check()! ? 1 : 2
    };

    Api.http
        .post('shopping/shipping/order-confirm', data: sendData)
        .then((response) {
      if (response.data['status']) {
        orderId = response.data['order']['id'];
        if (myPaymentSelection == "2") {
          Get.toNamed(
            '/payment-web-view',
            arguments: response.data['webPaymentUrl'],
          )?.then((value) {
            if (value != null) {
              Get.toNamed(
                '/shopping-thanks',
                arguments: orderId,
              );
            }
          });
        } else {
          Get.toNamed('/shopping-thanks', arguments: orderId);
        }
      } else {
        AppUtils.showErrorSnackBar(response.data['data']);
      }
    }).catchError((error) {
      if (error.response.statusCode == 422) {
        setState(() {
          validator.setErrors(error.response.data['errors']);
        });
      } else {
        GetBar(
          duration: Duration(seconds: 5),
          message: error.response.data['error'],
          backgroundColor: Colors.red,
        ).show();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
