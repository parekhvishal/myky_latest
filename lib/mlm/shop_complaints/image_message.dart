import 'dart:io';

import 'package:boxicons/boxicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart' hide white;

import '../../services/Vapor.dart';
import '../../services/api.dart';
import '../../services/validator_x.dart';
import '../../widget/image_picker.dart';
import '../../widget/theme.dart';

class ImageOrMessage extends StatefulWidget {
  const ImageOrMessage({super.key});

  @override
  State<ImageOrMessage> createState() => _ImageOrMessageState();
}

class _ImageOrMessageState extends State<ImageOrMessage> {
  final TextEditingController _messageController = TextEditingController();
  final _imageOrMessageKey = GlobalKey<FormState>();
  ValidatorX validator = ValidatorX();
  File? _image;
  bool? isImage = false;
  int? helpDeskId;
  final Map<String, dynamic> _errors = {};

  Future getImage(ImgSource source) async {
    PickedFile? image = await ImagePickerGC.pickImage(
      context: context,
      source: source,
      cameraIcon: Icon(
        Boxicons.bx_camera,
        color: colorPrimary,
      ),
      galleryIcon: Icon(
        Boxicons.bx_image,
        color: colorPrimary,
      ),
    );
    setState(() {
      _image = File(image!.path);
    });
  }

  @override
  void initState() {
    helpDeskId = Get.arguments;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _imageOrMessageKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Padding(
            padding: EdgeInsets.all(8.sp),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text('Message'),
                  20.height,
                  TextFormField(
                    autofocus: true,
                    controller: _messageController,
                    maxLength: 190,
                    maxLines: 5,
                    validator: validator.add(
                      key: 'message',
                    ),
                    onChanged: (value) {
                      validator.clearErrorsAt('message');
                    },
                    inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ ]'))],
                    style: TextStyle(fontSize: 15.sp, color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Your Message...',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                  20.height,
                  text('Select Image'),
                  10.height,
                  Center(
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
                                  _image != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8.r),
                                          child: Image.file(
                                            _image!,
                                            width: double.infinity,
                                            height: 200.h,
                                            fit: BoxFit.contain,
                                          ),
                                        )
                                      : Image.asset(
                                          noImage,
                                          width: double.infinity,
                                          height: 200.h,
                                          fit: BoxFit.contain,
                                        ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(4.sp),
                              margin: EdgeInsets.only(
                                top: 15.h,
                                right: 10.w,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: white,
                                border: Border.all(color: colorPrimary),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  getImage(ImgSource.gallery);
                                },
                                child: Icon(
                                  Icons.camera_alt,
                                  color: colorPrimary,
                                  size: 20.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_image == null && _errors.containsKey('image')) SizedBox(height: 5.h),
                        if (_image == null && _errors.containsKey('image'))
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: text(
                              _errors['image'][0],
                              textColor: red,
                            ),
                          ),
                      ],
                    ),
                  ),
                  20.height,
                  CustomButton(
                    textContent: 'Send',
                    onPressed: () async {
                      if (_imageOrMessageKey.currentState!.validate()) {
                        FocusScope.of(context).requestFocus(FocusNode());
                        dynamic screenShot;
                        if (_image != null) {
                          screenShot = await Vapor.upload(
                            _image,
                          );
                        }
                        Map<String, dynamic> sendData = {
                          if (screenShot != null) 'image': screenShot,
                          'message': _messageController.text,
                          'offlineShopComplaintId': helpDeskId,
                        };

                        Api.http
                            .post(
                          'member/offline-store-complaint/update',
                          data: sendData,
                          // data: FormData.fromMap(sendData),
                        )
                            .then((res) async {
                          if (res.data['status']) {
                            Get.back();
                          } else {
                            GetSnackBar(
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 3),
                              message: res.data['message'],
                            ).show();
                          }
                        }).catchError((error) {
                          if (error.response.statusCode == 422) {
                            setState(() {
                              validator.setErrors(error.response.data['errors']);
                            });
                          }
                        });
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
