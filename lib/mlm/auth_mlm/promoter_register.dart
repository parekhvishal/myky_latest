import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:myky_clone/utils/en_extensions.dart';
import 'package:nb_utils/nb_utils.dart' hide white;
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/Vapor.dart';
import '../../services/api.dart';
import '../../services/getImage_service.dart';
import '../../services/upi_apps_service.dart';
import '../../services/validator_x.dart';
import '../../utils/app_utils.dart';
import '../../widget/file_download_controller.dart';
import '../../widget/image_picker.dart';
import '../../widget/installed_app_list.dart';
import '../../widget/theme.dart';

class PromoterRegister extends StatefulWidget {
  const PromoterRegister({super.key});

  @override
  PromoterRegisterState createState() => PromoterRegisterState();
}

class PromoterRegisterState extends State<PromoterRegister> {
  final _registerFormKey = GlobalKey<FormState>();

  ValidatorX validator = ValidatorX();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _whatsappNumberController =
      TextEditingController();
  final TextEditingController _sponsorIdController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _shopAddressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomineeController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _shopPinCodeController = TextEditingController();

  bool isRemember = false;
  bool isVendor = false;
  bool isPetrolPump = false;

  List? citiesData, shopCitiesData;
  Map? stateData, shopStateData;
  String? cityId;
  String? myStateSelection, myShopStateSelection;
  String? myCitySelection, myShopCitySelection;

  String? categorySelection;
  String? subCategorySelection;
  String? countryCode;
  String? vendorSelection;

  int _sideVal = 1;

  List<dynamic>? categoryItems;
  List<dynamic>? vendorPercentageList;
  Map<String, dynamic>? selectedValue;
  List<Map<String, dynamic>> selectedItems = [];
  List selectedIds = [];

  String? sponsorName;
  bool isSponsorName = false;
  final format = DateFormat("dd-MM-yyyy");
  String? termCondition;
  String? qrImage;
  String? sponsorId;

  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  Map? arg;

  bool uploadingImage1 = false;
  bool uploadingImage2 = false;
  bool uploadingImage3 = false;
  bool uploadingImage4 = false;
  bool uploadingImage5 = false;
  bool uploadingProfile = false;

  String progressStringImage1 = "";
  String progressStringImage2 = "";
  String progressStringImage3 = "";
  String progressStringImage4 = "";
  String progressStringImage5 = "";
  String progressStringProfile = "";

  File? _image1;
  File? _image2;
  File? _image3;
  File? _image4;
  File? _image5;
  File? _profileImage;

  late UPIAppService appService;
  List<Map<String, String>> installedApps = [];

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

