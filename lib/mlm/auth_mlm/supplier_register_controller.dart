import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../mlm/auth_mlm/register.dart';
import '../../services/Vapor.dart';
import '../../services/api.dart';
import '../../services/validator_x.dart';
import '../../utils/app_utils.dart';

class RegisterBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RegisterController());
  }
}

class RegisterController extends GetxController {
  ValidatorX validator = ValidatorX();
  final supplierRegisterFormKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController(),
      businessNameController = TextEditingController(),
      whatsappNumberController = TextEditingController(),
      mobileController = TextEditingController(),
      addressController = TextEditingController(),
      pickUpAddressController = TextEditingController(),
      pinCodeController = TextEditingController(),
      pickUpPinCodeController = TextEditingController(),
      emailController = TextEditingController(),
      sponsorIdController = TextEditingController(),
      gstController = TextEditingController(),
      dobController = TextEditingController(),
      bankNameController = TextEditingController(),
      accountNameController = TextEditingController(),
      accountNumberController = TextEditingController(),
      ifscCodeController = TextEditingController(),
      branchNameController = TextEditingController(),
      aadharController = TextEditingController(),
      nomineeController = TextEditingController();

  String? accountType;
  List allIDImages = [];
  String? sponsorName;
  List accountTypes = [
    {"type": "Saving", "value": 1},
    {"type": "Current", "value": 2},
  ];
  List<File> fileListToUpload = [];

  bool uploadingAadhaarCardFront = false;
  bool uploadingAadhaarCardBack = false;
  bool uploadingGST = false;
  bool uploadingBank = false;
  String progressStringAadhaarFront = "";
  String progressStringAadhaarBack = "";
  String progressStringGST = "";
  String progressStringBank = "";

  List? citiesData, pickUpCitiesData;
  Map? stateData, pickUpStateData;
  String? cityId;
  String? myStateSelection, myPickUpStateSelection;
  String? myCitySelection, myPickUpCitySelection;
  bool isRemember = false, isSame = false;
  String? termCondition;

  Map<String, dynamic>? errors;
  File? aadharCardFrontImage;
  File? aadharCardBackImage;
  File? gstCardImage;
  File? bankCopyImage;
  StreamController<int> indexController = StreamController<int>.broadcast();
  Timer? _debounce;
  String progressString = "";
  num progressValue = 0;

  dynamic aadharCardFront1;
  dynamic aadharCardBack1;
  dynamic panCard1;
  dynamic gst1;
  dynamic bankProof1;

  final List<String> items = ['PDF', 'Image'];
  String? selectedType;

  File? selectedFile;
  String? fileName;
  int? fileSize;

  @override
  void onInit() {
    // if (!kReleaseMode) {
    //   nameController.text = 'ABC';
    //   businessNameController.text = 'BussinessName';
    //   mobileController.text = '9664512960';
    //   addressController.text = 'Vadodara';
    //   pinCodeController.text = '390006';
    //   emailController.text = 'a@gmail.com';
    //   sponsorIdController.text = '100002';
    //   nomineeController.text = 'Nominee Name';
    //   gstController.text = '24AABCU9603R1ZT';
    //   accountNameController.text = 'Account Name';
    //   accountNumberController.text = '55632356235';
    //   ifscCodeController.text = 'SBIN0010971';
    //   bankNameController.text = 'SBI';
    //   branchNameController.text = 'HARNI WARASIYA';
    //   panCardController.text = 'TRSPP3876D';
    //   aadharController.text = '123456789012';
    //   dobController.text = "20-11-1997";
    //   isRemember = true;
    // }
    sponsorIdController.text = '';
    fetchMemberName(sponsorIdController.text);
    getState(isPickUp: true);
    getRegister();
    super.onInit();
  }

  void getCity(String newValue, {bool isLoad = false, bool isPickUp = false}) {
    Api.http.get('shopping/cities/$newValue').then((value) {
      if (isPickUp == true) {
        pickUpCitiesData = value.data['cities'];
        if (isLoad) myPickUpCitySelection = cityId.toString();
      } else {
        citiesData = value.data['cities'];
        if (isLoad) myCitySelection = cityId.toString();
      }
      update();
    });
  }

  void getState({bool isPickUp = false}) {
    Api.http.get('shopping/states').then((response) {
      if (isPickUp == true) {
        pickUpStateData = response.data;
      }
      stateData = response.data;

      update();
    });
  }

  Future getRegister() async {
    return await Api.http.get('member/terms-conditions').then((response) async {
      termCondition = response.data['termsCondition'];

      return response.data;
    });
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      selectedFile = File(file.path!);
      fileName = file.name;
      fileSize = file.size;
    }

