import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart' hide white;
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../widget/customWidget.dart';
import '../../services/api.dart';
import '../../services/auth.dart';
import '../../services/size_config.dart';
import '../../services/validator_x.dart';
import '../../utils/app_utils.dart';
import '../../widget/guest_login_service.dart';
import '../../widget/network_image.dart';
import '../../widget/theme.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  MyAccountState createState() => MyAccountState();
}

class MyAccountState extends State<MyAccount> {
  var linkResponse;
  bool isOTP = false;
  final _guestLoginFormKey = GlobalKey<FormState>();
  final key = GlobalKey<FormState>();
  String? url;

  ValidatorX validator = ValidatorX();

  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  AutovalidateMode validationMode = AutovalidateMode.disabled;
  final BottomSheetService bottomSheetService = BottomSheetService();

  bool? supplierStatus;

  void showBottomSheet(BuildContext context) {
    bottomSheetService.showBottomSheet(context).then((value) {
      if (value != null && value) {
        setState(() {});
      }
    });
  }

  void openUrlWithAuthToken() async {
    Api.httpWithoutLoader.get('member/supplier/authUrl').then((response) {
      setState(() {
        url = response.data['url'];
        supplierStatus = response.data['supplierStatus'];
      });
    }).catchError((error) {});
  }

  @override
  void initState() {
    fetchWebLinks();
    if (Auth.check()!) {
      openUrlWithAuthToken();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        automaticallyImplyLeading: false,
        title: text(
          'Account'.toUpperCase(),
          fontweight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            constraints: const BoxConstraints(maxWidth: 35),
            onPressed: () {
              Get.toNamed('/search-page');
            },
            icon: const Icon(UniconsLine.search),
          ),
          const SizedBox(width: 10.0),
          buildMLMCart(context),
        ],
      ),
      body: SingleChildScrollView(
        child: Auth.check()! ? buildIfAuthTrue() : buildIfAuthFalse(),
      ),
    );
  }

  Widget option(
    var icon,
    var heading,
    String page, {
    dynamic arguments,
    linkUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          if (page == 'link') {
            launch(linkUrl);
          } else {
            if (page == 'address') {
              Get.toNamed('/addresses', arguments: "account");
            } else if (page == "member-logout") {
              logoutBox(context, 'member-logout');
            } else {
              Get.toNamed(page, arguments: arguments);
            }
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    icon,
                    color: textColorPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                text(
                  heading,
                  fontFamily: fontMedium,
                  fontSize: textSizeMedium,
                ),
              ],
            ),
            const Icon(
              Icons.keyboard_arrow_right,
              color: textColorSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIfAuthTrue() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (supplierStatus != null && supplierStatus!)
          Container(
            margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: white,
                border: Border.all(color: Colors.grey, width: 1)),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                text('Go To Supplier Terminal',
                    textColor: Colors.black, fontFamily: fontBold),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: colorPrimary,
                  ),
                  child:
                      text('Proceed', textColor: white, fontFamily: fontBold),
                ).onTap(() {
                  if (url != null) launch(url!);
                }),
              ],
            ),
          ),
        const SizedBox(
          height: 15,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0x194343b2).withOpacity(0.15),
                offset: const Offset(
                  5.0,
                  5.0,
                ),
                blurRadius: 10.0,
                spreadRadius: 2.0,
              ), //BoxShadow
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 30,
                child: PNetworkImage(
                  Auth.user() != null && Auth.user()!['profileImage'] != null
                      ? Auth.user()!['profileImage']
                      : "",
                  fit: BoxFit.cover,
                  borderRadius: 30,
                ),
              ),
              SizedBox(width: w(4)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    text(
                      Auth.user()!['name'],
                      fontSize: textSizeLargeMedium,
                      fontFamily: fontBold,
                      textColor: textColorPrimary,
                    ),
                    const SizedBox(width: 10),
                    text(
                      Auth.user()!['code'],
                      fontSize: textSizeLargeMedium,
                      fontFamily: fontBold,
                      textColor: textColorPrimary,
                    ),
                    text(
                      Auth.user()!['email'] ?? "",
                      fontSize: textSizeMedium,
                      textColor: textColorSecondary,
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed('/profile-mlm')!.then((value) {
                    setState(() {});
                  });
                },
                child: const Icon(
                  UniconsLine.edit,
                  color: textColorPrimary,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10, left: 16),
          child: text(
            'General',
            fontFamily: fontBold,
            textAllCaps: true,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0x194343b2).withOpacity(0.15),
                offset: const Offset(
                  5.0,
                  5.0,
                ),
                blurRadius: 10.0,
                spreadRadius: 2.0,
              ), //BoxShadow
            ],
          ),
          child: Column(
            children: <Widget>[
              option(
                UniconsLine.home,
                'Member Dashboard',
                '/dashboard',
              ),
              option(
                UniconsLine.lock,
                'Change Password',
                '/change-password',
              ),
              option(
                UniconsLine.shopping_cart,
                'Return Orders',
                '/return-orders',
              ),
              option(
                UniconsLine.language,
                'Language Settings',
                '/language-video',
                arguments: true,
              ),
              if (linkResponse != null) ...[
                option(
                  UniconsLine.user_square,
                  'About Us',
                  'link',
                  arguments: true,
                  linkUrl: linkResponse['aboutUs'],
                ),
                option(
                  UniconsLine.envelope,
                  'Founder Message',
                  'link',
                  arguments: true,
                  linkUrl: linkResponse['founderMessage'],
                ),
                option(
                  UniconsLine.file,
                  'Legal',
                  'link',
                  arguments: true,
                  linkUrl: linkResponse['legal'],
                ),
                option(
                  UniconsLine.image,
                  'Gallery',
                  'link',
                  arguments: true,
                  linkUrl: linkResponse['gallery'],
                ),
                option(
                  UniconsLine.file_check,
                  'Terms & Conditions',
                  'link',
                  arguments: true,
                  linkUrl: linkResponse['terms'],
                ),
                option(
                  UniconsLine.file_import,
                  'Return Policy',
                  'link',
                  arguments: true,
                  linkUrl: linkResponse['returnPolicy'],
                ),
                option(
                  UniconsLine.notes,
                  'Privacy Policy',
                  'link',
                  arguments: true,
                  linkUrl: linkResponse['privacyPolicy'],
                ),
                option(
                  UniconsLine.comments_alt,
                  'FAQs',
                  'link',
                  arguments: true,
                  linkUrl: linkResponse['faq'],
                ),
                option(
                  UniconsLine.phone,
                  'Contact Us',
                  'link',
                  arguments: true,
                  linkUrl: linkResponse['contactus'],
                ),
                option(
                  UniconsLine.headphones,
                  'Grievance',
                  'link',
                  arguments: true,
                  linkUrl: linkResponse['grievance'],
                ),
              ],
              if (Auth.user()!['isVendor']!)
                option(UniconsLine.gift, 'Audio Settings', '/audio-settings'),
              // option(
              //   UniconsLine.power,
              //   'Log Out',
              //   'member-logout',
              // ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget buildIfAuthFalse() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (Auth.isGuestLoggedIn!)
          Container(
            margin: const EdgeInsets.only(top: 15, left: 16, right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0x194343b2).withOpacity(0.15),
                  offset: const Offset(
                    5.0,
                    5.0,
                  ),
                  blurRadius: 10.0,
                  spreadRadius: 2.0,
                ), //BoxShadow
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 30,
                  child: Image.asset(
                    'assets/images/users.png',
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(width: w(4)),
                text(
                  Auth.userGuest()!['phone'] ?? "N/A",
                  fontSize: textSizeLargeMedium,
                  fontFamily: fontBold,
                  textColor: textColorPrimary,
                ),
              ],
            ),
          ),
        Container(
          margin: const EdgeInsets.only(top: 10, left: 16),
          child: text(
            'General',
            fontFamily: fontBold,
            textAllCaps: true,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 15, left: 16, right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0x194343b2).withOpacity(0.15),
                offset: const Offset(
                  5.0,
                  5.0,
                ),
                blurRadius: 10.0,
                spreadRadius: 2.0,
              ), //BoxShadow
            ],
          ),
          child: Column(
            children: <Widget>[
              optionIfFalse(UniconsLine.info_circle, 'Grievance-Redressal',
                  '/grievance-redressal'),
              optionIfFalse(
                  UniconsLine.university, 'Bank Details', '/bank-details',
                  isInfoShow: true),
              optionIfFalse(
                  UniconsLine.shopping_cart, 'Return Orders', '/return-orders'),
              if (Auth.isGuestLoggedIn!)
                optionIfFalse(UniconsLine.power, 'Log Out', 'guest-logout'),
            ],
          ),
        ),
      ],
    );
  }

  // void openUrlWithAuthToken() async {
  //   Api.httpWithoutLoader.get('member/supplier/authUrl').then((value) {
  //     if (value.data['url'] != null) {
  //       launch(value.data['url']);
  //     }
  //   }).catchError((error) {});
  // }

  logoutBox(BuildContext context, pageName) {
    return Get.dialog(Dialog(
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
              Container(
                width: 45,
                height: 45,
                decoration:
                    const BoxDecoration(shape: BoxShape.circle, color: green),
                child: const Icon(
                  Icons.power_settings_new_rounded,
                  color: white,
                ),
              ),
              const SizedBox(height: 24),
              text(
                'Are you sure you want to logout ?',
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
                    onPressed: () => Navigator.pop(context),
                    child: text(
                      'No',
                      fontSize: textSizeLargeMedium,
                      fontFamily: fontBold,
                      textColor: green,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (pageName == 'member-logout') {
                        await Auth.logout();
                        Get.offAllNamed('/ecommerce');
                      } else {
                        await Auth.logoutGuest();
                        Get.offAllNamed('/ecommerce');
                      }
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
  }

  Future<void> fetchWebLinks() async {
    await Api.httpWithoutLoader.get('shopping/web-links').then((response) {
      setState(() {
        if (response.data['status']) {
          linkResponse = response.data;
        } else {
          linkResponse = null;
        }
      });
    });
  }

  Widget optionIfFalse(var icon, var heading, String page,
      {bool isInfoShow = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          if (page == '/member-login') {
            AppUtils.redirect('/login-mlm', callWhileBack: () {
              Get.offAllNamed('ecommerce');
            });
          } else if (page == "/guest-dashboard") {
            if (Auth.isGuestLoggedIn!) {
              Get.toNamed('/guest-order-tab');
            } else {
              showBottomSheet(context);
            }
          } else if (page == "guest-logout") {
            logoutBox(context, 'guest-logout');
          } else {
            Get.toNamed(page);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      icon,
                      color: textColorPrimary,
                    ),
                  ),
                  const SizedBox(width: 5),
                  text(
                    heading,
                    fontFamily: fontMedium,
                    fontSize: textSizeMedium,
                  ),
                  const SizedBox(width: 10),
                  if (isInfoShow == true)
                    const Icon(
                      Icons.info,
                      color: textColorSecondary,
                    ).onTap(
                      () {
                        Get.dialog(
                          AlertDialog(
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(32.0)),
                            ),
                            content: const Text(
                              'Please fill your bank details for return or refund purposes',
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Ok'),
                                onPressed: () {
                                  // Pop the confirmation dialog and indicate that the page should
                                  // not be popped.
                                  Navigator.of(context).pop(false);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_right,
              color: textColorSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void loginPressed(mobile, password, context, setDialogState) {
    FocusScope.of(context).requestFocus(FocusNode());
    setDialogState(() {});

    if (_guestLoginFormKey.currentState!.validate()) {
      Api.http.post('guest/login', data: {
        'mobile': mobile,
        "otp": _otpController.text
      }).then((response) async {
        validationMode = AutovalidateMode.always;
        if (response.data['status']) {
          await Auth.guestLogin(
            token: response.data['token'],
            user: response.data['guestUser'],
          );
          Get.toNamed('/guest-order-tab');
        } else {
          AppUtils.showErrorSnackBar(response.data['message']);
        }
      }).catchError((error) {
        if (error.response.statusCode == 401 ||
            error.response.statusCode == 403) {
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
        "Mobile No field is required",
      );
    }
    Api.http.post('guest/otp', data: {"mobile": _mobileController.text}).then(
        (response) {
      if (response.data['status']) {
        setDialogState(() {
          isOTP = true;
        });
        AppUtils.showSuccessSnackBar(response.data['message']);
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

  void onResend(context, setDialogState) {
    _otpController.clear();
    key.currentState?.reset();
    setDialogState(() {});
    sendOTP(context, setDialogState);
  }
}
