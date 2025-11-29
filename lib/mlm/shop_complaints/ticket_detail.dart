import 'dart:async';
import 'dart:io';

import 'package:boxicons/boxicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_cropper/image_cropper.dart';
import 'package:myky_clone/utils/en_extensions.dart';
import 'package:nb_utils/nb_utils.dart' hide white;
import 'package:unicons/unicons.dart';

import '../../../services/api.dart';
import '../../services/Vapor.dart';
import '../../services/getImage_service.dart';
import '../../utils/app_utils.dart';
import '../../widget/image_picker.dart';
import '../../widget/image_popup.dart';
import '../../widget/network_image.dart';
import '../../widget/paginated_list.dart';
import '../../widget/show_uploading_model.dart';
import '../../widget/theme.dart';

class TicketDetails extends StatefulWidget {
  const TicketDetails({super.key});

  @override
  TicketDetailsState createState() => TicketDetailsState();
}

class TicketDetailsState extends State<TicketDetails> {
  int? ticketId;
  int? status;
  List? messages;
  File? _image;
  bool? isImage = false;
  num progressValue = 0;
  bool uploading = false;
  String progressString = "";
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<PaginatedListState> _ticketDetailPaginatedListKey = GlobalKey();
  StreamController<int> indexController = StreamController<int>.broadcast();

  bool isMessageSending = false;
  CroppedFile? croppedXFile;

  @override
  void initState() {
    ticketId = Get.arguments['id'];
    status = Get.arguments['status']['id'];
    _loadTicketDetails(ticketId!);
    super.initState();
  }

  @override
  void dispose() {
    indexController.close();
    super.dispose();
  }

