import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart' hide white;
import 'package:path/path.dart' as path;
import 'package:unicons/unicons.dart';

import '../../services/Vapor.dart';
import '../../services/api.dart';
import '../../services/getImage_service.dart';
import '../../services/size_config.dart';
import '../../services/validator_x.dart';
import '../../utils/app_utils.dart';
import '../../widget/image_picker.dart';
import '../../widget/theme.dart';
import '../../widget/video_thumbnail.dart';

class ProductReturn extends StatefulWidget {
  const ProductReturn({Key? key}) : super(key: key);

  @override
  State<ProductReturn> createState() => _ProductReturnState();
}

class _ProductReturnState extends State<ProductReturn> {
  final _requestFormKey = GlobalKey<FormState>();
  Map? orderDetail;
  ValidatorX validator = ValidatorX();
  TextEditingController _reasonController = TextEditingController();
  TextEditingController _remarkController = TextEditingController();
  String? reasonType;
  List reasonTypes = [];
  int? orderID;
  File? _image1;
  File? _image2;
  File? _video;
  bool uploadingImage1 = false;
  bool uploadingImage2 = false;
  String progressStringImage1 = "";
  String progressStringImage2 = "";
  String? thumbnail;
  List<File> fileListToUpload = [];
  dynamic allIDImages;
  StreamController<int> indexController = StreamController<int>.broadcast();
  Timer? _debounce;
  String progressString = "";
  num progressValue = 0;

