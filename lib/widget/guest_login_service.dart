import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:myky_clone/widget/theme.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:unicons/unicons.dart';

import '../services/api.dart';
import '../services/auth.dart';
import '../services/validator_x.dart';
import '../utils/app_utils.dart';

class BottomSheetService {
  bool isOTP = false;
  String? referralCode;
  String? fcmToken;
  String? from;

  final _guestLoginFormKey = GlobalKey<FormState>();
  final key = GlobalKey<FormState>();

  ValidatorX validator = ValidatorX();

  TextEditingController _mobileController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  TextEditingController _refferalCodeController = TextEditingController();
  AutovalidateMode validationMode = AutovalidateMode.disabled;

  // Define any other variables you need here

  Future showBottomSheet(BuildContext context, {product, String? from}) async {
    _mobileController.text = '';
    _otpController.text = '';
    _refferalCodeController.text = '';
    isOTP = false;
    this.from = from;
    // fcmToken = await FirebaseMessaging.instance.getToken();
    if (product != null) {
      referralCode = product['data']['referralCode'];
      if (referralCode != null) _refferalCodeController.text = referralCode!;
    }
    return Get.bottomSheet(
      StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setDialogState) {
        return Wrap(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Form(
                    key: _guestLoginFormKey,
                    autovalidateMode: validationMode,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.back();
                              },
                              child: Icon(Icons.close),
                            ),
                          ],
                        ),
                        text(
                          'Login as a guest',
                          fontFamily: fontBold,
                          fontSize: 14.0,
                        ),
                        SizedBox(height: 20),
                        formField(
                          context,
                          'Enter Mobile Number',
                          prefixIcon: UniconsLine.phone,
                          controller: _mobileController,
                          maxLength: 10,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[0-5 -.,]|[-., ]'))],
                          validator: validator.add(
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
                            validator.clearErrorsAt('mobile');
                          },
                        ),
                        10.height,
                        if (this.isOTP) ...[
                          formField(
                            context,
                            'Enter OTP',
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            prefixIcon: UniconsLine.mobile_android_alt,
                            maxLength: 6,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                RegExp(r'[- ,.]'),
                              ),
                            ],
                            onChanged: (String? value) {
                              validator.clearErrorsAt('code');
                            },
                            validator: validator.add(
                              key: 'code',
                              rules: [
                                ValidatorX.mandatory(message: "OTP field is required"),
                              ],
                            ),
                            suffixWidget: InkWell(
                              onTap: () {
                                onResend(context, setDialogState);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10.0, right: 8.0),
                                child: text(
                                  'Resend',
                                  fontSize: 16.0,
                                  fontFamily: fontRegular,
                                  textColor: colorPrimary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          formField(
                            context,
                            'Enter Referral Code (Optional)',
                            controller: _refferalCodeController,
                            prefixIcon: UniconsLine.code_branch,
                            maxLength: 6,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                RegExp(r'[- ,.]'),
                              ),
                            ],
                            onChanged: (String? value) {
                              validator.clearErrorsAt('code');
                            },
                            validator: validator.add(
                              key: 'code',
                              rules: [
                                // ValidatorX.mandatory(message: "OTP field is required"),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: 15),
                        CustomButton(
                          onPressed: () {
                            isOTP
                                ? loginPressed(_mobileController.text, _otpController.text, context, setDialogState)
                                : sendOTP(
                                    context,
                                    setDialogState,
                                  );
                          },
                          textContent: isOTP ? 'Continue' : 'Send OTP',
                        ),
                        20.height,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  void loginPressed(mobile, password, context, setDialogState) {
    FocusScope.of(context).requestFocus(FocusNode());
    setDialogState(() {});
    validationMode = AutovalidateMode.always;
    if (_guestLoginFormKey.currentState!.validate()) {
      Api.http.post('guest/login', data: {
        'mobile': mobile,
        "otp": _otpController.text,
        "code": _refferalCodeController.text,
        'fcmToken': fcmToken,
      }).then((response) async {
        validationMode = AutovalidateMode.always;
        if (response.data['status']) {
          await Auth.guestLogin(
            token: response.data['token'],
            user: response.data['guestUser'],
          );
          if (from == 'login_mlm') {
            Get.offAllNamed('/ecommerce');
            // Get.offAllNamed('/ecommerce', arguments: true);
          } else {
            print('object');
            Get.back(result: true);
          }
        } else {
          AppUtils.showErrorSnackBar(response.data['error']);
        }
      }).catchError((error) {
        if (error.response.statusCode == 401 || error.response.statusCode == 403) {
          AppUtils.showErrorSnackBar(error.response.data['message']);
        }
        if (error.response.statusCode == 422) {
          validator.setErrors(error.response.data['errors']);
          setDialogState(() {});
        }
      });
    }
  }

  void sendOTP(BuildContext context, setDialogState) {
    FocusScope.of(context).requestFocus(FocusNode());
    setDialogState(() {});
    if (_mobileController.text.isEmpty) {
      AppUtils.showErrorSnackBar(
        "The Mobile number is required",
      );
    } else {
      Api.http.post('guest/otp', data: {"mobile": _mobileController.text}).then((response) {
        if (response.data['status']) {
          AppUtils.showSuccessSnackBar(response.data['message']);
          setDialogState(() {
            isOTP = true;
          });
        } else {
          AppUtils.showErrorSnackBar(response.data['message']);
        }
      }).catchError((error) {
        if (error.response.statusCode == 422) {
          validator.setErrors(error.response.data['errors']);
          setDialogState(() {});
        }
      });
    }
  }

  void onResend(context, setDialogState) {
    _otpController.clear();
    key.currentState?.reset();
    setDialogState(() {});
    sendOTP(context, setDialogState);
  }
}
