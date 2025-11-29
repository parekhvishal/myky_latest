// import 'dart:async';
// import 'dart:io';
//
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:dio/dio.dart';
// // import 'package:external_path/external_path.dart';
// import 'package:flutter/material.dart';
// import 'package:nb_utils/nb_utils.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import '../../utils/app_utils.dart';
// import '../../widget/theme.dart';
//
// class FileDownloadCtrl {
//   static int progressInt = 0;
//   late String localPath;
//   String downloadTaskId = '';
//   final StreamController<int> generateNumbers = StreamController<int>.broadcast();
//   bool isDownloading = false;
//   int sdkVersion = 0;
//
//   FileDownloadCtrl();
//
//   Future _findLocalPath() async {
//     if (Platform.isAndroid) {
//       if (sdkVersion >= 33) {
//         // For android 13
//         return (await getApplicationDocumentsDirectory()).path;
//       }
//       Directory? directory = Directory('/storage/emulated/0/Download');
//       if (!await directory.exists()) directory = await getExternalStorageDirectory();
//       return directory?.path;
//       // return await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
//     } else {
//       return (await getApplicationDocumentsDirectory()).path;
//     }
//   }
//
//   download(String url, BuildContext context) async {
//     await setSDKVersion();
//
//     _checkPermission().then((hasGranted) async {
//       if (hasGranted) {
//         localPath = await _findLocalPath();
//         final savedDir = Directory(localPath);
//
//         bool hasExisted = await savedDir.exists();
//
//         if (!hasExisted) {
//           savedDir.create();
//         } else {}
//
//         if (!isDownloading) {
//           isDownloading = true;
//           try {
//             getFile(url);
//           } on Exception catch (exception) {
//             toast(
//               '${exception}exception',
//               bgColor: colorPrimary,
//               textColor: Colors.white,
//             );
//           } catch (error) {
//             toast(
//               '${error}error',
//               bgColor: colorPrimary,
//               textColor: Colors.white,
//             );
//           }
//         }
//       } else {}
//     });
//   }
//
//   Future<bool> _checkPermission() async {
//     if (sdkVersion >= 33) {
//       // For android 13
//       return true;
//     } else {
//       PermissionStatus status = await Permission.storage.status;
//       // Either the permission was already granted before or the user just granted it.
//       if (status.isGranted) {
//         return true;
//       } else {
//         bool permission = await Permission.storage.request().isGranted;
//         if (permission) {
//           return true;
//         } else {
//           return false;
//         }
//       }
//     }
//   }
//
//   void dispose() {
//     //
//   }
//
//   proceedDownload(String filePath, url) async {
//     Dio dio = Dio();
//
//     try {
//       await dio.download(url, filePath);
//     } catch (e) {
//       AppUtils.showErrorSnackBar(
//         "We could not download, please check internet or try again later",
//       );
//     }
//   }
//
//   Future<void> getFile(String url) async {
//     File file = File('$localPath/${url.split('/').last}');
//
//     if (await file.exists()) {
//       AppUtils.showSuccessSnackBar(
//         "Opening...",
//       );
//     } else {
//       AppUtils.showSuccessSnackBar(
//         "Saving...",
//       );
//
//       await proceedDownload(file.path, url);
//     }
//
//     OpenFilex.open(file.path);
//   }
//
//   Future<void> setSDKVersion() async {
//     AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
//
//     sdkVersion = info.version.sdkInt ?? 0;
//   }
// }