  Future getRegister() async {
    return await Api.http.get('member/terms-conditions').then((response) async {
      setState(() {
        termCondition = response.data['termsCondition'];
        qrImage = response.data['qrCodeImage'];

        sponsorId = response.data['sponsorCode'];
        if (arg != null) {
          _sponsorIdController.text = arg!['data']['referralCode'].toString();
        } else {
          _sponsorIdController.text = '';
        }
        fetchMemberName(_sponsorIdController.text);
      });
      return response.data;
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

  @override
  void initState() {
    if (Get.arguments != null) {
      arg = Get.arguments;
    }
    getDeviceLocation();
    getRegister();
    getSubCategory();
    getState(isShop: true);
    appService = Get.find<UPIAppService>();
    installedApps = appService.getInstalledApps();
    super.initState();
  }

  void _showUpiAppsBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 300,
          child: installedApps.isNotEmpty
              ? InstalledAppList(installedApps: installedApps)
              : const SizedBox.shrink(),
        );
      },
    );
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
        title: text('PROMOTER SIGNUP'),
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  _buildProfileImage(context),
                                  Center(
                                    child: text(
                                        'Upload passport size photo for ID card',
                                        textColor: redColor,
                                        isCentered: true,
                                        maxLine: 2),
                                  ),
                                  10.heightBox,
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
                                  const SizedBox(height: 10),
                                  if (sponsorName == null)
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.black),
                                        children: [
                                          const TextSpan(
                                              text:
                                                  "Please contact customer care "),
                                          TextSpan(
                                            text: "+91 9054949498",
                                            style: const TextStyle(
                                                color: Colors.blue,
                                                decoration:
                                                    TextDecoration.underline),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () async {
                                                final Uri phoneUri = Uri.parse(
                                                    "tel:+919054949498");
                                                if (await canLaunchUrl(
                                                    phoneUri)) {
                                                  await launchUrl(phoneUri);
                                                } else {
                                                  throw 'Could not launch $phoneUri';
                                                }
                                              },
                                          ),
                                          const TextSpan(
                                              text: " for sponsor Id"),
                                        ],
                                      ),
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
                                  TextFormField(
                                    controller: _dobController,
                                    readOnly: true,
                                    onTap: () =>
                                        _showBottomSheetDOBPicker(context),
                                    validator: (value) {
                                      final date = value?.isNotEmpty == true
                                          ? DateTime.tryParse(value!)
                                          : null;
                                      return _validateDOB(date);
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(0xFFf7f7f7),
                                      hintText: 'Select your DOB',
                                      prefixIcon: const Icon(
                                        Icons.date_range,
                                        color: Colors.grey,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
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
                                  const SizedBox(height: 10),
                                  formField(
                                    context,
                                    'Nominee Name',
                                    prefixIcon: UniconsLine.user,
                                    controller: _nomineeController,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'^[- ,.]'))
                                    ],
                                    validator: validator.add(
                                      key: 'nominee_name',
                                      rules: [
                                        ValidatorX.mandatory(
                                            message:
                                                "Nominee name field is required"),
                                      ],
                                    ),
                                    onChanged: (String? value) {
                                      validator.clearErrorsAt('nominee_name');
                                    },
                                  ),
                                  const SizedBox(height: 10.0),
                                  Container(
                                      padding: const EdgeInsets.all(12),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10.0),
                                          _buildPaymentDetailRow(
                                              "Bank Name :", "Kerala Bank"),
                                          10.heightBox,
                                          _buildPaymentDetailRow(
                                              "Account Name :",
                                              "Luck and Belief Marketing Solutions Pvt Ltd"),
                                          10.heightBox,
                                          _buildPaymentDetailRow(
                                              "Account Number :",
                                              "115410801200120"),
                                          10.heightBox,
                                          _buildPaymentDetailRow(
                                              "IFSC Code :", " KSBK0001154"),
                                          10.heightBox,
                                          _buildUPIRow(context),
                                          const SizedBox(height: 10.0),
                                          buildPayButton(),
                                          const SizedBox(height: 10.0),
                                          Center(
                                              child: GestureDetector(
                                            onTap: () {
                                              FileDownloadCtrl().download(
                                                qrImage!,
                                                context,
                                              );
                                            },
                                            child: text('Download QR Image',
                                                fontSize: 10.0),
                                          ))
                                        ],
                                      )),
                                  const SizedBox(height: 10.0),
                                  text(
                                    'Payment Screenshot ',
                                    fontweight: FontWeight.bold,
                                  ),
                                  const SizedBox(height: 10.0),
                                  Stack(
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
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            if (!uploadingImage5)
                                              _image5 != null
                                                  ? Image.file(
                                                      _image5!,
                                                      width: double.infinity,
                                                      height: 200,
                                                      fit: BoxFit.contain,
                                                    )
                                                  : Center(
                                                      child: SizedBox(
                                                      height: 200,
                                                      child: Center(
                                                        child: text(
                                                          'Attach screenshot',
                                                        ),
                                                      ),
                                                    )),
                                            if (uploadingImage5)
                                              const SizedBox(
                                                height: 200,
                                                width: double.infinity,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
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
                                          border:
                                              Border.all(color: colorPrimary),
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            GetImageFromDevice.instance
                                                .getImage(
                                                    ImgSource.both, context)
                                                .then((file) {
                                              if (file != null) {
                                                _image5 = file;
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
                                    10.height,
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

                                    if (!isPetrolPump) ...[
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
                                                  _onDropdownChanged(newValue!);
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
                                      const SizedBox(height: 10),
                                    ],
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
                                    // SizedBox(height: 10),
                                    // if (categoryList.length > 0) _categoryDropdown(),
                                    // if (subCategoryList.length > 0) SizedBox(height: 10),
                                    // if (subCategoryList.length > 0) _subCategoryDropdown(),
                                    const SizedBox(height: 10),
                                    formField(
                                      context,
                                      'GST Number',
                                      prefixIcon: UniconsLine.user,
                                      controller: _gstController,
                                      textCapitalization:
                                          TextCapitalization.characters,
                                      textInputAction: TextInputAction.next,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                            RegExp(r'^[- ,.]'))
                                      ],
                                      validator: validator.add(
                                        key: 'gst_number',
                                        rules: [],
                                      ),
                                      onChanged: (String? value) {
                                        validator.clearErrorsAt('gst_number');
                                      },
                                    ),
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
                                    const SizedBox(height: 10),
                                  ],
                                  Container(
                                    margin: const EdgeInsets.only(left: 0),
                                    child: Row(
                                      children: <Widget>[
                                        Checkbox(
                                          focusColor: colorPrimary,
                                          activeColor: colorPrimary,
                                          value: isRemember,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              isRemember = value!;
                                            });
                                          },
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  Terms(term: termCondition),
                                            );
                                          },
                                          child: RichText(
                                            text: TextSpan(
                                              text: "I agree to the ",
                                              style: const TextStyle(
                                                color: Colors.black,
                                                height: 1.5,
                                                fontSize: 14,
                                                fontFamily: fontRegular,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: 'Terms & Conditions.',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: colorPrimary,
                                                    fontFamily: fontBold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                  CustomButton(
                                    textContent: 'Sign Up',
                                    onPressed: () async {
                                      if (_registerFormKey.currentState!
                                          .validate()) {
                                        FocusScope.of(context).unfocus();

                                        if (!isRemember) {
                                          AppUtils.showErrorSnackBar(
                                              "You need to accept terms & conditions");

                                          return;
                                        }
                                        if (_image5 == null) {
                                          AppUtils.showErrorSnackBar(
                                              "Please attach payment proof");

                                          return;
                                        }
                                        if (_profileImage == null) {
                                          AppUtils.showErrorSnackBar(
                                              "Please attach profile image");

                                          return;
                                        }

                                        showLoadingDialog(
                                            context); // Show loading dialog

                                        try {
                                          List<String> subImagesList = [];
                                          String? profileImage;
                                          String? paymentProof;

                                          List<Future<String?>> uploadTasks =
                                              [];

                                          // Map of images to upload
                                          final imageMap = {
                                            _image1: 'Image 1',
                                            _image2: 'Image 2',
                                            _image3: 'Image 3',
                                            _image4: 'Image 4',
                                          };

                                          imageMap.forEach((image, label) {
                                            if (image != null) {
                                              uploadTasks.add(
                                                  uploadImage(image, label));
                                            }
                                          });

                                          if (_profileImage != null) {
                                            uploadTasks.add(uploadImage(
                                                    _profileImage,
                                                    'Profile Image')
                                                .then((img) {
                                              profileImage = img;
                                            }));
                                          }

                                          if (_image5 != null) {
                                            uploadTasks.add(uploadImage(
                                                    _image5, 'Payment Proof')
                                                .then((img) {
                                              paymentProof = img;
                                            }));
                                          }

                                          // Wait for all images to upload
                                          final uploadedImages =
                                              await Future.wait(uploadTasks);

                                          // Add regular images to subImagesList
                                          subImagesList.addAll(uploadedImages
                                              .whereType<String>());

                                          Map<String, dynamic> sendData = {
                                            'name': _nameController.text,
                                            'mobile': _mobileController.text,
                                            'whatsapp_no':
                                                _whatsappNumberController.text,
                                            'address': _addressController.text,
                                            'code': _sponsorIdController.text,
                                            'email': _emailController.text,
                                            'dob': _dobController.text,
                                            'nominee_name':
                                                _nomineeController.text,
                                            "is_vendor": isVendor,
                                            "isPetrolPump": isPetrolPump,
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
                                            if (isPetrolPump == false)
                                              "category_id": selectedIds,
                                            if (isPetrolPump == false)
                                              "vendor_percentage":
                                                  vendorSelection,
                                            "gst_number": _gstController.text,
                                            "sub_images":
                                                subImagesList, // Sub images
                                            "profile_image":
                                                profileImage, // Profile Image
                                            "payment_proof":
                                                paymentProof, // Payment Proof

                                            "latitude": position.latitude,
                                            "longitude": position.longitude,
                                          };

                                          final response = await Api.http.post(
                                              'member/promotor-register',
                                              data: sendData);

                                          Navigator.pop(
                                              context); // Close loading dialog

                                          if (response.data['status']) {
                                            showDialog(
                                              context: context,
                                              builder: (_) => SuccessBox(
                                                response.data['member_id']
                                                    .toString(),
                                                response.data['password']
                                                    .toString(),
                                              ),
                                            );
                                            clearForm();
                                          } else {
                                            showError(response.data['error']);
                                          }
                                        } catch (error) {
                                          Navigator.pop(
                                              context); // Close loading dialog
                                          handleError(error);
                                        }
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      text('Already have an account ?'),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        child: text(
                                          'Sign In',
                                          textColor: colorPrimary,
                                          fontFamily: fontBold,
                                        ),
                                        onTap: () {
                                          Get.back();
                                        },
                                      )
                                    ],
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
    _nomineeController.clear();
  }

  Widget _buildProfileImage(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(spacing_standard_new),
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: spacing_standard,
              margin: const EdgeInsets.all(spacing_control),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Column(
                    children: <Widget>[
                      if (!uploadingProfile)
                        _profileImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.file(
                                  _profileImage!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : SvgPicture.asset(
                                'assets/images/user_blank.svg',
                                width: 100,
                                height: 100,
                                placeholderBuilder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                      if (uploadingProfile)
                        SizedBox(
                          height: 85.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(progressStringProfile),
                              const CircularProgressIndicator(),
                            ],
                          ),
                        )
                    ],
                  )),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(spacing_control),
            margin: const EdgeInsets.only(bottom: 30, right: 15),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: white,
              border: Border.all(
                color: colorPrimary,
                width: 1,
              ),
            ),
            child: GestureDetector(
              onTap: () {
                GetImageFromDevice.instance
                    .getImage(ImgSource.both, context)
                    .then((file) {
                  if (file != null) {
                    _profileImage = file;
                    setState(() {});
                  }
                });
                // getImage(ImgSource.Both);
              },
              child: Icon(
                Icons.camera_alt,
                color: colorPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPayButton() {
    return GestureDetector(
      onTap: () {
        if (_nameController.text.isNotEmpty &&
            _mobileController.text.isNotEmpty &&
            _whatsappNumberController.text.isNotEmpty &&
            _addressController.text.isNotEmpty &&
            _pinCodeController.text.isNotEmpty &&
            _nomineeController.text.isNotEmpty) {
          HapticFeedback.heavyImpact(); // Adds haptic feedback
          _showUpiAppsBottomSheet();
          // _launchUPI();
        } else {
          AppUtils.showErrorSnackBar(
              'Kindly submit the necessary details as mentioned above."');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorPrimary,
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
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          child: Center(
            child: Text(
              "Pay ₹999",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ).paddingSymmetric(horizontal: 10);
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

  getSubCategory() {
    Api.http.get("member/vendor-category").then((response) {
      setState(() {
        categoryItems = response.data['vendorCategories'];
        vendorPercentageList = response.data['vendotPercentage'];
      });
      return response.data;
    });
  }

  Widget _buildPaymentDetailRow(String label, String value) {
    return Row(
      children: [
        text(label, fontweight: FontWeight.bold, fontSize: 13.0),
        const SizedBox(width: 5),
        Expanded(
          child: SelectableText(
            value,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 13.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUPIRow(BuildContext context) {
    return Row(
      children: [
        text("UPI ID :", fontweight: FontWeight.bold, fontSize: 13.0),
        const SizedBox(width: 8),
        Expanded(
          child: SelectableText("9656703607@okbizaxis",
              style: TextStyle(
                fontSize: 13.0,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              )),
        ),
        IconButton(
          icon: Icon(Icons.copy, color: Theme.of(context).primaryColor),
          onPressed: () {
            Clipboard.setData(
                const ClipboardData(text: "9656703607@okbizaxis"));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("UPI ID copied to clipboard")),
            );
          },
        ),
      ],
    );
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
          child: Text(paymentMode['name']),
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
                    Get.back();
                    Get.offAllNamed("/login-mlm");
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
