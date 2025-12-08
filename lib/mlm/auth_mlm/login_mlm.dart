import 'package:android_id/android_id.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:myky_clone/utils/en_extensions.dart';
import 'package:unicons/unicons.dart';

import '../../services/api.dart';
import '../../services/auth.dart';
import '../../services/validator_x.dart';
import '../../widget/guest_login_service.dart';
import '../../widget/theme.dart';

class LoginMLM extends StatefulWidget {
  LoginMLM({
    Key? key,
  }) : super(key: key);

  @override
  _LoginMLMState createState() => _LoginMLMState();
}

class _LoginMLMState extends State<LoginMLM> {
  final _loginFormKey = GlobalKey<FormState>();
  FocusNode memberIDFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  ValidatorX validator = ValidatorX();

  TextEditingController _codeController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool passwordVisible = false;

  var arg;
  String deviceId = '';
  static const _androidIdPlugin = AndroidId();
  var _androidId = 'Unknown';
  String? fcmToken;

  Future<void> _initAndroidId() async {
    try {
      deviceId = await _androidIdPlugin.getId() ?? '';
    } on PlatformException {
      deviceId = '';
    }
    if (!mounted) return;
    setState(() {
      _androidId = deviceId;
    });
  }

  getToken() async {
    fcmToken = null;
    // await FirebaseMessaging.instance.getToken();
    // setState(() {
    //   fcmToken = fcmToken;
    //   print('FCM Token : $fcmToken');
    // });
  }

  checkGuestLogin() async {
    if (Auth.isGuestLoggedIn!) {
      Auth.logoutGuest();
    }
  }

  @override
  void initState() {
    arg = Get.arguments;
    getToken();
    _initAndroidId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return scaffoldBackgroundImage(
      customBgImage: loginImage,
      fit: BoxFit.cover,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Form(
          key: _loginFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SafeArea(
            child: Stack(
              children: <Widget>[
                Center(
                  child: Container(
                    margin: EdgeInsets.all(spacing_standard_new),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          buildTopWidget(),
                          20.heightBox,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                child: formField(
                                  context,
                                  "Member ID",
                                  borderSideColor: Colors.grey.shade400,
                                  prefixIcon: UniconsLine.tag,
                                  focusNode: memberIDFocus,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  textInputAction: TextInputAction.next,
                                  nextFocus: passwordFocus,
                                  controller: _codeController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                        RegExp(r'[ -.,]'))
                                  ],
                                  onChanged: (String? value) {
                                    validator.clearErrorsAt('code');
                                  },
                                  validator: validator.add(
                                    key: 'code',
                                    rules: [
                                      ValidatorX.mandatory(
                                          message:
                                              'The member ID field is required')
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, left: 10, right: 10),
                                child: formField(
                                  context,
                                  "Password",
                                  prefixIcon: UniconsLine.lock,
                                  isPassword: true,
                                  isPasswordVisible: passwordVisible,
                                  focusNode: passwordFocus,
                                  // borderSideColor: colorPrimary,
                                  textInputAction: TextInputAction.done,
                                  controller: _passwordController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                        RegExp(r'^[ -.,]'))
                                  ],
                                  onChanged: (String? value) {
                                    validator.clearErrorsAt('password');
                                  },
                                  validator: validator.add(
                                    key: 'password',
                                    rules: [
                                      ValidatorX.mandatory(),
                                    ],
                                  ),
                                  suffixIconSelector: () {
                                    setState(() {
                                      passwordVisible = !passwordVisible;
                                    });
                                  },
                                  suffixIcon: passwordVisible
                                      ? Icon(Icons.visibility_off)
                                      : Icon(Icons.visibility),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Get.toNamed('/forget-password-mlm');
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 10, bottom: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  text(
                                    "Forgot password ? ",
                                    fontFamily: fontBold,
                                    fontSize: 15.sp,
                                    textColor: colorAccent,
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                textContent: 'Sign In',
                                onPressed: () {
                                  if (_loginFormKey.currentState!.validate()) {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());

                                    Api.http.post('member/login', data: {
                                      'code':_codeController.text,
                                      // 100001,
                                      'password': _passwordController.text,
                                      // 1,
                                      'deviceId': deviceId,
                                      'fcmToken': fcmToken,
                                    }).then((response) async {
                                      if (response.data['status']) {
                                        await checkGuestLogin();
                                        await Auth.login(
                                          token: response.data['token'],
                                          user: response.data['member'],
                                          isVendor: response.data['member']
                                              ['isVendor'],
                                        );

                                        if (arg != null && arg == 'justBack') {
                                          Get.back(result: true);
                                        } else {
                                          Get.offAllNamed('/main-dashboard');
                                        }
                                      } else {
                                        GetBar(
                                          backgroundColor: Colors.red,
                                          duration: Duration(seconds: 3),
                                          message: response.data['message'],
                                        ).show();
                                      }
                                    }).catchError((error) {
                                      if (error.response.statusCode == 422) {
                                        GetBar(
                                          message: error.response.data['errors']
                                              ['code'][0],
                                          duration: Duration(seconds: 3),
                                          backgroundColor: Colors.red,
                                        ).show();
                                        // setState(() {
                                        //   validator.setErrors(
                                        //       error.response.data['errors']);
                                        // });
                                      } else if (error.response.statusCode ==
                                          401) {
                                        GetBar(
                                          message:
                                              error.response.data['message'],
                                          duration: Duration(seconds: 3),
                                          backgroundColor: Colors.red,
                                        ).show();
                                      }
                                    });
                                  }
                                  // Get.offAllNamed("/home");
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 35),
                          // GestureDetector(
                          //   onTap: () {
                          //     Get.toNamed('/register-promoter');
                          //   },
                          //   child: RichText(
                          //     text: TextSpan(
                          //       text: "Wish to join as a promoter ? ",
                          //       style: TextStyle(
                          //         color: Colors.black,
                          //         height: 1.5,
                          //         fontSize: 12,
                          //         fontFamily: fontRegular,
                          //       ),
                          //       children: [
                          //         TextSpan(
                          //           text: 'Sign Up',
                          //           style: TextStyle(
                          //             fontSize: 12,
                          //             color: colorAccent,
                          //             fontFamily: fontBold,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          // SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed('/register-vendor');
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Don't have a member account ? ",
                                style: TextStyle(
                                  color: Colors.black,
                                  height: 1.5,
                                  fontSize: 12,
                                  fontFamily: fontRegular,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Sign Up',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorAccent,
                                      fontFamily: fontBold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed('/register-supplier');
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Are you an Ecommerce supplier ? ",
                                style: TextStyle(
                                  color: Colors.black,
                                  height: 1.5,
                                  fontSize: 12,
                                  fontFamily: fontRegular,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Sign Up',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorAccent,
                                      fontFamily: fontBold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              BottomSheetService().showBottomSheet(context, from: 'login_mlm');
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Login as a ",
                                style: TextStyle(
                                  color: Colors.black,
                                  height: 1.5,
                                  fontSize: 12,
                                  fontFamily: fontRegular,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Guest?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorAccent,
                                      fontFamily: fontBold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTopWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Image.asset(logo, height: 80.h, width: 80.w),
        ),
        20.heightBox,
        Text(
          'Hi there!\nWelcome back',
          style: TextStyle(fontFamily: fontBold, fontSize: 30.sp),
        ),
      ],
    );
  }

  // Container buildTopWidget() {
  //   return Container(
  //     alignment: Alignment.center,
  //     child: Image.asset(
  //       logo,
  //       width: 200,
  //       height: 200,
  //       // width: width / 1.3,
  //     ),
  //   );
  // }
}
