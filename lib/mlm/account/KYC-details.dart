import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:myky_clone/utils/app_utils.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../services/Vapor.dart';
import '../../services/api.dart';
import '../../services/getImage_service.dart';
import '../../services/size_config.dart';
import '../../services/validator_x.dart';
import '../../widget/image_picker.dart';
import '../../widget/network_image.dart';
import '../../widget/theme.dart';

class KycDetails extends StatefulWidget {
  @override
  _KycDetailsState createState() => _KycDetailsState();
}

class _KycDetailsState extends State<KycDetails> {
  final _kycFormKey = GlobalKey<FormState>();
  String? accountType;
  final List _accountTypes = [
    {"type": "Saving", "value": 1},
    {"type": "Current", "value": 2},
  ];

  ValidatorX validator = ValidatorX();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _bankBranchController = TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();

  bool uploadingAadhaar = false;
  bool uploadingAadhaarBack = false;
  bool uploadingCheque = false;
  String progressStringAadhaar = "";
  String progressStringAadhaarBack = "";
  String progressStringCheque = "";
  Map? kycData;

  Map<String, dynamic>? _errors;
  File? _cancelChequeImage;

  @override
  void initState() {
    getKyc();
    super.initState();
  }

  getKyc() {
    Api.http.get("member/profile/kyc").then((response) {
      setState(() {
        kycData = response.data;
        if (kycData! != true) {
          _aadhaarController.text = kycData!['aadhaarCard'] ?? "";
          _accountNameController.text = kycData!['accountName'] ?? "";
          _accountNumberController.text = kycData!['accountNumber'] ?? "";
          _ifscCodeController.text = kycData!['bankIfsc'] ?? "";
          _bankNameController.text = kycData!['bankName'] ?? "";
          _bankBranchController.text = kycData!['bankBranch'] ?? "";
          accountType = kycData!['accountType'];
        }
      });
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'KYC',
            ),
            if (kycData != null)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child: text(
                  kycData!['kycStatus']['name'],
                  textColor: kycData!['kycStatus']['id'] == 1
                      ? HexColor("##68BBE3")
                      : kycData!['kycStatus']['id'] == 2
                          ? Colors.amber
                          : kycData!['kycStatus']['id'] == 3
                              ? Colors.green
                              : Colors.red,
                  fontFamily: fontBold,
                ),
              )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _kycFormKey,
          autovalidateMode: autovalidateMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: boxDecoration(
                  showShadow: true,
                  bgColor: white_color,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (kycData != null &&
                        kycData!['kycStatus']['id'] == 4 &&
                        kycData!['rejectReason'] != null) ...[
                      text(
                        "Reason : ${kycData!['rejectReason'] ?? ''}",
                        fontSize: 14.0,
                        fontFamily: fontBold,
                        textColor: redColor,
                        isLongText: true,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: boxDecoration(
                  showShadow: true,
                  bgColor: white_color,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(
                      'Update your banking details',
                      fontSize: textSizeLargeMedium,
                      fontFamily: fontBold,
                      textColor: textColorPrimary,
                    ),
                    const SizedBox(height: 10),
                    floatingInput(
                      'Account Holder Name',
                      controller: _accountNameController,
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'^[ -.,]'))
                      ],
                      validator: validator.add(
                        key: 'accountName',
                        rules: [
                          ValidatorX.mandatory(
                              message: 'Account holder name field is required'),
                        ],
                      ),
                      onChanged: (String value) {
                        validator.clearErrorsAt('accountName');
                      },
                    ),
                    const SizedBox(height: 10),
                    floatingInput(
                      'Account Number',
                      controller: _accountNumberController,
                      keyboardType: TextInputType.number,
                      maxLength: 18,
                      validator: validator.add(
                        key: 'accountNumber',
                        rules: [
                          ValidatorX.mandatory(
                              message: 'Account number field is required'),
                          ValidatorX.minLength(
                              length: 9,
                              message:
                                  'The account number must be between 9 and 18 digits')
                        ],
                      ),
                      onChanged: (String value) {
                        validator.clearErrorsAt('accountNumber');
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
                              message: "Select your account type"),
                        ],
                      ),
                      hint: const Text('Select your account type'),
                      value: accountType,
                      decoration: InputDecoration(
                        isDense: true,
                        labelStyle: primaryTextStyle(
                          size: 16,
                          color: textColorPrimary.withOpacity(0.7),
                          fontFamily: fontMedium,
                        ),
                        // prefixIcon: prefixIcon,
                        enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: colorPrimary)),
                      ),
                      onChanged: (String? newValue) {
                        validator.clearErrorsAt('accountType');
                        setState(() {
                          accountType = newValue!;
                        });
                      },
                      items:
                          _accountTypes.map<DropdownMenuItem<String>>((type) {
                        return DropdownMenuItem<String>(
                          child: Text(type['type']),
                          value: type['value'].toString(),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    floatingInput(
                      'IFSC Code',
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'^[ ,-]'))
                      ],
                      controller: _ifscCodeController,
                      onChanged: (value) {
                        validator.clearErrorsAt('bankIfsc');
                        if (value.length == 11) {
                          Api.httpWithoutBaseUrl
                              .get('https://ifsc.razorpay.com/' +
                                  _ifscCodeController.text)
                              .then((res) {
                            setState(() {
                              _bankNameController.text = res.data['BANK'];
                              _bankBranchController.text = res.data['BRANCH'];
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
                    floatingInput(
                      'Bank Name',
                      controller: _bankNameController,
                      validator: validator.add(
                        key: 'bankName',
                        rules: [
                          ValidatorX.mandatory(
                              message: 'Bank name field is required'),
                        ],
                      ),
                      onChanged: (String value) {
                        validator.clearErrorsAt('bankName');
                      },
                    ),
                    const SizedBox(height: 10),
                    floatingInput(
                      'Bank Branch',
                      controller: _bankBranchController,
                      validator: validator.add(
                        key: 'bankBranch',
                        rules: [
                          ValidatorX.mandatory(
                              message: 'Bank branch field is required'),
                        ],
                      ),
                      onChanged: (String value) {
                        validator.clearErrorsAt('bankBranch');
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: boxDecoration(
                  showShadow: true,
                  bgColor: white_color,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (kycData != null) chequeImage(context),

                    // if (kycStages['kycStatus'] != null &&
                    //     kycStages['kycStatus']['id'] == 4 &&
                    //     kycStages['rejectReason'] != null) ...[
                    //   18.heightBox,
                    //   CustomText(
                    //     "Admin rejection reason",
                    //     fontFamily: fontBold,
                    //     textColor: colorAccent,
                    //     fontSize: 15.sp,
                    //   ),
                    //   10.heightBox,
                    //   Container(
                    //     alignment: Alignment.center,
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(12.r),
                    //       color: Colors.red,
                    //     ),
                    //     width: double.infinity,
                    //     child: RichText(
                    //       text: TextSpan(
                    //         text: kycStages['rejectReason'],
                    //         style: TextStyle(
                    //           color: textColorSecondary,
                    //           fontSize: 15.sp,
                    //           fontFamily: fontSemiBold,
                    //         ),
                    //       ),
                    //     ).appPadding(vertical: 12.h),
                    //   ),
                    // ]
                  ],
                ),
              ),
              if (kycData != null)
                kycData!['kycStatus']['id'] == 3
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomButton(
                          textContent: 'Submit',
                          onPressed: () async {
                            if (_kycFormKey.currentState!.validate()) {
                              setState(() {
                                autovalidateMode =
                                    AutovalidateMode.onUserInteraction;
                              });
                              FocusScope.of(context).requestFocus(FocusNode());
                              dynamic panCardImageVapor;

                              dynamic chequeImageVapor;

                              if (_cancelChequeImage != null) {
                                chequeImageVapor = await Vapor.upload(
                                  _cancelChequeImage,
                                  progressCallback:
                                      (int? completed, int? total) {
                                    setState(() {
                                      if (completed != total) {
                                        uploadingCheque = true;
                                        progressStringCheque =
                                            ((completed! / total!) * 100)
                                                    .toStringAsFixed(0) +
                                                "%";
                                      } else {
                                        uploadingCheque = false;
                                      }
                                    });
                                  },
                                );
                              }

                              Map sendData = {
                                'bankName': _bankNameController.text,
                                'bankBranch': _bankBranchController.text,
                                'bankIfsc': _ifscCodeController.text,
                                'accountType': accountType,
                                'accountName': _accountNameController.text,
                                'accountNumber': _accountNumberController.text,
                                if (_cancelChequeImage != null)
                                  'cancelChequeImage': chequeImageVapor,
                              };
                              Api.http
                                  .post('member/profile/kyc', data: sendData)
                                  .then((response) async {
                                if (response.data['status']) {
                                  Get.back();
                                  AppUtils.showSuccessSnackBar(
                                      response.data['message']);
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
                                if (error.response.statusCode == 422) {
                                  setState(() {
                                    validator.setErrors(
                                        error.response.data['errors']);
                                    _errors = error.response.data['errors'];
                                  });
                                }
                              });
                            }
                          },
                        ),
                      ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget chequeImage(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(
            'Upload Bank PassBook Front Page',
            fontSize: textSizeLargeMedium,
            fontFamily: fontSemibold,
            textColor: textColorPrimary,
            isLongText: true,
          ),
          Stack(
            alignment: Alignment.topRight,
            children: <Widget>[
              Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  margin: const EdgeInsets.all(spacing_control),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      if (!uploadingCheque)
                        _cancelChequeImage != null
                            ? Image.file(
                                _cancelChequeImage!,
                                width: w(100),
                                height: 200,
                                fit: BoxFit.contain,
                              )
                            : kycData!['cancelChequeImage'] != null
                                ? PNetworkImage(
                                    kycData!['cancelChequeImage'],
                                    width: w(100),
                                    fit: BoxFit.contain,
                                    height: 200,
                                  )
                                : Image.asset(
                                    'assets/images/no_image.png',
                                    width: w(100),
                                    height: 200,
                                    fit: BoxFit.contain,
                                  ),
                      if (uploadingCheque)
                        Container(
                          height: 200.0,
                          width: w(100),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const CircularProgressIndicator(),
                              const SizedBox(height: 20.0),
                              Text(
                                "Uploading Image: $progressStringCheque ",
                              )
                            ],
                          ),
                        )
                    ],
                  )),
              Container(
                padding: const EdgeInsets.all(spacing_control),
                margin: const EdgeInsets.only(top: 15, right: 10),
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
                        _cancelChequeImage = file;
                        setState(() {});
                      }
                    });
                    // getChequeImage(ImgSource.Both);
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
          if (_errors != null &&
              _cancelChequeImage == null &&
              _errors!.containsKey('cancel_cheque_image'))
            const SizedBox(height: 5),
          if (_errors != null &&
              _cancelChequeImage == null &&
              _errors!.containsKey('cancel_cheque_image'))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _errors!['cancel_cheque_image'][0],
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
