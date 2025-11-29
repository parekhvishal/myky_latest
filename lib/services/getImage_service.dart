import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:unicons/unicons.dart';

import '../utils/app_utils.dart';
import '../widget/image_picker.dart';

class GetImageFromDevice {
  GetImageFromDevice._internal();

  static final GetImageFromDevice _instance = GetImageFromDevice._internal();

  static GetImageFromDevice get instance => _instance;

  Future<File?> getImage(ImgSource source, context, {num uploadSize = 10}) async {
    XFile image = await ImagePickerGC.pickImage(
      context: context,
      source: source,
      barrierDismissible: true,
      cameraIcon: const Icon(
        UniconsLine.camera,
      ),
      galleryIcon: const Icon(
        UniconsLine.image,
      ),
    );

    num imageFileSizeInKB = File(image.path).readAsBytesSync().lengthInBytes / 1024;
    num imageFileSizeInMB = imageFileSizeInKB / 1024;
    if (imageFileSizeInMB < uploadSize) {
      var extension = path.extension(image.path);
      if (extension == '.jpg' || extension == '.jpeg' || extension == '.png') {
        return Future.value(File(image.path));
      } else {
        AppUtils.showErrorSnackBar('Image extension is invalid');
        return Future.value(null);
      }
    } else {
      AppUtils.showErrorSnackBar('Image should be less than $uploadSize MB');
      return Future.value(null);
    }
  }
}
