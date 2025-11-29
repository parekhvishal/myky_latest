import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:myky_clone/utils/en_extensions.dart';
import 'package:nb_utils/nb_utils.dart' hide white;
import 'package:unicons/unicons.dart';

import '../../services/Vapor.dart';
import '../../services/api.dart';
import '../../services/auth.dart';
import '../../services/getImage_service.dart';
import '../../services/validator_x.dart';
import '../../utils/app_utils.dart';
import '../../widget/image_picker.dart';
import '../../widget/theme.dart';

class VendorRegister extends StatefulWidget {
  const VendorRegister({super.key});

  @override
  VendorRegisterState createState() => VendorRegisterState();
}

class VendorRegisterState extends State<VendorRegister> {
  final _registerFormKey = GlobalKey<FormState>();

  String? accountType;
  final List _accountTypes = [
    {"type": "Saving", "value": 1},
    {"type": "Current", "value": 2},
  ];

  Widget accountTypeDropdown() {
    return DropdownButtonFormField<String>(
      isDense: true,
      isExpanded: true,
      validator: validator.add(
        key: 'account_type',
        rules: [
          ValidatorX.mandatory(message: "Select Your Account Type"),
        ],
      ),
      hint: const Text('Select Account Type'),
      value: accountType,
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(spacing_standard),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(spacing_standard),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        filled: true,
        fillColor: const Color(0xFFf7f7f7),
        hintText: 'Select',
        hintStyle: TextStyle(fontSize: textSizeMedium, color: Colors.grey[300]),
      ),
      onChanged: (String? newValue) {
        setState(() {
          accountType = newValue!;
        });
        validator.clearErrorsAt('accountType');
      },
      items: _accountTypes.map<DropdownMenuItem<String>>((type) {
        return DropdownMenuItem<String>(
          child: Text(type['type']),
          value: type['value'].toString(),
        );
      }).toList(),
    );
  }

  ValidatorX validator = ValidatorX();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _accountNumberConfirmationController =
      TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _bankBranchController = TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _whatsappNumberController =
      TextEditingController();
  final TextEditingController _sponsorIdController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _shopAddressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _shopPinCodeController = TextEditingController();

  List? citiesData, shopCitiesData;
  Map? stateData, shopStateData;
  String? cityId;
  String? myStateSelection, myShopStateSelection;
  String? myCitySelection, myShopCitySelection;

  String? categorySelection;
  String? subCategorySelection;
  String? countryCode;
  String? vendorSelection;
  bool isPetrolPump = false;

  String? sponsorName;
  bool isSponsorName = false;

  int _sideVal = 1;

  List<dynamic>? categoryItems;
  List<dynamic>? vendorPercentageList;
  Map<String, dynamic>? selectedValue;
  List<Map<String, dynamic>> selectedItems = [];
  List selectedIds = [];

  bool isVendor = false;

  final format = DateFormat("dd-MM-yyyy");
  String? termCondition;
  String? sponsorId;

  final Uri upiUri = Uri.parse(
      "upi://pay?pa=9656703607@okbizaxis&pn=Luck%20and%20Belief%20Marketing%20Solutions%20Pvt.Ltd&am=999&cu=INR");

  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  Map? arg;

  bool uploadingImage1 = false;
  bool uploadingImage2 = false;
  bool uploadingImage3 = false;
  bool uploadingImage4 = false;

  String progressStringImage1 = "";
  String progressStringImage2 = "";
  String progressStringImage3 = "";
  String progressStringImage4 = "";

  File? _image1;
  File? _image2;
  File? _image3;
  File? _image4;

  LatLng initPosition =
      const LatLng(0, 0); //initial Position cannot assign null values
  LatLng currentLatLng = const LatLng(
      0.0, 0.0); //initial currentPosition values cannot assign null values

  LocationPermission? permission;
  late Position position;

  void _onDropdownChanged(Map<String, dynamic> newValue) {
    setState(() {
      if (selectedItems.length < 3) {
        if (!selectedItems.contains(newValue)) {
          selectedItems.add(newValue);
          selectedIds =
              selectedItems.map((item) => item['id'].toString()).toList();
        }
      }
    });
  }

  String? _validateDOB(DateTime? date) {
    if (date == null && _dobController.text.isEmpty) {
      return 'Date of Birth is required';
    } else if (date != null &&
        DateTime.now().difference(date) < const Duration(days: 6570)) {
      return 'Only 18+ can join';
    } else {
      return null;
    }
  }

  void _showBottomSheetDOBPicker(BuildContext context) {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(1900),
      maxTime: DateTime.now(),
      onConfirm: (date) {
        setState(() {
          _dobController.text = date.toLocal().toString().split(' ')[0];
        });
      },
      currentTime: _dobController.text.isNotEmpty
          ? DateTime.tryParse(_dobController.text)
          : DateTime.now(),
      locale: LocaleType.en,
    );
  }

  Future getRegister() async {
    return await Api.http.get('member/terms-conditions').then((response) async {
      setState(() {
        termCondition = response.data['termsCondition'];
        sponsorId = response.data['sponsorCode'];
        if (arg != null) {
          _sponsorIdController.text = arg!['data']['referralCode'].toString();
        } else {
          _sponsorIdController.text = sponsorId!;
        }
        fetchMemberName(_sponsorIdController.text);
      });
      return response.data;
    });
  }

  void fetchMemberName(String value) {
    if (value.length == 6) {
      Api.httpWithoutLoader.post('member/member-detail',
          queryParameters: {"code": _sponsorIdController.text}).then((res) {
        setState(() {
          sponsorName = res.data['userName'];
        });
      }).catchError((err) {
        sponsorName = null;
        setState(() {});
      });
    } else {
      sponsorName = null;
      setState(() {});
    }
  }

  @override
  void initState() {
    getDeviceLocation();
    getRegister();

    getSubCategory();
    getState(isShop: true);
    super.initState();
  }

  //checkPermission before initialize the map
  void checkPermission() async {
    permission = await Geolocator.checkPermission();
    getCurrentLocation();
  }

  // get current location
  void getCurrentLocation() async {
    await Geolocator.getCurrentPosition().then((currLocation) {
      setState(() {
        currentLatLng = LatLng(currLocation.latitude, currLocation.longitude);
      });
    });
  }

  //Check permission status and currentPosition before render the map
  bool checkReady(LatLng? x, LocationPermission? y) {
    if (x == initPosition ||
        y == LocationPermission.denied ||
        y == LocationPermission.deniedForever) {
      return true;
    } else {
      return false;
    }
  }

  getDeviceLocation() async {
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        AppUtils.showErrorSnackBar(
            'Location permissions are permanently denied, we cannot request permissions.');
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
    }
    position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: text('MEMBER / VENDOR SIGN UP'),
      ),
      body: (permission != null)
          ? (permission == LocationPermission.whileInUse ||
                  permission == LocationPermission.always)
              ? SafeArea(
                  child: Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomLeft,
                            colors: [Color(0xFFF2F5F9), Color(0xFFB4C5D1)],
                          ),
                        ),
                        alignment: Alignment.bottomLeft,
                        child: SingleChildScrollView(
                          child: Container(
                            margin: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                            ),
                            child: Form(
                              key: _registerFormKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  formField(
                                    context,
                                    'Name',
                                    prefixIcon: UniconsLine.user,
                                    controller: _nameController,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'^[ -.,]'))
                                    ],
                                    validator: validator.add(
                                      key: 'name',
                                      rules: [
                                        ValidatorX.mandatory(
                                            message: "Name field is required"),
                                      ],
                                    ),
                                    onChanged: (value) {
                                      validator.clearErrorsAt('name');
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  formField(
                                    context,
                                    'Mobile Number',
                                    prefixIcon: UniconsLine.phone,
                                    controller: _mobileController,
                                    maxLength: 10,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'[ -.,]'))
                                    ],
                                    validator: validator.add(
                                      key: 'mobile',
                                      rules: [
                                        ValidatorX.custom((value, {key}) {
                                          String pattern = r'[6789][0-9]{9}$';
                                          RegExp regExp = new RegExp(pattern);
                                          if (value!.length == 0) {
                                            return "Mobile field is Required";
                                          } else if (value.length != 10) {
                                            return "Mobile number must 10 digits";
                                          } else if (!regExp.hasMatch(value)) {
                                            return "Mobile Number invalid";
                                          }
                                        })
                                      ],
                                    ),
                                    onChanged: (value) {
                                      validator.clearErrorsAt('mobile');
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  formField(
                                    context,
                                    'Whatsapp Number',
                                    prefixIcon: UniconsLine.whatsapp_alt,
                                    controller: _whatsappNumberController,
                                    maxLength: 10,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'[ -.,]'))
                                    ],
                                    validator: validator.add(
                                      key: 'whatsapp_no',
                                      rules: [
                                        ValidatorX.custom((value, {key}) {
                                          String pattern = r'[6789][0-9]{9}$';
                                          RegExp regExp = new RegExp(pattern);
                                          if (value!.length == 0) {
                                            return "Whatsapp number field is Required";
                                          } else if (value.length != 10) {
                                            return "Whatsapp number must 10 digits";
                                          } else if (!regExp.hasMatch(value)) {
                                            return "Whatsapp number invalid";
                                          }
                                        })
                                      ],
                                    ),
                                    onChanged: (value) {
                                      validator.clearErrorsAt('whatsapp_no');
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  formField(
                                    context,
                                    'Email ID',
                                    prefixIcon: UniconsLine.mailbox,
                                    controller: _emailController,
                                    textInputAction: TextInputAction.next,
                                    validator: validator.add(
                                      key: 'email',
                                      rules: [],
                                    ),
                                    onChanged: (value) {
                                      validator.clearErrorsAt('email');
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  formField(
                                    context,
                                    'Sponsor ID',
                                    prefixIcon: UniconsLine.arrow,
                                    controller: _sponsorIdController,
                                    keyboardType: TextInputType.number,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    textInputAction: TextInputAction.next,
                                    validator: validator.add(
                                      key: 'code',
                                      rules: [
                                        ValidatorX.mandatory(
                                            message:
                                                "Sponsor ID field is required"),
                                      ],
                                    ),
                                    onChanged: (value) {
                                      validator.clearErrorsAt('code');
                                      fetchMemberName(value!);
                                    },
                                  ),
                                  if (sponsorName != null)
                                    text(
                                      sponsorName!,
                                      fontSize: 15.0,
                                      fontFamily: fontBold,
                                      textColor: colorPrimary,
                                      isLongText: true,
                                    ),
                                  const SizedBox(height: 10),
                                  formField(
                                    context,
                                    'Address',
                                    prefixIcon: UniconsLine.home,
                                    controller: _addressController,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'^[ -.,]'))
                                    ],
                                    validator: validator.add(
                                      key: 'address',
                                      rules: [
                                        ValidatorX.mandatory(
                                            message:
                                                "Address field is required"),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  if (stateData != null) _stateDropdown(),
                                  if (citiesData != null)
                                    const SizedBox(height: 10),
                                  if (citiesData != null) _cityDropdown(),
                                  const SizedBox(height: 10),
                                  formField(
                                    context,
                                    'Pincode',
                                    prefixIcon: UniconsLine.location_pin_alt,
                                    controller: _pinCodeController,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(
                                        RegExp(r'^[- ,.]'),
                                      )
                                    ],
                                    validator: validator.add(
                                      key: 'pincode',
                                      rules: [
                                        ValidatorX.mandatory(
                                            message:
                                                "Pincode field is required"),
                                      ],
                                    ),
                                    onChanged: (String? value) {
                                      validator.clearErrorsAt('pincode');
                                    },
                                  ),
                                  SizedBox(height: 10),
                                  formField(
                                    context,
                                    'Account Holder Name',
                                    prefixIcon: Icons.person,
                                    controller: _accountNameController,
                                    keyboardType: TextInputType.text,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'^[ -.,]'))
                                    ],
                                    validator: validator.add(
                                      key: 'accountName',
                                      rules: [
                                        ValidatorX.mandatory(
                                            message:
                                                'Account holder name field is required'),
                                      ],
                                    ),
                                    onChanged: (String? value) {
                                      validator.clearErrorsAt('accountName');
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  formField(
                                    context,
                                    'Account Number',
                                    prefixIcon: Icons.numbers,
                                    controller: _accountNumberController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 18,
                                    obscureText: true,
                                    validator: validator.add(
                                      key: 'accountNumber',
                                      rules: [
                                        ValidatorX.mandatory(
                                            message:
                                                'Account number field is required'),
                                        ValidatorX.minLength(
                                            length: 9,
                                            message:
                                                'The account number must be between 9 and 18 digits')
                                      ],
                                    ),
                                    onChanged: (String? value) {
                                      validator.clearErrorsAt('accountNumber');
                                      validator.clearErrorsAt(
                                          'accountNumber_confirmation');
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  formField(
                                    context,
                                    'Re-Enter Account Number',
                                    prefixIcon: Icons.numbers,
                                    controller:
                                        _accountNumberConfirmationController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 18,
                                    validator: validator.add(
                                      key: 'accountNumber_confirmation',
                                      rules: [
                                        ValidatorX.mandatory(
                                            message:
                                                'Confirm account number field is required'),
                                        ValidatorX.minLength(
                                            length: 9,
                                            message:
                                                'The confirm account number must be between 9 and 18 digits'),
                                        ValidatorX.custom((value, {key}) {
                                          if (value != null &&
                                              _accountNumberController.text !=
                                                  value) {
                                            return "Account numbers don't match";
                                          }
                                          return null;
                                        })
                                      ],
                                    ),
                                    onChanged: (String? value) {
                                      validator.clearErrorsAt(
                                          'accountNumber_confirmation');
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  DropdownButtonFormField<String>(
                                    isDense: true,
                                    isExpanded: true,
                                    validator: validator.add(
                                      key: 'accountType',
                                      rules: [
                                        ValidatorX.mandatory(
                                            message:
                                                "Select your account type"),
                                      ],
                                    ),
                                    hint:
                                        const Text('Select your account type'),
                                    value: accountType,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelStyle: primaryTextStyle(
                                        size: 16,
                                        color:
                                            textColorPrimary.withOpacity(0.7),
                                        fontFamily: fontMedium,
                                      ),
                                      // prefixIcon: prefixIcon,
                                      enabledBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black12)),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: colorPrimary)),
                                    ),
                                    onChanged: (String? newValue) {
                                      validator.clearErrorsAt('accountType');
                                      setState(() {
                                        accountType = newValue!;
                                      });
                                    },
                                    items: _accountTypes
                                        .map<DropdownMenuItem<String>>((type) {
                                      return DropdownMenuItem<String>(
                                        child: Text(type['type']),
                                        value: type['value'].toString(),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 10),
                                  formField(
                                    context,
                                    prefixIcon: Icons.code,
                                    'IFSC Code',
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'^[ ,-]'))
                                    ],
                                    controller: _ifscCodeController,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    onChanged: (value) {
                                      validator.clearErrorsAt('bankIfsc');
                                      if (value!.length == 11) {
                                        Api.httpWithoutBaseUrl
                                            .get('https://ifsc.razorpay.com/' +
                                                _ifscCodeController.text)
                                            .then((res) {
                                          setState(() {
                                            _bankNameController.text =
                                                res.data['BANK'];
                                            _bankBranchController.text =
                                                res.data['BRANCH'];
                                          });
                                        }).catchError((err) {
                                          setState(() {
                                            _bankNameController.text = '';
                                            _bankBranchController.text = '';
                                          });
                                        });
                                      } else {
                                        setState(() {
                                          _bankNameController.text = '';
                                          _bankBranchController.text = '';
                                        });
                                      }
                                    },
                                    validator: validator.add(
                                      key: 'bankIfsc',
                                      rules: [
                                        ValidatorX.mandatory(
                                            message: 'IFSC code is required'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  formField(
                                    context,
                                    prefixIcon: Icons.money_sharp,
                                    'Bank Name',
                                    controller: _bankNameController,
                                    validator: validator.add(
                                      key: 'bankName',
                                      rules: [
                                        ValidatorX.mandatory(
                                            message:
                                                'Bank name field is required'),
                                      ],
                                    ),
                                    onChanged: (String? value) {
                                      validator.clearErrorsAt('bankName');
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  formField(
                                    context,
                                    prefixIcon: Icons.money_sharp,
                                    'Bank Branch',
                                    controller: _bankBranchController,
                                    validator: validator.add(
                                      key: 'bankBranch',
                                      rules: [
                                        ValidatorX.mandatory(
                                            message:
                                                'Bank branch field is required'),
                                      ],
                                    ),
                                    onChanged: (String? value) {
                                      validator.clearErrorsAt('bankBranch');
                                    },
                                  ),
                                  const SizedBox(height: 10.0),
                                  Container(
                                    margin: const EdgeInsets.only(left: 0),
                                    child: Row(
                                      children: <Widget>[
                                        Checkbox(
                                          focusColor: colorPrimary,
                                          activeColor: colorPrimary,
                                          value: isVendor,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              isVendor = value!;
                                            });
                                          },
                                        ),
                                        text('Are you a shop owner?'),
                                      ],
                                    ),
                                  ),
                                  if (isVendor) ...[
                                    formField(
                                      context,
                                      'Shop Name',
                                      prefixIcon: UniconsLine.shop,
                                      controller: _shopNameController,
                                      textInputAction: TextInputAction.next,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                            RegExp(r'^[- ,.]'))
                                      ],
                                      validator: validator.add(
                                        key: 'shop_name',
                                        rules: [
                                          ValidatorX.mandatory(
                                              message:
                                                  "Shop name field is required"),
                                        ],
                                      ),
                                      onChanged: (String? value) {
                                        validator.clearErrorsAt('shop_name');
                                      },
                                    ),
                                    10.height,
                                    Container(
                                      margin: const EdgeInsets.only(left: 0),
                                      child: Row(
                                        children: <Widget>[
                                          Checkbox(
                                            focusColor: colorPrimary,
                                            activeColor: colorPrimary,
                                            value: isPetrolPump,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                isPetrolPump = value!;
                                              });
                                            },
                                          ),
                                          Flexible(
                                            child: text(
                                              "Do you want to add Petrol Pump as a category?",
                                              maxLine: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isPetrolPump) ...[
                                      10.height,
                                      if (categoryItems != null)
                                        Container(
                                          decoration: boxDecoration(
                                              radius: 6,
                                              showShadow: false,
                                              bgColor: const Color(0xFFf7f7f7)),
                                          // decoration: boxDecoration(radius: 6, showShadow: false, bgColor: white),
                                          child: Row(
                                            children: [
                                              Center(
                                                child: const Icon(
                                                  Icons.category,
                                                  color: textColorSecondary,
                                                  size: 20,
                                                ).paddingOnly(
                                                    left: 15.0, right: 12.0),
                                              ),
                                              DropdownButtonHideUnderline(
                                                child: DropdownButton<
                                                    Map<String, dynamic>>(
                                                  isExpanded: true,
                                                  hint: const Text(
                                                    'Select up to 3 category',
                                                    style: TextStyle(
                                                      fontSize: textSizeMedium,
                                                      color: textColorSecondary,
                                                    ),
                                                  ),
                                                  onChanged: (newValue) {
                                                    _onDropdownChanged(
                                                        newValue!);
                                                  },
                                                  items: categoryItems!
                                                      .where((item) =>
                                                          !selectedItems
                                                              .contains(item))
                                                      .map((item) {
                                                    return DropdownMenuItem<
                                                        Map<String, dynamic>>(
                                                      value: item,
                                                      child: Text(item['name']),
                                                    );
                                                  }).toList(),
                                                ),
                                              ).expand(),
                                            ],
                                          ),
                                        ),
                                      if (selectedItems.length > 0) ...[
                                        10.height,
                                        const Text('Selected category :'),
                                        5.height,
                                        Wrap(
                                          spacing: 8,
                                          children: selectedItems.map((item) {
                                            return Chip(
                                              label: Text(item['name']),
                                              onDeleted: () {
                                                setState(() {
                                                  selectedItems.remove(item);
                                                });
                                              },
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                      const SizedBox(height: 10),
                                      _selectVendorPercetageDropdown(),
                                    ],
                                    const SizedBox(height: 10),
                                    formField(
                                      context,
                                      'Shop Address',
                                      prefixIcon: UniconsLine.home,
                                      controller: _shopAddressController,
                                      textCapitalization:
                                          TextCapitalization.characters,
                                      textInputAction: TextInputAction.next,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                            RegExp(r'^[ -.,]'))
                                      ],
                                      validator: validator.add(
                                        key: 'shop_address',
                                        rules: [
                                          ValidatorX.mandatory(
                                              message:
                                                  "Shop address field is required"),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    if (shopStateData != null)
                                      _pickUpstateDropdown(),
                                    if (shopCitiesData != null)
                                      const SizedBox(height: 10),
                                    if (shopCitiesData != null)
                                      _pickUpCityDropdown(),
                                    const SizedBox(height: 10),
                                    formField(
                                      context,
                                      'Shop Pincode',
                                      prefixIcon: UniconsLine.location_pin_alt,
                                      controller: _shopPinCodeController,
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.number,
                                      maxLength: 6,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                            RegExp(r'^[- ,.]'))
                                      ],
                                      validator: validator.add(
                                        key: 'shop_pincode',
                                        rules: [
                                          ValidatorX.mandatory(
                                              message:
                                                  "Shop pincode field is required"),
                                        ],
                                      ),
                                      onChanged: (String? value) {
                                        validator.clearErrorsAt('shop_pincode');
                                      },
                                    ),
                                    // if (categoryList.length > 0) _categoryDropdown(),
                                    // if (subCategoryList.length > 0) SizedBox(height: 10),
                                    // if (subCategoryList.length > 0) _subCategoryDropdown(),

                                    const SizedBox(height: 10),
                                    Text(
                                      ' Front image of shop',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Stack(
                                            alignment: Alignment.topRight,
                                            children: [
                                              Card(
                                                semanticContainer: true,
                                                clipBehavior:
                                                    Clip.antiAliasWithSaveLayer,
                                                margin: const EdgeInsets.all(
                                                    spacing_control),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Column(
                                                  children: <Widget>[
                                                    if (!uploadingImage1)
                                                      _image1 != null
                                                          ? Image.file(
                                                              _image1!,
                                                              width: double
                                                                  .infinity,
                                                              height: 100,
                                                              fit: BoxFit
                                                                  .contain,
                                                            )
                                                          : Image.asset(
                                                              'assets/images/no_image.png',
                                                              width: double
                                                                  .infinity,
                                                              height: 100,
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                    if (uploadingImage1)
                                                      const SizedBox(
                                                        height: 100,
                                                        width: double.infinity,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            CircularProgressIndicator(),
                                                          ],
                                                        ),
                                                      )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.all(
                                                    spacing_control),
                                                margin: const EdgeInsets.only(
                                                    top: 15, right: 10),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: white_color,
                                                  border: Border.all(
                                                      color: colorPrimary),
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    GetImageFromDevice.instance
                                                        .getImage(
                                                            ImgSource.both,
                                                            context)
                                                        .then((file) {
                                                      if (file != null) {
                                                        _image1 = file;
                                                        setState(() {});
                                                      }
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.camera_alt,
                                                    color: colorPrimary,
                                                    size: 15,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Stack(
                                            alignment: Alignment.topRight,
                                            children: [
                                              Card(
                                                semanticContainer: true,
                                                clipBehavior:
                                                    Clip.antiAliasWithSaveLayer,
                                                margin: const EdgeInsets.all(
                                                    spacing_control),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Column(
                                                  children: <Widget>[
                                                    if (!uploadingImage2)
                                                      _image2 != null
                                                          ? Image.file(
                                                              _image2!,
                                                              width: double
                                                                  .infinity,
                                                              height: 100,
                                                              fit: BoxFit
                                                                  .contain,
                                                            )
                                                          : Image.asset(
                                                              'assets/images/no_image.png',
                                                              width: double
                                                                  .infinity,
                                                              height: 100,
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                    if (uploadingImage2)
                                                      const SizedBox(
                                                        height: 100,
                                                        width: double.infinity,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            CircularProgressIndicator(),
                                                          ],
                                                        ),
                                                      )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.all(
                                                    spacing_control),
                                                margin: const EdgeInsets.only(
                                                    top: 15, right: 10),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: white_color,
                                                  border: Border.all(
                                                      color: colorPrimary),
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    GetImageFromDevice.instance
                                                        .getImage(
                                                            ImgSource.both,
                                                            context)
                                                        .then((file) {
                                                      if (file != null) {
                                                        _image2 = file;
                                                        setState(() {});
                                                      }
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.camera_alt,
                                                    color: colorPrimary,
                                                    size: 15,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Stack(
                                            alignment: Alignment.topRight,
                                            children: [
                                              Card(
                                                semanticContainer: true,
                                                clipBehavior:
                                                    Clip.antiAliasWithSaveLayer,
                                                margin: const EdgeInsets.all(
                                                    spacing_control),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Column(
                                                  children: <Widget>[
                                                    if (!uploadingImage3)
                                                      _image3 != null
                                                          ? Image.file(
                                                              _image3!,
                                                              width: double
                                                                  .infinity,
                                                              height: 100,
                                                              fit: BoxFit
                                                                  .contain,
                                                            )
                                                          : Image.asset(
                                                              'assets/images/no_image.png',
                                                              width: double
                                                                  .infinity,
                                                              height: 100,
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                    if (uploadingImage3)
                                                      const SizedBox(
                                                        height: 100,
                                                        width: double.infinity,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            CircularProgressIndicator(),
                                                          ],
                                                        ),
                                                      )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.all(
                                                    spacing_control),
                                                margin: const EdgeInsets.only(
                                                    top: 15, right: 10),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: white_color,
                                                  border: Border.all(
                                                      color: colorPrimary),
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    GetImageFromDevice.instance
                                                        .getImage(
                                                            ImgSource.both,
                                                            context)
                                                        .then((file) {
                                                      if (file != null) {
                                                        _image3 = file;
                                                        setState(() {});
                                                      }
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.camera_alt,
                                                    color: colorPrimary,
                                                    size: 15,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Stack(
                                            alignment: Alignment.topRight,
                                            children: [
                                              Card(
                                                semanticContainer: true,
                                                clipBehavior:
                                                    Clip.antiAliasWithSaveLayer,
                                                margin: const EdgeInsets.all(
                                                    spacing_control),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Column(
                                                  children: <Widget>[
                                                    if (!uploadingImage4)
                                                      _image4 != null
                                                          ? Image.file(
                                                              _image4!,
                                                              width: double
                                                                  .infinity,
                                                              height: 100,
                                                              fit: BoxFit
                                                                  .contain,
                                                            )
                                                          : Image.asset(
                                                              'assets/images/no_image.png',
                                                              width: double
                                                                  .infinity,
                                                              height: 100,
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                    if (uploadingImage4)
                                                      const SizedBox(
                                                        height: 100,
                                                        width: double.infinity,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            CircularProgressIndicator(),
                                                          ],
                                                        ),
                                                      )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.all(
                                                    spacing_control),
                                                margin: const EdgeInsets.only(
                                                    top: 15, right: 10),
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: white_color,
                                                    border: Border.all(
                                                        color: colorPrimary)),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    GetImageFromDevice.instance
                                                        .getImage(
                                                            ImgSource.both,
                                                            context)
                                                        .then((file) {
                                                      if (file != null) {
                                                        _image4 = file;
                                                        setState(() {});
                                                      }
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.camera_alt,
                                                    color: colorPrimary,
                                                    size: 15,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 10),
                                  CustomButton(
                                    textContent: 'Sign Up',
                                    onPressed: () async {
                                      if (_registerFormKey.currentState!
                                          .validate()) {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());

                                        if (false) {
                                          const GetBar(
                                            backgroundColor: Colors.red,
                                            duration: Duration(seconds: 3),
                                            message:
                                                'You need to accept terms & conditions',
                                          ).show();
                                        } else {
                                          List subImagesList = [];

                                          dynamic image1;
                                          dynamic image2;
                                          dynamic image3;
                                          dynamic image4;

                                          if (_image1 != null) {
                                            image1 = await Vapor.uploadRegister(
                                              _image1,
                                              progressCallback:
                                                  (int? completed, int? total) {
                                                setState(() {
                                                  if (completed != total) {
                                                    uploadingImage1 = true;
                                                    progressStringImage1 =
                                                        ((completed! / total!) *
                                                                    100)
                                                                .toStringAsFixed(
                                                                    0) +
                                                            "%";
                                                  } else {
                                                    uploadingImage1 = false;
                                                  }
                                                });
                                              },
                                            );
                                          }

                                          if (_image2 != null) {
                                            image2 = await Vapor.uploadRegister(
                                              _image2,
                                              progressCallback:
                                                  (int? completed, int? total) {
                                                setState(() {
                                                  if (completed != total) {
                                                    uploadingImage2 = true;
                                                    progressStringImage2 =
                                                        ((completed! / total!) *
                                                                    100)
                                                                .toStringAsFixed(
                                                                    0) +
                                                            "%";
                                                  } else {
                                                    uploadingImage2 = false;
                                                  }
                                                });
                                              },
                                            );
                                          }

                                          if (_image3 != null) {
                                            image3 = await Vapor.uploadRegister(
                                              _image3,
                                              progressCallback:
                                                  (int? completed, int? total) {
                                                setState(() {
                                                  if (completed != total) {
                                                    uploadingImage3 = true;
                                                    progressStringImage3 =
                                                        ((completed! / total!) *
                                                                    100)
                                                                .toStringAsFixed(
                                                                    0) +
                                                            "%";
                                                  } else {
                                                    uploadingImage3 = false;
                                                  }
                                                });
                                              },
                                            );
                                          }

                                          if (_image4 != null) {
                                            image4 = await Vapor.uploadRegister(
                                              _image4,
                                              progressCallback:
                                                  (int? completed, int? total) {
                                                setState(() {
                                                  if (completed != total) {
                                                    uploadingImage4 = true;
                                                    progressStringImage4 =
                                                        ((completed! / total!) *
                                                                    100)
                                                                .toStringAsFixed(
                                                                    0) +
                                                            "%";
                                                  } else {
                                                    uploadingImage4 = false;
                                                  }
                                                });
                                              },
                                            );
                                          }

                                          if (image1 != null)
                                            subImagesList.add(image1);
                                          if (image2 != null)
                                            subImagesList.add(image2);
                                          if (image3 != null)
                                            subImagesList.add(image3);
                                          if (image4 != null)
                                            subImagesList.add(image4);

                                          Map<String, dynamic> sendData = {
                                            'name': _nameController.text,
                                            'mobile': _mobileController.text,
                                            'whatsapp_no':
                                                _whatsappNumberController.text,
                                            'address': _addressController.text,
                                            'code': _sponsorIdController.text,
                                            'email': _emailController.text,
                                            'bankName':
                                                _bankNameController.text,
                                            'bankBranch':
                                                _bankBranchController.text,
                                            'bankIfsc':
                                                _ifscCodeController.text,
                                            'accountType': accountType,
                                            'accountName':
                                                _accountNameController.text,
                                            'accountNumber':
                                                _accountNumberController.text,
                                            'accountNumber_confirmation':
                                                _accountNumberConfirmationController
                                                    .text,
                                            "is_vendor": isVendor,
                                            "isPetrolPump": isPetrolPump,
                                            "dob": "1997-02-02",

                                            "shop_name":
                                                _shopNameController.text,
                                            "state_id": myStateSelection,
                                            "city_id": myCitySelection,
                                            "pincode": _pinCodeController.text,
                                            "shop_address":
                                                _shopAddressController.text,
                                            "shop_state_id":
                                                myShopStateSelection,
                                            "shop_city_id": myShopCitySelection,
                                            "shop_pincode":
                                                _shopPinCodeController.text,

                                            "sub_images":
                                                subImagesList, // Sub images

                                            if (isPetrolPump == false)
                                              "category_id": selectedIds,
                                            if (isPetrolPump == false)
                                              "vendor_percentage":
                                                  vendorSelection,
                                            "latitude": position.latitude,
                                            "longitude": position.longitude,
                                          };

                                          Api.http
                                              .post('member/register',
                                                  data: sendData)
                                              .then((res) async {
                                            if (res.data['status']) {
                                              // await checkGuestLogin();
                                              await Auth.login(
                                                token: res.data['token'],
                                                user: res.data['member'],
                                                isVendor: res.data['member']
                                                    ['isVendor'],
                                              );
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder:
                                                    (BuildContext context) =>
                                                        SuccessBox(
                                                  res.data['member_id']
                                                      .toString(),
                                                  res.data['password']
                                                      .toString(),
                                                ),
                                              );

                                              setState(() {
                                                _nameController.clear();
                                                _mobileController.clear();
                                                _addressController.clear();
                                                _sponsorIdController.clear();
                                                _emailController.clear();
                                                _dobController.clear();
                                              });
                                            } else {
                                              GetBar(
                                                duration:
                                                    const Duration(seconds: 5),
                                                message: res.data['error'],
                                                backgroundColor: Colors.red,
                                              ).show();
                                            }
                                          }).catchError((error) {
                                            if (error.response.statusCode ==
                                                    401 ||
                                                error.response.statusCode ==
                                                    403) {
                                              GetBar(
                                                backgroundColor: Colors.red,
                                                duration:
                                                    const Duration(seconds: 5),
                                                message: error
                                                    .response.data['message'],
                                              ).show();
                                            }
                                            if (error.response.statusCode ==
                                                422) {
                                              setState(() {
                                                validator.setErrors(error
                                                    .response.data['errors']);
                                                // _errors = error.response.data['errors'];
                                              });
                                            }
                                          });
                                        }
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        15.heightBox,
                        Icon(
                          Icons
                              .signal_cellular_connected_no_internet_0_bar_outlined,
                          size: 100.sp,
                        ),
                        10.heightBox,
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        text(
                          "Unable to retrieve location",
                          fontFamily: fontBold,
                          isCentered: true,
                          fontSize: 12.sp,
                        ),
                        10.heightBox,
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 90.w),
                          child: CustomButton(
                            onPressed: () async {
                              getDeviceLocation();
                            },
                            textContent: 'Retry',
                          ),
                        ),
                      ],
                    ),
                  ],
                )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Future<String?> uploadImage(dynamic image, String label) async {
    return await Vapor.uploadRegister(
      image,
      progressCallback: (int? completed, int? total) {
        if (completed != total) {
          print(
              "$label Uploading: ${(completed! / total! * 100).toStringAsFixed(0)}%");
        }
      },
    );
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Uploading images, please wait..."),
          ],
        ),
      ),
    );
  }

  void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 5),
    );
  }

  void handleError(dynamic error) {
    if (error.response != null) {
      if (error.response.statusCode == 401 ||
          error.response.statusCode == 403) {
        showError(error.response.data['message']);
      } else if (error.response.statusCode == 422) {
        validator.setErrors(error.response.data['errors']);
      }
    } else {
      showError("An unexpected error occurred.");
    }
  }

  void clearForm() {
    _nameController.clear();
    _mobileController.clear();
    _addressController.clear();
    _sponsorIdController.clear();
    _emailController.clear();
    _dobController.clear();
  }

  Widget sideVal(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Row(
          children: <Widget>[
            Radio<int>(
              value: 1,
              groupValue: _sideVal,
              onChanged: (int? value) {
                setState(() => _sideVal = value!);
              },
            ),
            text('Left'),
          ],
        ),
        Row(
          children: <Widget>[
            Radio<int>(
                value: 2,
                groupValue: _sideVal,
                onChanged: (int? value) {
                  setState(
                    () => _sideVal = value!,
                  );
                }),
            text('Right'),
          ],
        ),
      ],
    );
  }

  getSubCategory() {
    Api.http.get("member/vendor-category").then((response) {
      setState(() {
        categoryItems = response.data['vendorCategories'];
        vendorPercentageList = response.data['vendotPercentage'];
      });
      return response.data;
    });
  }

  Widget _pickUpstateDropdown() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: DropdownButtonFormField<String>(
        isDense: true,
        isExpanded: true,
        validator: (String? value) {
          if (myShopStateSelection == null || myShopStateSelection!.isEmpty) {
            return "Please select state";
          }
          return null;
        },
        hint: text('Select State',
            fontSize: textSizeMedium, textColor: textColorSecondary),
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.add_location_alt,
            color: textColorSecondary,
            size: 20,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: whiteColor, width: 0.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: whiteColor, width: 0.0),
          ),
          border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black12)),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          // hintText: 'Select State',
          filled: true,
          fillColor: const Color(0xFFf7f7f7),
          hintStyle:
              const TextStyle(fontSize: textSizeMedium, color: Colors.black),
        ),
        value: myShopStateSelection,
        iconSize: 20,
        elevation: 16,
        onChanged: (String? newValue) {
          setState(() {
            myShopCitySelection = null;
            shopCitiesData = [];
            getCity(newValue!, isShop: true);
            validator.clearErrorsAt('shop_state_id');
            myShopStateSelection = newValue;
          });
        },
        items: shopStateData!['states'].map<DropdownMenuItem<String>>((state) {
          return DropdownMenuItem<String>(
            value: state['id'].toString(),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                state['name'].toString(),
                style: const TextStyle(color: Colors.black),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _selectVendorPercetageDropdown() {
    return DropdownButtonFormField<String>(
      isDense: true,
      isExpanded: true,
      validator: validator.add(
        key: 'vendor_percentage',
        rules: [
          ValidatorX.mandatory(message: "Select vendor percentage"),
        ],
      ),
      hint: text(
        'Select Vendor Percentage',
        fontSize: textSizeMedium,
        textColor: textColorPrimary.withOpacity(0.7),
        fontFamily: fontMedium,
      ),
      value: vendorSelection,
      decoration: const InputDecoration(
        border:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
      ),
      onChanged: (String? newValue) {
        validator.clearErrorsAt('vendor_percentage');
        setState(() {
          vendorSelection = newValue!;
        });
      },
      items: vendorPercentageList?.map<DropdownMenuItem<String>>((paymentMode) {
        return DropdownMenuItem<String>(
          value: paymentMode['id'].toString(),
          child: Text(paymentMode['name'].toString()),
        );
      }).toList(),
    );
  }

  Widget _pickUpCityDropdown() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: DropdownButtonFormField<String>(
        isDense: true,
        isExpanded: true,
        validator: (String? value) {
          if (myShopCitySelection == null || myShopCitySelection!.isEmpty) {
            return "Please select city";
          }
          return null;
        },
        hint: text('Select City',
            fontSize: textSizeMedium, textColor: textColorSecondary),
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.add_location_alt,
            color: textColorSecondary,
            size: 20,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: whiteColor, width: 0.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: whiteColor, width: 0.0),
          ),
          border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black12)),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          filled: true,
          fillColor: const Color(0xFFf7f7f7),
          // hintText: 'Select City',
          hintStyle:
              const TextStyle(fontSize: textSizeMedium, color: Colors.black),
        ),
        value: myShopCitySelection,
        iconSize: 20,
        elevation: 16,
        onChanged: (String? newValue) {
          validator.clearErrorsAt('shop_city_id');

          setState(() {
            myShopCitySelection = newValue!;
          });
        },
        items: shopCitiesData!.map<DropdownMenuItem<String>>((city) {
          return DropdownMenuItem<String>(
            value: city['id'].toString(),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                city['name'].toString(),
              ),
            ),
          );
        }).toList(),
      ),
    );
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
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              const Icon(
                UniconsLine.map_pin,
                size: 20,
                color: textColorSecondary,
              ),
              const SizedBox(
                width: 8,
              ),
              text('Select State'),
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
          border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black12)),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          // hintText: 'Select State',
          filled: true,
          fillColor: const Color(0xFFf7f7f7),
          hintStyle:
              const TextStyle(fontSize: textSizeMedium, color: Colors.black),
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
        },
        items: stateData!['states'].map<DropdownMenuItem<String>>((state) {
          return DropdownMenuItem<String>(
            value: state['id'].toString(),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                children: [
                  const Icon(
                    UniconsLine.map_pin,
                    size: 20,
                    color: textColorSecondary,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    state['name'].toString(),
                    style: const TextStyle(color: Colors.black),
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
      padding: const EdgeInsets.all(2.0),
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
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              const Icon(
                UniconsLine.map_pin,
                size: 20,
                color: textColorSecondary,
              ),
              const SizedBox(
                width: 8,
              ),
              text('Select City'),
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
          border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black12)),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          filled: true,
          fillColor: const Color(0xFFf7f7f7),
          // hintText: 'Select City',
          hintStyle:
              const TextStyle(fontSize: textSizeMedium, color: Colors.black),
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
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                children: [
                  const Icon(
                    UniconsLine.map_pin,
                    size: 20,
                    color: textColorSecondary,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    city['name'].toString(),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void getCity(String newValue, {bool isLoad = false, bool isShop = false}) {
    Api.http.get('shopping/cities/$newValue').then((value) {
      setState(() {
        if (isShop == true) {
          shopCitiesData = value.data['cities'];
          if (isLoad) myShopCitySelection = cityId.toString();
        } else {
          citiesData = value.data['cities'];
          if (isLoad) myCitySelection = cityId.toString();
        }
      });
    });
  }

  void getState({bool isShop = false}) {
    Api.http.get('shopping/states').then((response) {
      setState(() {
        if (isShop == true) {
          shopStateData = response.data;
        }
        stateData = response.data;
      });
    });
  }

  Future getImage1(ImgSource source) async {
    PickedFile image = await ImagePickerGC.pickImage(
      context: context,
      source: source,
      cameraIcon: const Icon(UniconsLine.camera),
      galleryIcon: const Icon(UniconsLine.image),
      cameraText: text("From Camera"),
      galleryText: text("From Gallery"),
      barrierDismissible: true,
    );
    setState(() {
      _image1 = File(image.path);
    });
  }

  Future getImage2(ImgSource source) async {
    PickedFile image = await ImagePickerGC.pickImage(
      context: context,
      source: source,
      cameraIcon: const Icon(UniconsLine.camera),
      galleryIcon: const Icon(UniconsLine.image),
      cameraText: text("From Camera"),
      galleryText: text("From Gallery"),
      barrierDismissible: true,
    );
    setState(() {
      _image2 = File(image.path);
    });
  }

  Future getImage3(ImgSource source) async {
    PickedFile image = await ImagePickerGC.pickImage(
      context: context,
      source: source,
      cameraIcon: const Icon(UniconsLine.camera),
      galleryIcon: const Icon(UniconsLine.image),
      cameraText: text("From Camera"),
      galleryText: text("From Gallery"),
      barrierDismissible: true,
    );
    setState(() {
      _image3 = File(image.path);
    });
  }

  Future getImage4(ImgSource source) async {
    PickedFile image = await ImagePickerGC.pickImage(
      context: context,
      source: source,
      cameraIcon: const Icon(UniconsLine.camera),
      galleryIcon: const Icon(UniconsLine.image),
      cameraText: text("From Camera"),
      galleryText: text("From Gallery"),
      barrierDismissible: true,
    );
    setState(() {
      _image4 = File(image.path);
    });
  }
}

class Terms extends StatelessWidget {
  final String? term;

  Terms({Key? key, @required this.term}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: termsCondition(context, term),
    );
  }
}

Widget termsCondition(BuildContext context, term) {
  return Container(
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
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min, // To make the card compact
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              15.widthBox,
              text(
                'Terms & Conditions',
                textColor: colorAccent,
                fontFamily: fontBold,
                fontSize: textSizeNormal,
              ).expand(),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.close,
                    color: colorAccent,
                  ),
                ),
              ),
            ],
          ),
          Html(
            data: term,
          ),
        ],
      ),
    ),
  );
}

class SuccessBox extends StatefulWidget {
  final String member;
  final String password;

  SuccessBox(this.member, this.password);

  @override
  _SuccessBoxState createState() => _SuccessBoxState();
}

class _SuccessBoxState extends State<SuccessBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: successBox(context, widget.member, widget.password),
    );
  }
}

Widget successBox(BuildContext context, String memberId, String password) {
  return Container(
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
        const SizedBox(height: 20),
        Container(
          width: 45,
          height: 45,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: green),
          child: const Icon(
            Icons.done,
            color: white,
          ),
        ),
        const SizedBox(height: 24),
        text(
          'Register Successfully',
          textColor: textColorPrimary,
          fontFamily: fontBold,
          fontSize: textSizeNormal,
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 30, right: 30, bottom: 16, top: 10),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              text(
                'Member ID : $memberId',
                textColor: textColorSecondary,
                fontFamily: fontMedium,
                fontSize: textSizeMedium,
                isLongText: true,
              ),
              text(
                'Password : $password',
                textColor: textColorSecondary,
                fontFamily: fontMedium,
                fontSize: textSizeMedium,
                isLongText: true,
              ),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Get.offAllNamed('/ecommerce');
                  },
                  child: const Text("Ok"),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
