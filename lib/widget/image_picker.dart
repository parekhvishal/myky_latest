library image_picker_gallery_camera;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myky_clone/widget/theme.dart';
import 'package:unicons/unicons.dart';

import 'inner_shadow.dart';

class ImagePickerGC {
  static Future pickImage(
      {required BuildContext context,
      required ImgSource source,
      bool? enableCloseButton,
      double? maxWidth,
      double? maxHeight,
      Icon? cameraIcon,
      Icon? galleryIcon,
      Widget? cameraText,
      Widget? galleryText,
      bool barrierDismissible = false,
      Icon? closeIcon,
      int? imageQuality}) async {
    assert(imageQuality == null || (imageQuality >= 0 && imageQuality <= 100));

    if (maxWidth != null && maxWidth < 0) {
      throw ArgumentError.value(maxWidth, 'maxWidth cannot be negative');
    }

    if (maxHeight != null && maxHeight < 0) {
      throw ArgumentError.value(maxHeight, 'maxHeight cannot be negative');
    }

    switch (source) {
      case ImgSource.camera:
        return await ImagePicker()
            .pickImage(source: ImageSource.camera, maxWidth: maxWidth, maxHeight: maxHeight);
      case ImgSource.gallery:
        return await ImagePicker()
            .pickImage(source: ImageSource.gallery, maxWidth: maxWidth, maxHeight: maxHeight);
      case ImgSource.both:
        return await showDialog<void>(
          context: context,
          barrierDismissible: barrierDismissible, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25.r))),
              content: InnerShadowContainer(
                color: white,
                borderColor: colorAccent,
                offset: const Offset(0, 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    enableCloseButton == true
                        ? GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Align(
                              alignment: Alignment.topRight,
                              child: closeIcon ??
                                  const Icon(
                                    Icons.close,
                                    size: 14,
                                  ),
                            ),
                          )
                        : Container(),
                    InkWell(
                      onTap: () async {
                        ImagePicker()
                            .pickImage(
                                source: ImageSource.gallery,
                                maxWidth: maxWidth,
                                maxHeight: maxHeight,
                                imageQuality: imageQuality)
                            .then((image) {
                          Navigator.pop(context, image);
                        });
                      },
                      child: ListTile(
                        title: galleryText ??
                            text(
                              "From Gallery",
                              fontFamily: fontBold,
                              textColor: colorPrimary,
                            ),
                        leading: galleryIcon != null
                            ? Icon(
                                UniconsLine.image_plus,
                                color: colorAccent,
                              )
                            : Icon(
                                UniconsLine.image_plus,
                                color: colorAccent,
                              ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        ImagePicker()
                            .pickImage(
                                source: ImageSource.camera,
                                maxWidth: maxWidth,
                                maxHeight: maxHeight)
                            .then((image) {
                          Navigator.pop(context, image);
                        });
                      },
                      child: ListTile(
                        title: cameraText ??
                            text(
                              "From Camera",
                              fontFamily: fontBold,
                              textColor: colorPrimary,
                            ),
                        leading: cameraIcon != null
                            ? Icon(
                                UniconsLine.camera_plus,
                                color: colorAccent,
                              )
                            : Icon(
                                UniconsLine.camera_plus,
                                color: colorAccent,
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
  }
}

enum ImgSource { camera, gallery, both }
