import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:myky_clone/widget/theme.dart';
import 'package:nb_utils/nb_utils.dart' hide white;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/app_utils.dart';

class FileDownloadCtrl {
  static int progressInt = 0;
  late String localPath;
  String downloadTaskId = '';
  final StreamController<int> generateNumbers = StreamController<int>.broadcast();
  bool isDownloading = false;
  int sdkVersion = 0;
  bool? shouldAlwaysDownload;

  FileDownloadCtrl();

  Future _findLocalPath() async {
    if (Platform.isAndroid) {
      if (sdkVersion >= 33) {
        // For android 13
        return (await getApplicationDocumentsDirectory()).path;
      }

      return await ExternalPath.getExternalStoragePublicDirectory('Download');
    } else {
      return (await getApplicationDocumentsDirectory()).path;
    }
  }

  download(String url, BuildContext context, {bool? shouldAlwaysDownload}) async {
    if (shouldAlwaysDownload != null) {
      this.shouldAlwaysDownload = shouldAlwaysDownload;
    }
    await setSDKVersion();

    _checkPermission().then((hasGranted) async {
      if (hasGranted) {
        localPath = await _findLocalPath();
        final savedDir = Directory(localPath);

        bool hasExisted = await savedDir.exists();

        if (!hasExisted) {
          savedDir.create();
        } else {}

        if (!isDownloading) {
          isDownloading = true;
          try {
            getFile(url);
          } on Exception catch (exception) {
            toast(
              '${exception}exception',
              bgColor: colorPrimary,
              textColor: white,
            );
          } catch (error) {
            toast(
              '${error}error',
              bgColor: colorPrimary,
              textColor: white,
            );
          }
        }
      } else {}
    });
  }

  Future<bool> _checkPermission() async {
    if (sdkVersion >= 33) {
      // For android 13
      return true;
    } else {
      PermissionStatus status = await Permission.storage.status;
      // Either the permission was already granted before or the user just granted it.
      if (status.isGranted) {
        return true;
      } else {
        bool permission = await Permission.storage.request().isGranted;
        if (permission) {
          return true;
        } else {
          return false;
        }
      }
    }
  }

  void dispose() {
    //
  }

  proceedDownload(String filePath, url) async {
    Dio dio = Dio();

    try {
      await dio.download(url, filePath);
    } catch (e) {
      AppUtils.showErrorSnackBar("We could not download, please check internet or try again later",
          secondsToDisplay: 3);
    }
  }

  Future<void> getFile(String url) async {
    File file = File('$localPath/${url.split('/').last}');

    if (shouldAlwaysDownload != null && shouldAlwaysDownload!) {
      AppUtils.showSuccessSnackBar("Saving...", secondsToDisplay: 1);

      await proceedDownload(file.path, url);
    } else {
      if (await file.exists()) {
        AppUtils.showSuccessSnackBar("Opening...", secondsToDisplay: 1);
      } else {
        AppUtils.showSuccessSnackBar("Saving...", secondsToDisplay: 1);

        await proceedDownload(file.path, url);
      }
    }

    OpenFilex.open(file.path);
  }

  Future<void> setSDKVersion() async {
    AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;

    sdkVersion = info.version.sdkInt;
  }
}