  @override
  void initState() {
    orderDetail = Get.arguments;
    orderID = orderDetail!['orderID'];
    reasonTypes = orderDetail!['returnTypes'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: text('Return Process'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _requestFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: () {},
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        20.height,
                        reasonDropdown(),
                        20.height,
                        buildReturnReasonFormField(context),
                        10.height,
                        buildImagePickerBlock(),
                        text('(Note : Must upload video and images)',
                            textColor: redColor, fontSize: 12.0),
                        20.height,
                        buildVideoPickerBlock(),
                        10.height,
                        text(
                          '(Upload Video : Parcel opening video When the product is received, must upload without any pause or cut. Otherwise, NO complaint will be attended)',
                          textColor: redColor,
                          fontSize: 12.0,
                          isLongText: true,
                        ),
                        20.height,
                        _sendButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildReturnReasonFormField(BuildContext context) {
    return formField(
      context,
      'Why you want to return ?',
      controller: _reasonController,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ ]'))],
      validator: validator.add(
        key: 'reason',
        rules: [
          ValidatorX.mandatory(message: 'Reason field is required'),
        ],
      ),
      onChanged: (String? value) {
        validator.clearErrorsAt('reason');
      },
    );
  }

  Widget buildVideoPickerBlock() {
    return thumbnail != null
        ? Container(
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  margin: EdgeInsets.all(spacing_control),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: h(30),
                        width: w(100),
                        decoration: BoxDecoration(
                          // color: Colors.black,
                          color: white,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(
                              File(thumbnail!),
                            ),
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(0),
                          ),
                        ),
                        child: Icon(
                          Icons.play_circle_fill,
                          color: colorPrimary,
                          size: 50,
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
                      color: white_color,
                      border: Border.all(color: colorPrimary)),
                  child: GestureDetector(
                    onTap: () {
                      getVideo();
                    },
                    child: Icon(
                      Icons.video_camera_back_outlined,
                      color: colorPrimary,
                      size: 15,
                    ),
                  ),
                ),
              ],
            ),
          )
        : CustomButton(
            customColor: colorAccent,
            textContent: 'Add Video',
            onPressed: () {
              getVideo();
            });
  }

  Widget buildImagePickerBlock() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              margin: EdgeInsets.all(spacing_control),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: <Widget>[
                  if (!uploadingImage1)
                    _image1 != null
                        ? Image.file(
                            _image1!,
                            width: w(40.0),
                            height: 100,
                            fit: BoxFit.contain,
                          )
                        : Image.asset(
                            'assets/images/no_image.png',
                            width: w(40.0),
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                  if (uploadingImage1)
                    Container(
                      height: 100,
                      width: w(40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(),
                          SizedBox(height: 20.0),
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
              padding: EdgeInsets.all(spacing_control),
              margin: EdgeInsets.only(top: 15, right: 10),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: white_color,
                  border: Border.all(color: colorPrimary)),
              child: GestureDetector(
                onTap: () {
                  GetImageFromDevice.instance.getImage(ImgSource.both, context).then((file) {
                    if (file != null) {
                      _image1 = file;
                      setState(() {});
                    }
                  });
                  // getImage1(ImgSource.Both);
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
              margin: EdgeInsets.all(spacing_control),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: <Widget>[
                  if (!uploadingImage2)
                    _image2 != null
                        ? Image.file(
                            _image2!,
                            width: w(40.0),
                            height: 100,
                            fit: BoxFit.contain,
                          )
                        : Image.asset(
                            'assets/images/no_image.png',
                            width: w(40.0),
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                  if (uploadingImage2)
                    Container(
                      height: 100,
                      width: w(40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(),
                          SizedBox(height: 20.0),
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
              padding: EdgeInsets.all(spacing_control),
              margin: EdgeInsets.only(top: 15, right: 10),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: white_color,
                  border: Border.all(color: colorPrimary)),
              child: GestureDetector(
                onTap: () {
                  GetImageFromDevice.instance.getImage(ImgSource.both, context).then((file) {
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
    );
  }

  Widget reasonDropdown() {
    return DropdownButtonFormField<String>(
      isDense: true,
      isExpanded: true,
      validator: validator.add(
        key: 'return_reason_id',
        rules: [
          ValidatorX.mandatory(message: "Select Reason"),
        ],
      ),
      hint: Text('Select Reason'),
      value: reasonType,
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(spacing_standard),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(spacing_standard),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        filled: true,
        fillColor: Color(0xFFf7f7f7),
        hintText: 'Select',
        hintStyle: TextStyle(fontSize: textSizeMedium, color: Colors.grey[300]),
      ),
      onChanged: (String? newValue) {
        setState(() {
          reasonType = newValue!;
        });
        validator.clearErrorsAt('return_reason_id');
      },
      items: reasonTypes.map<DropdownMenuItem<String>>((type) {
        return DropdownMenuItem<String>(
          child: Text(type['reason']),
          value: type['id'].toString(),
        );
      }).toList(),
    );
  }

  Future<void> uploadingImages(BuildContext context) async {
    Future.delayed(const Duration(milliseconds: 200), () {
      AppUtils.onLoading(context, "Your documents are\nuploading please wait..");
    });

    allIDImages = await Vapor.uploadList(
      fileListToUpload,
      onConnectionLost: () {
        Get.back();
        Get.toNamed('/no-internet')!.then((value) {
          uploadingImages(context);
          setState(() {});
        });
      },
      progressCallback: (int? completed, int? total) {
        setState(() {});
        progressString = ((completed! / total!) * 100).toStringAsFixed(0);
        progressValue = ((completed / total));
        indexController.add(progressString.toInt());
      },
    );
    Get.back();
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await _sendButton(context);
      // do something with query
    });
  }

  _sendButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: MaterialButton(
        color: colorPrimary,
        padding: EdgeInsets.all(15),
        child: text(
          'Submit',
          textColor: white,
          fontFamily: fontBold,
          textAllCaps: true,
        ),
        onPressed: () async {
          if (_requestFormKey.currentState!.validate()) {
            if (_image1 == null || _image1!.path.toString().isEmpty) {
              AppUtils.showErrorSnackBar('Image is required');
            } else if (_image2 == null || _image2!.path.toString().isEmpty) {
              AppUtils.showErrorSnackBar('Image is required');
            } else if (_video == null || _video!.path.toString().isEmpty) {
              AppUtils.showErrorSnackBar('Video is required');
            } else {
              fileListToUpload.add(File(_image1!.path.toString()));
              fileListToUpload.add(File(_image2!.path.toString()));
              fileListToUpload.add(File(_video!.path.toString()));
              await uploadingImages(context);
              sendDataToServer(context);
            }
          }
        },
      ),
    );
  }

  void sendDataToServer(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
    Map requestData = {
      'reason': _reasonController.text,
      'id': orderID,
      'return_reason_id': reasonType,
      'return_order_image1': allIDImages[0],
      'return_order_image2': allIDImages[1],
      'order_return_video': allIDImages[2],
      // 'user_type': Auth.check()! ? 1 : 2,
    };
    Api.http.post('shopping/order/return', data: requestData).then(
      (response) async {
        AppUtils.showInfoSnackBar(
          response.data['message'],
          color: response.data['status'] ? Colors.green : Colors.red,
        );
        if (response.data['status']) {
          Timer(Duration(seconds: 3), () {
            Get.back(result: true);
          });
        }
      },
    ).catchError(
      (error) {
        if (error.response.statusCode == 422) {
          AppUtils.showErrorSnackBar(error.response.data['message']);
        } else if (error.response.statusCode == 401) {
          AppUtils.showErrorSnackBar(error.response.data['message']);
        }
      },
    );
  }

  Future getImage1(ImgSource source) async {
    PickedFile image = await ImagePickerGC.pickImage(
      context: context,
      source: source,
      cameraIcon: Icon(UniconsLine.camera),
      galleryIcon: Icon(UniconsLine.image),
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
      cameraIcon: Icon(UniconsLine.camera),
      galleryIcon: Icon(UniconsLine.image),
      cameraText: text("From Camera"),
      galleryText: text("From Gallery"),
      barrierDismissible: true,
    );
    setState(() {
      _image2 = File(image.path);
    });
  }

  getVideo() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.camera);
    if (pickedFile != null) {
      num videoFileSizeInKB = File(pickedFile.path).readAsBytesSync().lengthInBytes / 1024;
      num videoFileSizeInMB = videoFileSizeInKB / 1024;
      if (videoFileSizeInMB < AppUtils.videoSize) {
        var extension = path.extension(pickedFile.path);
        if (extension == '.mkv' || extension == '.mp4' || extension == '.mp3') {
          _video = File(pickedFile.path);
          String? thumbnailPath = await Thumbnail.getThumbnailFromFile(_video!);
          setState(() {
            thumbnail = thumbnailPath;
          });
        } else {
          AppUtils.showErrorSnackBar('Video extension is invalid');
        }
      } else {
        AppUtils.showErrorSnackBar('Video should be less than ${AppUtils.videoSize} MB');
      }
    } else {}
  }
}
