import 'dart:async';
import 'dart:io';

import 'package:boxicons/boxicons.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:nb_utils/nb_utils.dart' hide white;
import 'package:search_choices/search_choices.dart';
import 'package:unicons/unicons.dart';

import '../../../services/validator_x.dart';
import '../../services/Vapor.dart';
import '../../services/api.dart';
import '../../services/getImage_service.dart';
import '../../utils/app_utils.dart';
import '../../utils/en_extensions.dart';
import '../../widget/custom_container.dart';
import '../../widget/image_picker.dart';
import '../../widget/show_uploading_model.dart';
import '../../widget/theme.dart';

class CreateTicket extends StatefulWidget {
  const CreateTicket({super.key});

  @override
  CreateTicketState createState() => CreateTicketState();
}

class CreateTicketState extends State<CreateTicket> {
  ValidatorX validator = ValidatorX();
  final _createTicketFormKey = GlobalKey<FormState>();
  bool autoValidate = false;
  File? _image;
  bool isImageUpload = false;
  bool uploading = false;
  String progressString = "";
  num progressValue = 0;
  List issueList = [], vendorList = [];
  List<DropdownMenuItem> vendorCustomList = [];
  String? selectedIssue;
  String? selectedVendor, selectedSearchVendor;

  CroppedFile? croppedXFile;

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  StreamController<int> indexController = StreamController<int>.broadcast();
  bool isCreatingTicket = false;
  Map<int, String> issues = {};
  Map<int, String> vendorData = {};

  @override
  void initState() {
    getIssueList();
    getVendorList();
    // TODO: implement initState
    super.initState();
  }

  void getIssueList() async {
    Api.httpWithoutLoader.get('member/offline-store-complaint').then((response) {
      setState(() {
        issueList = response.data['complaintType'];
        issues = {for (var issueType in issueList) issueType['id']: issueType['name']};
      });
    });
  }

  void getVendorList() async {
    Api.httpWithoutLoader.get('member/offline-store-complaint/vendor-list').then((response) {
      setState(() {
        vendorList = response.data['list'];
        vendorCustomList = vendorList.map((item) {
          return DropdownMenuItem<String>(
            value: item['name'],
            child: Text(
              '${item['name']} (${item['code']})',
            ),
            onTap: () {
              setState(() {
                selectedVendor = item['id'].toString();
              });
            },
          );
        }).toList();
        vendorData = {for (var vendor in vendorList) vendor['id']: vendor['name']};
      });
    });
  }