  confirmationImageDialog() {
    showDialog(
        context: context,
        barrierColor: black.withOpacity(0.9),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
            return Container(
              margin: EdgeInsets.symmetric(
                horizontal: 20.w,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 40,
                    ),
                    child: Image.file(
                      _image != null
                          ? _image!
                          : _image == null && croppedXFile != null
                              ? File(croppedXFile!.path)
                              : File(noImage),
                      width: double.infinity,
                      height: 450.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          Get.back();
                          _image = null;
                        },
                        icon: Icon(
                          UniconsLine.trash_alt,
                          size: 30.sp,
                          color: redColor.withOpacity(0.6),
                        ),
                      ),
                      10.widthBox,
                      if (_image != null)
                        IconButton(
                          onPressed: () async {
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
                          },
                          icon: Icon(
                            UniconsLine.crop_alt,
                            size: 30.sp,
                            color: white.withOpacity(0.6),
                          ),
                        ),
                      10.widthBox,
                      IconButton(
                        onPressed: () {
                          Get.back();
                          // _sendMessage(_messageController.text);
                        },
                        icon: Icon(
                          UniconsLine.check,
                          size: 30.sp,
                          color: greenColor,
                        ),
                      ),
                    ],
                  ),
                  10.heightBox,
                ],
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Ticket"),
          actions: [
            IconButton(
              onPressed: () async {
                _loadTicketDetails(ticketId!);
                _ticketDetailPaginatedListKey.currentState!.refresh();
              },
              icon: Icon(
                Boxicons.bx_refresh,
                size: 25.sp,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: PaginatedList(
                key: _ticketDetailPaginatedListKey,
                resetStateOnRefresh: true,
                isPullToRefresh: false,
                apiFuture: (page) async {
                  return await Api.http.post(
                    'member/offline-store-complaint/messages?page=$page',
                    data: {
                      'offlineShopComplaintId': ticketId,
                    },
                  );
                },
                listItemBuilder: _chatWidget,
              ),
            ),
            status != 2
                ? Column(
                    children: [
                      imageBlock(),
                      Container(
                        margin: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                        child: Stack(
                          alignment: Alignment.centerRight,
                          clipBehavior: Clip.none,
                          children: [
                            AppTextField(
                              textFieldType: TextFieldType.OTHER,
                              maxLines: 3,
                              textStyle: const TextStyle(color: gray),
                              controller: _messageController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                fillColor: Colors.white,
                                hintText: 'Write a reply...',
                                hintStyle: TextStyle(
                                  fontSize: 17.sp,
                                  color: Colors.grey,
                                  fontFamily: fontRegular,
                                ),
                                suffixIcon: Icon(
                                  Boxicons.bx_send,
                                  size: 25.sp,
                                  color: colorAccent,
                                ).onTap(
                                  () {
                                    if (_messageController.text.isNotEmpty || _image != null) {
                                      _sendMessage(_messageController.text);
                                    } else {
                                      AppUtils.showErrorSnackBar('Please enter message to proceed');
                                    }
                                  },
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SvgPicture.asset(
                                    attach,
                                  ).onTap(
                                    () {
                                      GetImageFromDevice.instance
                                          .getImage(ImgSource.both, context)
                                          .then(
                                        (file) {
                                          if (file != null) {
                                            setState(() {
                                              _image = file;
                                            });
                                            if (_image != null) {
                                              confirmationImageDialog();
                                            }
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 5.h,
                    ),
                    margin: EdgeInsets.only(bottom: 10.h),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppUtils.setStatusColor('closed'),
                        width: 2.w,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.r),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.h,
                      ),
                      child: text(
                        'This ticket is closed by admin',
                        fontSize: 18.sp,
                        fontFamily: fontSemibold,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _chatWidget(data, index) {
    return (data['sendBy']['id'] == 2) ? userMessage(data) : adminMessage(data);
  }

  imageBlock() {
    if (_image != null) {
      return Container(
        padding: EdgeInsets.symmetric(
          vertical: 5.h,
          horizontal: 15.w,
        ),
        decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            text(
              "One Photo Attached",
              textColor: colorAccent,
              fontFamily: fontSemibold,
              fontSize: 15.sp,
            ),
            5.widthBox,
            GestureDetector(
              onTap: () {
                setState(() {
                  _image = null;
                });
              },
              child: Icon(
                UniconsLine.times_circle,
                color: Colors.red,
                size: 22.sp,
              ),
            ),
          ],
        ),
      ).onTap(() {
        // showDialogForImageExpand(context, _image, isFileFormat: true);
      });
    }
    return const SizedBox.shrink();
  }

  Widget userMessage(data) {
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: Column(
        children: [
          10.heightBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: radius(8.r),
                ),
                padding: EdgeInsets.all(10.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    data['message'] != null && data['imageUrl'] != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PNetworkImage(
                                data['imageUrl'],
                                height: 325.sp,
                                width: double.infinity,
                                fit: BoxFit.contain,
                                borderRadius: 12.r,
                              ).onTap(() {
                                showDialog(
                                  barrierColor: black.withOpacity(0.9),
                                  context: context,
                                  builder: (_) {
                                    return ImageDialog(
                                      url: data['imageUrl'],
                                    );
                                  },
                                );
                              }),
                              10.heightBox,
                              text(data['message'], fontSize: 14.sp, isLongText: true)
                            ],
                          )
                        : data['message'] != null
                            ? text(data['message'], fontSize: 14.sp, isLongText: true)
                            : PNetworkImage(
                                data['imageUrl'],
                                height: 325.sp,
                                width: double.infinity,
                                fit: BoxFit.contain,
                                borderRadius: 12.r,
                              ).onTap(
                                () {
                                  showDialog(
                                    context: context,
                                    builder: (_) {
                                      return ImageDialog(
                                        url: data['imageUrl'],
                                      );
                                    },
                                  );
                                },
                              ),
                    5.height,
                    Align(
                      alignment: Alignment.centerRight,
                      child: text(
                        data['createdAt'],
                        fontSize: 12.sp,
                        fontFamily: fontBold,
                        textColor: colorAccent,
                      ),
                    )
                  ],
                ),
              ).paddingOnly(left: 42.w).expand(),
              12.widthBox,
              Container(
                  width: 40.sp,
                  height: 40.sp,
                  // padding: EdgeInsets.all(5.sp),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      // size: 35.sp,
                      Boxicons.bxs_user_circle,
                      color: colorPrimary,
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget adminMessage(data) {
    return Padding(
      padding: EdgeInsets.only(left: 12.w),
      child: Column(
        children: [
          10.heightBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: white,
                radius: 20,
                child: data['profileImage'] != null
                    ? PNetworkImage(
                        data['profileImage'],
                        fit: BoxFit.cover,
                      ).cornerRadiusWithClipRRect(30.r)
                    : Image.asset(
                        profileImage,
                        fit: BoxFit.fill,
                      ).cornerRadiusWithClipRRect(30.r),
              ),
              12.widthBox,
              Container(
                decoration: BoxDecoration(
                  color: colorPrimary.withOpacity(0.2),
                  borderRadius: radius(8.r),
                ),
                padding: EdgeInsets.all(10.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    data['message'] != null
                        ? text(data['message'], fontSize: 14.sp, isLongText: true)
                        : PNetworkImage(
                            data['imageUrl'],
                            height: 325.h,
                            width: double.infinity,
                            borderRadius: 8.r,
                            fit: BoxFit.contain,
                          ).onTap(
                            () {
                              showDialog(
                                context: context,
                                builder: (_) {
                                  return ImageDialog(
                                    url: data['imageUrl'],
                                  );
                                },
                              );
                            },
                          ),
                    5.heightBox,
                    text(
                      data['createdAt'],
                      fontSize: 12.sp,
                      fontFamily: fontBold,
                      textColor: colorAccent,
                    )
                  ],
                ),
              ).paddingOnly(right: 52.w).expand(),
            ],
          ),
        ],
      ),
    );
  }

  void _loadTicketDetails(int ticketId) {
    Api.http.post(
      'member/offline-store-complaint/messages',
      data: {
        'offlineShopComplaintId': ticketId,
      },
    ).then((response) {
      if (response.data['status']) {
        setState(() {
          messages = response.data['data'];
        });
      }
    });
  }

  void _sendMessage(msg) async {
    if (!isMessageSending) {
      isMessageSending = true;
      dynamic screenShot;
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
      Map<String, dynamic> sendData = {
        if (screenShot != null) 'image': screenShot,
        'message': msg,
        'offlineShopComplaintId': ticketId,
      };
      Api.httpWithoutLoader
          .post('member/offline-store-complaint/update', data: sendData)
          .then((response) {
        isMessageSending = false;
        // if (screenShot != null) {
        //   Get.back();
        // }
        if (response.data['status']) {
          _messageController.text = '';
          AppUtils.showSuccessSnackBar(
            response.data['message'],
            secondsToDisplay: 1,
          );
          screenShot = null;
          _image = null;
          setState(() {
            _ticketDetailPaginatedListKey.currentState!.refresh();
          });
          _loadTicketDetails(ticketId!);
        }
      }).catchError((error) {
        Get.back();
        if (error.response.statusCode == 422) {
          AppUtils.showSuccessSnackBar(error.response.data['errors']);
        }
      });
    }
  }
}
