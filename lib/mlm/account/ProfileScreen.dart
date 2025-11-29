import 'dart:async';
import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:myky_clone/utils/app_utils.dart';
import 'package:myky_clone/widget/confirmation_dialog.dart';
import 'package:nb_utils/nb_utils.dart' hide white;
import 'package:unicons/unicons.dart';

import '../../../../services/auth.dart';
import '../../services/Vapor.dart';
import '../../services/api.dart';
import '../../services/getImage_service.dart';
import '../../services/validator_x.dart';
import '../../widget/image_picker.dart';
import '../../widget/network_image.dart';
import '../../widget/theme.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _gender = 0;
  Map? userResponse;
  bool uploading = false;
  File? _image;
  String progressString = "";
  final format = DateFormat("dd-MM-yyyy");
  final _profileFormKey = GlobalKey<FormState>();
  ValidatorX validator = ValidatorX();
  List<dynamic>? categoryItems;
  Map<String, dynamic>? selectedValue;
  List<dynamic> selectedItems = [];
  List selectedIds = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _whatsappNumberController =
      TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nomineeController = TextEditingController();
  final TextEditingController _emailIDController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopAddressController = TextEditingController();
  final TextEditingController _shopPinCodeController = TextEditingController();

  late DateTime selectedDate;

  late String pinImageB64;

  late Future _profileApi;

  List? citiesData, shopCitiesData;
  Map? stateData, shopStateData;
  String? cityId, shopCityId;
  String? myStateSelection, myShopStateSelection;
  String? myCitySelection, myShopCitySelection;

  String? categorySelection;
  String? subCategorySelection;
  String? countryCode;

  List filteredList = [];

  // LatLng initPosition = LatLng(0, 0); //initial Position cannot assign null values
  // LatLng currentLatLng = LatLng(0.0, 0.0); //initial currentPosition values cannot assign null values
  // LocationPermission permission = LocationPermission.always; //initial permission status

  LocationPermission? permission;
  Position? position;

  void _onDropdownChanged(Map<String, dynamic> newValue) {
    dynamic id = selectedItems
        .firstWhere((item) => item['id'] == newValue['id'], orElse: () => -1);
    bool itemAlreadyAdded = id != -1;
    if (selectedItems.length < 3 && !itemAlreadyAdded) {
      selectedItems.add(newValue);
      selectedIds = selectedItems.map((item) => item['id'].toString()).toList();
      filterCategoryList();
    }
  }

  @override
  void initState() {
    _profileApi = getData();
    getState(isShop: true);
    super.initState();
  }

  getSubCategory() {
    Api.http.get("member/vendor-category").then((response) {
      categoryItems = response.data['vendorCategories'];
      filterCategoryList();
      return response.data;
    });
  }

  void filterCategoryList() {
    filteredList = [];
    filteredList.addAll(categoryItems!);
    if (selectedItems.length > 0) {
      for (Map item in selectedItems) {
        Map? itemFound = filteredList.firstWhere(
            (element) => element['id'] == item['id'],
            orElse: () => null);
        if (itemFound != null) {
          filteredList
              .removeWhere((element) => element['id'] == itemFound['id']);
        }
      }
      selectedValue = null;
    }
    setState(() {});
  }

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

  Future getData() async {
    await Api.http.get('member/profile').then((response) async {
      setState(() {
        userResponse = response.data;
        _nameController.text = userResponse!['name'] ?? "";
        _numberController.text = userResponse!['phone'] ?? "";
        _whatsappNumberController.text = userResponse!['whatsappNo'] ?? "";
        _addressController.text = userResponse!['address'] ?? "";
        _nomineeController.text = userResponse!['nomineeName'] ?? "";
        _businessNameController.text = userResponse!['business_name'] ?? "";
        _emailIDController.text = userResponse!['email'] ?? "";
        _gstController.text = userResponse!['gst_number'] ?? "";

        if (userResponse!['category'] != null &&
            userResponse!['category'].isNotEmpty) {
          selectedItems = userResponse!['category'];

          selectedIds =
              selectedItems.map((item) => item['id'].toString()).toList();

          getSubCategory();
        }
        _pinCodeController.text = userResponse!['pincode'] != null
            ? userResponse!['pincode'].toString()
            : "";
        if (userResponse!['dob'] != null && userResponse!['dob'] != "") {
          _dobController.text = formatDate(
            DateTime.parse(userResponse!['dob']).toLocal(),
            [dd, '-', mm, '-', yyyy],
          );
        }

        if (userResponse!['gender'] != null) {
          _gender = userResponse!['gender'];
        }

        if (response.data['state'] != null && response.data['state'] != '') {
          myStateSelection = response.data['state']['id'].toString();
        }
        if (response.data['city'] != null && response.data['city'] != '') {
          cityId = response.data['city']['id'].toString();
          getCity(myStateSelection!, isLoad: true);
        }

        _shopNameController.text = userResponse!['shopName'] ?? '';
        _gstController.text = userResponse!['gstNumber'] ?? '';

        _shopAddressController.text = userResponse!['shopAddress'] ?? '';
        _shopPinCodeController.text = userResponse!['shopPincode'].toString();

        if (response.data['ShopState'] != null &&
            response.data['ShopState'] != '') {
          myShopStateSelection = response.data['ShopState']['id'].toString();
        }
        if (response.data['ShopCity'] != null &&
            response.data['ShopCity'] != '') {
          shopCityId = response.data['ShopCity']['id'].toString();
          getCity(myShopStateSelection!, isLoad: true, isShop: true);
        }
      });
    });
  }

  String validateEmail(String? value) {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return 'Enter a valid email address';
    } else {
      return "";
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
    return scaffoldBackgroundImage(
      customBgImage: bg,
      fit: BoxFit.cover,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 2.0,
          title: const Text('Profile Section'),
        ),
        body: FutureBuilder(
          future: _profileApi,
          builder: (context, snapshot) {
            if (userResponse == null) {
              return const Center();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Form(
                key: _profileFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          _buildProfileImage(context),
                        ],
                      ),
                      // SizedBox(height: 40.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          // Padding(padding: const EdgeInsets.all(10.0)),
                          Row(
                            children: <Widget>[
                              Radio<int>(
                                value: 1,
                                groupValue: _gender,
                                onChanged: (int? value) {
                                  setState(() {
                                    _gender = value!;
                                  });
                                },
                              ),
                              const Text('Male'),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Radio<int>(
                                value: 2,
                                groupValue: _gender,
                                onChanged: (int? value) {
                                  setState(() {
                                    _gender = value!;
                                  });
                                },
                              ),
                              const Text('Female'),
                            ],
                          ),
                        ],
                      ),

                      formField(
                        context,
                        'Name',
                        prefixIcon: UniconsLine.user,
                        controller: _nameController,
                        textCapitalization: TextCapitalization.characters,
                        textInputAction: TextInputAction.next,
                        readOnly: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))
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
                      const SizedBox(height: 10.0),
                      formField(
                        context,
                        'Whatsapp Number',
                        prefixIcon: UniconsLine.whatsapp_alt,
                        controller: _whatsappNumberController,
                        maxLength: 10,
                        textCapitalization: TextCapitalization.characters,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))
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
                      const SizedBox(height: 10.0),
                      formField(
                        context,
                        'Mobile Number',
                        prefixIcon: UniconsLine.phone,
                        controller: _numberController,
                        maxLength: 10,
                        readOnly: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))
                        ],
                        validator: validator.add(
                          key: 'phone',
                          rules: [
                            ValidatorX.mandatory(
                                message: "Mobile Number field is required"),
                            ValidatorX.minLength(
                                length: 10,
                                message: "Mobile Number must be of 10 digit"),
                          ],
                        ),
                        onChanged: (value) {
                          validator.clearErrorsAt('phone');
                        },
                      ),
                      const SizedBox(height: 10.0),
                      DateTimeField(
                        controller: _dobController,
                        validator: (date) {
                          if (date == null && _dobController.text.isEmpty) {
                            return 'Date of Birth is required';
                          } else if (date != null &&
                              DateTime.now().difference(date) <
                                  const Duration(days: 6570)) {
                            return 'Only 18+ can join';
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(spacing_standard),
                            borderSide:
                                const BorderSide(color: Colors.transparent),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(spacing_standard),
                            borderSide:
                                const BorderSide(color: Colors.transparent),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 15),
                          counterText: "",
                          filled: true,
                          fillColor: const Color(0xFFf7f7f7),
                          hintText: 'Date of birth',
                          hintStyle: const TextStyle(
                              fontSize: textSizeMedium,
                              color: textColorSecondary),
                          prefixIcon: const Icon(
                            Icons.date_range,
                            color: textColorSecondary,
                            size: 20,
                          ),
                        ),
                        format: format,
                        onShowPicker: (context, currentValue) {
                          return showDatePicker(
                            context: context,
                            initialDate: currentValue ?? DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          ).then((res) {
                            if (res != null) {
                              _dobController.text =
                                  res.toLocal().toString().split(' ')[0];
                            }
                            return res;
                          });
                        },
                      ),
                      const SizedBox(height: 10.0),
                      formField(
                        context,
                        'address',
                        prefixIcon: UniconsLine.home,
                        controller: _addressController,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'^[ -.,]'))
                        ],
                        validator: validator.add(
                          key: 'address',
                          rules: [
                            ValidatorX.mandatory(
                                message: "Address field is required"),
                          ],
                        ),
                        onChanged: (value) {
                          validator.clearErrorsAt('address');
                        },
                      ),
                      const SizedBox(height: 10),
                      if (stateData != null) _stateDropdown(),
                      if (citiesData != null) const SizedBox(height: 10),
                      if (citiesData != null) _cityDropdown(),
                      const SizedBox(height: 10.0),
                      formField(
                        context,
                        'Pincode',
                        prefixIcon: Icons.pin_drop,
                        controller: _pinCodeController,
                        textInputAction: TextInputAction.next,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))
                        ],
                        validator: validator.add(
                          key: 'pincode',
                          rules: [
                            ValidatorX.mandatory(
                                message: "Pincode field is required"),
                          ],
                        ),
                        onChanged: (value) {
                          validator.clearErrorsAt('pincode');
                        },
                      ),
                      const SizedBox(height: 10.0),
                      formField(
                        context,
                        'Enter Email ID',
                        prefixIcon: Icons.email,
                        controller: _emailIDController,
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(
                            RegExp(r'^[ ]'),
                          ),
                        ],
                        validator: validator.add(
                          key: 'email',
                          rules: [
                            ValidatorX.mandatory(
                                message: "The Email ID can't be empty"),
                            ValidatorX.custom((value, {key}) {
                              bool emailValid = RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value!);
                              if (!emailValid && value.isNotEmpty) {
                                return 'Please enter valid Email ID';
                              }
                              return null;
                            }),
                          ],
                        ),
                        onChanged: (value) {
                          validator.clearErrorsAt('email');
                        },
                      ),
                      const SizedBox(height: 10.0),
                      formField(
                        context,
                        'Nominee Name',
                        prefixIcon: UniconsLine.user,
                        controller: _nomineeController,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'^[ -.,]'))
                        ],
                        validator: validator.add(
                          key: 'nomineeName',
                          rules: [
                            ValidatorX.mandatory(
                                message: "Nominee Name field is required"),
                          ],
                        ),
                        onChanged: (value) {
                          validator.clearErrorsAt('nomineeName');
                        },
                      ),
                      const SizedBox(height: 10.0),

                      if (Auth.isUserVendor != null && Auth.isUserVendor!) ...[
                        formField(
                          context,
                          'Shop Name',
                          prefixIcon: UniconsLine.shop,
                          controller: _shopNameController,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'^[- ,.]'))
                          ],
                          validator: validator.add(
                            key: 'shop_name',
                            rules: [
                              ValidatorX.mandatory(
                                  message: "Shop name is required"),
                            ],
                          ),
                          onChanged: (String? value) {
                            validator.clearErrorsAt('shop_name');
                          },
                        ),
                        const SizedBox(height: 10),
                        if (userResponse != null &&
                            userResponse!.isNotEmpty &&
                            categoryItems != null &&
                            categoryItems!.length > 0)
                          Row(
                            children: [
                              Center(
                                child: const Icon(
                                  Icons.category,
                                  color: textColorSecondary,
                                  size: 20,
                                ).paddingOnly(left: 15.0, right: 12.0),
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<Map<String, dynamic>>(
                                  isExpanded: true,
                                  value: selectedValue,
                                  hint: const Text('Select up to 3 category'),
                                  onChanged: (newValue) {
                                    _onDropdownChanged(newValue!);
                                  },
                                  items: categoryItems!
                                      .where((item) => !selectedItems.any(
                                          (element) =>
                                              element['id'] == item['id']))
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
                                  selectedItems.removeWhere(
                                      (element) => element['id'] == item['id']);
                                  filterCategoryList();

                                  // selectedValue = null;
                                },
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 10),
                        formField(
                          context,
                          'Shop Address',
                          prefixIcon: UniconsLine.home,
                          controller: _shopAddressController,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'^[ -.,]'))
                          ],
                          validator: validator.add(
                            key: 'shop_address',
                            rules: [
                              ValidatorX.mandatory(
                                  message: "Shop address field is required"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (shopStateData != null) _pickUpstateDropdown(),
                        if (shopCitiesData != null) const SizedBox(height: 10),
                        if (shopCitiesData != null) _pickUpCityDropdown(),
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
                            FilteringTextInputFormatter.deny(RegExp(r'^[- ,.]'))
                          ],
                          validator: validator.add(
                            key: 'shop_pincode',
                            rules: [
                              ValidatorX.mandatory(
                                  message: "Shop pincode field is required"),
                            ],
                          ),
                          onChanged: (String? value) {
                            validator.clearErrorsAt('shop_pincode');
                          },
                        ),
                        const SizedBox(height: 10),
                        formField(
                          context,
                          'GST Number',
                          prefixIcon: UniconsLine.file_landscape_alt,
                          controller: _gstController,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'^[- ,.]'))
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Card(
                                  semanticContainer: true,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  margin: const EdgeInsets.all(spacing_control),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      if (!uploadingImage1)
                                        _image1 != null
                                            ? Image.file(
                                                _image1!,
                                                width: 150,
                                                height: 100,
                                                fit: BoxFit.contain,
                                              )
                                            : userResponse!['vendorImages'] !=
                                                    null
                                                ? PNetworkImage(
                                                    userResponse![
                                                            'vendorImages'][0]
                                                        ['fileName'],
                                                    width: 150,
                                                    height: 100,
                                                    fit: BoxFit.contain,
                                                  )
                                                : Image.asset(
                                                    'assets/images/no_image.png',
                                                    width: 150,
                                                    height: 100,
                                                    fit: BoxFit.contain,
                                                  ),
                                      if (uploadingImage1)
                                        Container(
                                          height: 150,
                                          width: 100,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              const CircularProgressIndicator(),
                                              const SizedBox(height: 20.0),
                                              Text(
                                                "Uploading Image: $progressStringImage1 ",
                                              )
                                            ],
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.all(spacing_control),
                                  margin:
                                      const EdgeInsets.only(top: 15, right: 10),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: white_color,
                                      border: Border.all(color: colorPrimary)),
                                  child: GestureDetector(
                                    onTap: () {
                                      GetImageFromDevice.instance
                                          .getImage(ImgSource.both, context)
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
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Card(
                                  semanticContainer: true,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  margin: const EdgeInsets.all(spacing_control),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      if (!uploadingImage2)
                                        _image2 != null
                                            ? Image.file(
                                                _image2!,
                                                width: 150,
                                                height: 100,
                                                fit: BoxFit.contain,
                                              )
                                            : userResponse!['vendorImages'] !=
                                                        null &&
                                                    userResponse![
                                                                'vendorImages']
                                                            .length >
                                                        1
                                                ? PNetworkImage(
                                                    userResponse![
                                                            'vendorImages'][1]
                                                        ['fileName'],
                                                    width: 150,
                                                    height: 100,
                                                    fit: BoxFit.contain,
                                                  )
                                                : Image.asset(
                                                    'assets/images/no_image.png',
                                                    width: 150,
                                                    height: 100,
                                                    fit: BoxFit.contain,
                                                  ),
                                      if (uploadingImage2)
                                        Container(
                                          height: 150,
                                          width: 100,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              const CircularProgressIndicator(),
                                              const SizedBox(height: 20.0),
                                              Text(
                                                "Uploading Image: $progressStringImage2 ",
                                              )
                                            ],
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.all(spacing_control),
                                  margin:
                                      const EdgeInsets.only(top: 15, right: 10),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: white_color,
                                      border: Border.all(color: colorPrimary)),
                                  child: GestureDetector(
                                    onTap: () {
                                      GetImageFromDevice.instance
                                          .getImage(ImgSource.both, context)
                                          .then((file) {
                                        if (file != null) {
                                          _image2 = file;
                                          setState(() {});
                                        }
                                      });
                                      // getImage2(ImgSource.Both);
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
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Card(
                                  semanticContainer: true,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  margin: const EdgeInsets.all(spacing_control),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      if (!uploadingImage3)
                                        _image3 != null
                                            ? Image.file(
                                                _image3!,
                                                width: 150,
                                                height: 100,
                                                fit: BoxFit.contain,
                                              )
                                            : userResponse!['vendorImages'] !=
                                                        null &&
                                                    userResponse![
                                                                'vendorImages']
                                                            .length >
                                                        2
                                                ? PNetworkImage(
                                                    userResponse![
                                                            'vendorImages'][2]
                                                        ['fileName'],
                                                    width: 150,
                                                    height: 100,
                                                    fit: BoxFit.contain,
                                                  )
                                                : Image.asset(
                                                    'assets/images/no_image.png',
                                                    width: 150,
                                                    height: 100,
                                                    fit: BoxFit.contain,
                                                  ),
                                      if (uploadingImage3)
                                        Container(
                                          height: 150,
                                          width: 100,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              const CircularProgressIndicator(),
                                              const SizedBox(height: 20.0),
                                              Text(
                                                "Uploading Image: $progressStringImage3 ",
                                              )
                                            ],
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.all(spacing_control),
                                  margin:
                                      const EdgeInsets.only(top: 15, right: 10),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: white_color,
                                      border: Border.all(color: colorPrimary)),
                                  child: GestureDetector(
                                    onTap: () {
                                      GetImageFromDevice.instance
                                          .getImage(ImgSource.both, context)
                                          .then((file) {
                                        if (file != null) {
                                          _image3 = file;
                                          setState(() {});
                                        }
                                      });
                                      // getImage3(ImgSource.Both);
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
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Card(
                                  semanticContainer: true,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  margin: const EdgeInsets.all(spacing_control),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      if (!uploadingImage4)
                                        _image4 != null
                                            ? Image.file(
                                                _image4!,
                                                width: 150,
                                                height: 100,
                                                fit: BoxFit.contain,
                                              )
                                            : userResponse!['vendorImages'] !=
                                                        null &&
                                                    userResponse![
                                                                'vendorImages']
                                                            .length >
                                                        3
                                                ? PNetworkImage(
                                                    userResponse![
                                                            'vendorImages'][3]
                                                        ['fileName'],
                                                    width: 150,
                                                    height: 100,
                                                    fit: BoxFit.contain,
                                                  )
                                                : Image.asset(
                                                    'assets/images/no_image.png',
                                                    width: 150,
                                                    height: 100,
                                                    fit: BoxFit.contain,
                                                  ),
                                      if (uploadingImage4)
                                        Container(
                                          height: 150,
                                          width: 100,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              const CircularProgressIndicator(),
                                              const SizedBox(height: 20.0),
                                              Text(
                                                "Uploading Image: $progressStringImage4 ",
                                              )
                                            ],
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.all(spacing_control),
                                  margin:
                                      const EdgeInsets.only(top: 15, right: 10),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: white_color,
                                      border: Border.all(color: colorPrimary)),
                                  child: GestureDetector(
                                    onTap: () {
                                      GetImageFromDevice.instance
                                          .getImage(ImgSource.both, context)
                                          .then((file) {
                                        if (file != null) {
                                          _image4 = file;
                                          setState(() {});
                                        }
                                      });
                                      // getImage4(ImgSource.Both);
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
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Flexible(
                              child: text(
                                "Do you want to change your store current location with this location?",
                                isLongText: true,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: boxDecoration(
                                  bgColor: colorAccent, radius: 8.r),
                              padding: EdgeInsets.symmetric(
                                vertical: 5.h,
                                horizontal: 12.w,
                              ),
                              child: text(
                                "Update",
                                fontSize: 14.sp,
                                textColor: white_color,
                              ),
                            ).onTap(() {
                              // showDialog(
                              //     context: context,
                              //     builder: (context) => ConfirmationDialog(

                              showDialog(
                                context: context,
                                builder: (context) => ConfirmationDialog(
                                    title:
                                        "Are you sure you want to change location?",
                                    onPositiveClick: () {
                                      Get.back();
                                      getDeviceLocation();
                                    }),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 25.0),
                      Container(
                        width: double.infinity,
                        child: MaterialButton(
                          onPressed: () async {
                            if (_profileFormKey.currentState!.validate()) {
                              FocusScope.of(context).requestFocus(FocusNode());

                              dynamic profileImage;
                              if (_image != null) {
                                profileImage = await Vapor.upload(
                                  _image,
                                  progressCallback:
                                      (int? completed, int? total) {
                                    setState(() {
                                      uploading = true;
                                      progressString =
                                          ((completed! / total!) * 100)
                                                  .toStringAsFixed(0) +
                                              "%";
                                    });
                                  },
                                );

                                setState(() {
                                  uploading = false;
                                });
                              }

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
                                            ((completed! / total!) * 100)
                                                    .toStringAsFixed(0) +
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
                                            ((completed! / total!) * 100)
                                                    .toStringAsFixed(0) +
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
                                            ((completed! / total!) * 100)
                                                    .toStringAsFixed(0) +
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
                                            ((completed! / total!) * 100)
                                                    .toStringAsFixed(0) +
                                                "%";
                                      } else {
                                        uploadingImage4 = false;
                                      }
                                    });
                                  },
                                );
                              }

                              if (image1 != null) subImagesList.add(image1);
                              if (image2 != null) subImagesList.add(image2);
                              if (image3 != null) subImagesList.add(image3);
                              if (image4 != null) subImagesList.add(image4);

                              Map sendData = {
                                "name": _nameController.text,
                                "mobile": _numberController.text,
                                "whatsapp_no": _whatsappNumberController.text,
                                "address": _addressController.text,
                                "gender": _gender,
                                "dob": _dobController.text,
                                "profile": profileImage,
                                "nomineeName": _nomineeController.text,
                                "shop_name": _shopNameController.text,
                                "state_id": myStateSelection,
                                "city_id": myCitySelection,
                                "pincode": _pinCodeController.text,
                                "is_vendor": Auth.isUserVendor != null &&
                                        Auth.isUserVendor!
                                    ? 1
                                    : 0,
                                "category_id": selectedIds,
                                "sub_category_id": subCategorySelection,
                                "gst_number": _gstController.text,
                                "sub_images": subImagesList,
                                "business_name": _businessNameController.text,
                                "email": _emailIDController.text,
                                "shop_address": _shopAddressController.text,
                                "shop_state_id": myShopStateSelection,
                                "shop_city_id": myShopCitySelection,
                                "shop_pincode": _shopPinCodeController.text,
                                if (position != null)
                                  "latitude": position!.latitude,
                                if (position != null)
                                  "longitude": position!.longitude,
                              };

                              Api.http
                                  .post('member/profile/update', data: sendData)
                                  .then((response) async {
                                if (response.data['status']) {
                                  Map? exitingUser = Auth.user();

                                  exitingUser!['profileImage'] =
                                      response.data['member']['profileImage'];
                                  exitingUser['email'] =
                                      response.data['member']['user']['email'];
                                  Auth.updateUser(exitingUser);
                                  Get.back();

                                  AppUtils.showSuccessSnackBar(
                                      response.data['message']);
                                }
                              }).catchError((error) {
                                AppUtils.showErrorSnackBar(
                                    error.response.data['message']);

                                validator
                                    .setErrors(error.response.data['errors']);
                              });
                            }
                          },
                          child: const Text(
                            'SUBMIT',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          padding: const EdgeInsets.all(15.0),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildBusinessNameField(BuildContext context) {
    return formField(
      context,
      "Business Name",
      controller: _businessNameController,
      prefixIcon: UniconsLine.building,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]|[ ]+$'))
      ],
      validator: validator.add(
        rules: [
          ValidatorX.mandatory(message: "Business name field is required"),
        ],
        key: 'business_name',
      ),
      onChanged: (value) {
        validator.clearErrorsAt('business_name');
      },
    );
  }

  Widget buildGstNoField(BuildContext context) {
    return formField(
      context,
      "GST Number",
      controller: _gstController,
      prefixIcon: UniconsLine.card_atm,
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ -.,]'))],
      validator: validator.add(
        rules: [
          ValidatorX.mandatory(message: "GST number field is required"),
        ],
        key: 'gst_number',
      ),
      onChanged: (value) {
        validator.clearErrorsAt('gst_number');
      },
    );
  }

  Widget buildEmailField(BuildContext context) {
    return formField(
      context,
      "Email",
      controller: _emailIDController,
      prefixIcon: UniconsLine.envelope,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ -.,]'))],
      validator: validator.add(
        rules: [
          ValidatorX.email(message: "Email field is required"),
        ],
        key: 'email',
      ),
      onChanged: (value) {
        validator.clearErrorsAt('email');
      },
    );
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
                      if (!uploading)
                        _image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.file(
                                  _image!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : userResponse!['profileImage'] != null
                                ? PNetworkImage(
                                    userResponse!['profileImage'],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.contain,
                                  )
                                : Image.asset(
                                    'assets/images/no_image.png',
                                    fit: BoxFit.contain,
                                    // width: 100,
                                    // height: 100,
                                  ),
                      if (uploading)
                        Container(
                          height: 85.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(progressString),
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
                    _image = file;
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
            borderSide: BorderSide(color: whiteColor, width: 0.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: whiteColor, width: 0.0),
          ),
          border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black12)),
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          // hintText: 'Select State',
          filled: true,
          fillColor: Color(0xFFf7f7f7),
          hintStyle: TextStyle(fontSize: textSizeMedium, color: Colors.black),
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
                style: TextStyle(color: Colors.black),
              ),
            ),
          );
        }).toList(),
      ),
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
          prefixIcon: Icon(
            Icons.add_location_alt,
            color: textColorSecondary,
            size: 20,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: whiteColor, width: 0.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: whiteColor, width: 0.0),
          ),
          border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black12)),
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          filled: true,
          fillColor: Color(0xFFf7f7f7),
          // hintText: 'Select City',
          hintStyle: TextStyle(fontSize: textSizeMedium, color: Colors.black),
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
    return DropdownButtonFormField<String>(
      isDense: true,
      isExpanded: true,
      validator: (String? value) {
        if (myStateSelection == null || myStateSelection!.isEmpty) {
          return "Please select state";
        }
        return null;
      },
      hint: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: text('Select State'),
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
        prefixIcon: const Icon(Icons.location_city),
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
            child: Text(
              state['name'].toString(),
              style: const TextStyle(color: Colors.black),
            ),
          ),
        );
      }).toList(),
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
          child: text('Select City'),
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
          prefixIcon: const Icon(Icons.location_city),
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
              child: Text(
                city['name'].toString(),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // void getCity(String newValue, {bool isLoad = false}) {
  //   Api.http.get('shopping/cities/$newValue').then((value) {
  //     setState(() {
  //       citiesData = value.data['cities'];
  //       if (isLoad) myCitySelection = cityId.toString();
  //     });
  //   });
  // }
  //
  // void getState() {
  //   Api.http.get('shopping/states').then((response) {
  //     setState(() {
  //       stateData = response.data;
  //     });
  //   });
  // }

  void getCity(String newValue, {bool isLoad = false, bool isShop = false}) {
    Api.http.get('shopping/cities/$newValue').then((value) {
      setState(() {
        if (isShop == true) {
          shopCitiesData = value.data['cities'];
          if (isLoad) myShopCitySelection = shopCityId.toString();
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

  Future getImage(ImgSource source) async {
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
      _image = File(image.path);
    });
  }
}