  @override
  void dispose() {
    indexController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Ticket",
        ),
      ),
      body: SingleChildScrollView(
        child: _buildCreateTicketBlock(),
      ),
    );
  }

  _buildCreateTicketBlock() {
    return Form(
      key: _createTicketFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: CustomContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vendorCustomList.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(
                    color: silver,
                    width: 0.5.w,
                  ),
                ),
                child: SearchChoices.single(
                  items: vendorCustomList,
                  value: selectedSearchVendor,
                  hint: "Select one",
                  searchHint: "Select one",
                  underline: Container(
                    height: 0.0,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 4.h),
                  onChanged: (value) {
                    setState(() {
                      selectedSearchVendor = value;
                    });
                  },
                  isExpanded: true,
                ),
              ),

            // selectVendorDropdown(),

            20.heightBox,
            selectIssueDropdown(),
            20.heightBox,
            buildMessageField(),
            5.heightBox,
            fileAddOptionBlock(),
            if (isImageUpload) 20.heightBox,
            if (isImageUpload) buildImageField(context),
            30.heightBox,
            buildSubmitButton(context),
            10.heightBox,
          ],
        ),
      ),
    );
  }

  fileAddOptionBlock() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 15.h),
          child: text(
            "Attachments (optional)",
            fontSize: 14.sp,
          ),
        ),
        if (!isImageUpload)
          Container(
            margin: EdgeInsets.only(top: 10.h),
            padding: EdgeInsets.symmetric(
              vertical: 15.h,
              horizontal: 15.w,
            ),
            decoration: BoxDecoration(
              color: white,
              borderRadius: radius(8.r),
              border: Border.all(
                color: textPrimaryColor,
                width: 0.5.w,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                text(
                  'Select Image',
                  textColor: grey,
                  fontSize: 15.sp,
                ),
                SvgPicture.asset(
                  attach,
                  height: 22,
                )
              ],
            ),
          ).onTap(() {
            GetImageFromDevice.instance.getImage(ImgSource.both, context).then(
              (file) {
                if (file != null) {
                  setState(
                    () {
                      isImageUpload = true;
                      _image = file;
                    },
                  );
                }
              },
            );
          }),
      ],
    );
  }

  selectIssueDropdown() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text(
          'Please choose type of issue you are facing',
          fontSize: 14.sp,
        ),
        8.heightBox,
        DropdownButtonHideUnderline(
          child: DropdownButtonFormField2(
            decoration: const InputDecoration(
              fillColor: white,
              contentPadding: EdgeInsets.fromLTRB(0, 20, 15, 13),
            ),
            iconStyleData: IconStyleData(
              icon: Icon(
                Boxicons.bx_chevron_down,
                color: Colors.black,
                size: 20.sp,
              ),
              iconSize: 22.sp,
              iconEnabledColor: colorPrimary,
              iconDisabledColor: gray,
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 175.h,
              decoration: const BoxDecoration(color: Colors.white),
              offset: const Offset(0, -5),
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: MaterialStateProperty.all<double>(3),
                thumbVisibility: MaterialStateProperty.all<bool>(true),
              ),
            ),
            menuItemStyleData: MenuItemStyleData(
              height: 40.h,
              padding: EdgeInsets.only(left: 25.w),
            ),
            value: selectedIssue,
            hint: text(
              'Select issue',
              fontSize: 16.sp,
              textColor: gray,
            ),
            items: issueList.map<DropdownMenuItem<String>>((type) {
              return DropdownMenuItem<String>(
                value: type['id'].toString(),
                child: text(
                  type['name'],
                  // textColor: _themeController.isDarkMode.value ? white : line,
                  fontSize: 17.sp,
                ),
              );
            }).toList(),
            validator: (value) {
              if (value == null) {
                return 'Please select Issue type';
              }
              return null;
            },
            onChanged: (value) {
              validator.clearErrorsAt('issueType');
              setState(() {
                selectedIssue = value;
              });
            },
            onSaved: (value) {
              // selectedValue = value.toString();
            },
          ),
        ),
      ],
    );
  }

  selectVendorDropdown() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text(
          'Please select vendor',
          fontSize: 14.sp,
        ),
        8.heightBox,
        DropdownButtonHideUnderline(
          child: DropdownButtonFormField2(
            decoration: const InputDecoration(
              fillColor: white,
              contentPadding: EdgeInsets.fromLTRB(0, 20, 15, 13),
            ),
            iconStyleData: IconStyleData(
              icon: Icon(
                Boxicons.bx_chevron_down,
                color: Colors.black,
                size: 20.sp,
              ),
              iconSize: 22.sp,
              iconEnabledColor: colorPrimary,
              iconDisabledColor: gray,
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 175.h,
              decoration: const BoxDecoration(color: Colors.white),
              offset: const Offset(0, -5),
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: MaterialStateProperty.all<double>(3),
                thumbVisibility: MaterialStateProperty.all<bool>(true),
              ),
            ),
            menuItemStyleData: MenuItemStyleData(
              height: 40.h,
              padding: EdgeInsets.only(left: 25.w),
            ),
            value: selectedVendor,
            hint: text(
              'Select vendor',
              fontSize: 16.sp,
              textColor: gray,
            ),
            items: vendorList.map<DropdownMenuItem<String>>((type) {
              return DropdownMenuItem<String>(
                value: type['id'].toString(),
                child: text(
                  '${type['name']} (${type['code']})',
                  fontSize: 17.sp,
                ),
              );
            }).toList(),
            validator: (value) {
              if (value == null) {
                return 'Please select vendor';
              }
              return null;
            },
            onChanged: (value) {
              validator.clearErrorsAt('vendorId');
              setState(() {
                selectedVendor = value;
              });
            },
            onSaved: (value) {
              // selectedValue = value.toString();
            },
          ),
        ),
      ],
    );
  }

  Future<void> cropImage() async {
    if (_image != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _image!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Crop your image',
              toolbarColor: colorPrimary,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          croppedXFile = croppedFile;
          _image = null;
        });
      }
    }
  }

  void clear() {
    setState(() {
      _image = null;
      croppedXFile = null;
    });
  }

  Widget buildSubjectField() {
    return formField(context, 'Enter the subject',
        keyboardType: TextInputType.text,
        controller: _subjectController,
        validator: validator.add(
          key: 'subject',
          rules: [
            ValidatorX.mandatory(),
          ],
        ), onChanged: (value) {
      value = value?.replaceAll(' ', '');
      bool onlyWhiteSpaces = value!.isEmpty;
      if (onlyWhiteSpaces) {
        _subjectController.clear();
      }
      validator.clearErrorsAt('subject');
    }, inputFormatters: [
      FilteringTextInputFormatter.deny(
        RegExp(r'^\s'),
      ),
    ]);
  }

  Widget buildMessageField() {
    return formField(context,
        'Please enter the details of your request, our support staff will provide a response as soon as possible',
        keyboardType: TextInputType.text,
        maxLine: 5,
        controller: _descriptionController,
        validator: validator.add(
          key: 'description',
          rules: [
            ValidatorX.mandatory(),
          ],
        ), onChanged: (value) {
      value = value!.replaceAll(' ', '');
      bool onlyWhiteSpaces = value.isEmpty;
      if (onlyWhiteSpaces) {
        _descriptionController.clear();
      }
      validator.clearErrorsAt('description');
    }, inputFormatters: [
      FilteringTextInputFormatter.deny(
        RegExp(r'^\s'),
      ),
    ]);
  }

  Widget buildSubmitButton(BuildContext context) {
    return CustomButton(
      textContent: 'Submit',
      onPressed: () async {
        setState(() {
          autoValidate = true;
        });

        if (_createTicketFormKey.currentState!.validate()) {
          FocusScope.of(context).requestFocus(FocusNode());
          await createTicket(context);
        }
      },
    );
  }

  Future<void> createTicket(BuildContext context) async {
    dynamic screenShot;
    if (!isCreatingTicket) {
      isCreatingTicket = true;
      if (_image != null) {
        Future.delayed(const Duration(milliseconds: 200), () {
          showUploadingDialog(context, indexController);
        });
        screenShot = await Vapor.upload(
          _image,
          progressCallback: (int? completed, int? total) {
            setState(() {
              uploading = true;
            });
            progressString = ((completed! / total!) * 100).toStringAsFixed(0);
            progressValue = ((completed / total));
            indexController.add(progressString.toInt());
          },
        );
        Get.back();
      } else if (_image == null && croppedXFile != null) {
        Future.delayed(const Duration(milliseconds: 200), () {
          showUploadingDialog(context, indexController);
        });
        screenShot = await Vapor.upload(
          File(croppedXFile!.path),
          progressCallback: (int? completed, int? total) {
            setState(() {
              uploading = true;
            });
            progressString = ((completed! / total!) * 100).toStringAsFixed(0);
            progressValue = ((completed / total));
            indexController.add(progressString.toInt());
          },
        );
      }
      setState(() {
        uploading = false;
      });
      Map<String, dynamic> sendData = {
        if (screenShot != null) 'image': screenShot,
        'description': _descriptionController.text,
        "complaintType": selectedIssue,
        "vendorId": selectedVendor,
      };
      Api.http.post('member/offline-store-complaint/store', data: sendData).then((response) {
        isCreatingTicket = false;
        if (response.data['status']) {
          Get.back(result: true);
          AppUtils.showSuccessSnackBar(response.data['message']);
        } else {
          AppUtils.showErrorSnackBar(response.data['message']);
        }
      }).catchError((error) {
        isCreatingTicket = false;
        if (error.response.statusCode == 422) {
          validator.setErrors(error.response.data['errors']);
          AppUtils.showSuccessSnackBar(error.response.data['errors'][0]['message']);
        }
      });
    }
  }

  Widget buildImageField(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: <Widget>[
              Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                margin: EdgeInsets.all(4.sp),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  children: <Widget>[
                    if (!uploading)
                      _image != null
                          ? Container(
                              margin: EdgeInsets.symmetric(horizontal: 40.w),
                              child: Image.file(
                                _image!,
                                width: double.infinity,
                                height: 200.h,
                                fit: BoxFit.fitHeight,
                              ),
                            ).onTap(() {
                              AppUtils.showDialogForImageExpand(
                                context,
                                imageWidget: Image.file(
                                  _image!,
                                  width: 500.sp,
                                  height: 500.sp,
                                ),
                              );
                            })
                          : _image == null && croppedXFile != null
                              ? Container(
                                  margin: EdgeInsets.symmetric(horizontal: 40.w),
                                  child: Image.file(
                                    File(croppedXFile!.path),
                                    width: double.infinity,
                                    height: 200.h,
                                    fit: BoxFit.contain,
                                  ),
                                ).onTap(() {
                                  AppUtils.showDialogForImageExpand(
                                    context,
                                    imageWidget: Image.file(
                                      File(croppedXFile!.path),
                                      width: 500.sp,
                                      height: 500.sp,
                                    ),
                                  );
                                })
                              : Image.asset(
                                  noImage,
                                  width: double.infinity,
                                  height: 200.h,
                                  fit: BoxFit.contain,
                                ),
                    if (uploading && _image != null)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 40.w),
                        child: Image.file(
                          _image!,
                          width: double.infinity,
                          height: 200.h,
                          fit: BoxFit.fitHeight,
                        ),
                      )
                  ],
                ),
              ),
              if (!uploading)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isImageUpload = false;
                          _image = null;
                        });
                      },
                      icon: const Icon(
                        UniconsLine.trash_alt,
                        color: red,
                      ),
                    ),
                    if (_image != null)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            cropImage();
                          });
                        },
                        icon: const Icon(
                          UniconsLine.crop_alt,
                          color: red,
                        ),
                      ),
                  ],
                )
            ],
          ),
        ],
      ),
    );
  }
}