    update();
  }

  void register(BuildContext context) async {
    if (supplierRegisterFormKey.currentState!.validate()) {
      if (isRemember) {
        if (aadharCardFrontImage != null &&
            aadharCardBackImage != null &&
            ((selectedType?.toLowerCase() == "image" && gstCardImage != null) ||
                (selectedType?.toLowerCase() == "pdf" &&
                    selectedFile != null)) &&
            bankCopyImage != null) {
          AppUtils.onLoading(
              context, "Your documents are\nuploading please wait..");

          if (aadharCardFrontImage != null) {
            aadharCardFront1 = await Vapor.uploadWithoutLoaderRegister(
              aadharCardFrontImage,
              progressCallback: (int? completed, int? total) {
                if (completed != total) {
                  uploadingAadhaarCardFront = true;
                  progressStringAadhaarFront =
                      ((completed! / total!) * 100).toStringAsFixed(0) + "%";
                } else {
                  uploadingAadhaarCardFront = false;
                }
                update();
              },
            );
          }

          if (aadharCardBackImage != null) {
            aadharCardBack1 = await Vapor.uploadWithoutLoaderRegister(
              aadharCardBackImage,
              progressCallback: (int? completed, int? total) {
                if (completed != total) {
                  uploadingAadhaarCardBack = true;
                  progressStringAadhaarBack =
                      ((completed! / total!) * 100).toStringAsFixed(0) + "%";
                } else {
                  uploadingAadhaarCardBack = false;
                }
                update();
              },
            );
          }

          if (gstCardImage != null || selectedFile != null) {
            gst1 = await Vapor.uploadWithoutLoaderRegister(
              (selectedFile != null) ? selectedFile : gstCardImage,
              progressCallback: (int? completed, int? total) {
                if (completed != total) {
                  uploadingGST = true;
                  progressStringGST =
                      ((completed! / total!) * 100).toStringAsFixed(0) + "%";
                } else {
                  uploadingGST = false;
                }
                update();
              },
            );
          }
          if (bankCopyImage != null) {
            bankProof1 = await Vapor.uploadWithoutLoaderRegister(
              bankCopyImage,
              progressCallback: (int? completed, int? total) {
                if (completed != total) {
                  uploadingBank = true;
                  progressStringBank =
                      ((completed! / total!) * 100).toStringAsFixed(0) + "%";
                } else {
                  uploadingBank = false;
                }
                update();
              },
            );
          }

          FocusScope.of(context).requestFocus(FocusNode());
          update();
          if (!isRemember) {
            GetBar(
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              message: 'You need to accept terms & conditions',
            ).show();
          } else {
            uploadSupplierRegister(context);
          }
          if (_debounce?.isActive ?? false) _debounce?.cancel();
        }
      } else {
        AppUtils.showErrorSnackBar('You need to accept terms & conditions');
      }
    }
  }

  void uploadSupplierRegister(BuildContext context) {
    Map sendData = {
      'name': nameController.text,
      'mobile': mobileController.text,
      'whatsapp_no': whatsappNumberController.text,
      'email': emailController.text,
      'code': sponsorIdController.text,
      'address': addressController.text,
      'dob': dobController.text,
      "business_name": businessNameController.text,
      "state_id": myStateSelection,
      "city_id": myCitySelection,
      "pincode": pinCodeController.text,
      'pickup_address': pickUpAddressController.text,
      "pickup_state_id": myPickUpStateSelection,
      "pickup_city_id": myPickUpCitySelection,
      "pickup_pincode": pickUpPinCodeController.text,
      "gst_number": gstController.text,
      "nominee_name": nomineeController.text,
      "aadhaar_card": aadharController.text,
      "account_name": accountNameController.text,
      "account_number": accountNumberController.text,
      "bank_name": bankNameController.text,
      "account_type": accountType,
      "bank_branch": branchNameController.text,
      "bank_ifsc": ifscCodeController.text,
      // "pan_card_image": allIDImages[0],
      // "aadhaar_card_image": allIDImages[1],
      // "aadhaar_card_back_image": allIDImages[2],
      // "cancel_cheque_image": allIDImages[3],
      // "gst_certificate_image": allIDImages[4],

      "aadhaar_card_image": aadharCardFront1,
      "aadhaar_card_back_image": aadharCardBack1,
      "cancel_cheque_image": bankProof1,
      "gst_certificate_image": gst1,
    };

    Api.http.post('member/supplier-register', data: sendData).then((res) async {
      if (res.data['status']) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: SuccessBox(
              res.data['member_id'].toString(),
              res.data['password'].toString(),
            ),
          ),
        );
      } else {
        GetBar(
          duration: Duration(seconds: 5),
          message: res.data['error'],
          backgroundColor: Colors.red,
        ).show();
      }
    }).catchError((error) {
      if (error.response.statusCode == 401 ||
          error.response.statusCode == 403) {
        AppUtils.showErrorSnackBar(error.response.data['message']);
      }
      if (error.response.statusCode == 422) {
        errors = error.response.data['errors'];
        validator.setErrors(error.response.data['errors']);
        update();
      }
    });
  }

  void bankFetchFromIFSC(String value) {
    if (value.length == 11) {
      Api.httpWithoutBaseUrl
          .get('https://ifsc.razorpay.com/' + ifscCodeController.text)
          .then((res) {
        bankNameController.text = res.data['BANK'];
        branchNameController.text = res.data['BRANCH'];
        update();
      }).catchError((err) {
        AppUtils.showErrorSnackBar('IFSC code is invalid');
        bankNameController.text = '';
        branchNameController.text = '';
        update();
      });
    } else {
      bankNameController.text = '';
      branchNameController.text = '';
      update();
    }
  }

  void fetchMemberName(String value) {
    if (value.length == 6) {
      Api.httpWithoutLoader.post('member/member-detail',
          queryParameters: {"code": sponsorIdController.text}).then((res) {
        sponsorName = res.data['userName'];
        update();
      }).catchError((err) {
        sponsorName = null;
        update();
      });
    } else {
      sponsorName = null;
      update();
    }
  }
}
