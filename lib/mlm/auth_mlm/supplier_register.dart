import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myky_clone/utils/en_extensions.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/getImage_service.dart';
import '../../services/validator_x.dart';
import '../../widget/image_picker.dart';
import '../../widget/theme.dart';
import 'register.dart';
import 'supplier_register_controller.dart';

class SupplierRegister extends GetView<RegisterController> {
  final format = DateFormat("dd-MM-yyyy");

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (GetxController ctrl) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: whiteColor,
            appBar: AppBar(
              title: text('SUPPLIER SIGN UP'),
            ),
            body: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFFF2F5F9), Color(0xFFB4C5D1)],
                    ),
                  ),
                  alignment: Alignment.bottomLeft,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Column(
                        children: [
                          Form(
                            key: controller.supplierRegisterFormKey,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                10.height,
                                Container(
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    logo,
                                    width: 200,
                                    height: 200,
                                  ),
                                ),
                                buildNameField(context),
                                10.height,
                                buildMobileNoField(context),
                                10.height,
                                buildWhatsappNoField(context),
                                10.height,
                                buildAddressField(context),
                                10.height,
                                if (controller.stateData != null)
                                  _stateDropdown(),
                                if (controller.citiesData != null) 10.height,
                                if (controller.citiesData != null)
                                  _cityDropdown(),
                                10.height,
                                buildPincodeField(context),
                                10.height,
                                buildDOBField(),
                                10.height,
                                buildEmailField(context),
                                10.height,
                                buildSponsorIDField(context),
                                const SizedBox(height: 10),
                                if (controller.sponsorName == null)
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
                                        const TextSpan(text: " for sponsor Id"),
                                      ],
                                    ),
                                  ),
                                if (controller.sponsorName != null)
                                  text(
                                    controller.sponsorName!,
                                    fontSize: 15.0,
                                    fontFamily: fontBold,
                                    textColor: colorPrimary,
                                    isLongText: true,
                                  ),
                                10.height,
                                buildNomineeNameField(context),
                                10.height,
                                text(
                                  'Pick Up Address',
                                  fontSize: 15.0,
                                  fontFamily: fontBold,
                                  textColor: textColorPrimary,
                                  isLongText: true,
                                ),
                                buildPickUpCheckbox(context),
                                buildPickUpAddressField(context),
                                10.height,
                                if (controller.pickUpStateData != null)
                                  _pickUpstateDropdown(),
                                if (controller.pickUpCitiesData != null)
                                  10.height,
                                if (controller.pickUpCitiesData != null)
                                  _pickUpCityDropdown(),
                                10.height,
                                buildPickUpPincodeField(context),
                                10.height,
                                text(
                                  'GST Details',
                                  fontSize: 15.0,
                                  fontFamily: fontBold,
                                  textColor: textColorPrimary,
                                  isLongText: true,
                                ),
                                10.height,
                                buildBusinessNameField(context),
                                10.height,
                                buildGSTNoField(context),
                                15.height,
                                text(
                                  'Bank Details',
                                  fontSize: 15.0,
                                  fontFamily: fontBold,
                                  textColor: textColorPrimary,
                                  isLongText: true,
                                ),
                                10.height,
                                buildAccountNameField(context),
                                10.height,
                                buildAccountNoField(context),
                                10.height,
                                accountTypeDropdown(),
                                10.height,
                                buildIFSCField(context),
                                10.height,
                                buildBankNameField(context),
                                10.height,
                                buildBranchNameField(context),
                                10.height,
                                text(
                                  'Identity Information',
                                  fontSize: 15.0,
                                  fontFamily: fontBold,
                                  textColor: textColorPrimary,
                                  isLongText: true,
                                ),

                                10.height,
                                buildAadharCardField(context),

                                20.height,
                                aadharCardFrontImage(context),
                                20.height,
                                aadharCardBackImage(context),
                                20.height,
                                gstProofImage(context),
                                20.height,
                                bankCopyImage(context),
                                10.height,
                                buildTermsAndConditionBlock(context),
                                10.height,
                                text(
                                  'Being a member of MYKY is completely free, which means you have no fees!',
                                  textColor: red,
                                  isLongText: true,
                                  isCentered: true,
                                ),
                                10.height,
                                buildRegisterButton(context),
                                10.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    text('Already have an account ?'),
                                    SizedBox(width: 4),
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
                                10.height,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildWhatsappNoField(BuildContext context) {
    return formField(
      context,
      'Whatsapp Number',
      prefixIcon: UniconsLine.whatsapp_alt,
      controller: controller.whatsappNumberController,
      maxLength: 10,
      textCapitalization: TextCapitalization.characters,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))],
      validator: controller.validator.add(
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
        controller.validator.clearErrorsAt('whatsapp_no');
      },
    );
  }

  Padding buildRegisterButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: CustomButton(
          textContent: 'Sign Up'.toUpperCase(),
          onPressed: () {
            controller.register(context);
          },
        ),
      ),
    );
  }

  Widget buildPickUpCheckbox(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 0),
      child: Row(
        children: <Widget>[
          Checkbox(
            focusColor: colorPrimary,
            activeColor: colorPrimary,
            value: controller.isSame,
            // semanticLabel: "test",
            onChanged: (bool? value) {
              if (value != null) {
                _handleTap();
              }
            },
          ),
          text('same as above'),
        ],
      ),
    ).onTap(() => _handleTap());
  }

  void _handleTap() {
    controller.isSame = !controller.isSame;

    if (controller.isSame == true) {
      if (controller.addressController.text.isNotEmpty) {
        controller.pickUpAddressController = controller.addressController;
        // controller.isSame = value;
      }
      if (controller.pinCodeController.text.isNotEmpty) {
        controller.pickUpPinCodeController = controller.pinCodeController;
        // controller.isSame = value;
      }

      if (controller.myStateSelection != null) {
        controller.myPickUpStateSelection = controller.myStateSelection;
        controller.getCity(controller.myPickUpStateSelection!, isPickUp: true);
        controller.myPickUpCitySelection = controller.myCitySelection;
        // controller.isSame = value;
      }
    } else {
      controller.pickUpAddressController = TextEditingController();
      controller.myPickUpStateSelection = null;
      controller.pickUpCitiesData = null;
      controller.myPickUpCitySelection = null;
      controller.pickUpPinCodeController = TextEditingController();
      // controller.isSame = value!;
    }
    controller.update();
  }

  Container buildTermsAndConditionBlock(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 0),
      child: Row(
        children: <Widget>[
          Checkbox(
            focusColor: colorPrimary,
            activeColor: colorPrimary,
            value: controller.isRemember,
            onChanged: (bool? value) {
              controller.isRemember = value!;
              controller.update();
            },
          ),

          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) =>
                    Terms(term: controller.termCondition),
              );
            },
            child: RichText(
              text: TextSpan(
                text: "I agree to the ",
                style: TextStyle(
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
                      color: colorAccent,
                      fontFamily: fontBold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // text('I agree to the'),
          // SizedBox(width: 4),
          // GestureDetector(
          //   child: text(
          //     'Terms & Conditions.',
          //     textColor: colorAccent,
          //     fontFamily: fontBold,
          //   ),
          //   onTap: () {
          //     showDialog(
          //       context: context,
          //       builder: (BuildContext context) => Terms(term: controller.termCondition),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }

  Widget buildAadharCardField(BuildContext context) {
    return formField(
      context,
      'Aadhaar Card',
      validator: controller.validator.add(
        key: 'aadhaar_card',
        rules: [
          ValidatorX.mandatory(message: 'Aadhaar card field is required'),
        ],
      ),
      onChanged: (String? value) {
        controller.validator.clearErrorsAt('aadhaar_card');
      },
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[-., ]'))],
      prefixIcon: UniconsLine.card_atm,
      maxLength: 12,
      controller: controller.aadharController,
    );
  }


  Widget buildBranchNameField(BuildContext context) {
    return formField(
      context,
      "Branch Name",
      controller: controller.branchNameController,
      prefixIcon: UniconsLine.building,
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ -.,]'))],
      validator: controller.validator.add(
        rules: [
          ValidatorX.mandatory(message: "Branch name field is required"),
        ],
        key: 'bank_branch',
      ),
      onChanged: (value) {
        controller.validator.clearErrorsAt('bank_branch');
      },
    );
  }

  Widget buildBankNameField(BuildContext context) {
    return formField(
      context,
      "Bank Name",
      controller: controller.bankNameController,
      prefixIcon: UniconsLine.building,
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ -.,]'))],
      validator: controller.validator.add(
        rules: [
          ValidatorX.mandatory(message: "Bank name field is required"),
        ],
        key: 'bank_name',
      ),
      onChanged: (value) {
        controller.validator.clearErrorsAt('bank_name');
      },
    );
  }

  Widget buildIFSCField(BuildContext context) {
    return formField(
      context,
      "IFSC Code",
      controller: controller.ifscCodeController,
      prefixIcon: UniconsLine.user,
      textCapitalization: TextCapitalization.characters,
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ -.,]'))],
      validator: controller.validator.add(
        rules: [
          ValidatorX.mandatory(message: "IFSC Code field is required"),
        ],
        key: 'bank_ifsc',
      ),
      onChanged: (value) {
        controller.validator.clearErrorsAt('bank_ifsc');
        controller.bankFetchFromIFSC(value!);
      },
    );
  }

  Widget buildAccountNoField(BuildContext context) {
    return formField(
      context,
      "Account Number",
      controller: controller.accountNumberController,
      prefixIcon: UniconsLine.user,
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ -.,]'))],
      validator: controller.validator.add(
        rules: [
          ValidatorX.mandatory(message: "Account number field is required"),
        ],
        key: 'account_number',
      ),
      onChanged: (value) {
        controller.validator.clearErrorsAt('account_number');
      },
    );
  }

  Widget buildAccountNameField(BuildContext context) {
    return formField(
      context,
      "Account Holder Name",
      controller: controller.accountNameController,
      prefixIcon: UniconsLine.user,
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ -.,]'))],
      validator: controller.validator.add(
        rules: [
          ValidatorX.mandatory(
              message: "Account holder name field is required"),
        ],
        key: 'account_name',
      ),
      onChanged: (value) {
        controller.validator.clearErrorsAt('account_name');
      },
    );
  }

  Widget buildGSTNoField(BuildContext context) {
    return formField(
      context,
      "GST Number",
      controller: controller.gstController,
      prefixIcon: UniconsLine.card_atm,
      textCapitalization: TextCapitalization.characters,
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ -.,]'))],
      validator: controller.validator.add(
        rules: [
          ValidatorX.mandatory(message: "GST number field is required"),
        ],
        key: 'gst_number',
      ),
      onChanged: (value) {
        controller.validator.clearErrorsAt('gst_number');
      },
    );
  }

  Widget buildNomineeNameField(BuildContext context) {
    return formField(
      context,
      'Nominee Name',
      prefixIcon: UniconsLine.user,
      controller: controller.nomineeController,
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[- ,.]'))],
      validator: controller.validator.add(
        key: 'nominee_name',
        rules: [
          ValidatorX.mandatory(message: "Nominee name field is required"),
        ],
      ),
      onChanged: (String? value) {
        controller.validator.clearErrorsAt('nominee_name');
      },
    );
  }

  Widget buildSponsorIDField(BuildContext context) {
    return formField(
      context,
      "Sponsor Tracking ID",
      controller: controller.sponsorIdController,
      prefixIcon: UniconsLine.credit_card_search,
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ -.,]'))],
      validator: controller.validator.add(
        rules: [
          ValidatorX.mandatory(message: "Sponsor ID field is required"),
        ],
        key: 'code',
      ),
      onChanged: (value) {
        controller.validator.clearErrorsAt('code');
        controller.fetchMemberName(value!);
      },
    );
  }

  Widget buildEmailField(BuildContext context) {
    return formField(
      context,
      "Email ID",
      controller: controller.emailController,
      prefixIcon: UniconsLine.envelope,
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ -.,]'))],
      validator: controller.validator.add(
        rules: [
          ValidatorX.email(message: "Email ID field is required"),
        ],
        key: 'email',
      ),
      onChanged: (value) {
        controller.validator.clearErrorsAt('email');
      },
    );
  }

  DateTimeField buildDOBField() {
    return DateTimeField(
      controller: controller.dobController,
      validator: (date) {
        if (date == null && controller.dobController.text.isEmpty) {
          return 'Date of Birth field is required';
        } else if (date != null &&
            DateTime.now().difference(date) < Duration(days: 6570)) {
          return 'Only 18+ can join';
        } else {
          return null;
        }
      },
      onChanged: (value) {
        controller.validator.clearErrorsAt('dob');
      },
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(spacing_standard),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(spacing_standard),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15),
        counterText: "",
        filled: true,
        fillColor: Color(0xFFf7f7f7),
        hintText: 'Date of birth (Only 18+ can join)',
        hintStyle:
            TextStyle(fontSize: textSizeMedium, color: textColorSecondary),
        prefixIcon: Icon(
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
            controller.dobController.text =
                res.toLocal().toString().split(' ')[0];
          }
          return res;
        });
      },
    );
  }

  Widget buildPickUpPincodeField(BuildContext context) {
    return formField(
      context,
      "Pick Up Pincode",
      controller: controller.pickUpPinCodeController,
      prefixIcon: UniconsLine.lock_alt,
      maxLength: 6,
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))],
      keyboardType: TextInputType.number,
      validator: (value) {
        if (controller.pickUpPinCodeController.text.length < 6 &&
            controller.pickUpPinCodeController.text.length != 0) {
          return 'Pick up pincode must be 6 digit';
        } else {
          return null;
        }
      },
      onChanged: (value) {
        controller.validator.clearErrorsAt('pickup_pincode');
      },
    );
  }

  Widget buildPincodeField(BuildContext context) {
    return formField(
      context,
      "Pincode",
      controller: controller.pinCodeController,
      prefixIcon: UniconsLine.lock_alt,
      maxLength: 6,
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))],
      keyboardType: TextInputType.number,
      validator: (value) {
        if (controller.pinCodeController.text.length < 6 &&
            controller.pinCodeController.text.length != 0) {
          return 'The Pincode must be 6 digit';
        } else {
          return null;
        }
      },
      onChanged: (value) {
        controller.validator.clearErrorsAt('pincode');
      },
    );
  }

  Widget buildPickUpAddressField(BuildContext context) {
    return formField(
      context,
      "Pick Up Address",
      controller: controller.pickUpAddressController,
      prefixIcon: UniconsLine.user_location,
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ ]'))],
      validator: controller.validator.add(
        rules: [
          ValidatorX.mandatory(message: "Pick up address field is required"),
        ],
        key: 'pickup_address',
      ),
      onChanged: (value) {
        controller.validator.clearErrorsAt('pickup_address');
      },
    );
  }

  Widget buildAddressField(BuildContext context) {
    return formField(
      context,
      "Address",
      controller: controller.addressController,
      prefixIcon: UniconsLine.user_location,
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ ]'))],
      validator: controller.validator.add(
        rules: [
          ValidatorX.mandatory(message: "Address field is required"),
        ],
        key: 'address',
      ),
      onChanged: (value) {
        controller.validator.clearErrorsAt('address');
      },
    );
  }

  Widget buildMobileNoField(BuildContext context) {
    return formField(
      context,
      "Mobile Number",
      controller: controller.mobileController,
      prefixIcon: UniconsLine.mobile_android,
      maxLength: 10,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'^[0-5 -.,]|[-., ]'))
      ],
      validator: controller.validator.add(
        key: 'mobile',
        rules: [
          ValidatorX.mandatory(message: "Mobile field is required"),
          ValidatorX.minLength(
            length: 10,
            message: 'Mobile number must be at least 10 digit long',
          )
        ],
      ),
      onChanged: (value) {
        controller.validator.clearErrorsAt('mobile');
      },
    );
  }

  Widget buildBusinessNameField(BuildContext context) {
    return formField(
      context,
      "Business Name",
      controller: controller.businessNameController,
      prefixIcon: UniconsLine.building,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.deny(
          RegExp(r'^[ ]'),
        ),
        // FilteringTextInputFormatter.allow(
        //   RegExp(r'[a-zA-Z ]'),
        //   // RegExp(r'[a-zA-Z]+(?: [a-zA-Z]+)*'),
        // ),
      ],
      validator: controller.validator.add(
        rules: [
          ValidatorX.mandatory(message: "Business name field is required"),
        ],
        key: 'business_name',
      ),
      onChanged: (value) {
        controller.validator.clearErrorsAt('business_name');
      },
    );
  }

  Widget buildNameField(BuildContext context) {
    return formField(
      context,
      "Name",
      controller: controller.nameController,
      prefixIcon: UniconsLine.user,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]|[ ]+$'))
      ],
      validator: controller.validator.add(
        rules: [
          ValidatorX.mandatory(message: "Name field is required"),
        ],
        key: 'name',
      ),
      onChanged: (value) {
        controller.validator.clearErrorsAt('name');
      },
    );
  }

  Widget gstProofImage(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(
            'Upload GST Certificate',
            fontSize: 15.0,
            fontFamily: fontSemibold,
            textColor: textColorPrimary,
          ),
          Container(
            padding: EdgeInsets.only(right: 14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11.r),
              border: Border.all(color: gray, width: 1.w),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2(
                isExpanded: true,
                hint: Text(
                  "Select Type",
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: gray,
                    fontFamily: fontMedium,
                  ),
                ),
                items: controller.items
                    .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.black,
                              fontFamily: fontMedium,
                            ),
                          ),
                        ))
                    .toList(),
                value: controller.selectedType,
                onChanged: (value) {
                  controller.selectedType = value as String;
                  controller.update();
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (controller.selectedType != null) ...[
            if (controller.selectedType?.toLowerCase() == "pdf")
              Container(
                decoration: boxDecoration(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.file_copy,
                      size: 22.sp,
                      color: colorPrimary,
                    ),
                    12.widthBox,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        text(
                          '${controller.fileName == null ? "File name" : controller.fileName!}',
                          fontSize: 14.0,
                          fontFamily: fontBold,
                          textColor: textColorPrimary,
                        ),
                        if (controller.fileSize != null)
                          text(
                            '${(controller.fileSize! / 1024).toStringAsFixed(2)} KB',
                            fontSize: 14.0,
                            fontFamily: fontMedium,
                            textColor: textColorPrimary,
                          ),
                        // text(
                        //   'Date',
                        //   fontSize: 14.0,
                        //   fontFamily: fontMedium,
                        //   textColor: textColorPrimary,
                        // ),
                        if (controller.uploadingGST)
                          Container(
                            height: 200.0,
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                CircularProgressIndicator(),
                                SizedBox(height: 20.0),
                                Text(
                                  "Uploading Image: ${controller.progressStringGST} ",
                                ),
                              ],
                            ),
                          )
                      ],
                    ).expand(),
                    Icon(
                      Icons.upload,
                      size: 22.sp,
                      color: Colors.black,
                    ).onTap(() {
                      controller.pickFile();
                    }),
                  ],
                ).paddingSymmetric(
                  horizontal: 14.w,
                  vertical: 8.h,
                ),
              )
            else
              Stack(
                alignment: Alignment.topRight,
                children: <Widget>[
                  Card(
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      margin: EdgeInsets.all(spacing_control),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        children: <Widget>[
                          if (!controller.uploadingGST)
                            controller.gstCardImage != null
                                ? Image.file(
                                    controller.gstCardImage!,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.contain,
                                  )
                                : Image.asset(
                                    'assets/images/no_image.png',
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    height: 200,
                                  ),
                          if (controller.uploadingGST)
                            Container(
                              height: 200.0,
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  CircularProgressIndicator(),
                                  SizedBox(height: 20.0),
                                  Text(
                                    "Uploading Image: ${controller.progressStringGST} ",
                                  ),
                                ],
                              ),
                            )
                        ],
                      )),
                  Container(
                    padding: EdgeInsets.all(spacing_control),
                    margin: EdgeInsets.only(top: 15, right: 10),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: whiteColor,
                        border: Border.all(color: colorPrimary)),
                    child: GestureDetector(
                      onTap: () {
                        GetImageFromDevice.instance
                            .getImage(ImgSource.both, context)
                            .then((file) {
                          if (file != null) {
                            controller.gstCardImage = file;
                            controller.update();
                          }
                        });
                        // controller.getGstImage(ImgSource.Both, context);
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
            if ((controller.selectedType?.toLowerCase() == "pdf" &&
                    controller.fileName == null) ||
                (controller.selectedType?.toLowerCase() == "image" &&
                    controller.gstCardImage == null) ||
                controller.errors != null &&
                    controller.gstCardImage == null &&
                    controller.errors!
                        .containsKey('gst_certificate_image')) ...[
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  controller.errors != null
                      ? controller.errors!['gst_certificate_image'][0]
                      : "GST Certificate is required",
                  // controller.errors!['gst_certificate_image'][0],
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget bankCopyImage(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(
            'Bank Passbook Front Page Image',
            fontSize: 15.0,
            fontFamily: fontSemibold,
            textColor: textColorPrimary,
            isLongText: true,
            maxLine: 2,
          ),
          Stack(
            alignment: Alignment.topRight,
            children: <Widget>[
              Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  margin: EdgeInsets.all(spacing_control),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      if (!controller.uploadingBank)
                        controller.bankCopyImage != null
                            ? Image.file(
                                controller.bankCopyImage!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.contain,
                              )
                            : Image.asset(
                                'assets/images/no_image.png',
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: 200,
                              ),
                      if (controller.uploadingBank)
                        Container(
                          height: 200.0,
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircularProgressIndicator(),
                              SizedBox(height: 20.0),
                              Text(
                                "Uploading Image: ${controller.progressStringBank} ",
                              )
                            ],
                          ),
                        )
                    ],
                  )),
              Container(
                padding: EdgeInsets.all(spacing_control),
                margin: EdgeInsets.only(top: 15, right: 10),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: whiteColor,
                    border: Border.all(color: colorPrimary)),
                child: GestureDetector(
                  onTap: () {
                    GetImageFromDevice.instance
                        .getImage(ImgSource.both, context)
                        .then((file) {
                      if (file != null) {
                        controller.bankCopyImage = file;
                        controller.update();
                      }
                    });
                    // controller.getBankImage(ImgSource.Both, context);
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
          if (controller.bankCopyImage == null ||
              controller.errors != null &&
                  controller.bankCopyImage == null &&
                  controller.errors!.containsKey('cancel_cheque_image')) ...[
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                controller.errors != null
                    ? controller.errors!['cancel_cheque_image'][0]
                    : "Cancel cheque or bank passbook front page image is required",
                // controller.errors!['cancel_cheque_image'][0],
                style: TextStyle(color: Colors.red),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget aadharCardFrontImage(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(
            'Upload Aadhar Card Front Image',
            fontSize: 15.0,
            fontFamily: fontSemibold,
            textColor: textColorPrimary,
          ),
          Stack(
            alignment: Alignment.topRight,
            children: <Widget>[
              Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  margin: EdgeInsets.all(spacing_control),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      if (!controller.uploadingAadhaarCardFront)
                        controller.aadharCardFrontImage != null
                            ? Image.file(
                                controller.aadharCardFrontImage!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.contain,
                              )
                            : Image.asset(
                                'assets/images/no_image.png',
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: 200,
                              ),
                      if (controller.uploadingAadhaarCardFront)
                        Container(
                          height: 200.0,
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircularProgressIndicator(),
                              SizedBox(height: 20.0),
                              Text(
                                "Uploading Image: ${controller.progressStringAadhaarFront} ",
                              )
                            ],
                          ),
                        )
                    ],
                  )),
              Container(
                padding: EdgeInsets.all(spacing_control),
                margin: EdgeInsets.only(top: 15, right: 10),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: whiteColor,
                    border: Border.all(color: colorPrimary)),
                child: GestureDetector(
                  onTap: () {
                    GetImageFromDevice.instance
                        .getImage(ImgSource.both, context)
                        .then((file) {
                      if (file != null) {
                        controller.aadharCardFrontImage = file;
                        controller.update();
                      }
                    });
                    // controller.getAadharFrontImage(ImgSource.Both, context);
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
          if (controller.aadharCardFrontImage == null ||
              controller.errors != null &&
                  controller.aadharCardFrontImage == null &&
                  controller.errors!.containsKey('aadhaar_card_image')) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                controller.errors != null
                    ? controller.errors!['aadhaar_card_image'][0]
                    : "Aadhar Card front image is required",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget aadharCardBackImage(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(
            'Upload Aadhar Card Back Image',
            fontSize: 15.0,
            fontFamily: fontSemibold,
            textColor: textColorPrimary,
          ),
          Stack(
            alignment: Alignment.topRight,
            children: <Widget>[
              Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                margin: EdgeInsets.all(spacing_control),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: <Widget>[
                    if (!controller.uploadingAadhaarCardBack)
                      controller.aadharCardBackImage != null
                          ? Image.file(
                              controller.aadharCardBackImage!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.contain,
                            )
                          : Image.asset(
                              'assets/images/no_image.png',
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: 200,
                            ),
                    if (controller.uploadingAadhaarCardBack)
                      Container(
                        height: 200.0,
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(),
                            SizedBox(height: 20.0),
                            Text(
                              "Uploading Image: ${controller.progressStringAadhaarBack} ",
                            )
                          ],
                        ),
                      )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(spacing_control),
                margin: EdgeInsets.only(top: 15, right: 10),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: whiteColor,
                    border: Border.all(color: colorPrimary)),
                child: GestureDetector(
                  onTap: () {
                    GetImageFromDevice.instance
                        .getImage(ImgSource.both, context)
                        .then((file) {
                      if (file != null) {
                        controller.aadharCardBackImage = file;
                        controller.update();
                      }
                    });
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
          if (controller.aadharCardBackImage == null ||
              controller.errors != null &&
                  controller.aadharCardBackImage == null &&
                  controller.errors!
                      .containsKey('aadhaar_card_back_image')) ...[
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                controller.errors != null
                    ? controller.errors!['aadhaar_card_back_image'][0]
                    : "Aadhar Card back image is required",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
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
          if (controller.myPickUpStateSelection == null ||
              controller.myPickUpStateSelection!.isEmpty) {
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
        value: controller.myPickUpStateSelection,
        iconSize: 20,
        elevation: 16,
        onChanged: (String? newValue) {
          controller.myPickUpCitySelection = null;
          controller.pickUpCitiesData = [];
          controller.getCity(newValue!, isPickUp: true);
          controller.validator.clearErrorsAt('pickup_state_id');
          controller.myPickUpStateSelection = newValue;
          controller.update();
        },
        items: controller.pickUpStateData!['states']
            .map<DropdownMenuItem<String>>((state) {
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

  Widget _stateDropdown() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: DropdownButtonFormField<String>(
        isDense: true,
        isExpanded: true,
        validator: (String? value) {
          if (controller.myStateSelection == null ||
              controller.myStateSelection!.isEmpty) {
            return "Please select state";
          }
          return null;
        },
        hint: text('Select State',
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
          // hintText: 'Select State',
          filled: true,
          fillColor: Color(0xFFf7f7f7),
          hintStyle: TextStyle(fontSize: textSizeMedium, color: Colors.black),
        ),
        value: controller.myStateSelection,
        iconSize: 20,
        elevation: 16,
        onChanged: (String? newValue) {
          controller.myCitySelection = null;
          controller.citiesData = [];
          controller.getCity(newValue!);
          controller.validator.clearErrorsAt('state_id');
          controller.myStateSelection = newValue;
          controller.update();
        },
        items: controller.stateData!['states']
            .map<DropdownMenuItem<String>>((state) {
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
          if (controller.myPickUpCitySelection == null ||
              controller.myPickUpCitySelection!.isEmpty) {
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
        value: controller.myPickUpCitySelection,
        iconSize: 20,
        elevation: 16,
        onChanged: (String? newValue) {
          controller.validator.clearErrorsAt('pickup_city_id');

          controller.myPickUpCitySelection = newValue!;
          controller.update();
        },
        items:
            controller.pickUpCitiesData!.map<DropdownMenuItem<String>>((city) {
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

  Widget _cityDropdown() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: DropdownButtonFormField<String>(
        isDense: true,
        isExpanded: true,
        validator: (String? value) {
          if (controller.myCitySelection == null ||
              controller.myCitySelection!.isEmpty) {
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
        value: controller.myCitySelection,
        iconSize: 20,
        elevation: 16,
        onChanged: (String? newValue) {
          controller.validator.clearErrorsAt('city_id');

          controller.myCitySelection = newValue!;
          controller.update();
        },
        items: controller.citiesData!.map<DropdownMenuItem<String>>((city) {
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

  Widget accountTypeDropdown() {
    return DropdownButtonFormField<String>(
      isDense: true,
      isExpanded: true,
      validator: controller.validator.add(
        key: 'account_type',
        rules: [
          ValidatorX.mandatory(message: "Select Your Account Type"),
        ],
      ),
      hint: Text('Select Account Type'),
      value: controller.accountType,
      decoration: InputDecoration(
        prefixIcon: Icon(UniconsLine.building),
        focusedBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(spacing_standard),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(spacing_standard),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15),
        filled: true,
        fillColor: Color(0xFFf7f7f7),
        hintText: 'Select Type',
        hintStyle: TextStyle(fontSize: textSizeMedium, color: Colors.grey[300]),
      ),
      onChanged: (String? newValue) {
        controller.accountType = newValue!;
        controller.validator.clearErrorsAt('account_type');
        controller.update();
      },
      items: controller.accountTypes.map<DropdownMenuItem<String>>((type) {
        return DropdownMenuItem<String>(
          child: Text(type['type']),
          value: type['value'].toString(),
        );
      }).toList(),
    );
  }
}
