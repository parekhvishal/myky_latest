// import 'dart:async';
// import 'dart:io';
// import 'dart:isolate';
// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:get/get.dart';
// import 'package:nb_utils/nb_utils.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import '../../../../utils/app_utils.dart';
// import '../../../../widget/theme.dart';
// import '../services/size_config.dart';
//
// class DownloadCtrl {
//   String progressString = "0";
//   late String localPath;
//   ReceivePort _port = ReceivePort();
//   StreamController<int> indexController = StreamController<int>.broadcast();
//   String downloadTaskId = '';
//
//   init() {
//     IsolateNameServer.registerPortWithName(
//       _port.sendPort,
//       'invoice_send_port',
//     );
//
//     indexController.stream.listen((data) {
//     });
//
//     _port.listen((dynamic data) {
//       String id = data[0];
//       DownloadTaskStatus status = data[1];
//       int progress = data[2];
//
//       if (status == DownloadTaskStatus.complete) {
//         downloadTaskId = id;
//       }
//       // indexController.sink.add(progress);
//       indexController.add(progress);
//
//       progressString = progress.toString();
//     });
//
//     FlutterDownloader.registerCallback(downloadCallback);
//   }
//
//   Future _findLocalPath() async {
//     var directory;
//     if (Platform.isAndroid) {
//       // directory = await getExternalStorageDirectory();
//       // directory = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
//     } else {
//       directory = await getApplicationDocumentsDirectory();
//     }
//     return directory is String ? directory : directory.path;
//   }
//
//   Future download(String url, BuildContext context, {bool shouldInit = false}) async {
//     // var androidVersion;
//     // final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
//     // var deviceData = <String, dynamic>{};
//     //
//     // try {
//     //   if (Platform.isAndroid) {
//     //     AndroidDeviceInfo deviceInfo = await deviceInfoPlugin.androidInfo;
//     //     androidVersion = num.parse(deviceInfo.version.release!);
//     //   }
//     // } on PlatformException {
//     //   deviceData = <String, dynamic>{
//     //     'Error:': 'Failed to get platform version.'
//     //   };
//     // }
//     if (url.isNotEmpty && url != null && url != 'null') {
//       checkIfFileExist(url).then((value) {
//         if (value != null) {
//           Get.toNamed('pdf-viewer', arguments: value);
//         } else {
//           _checkPermission().then((hasGranted) async {
//             if (hasGranted) {
//               if (shouldInit) init();
//
//               localPath = await _findLocalPath();
//               final savedDir = Directory(localPath);
//
//               bool hasExisted = await savedDir.exists();
//
//               if (!hasExisted) {
//                 savedDir.create();
//               }
//               _proceedDownload(url, localPath, context);
//             }
//           });
//         }
//       });
//     } else {
//       AppUtils.showErrorSnackBar('Invalid Invoice Link');
//     }
//   }
//
//   Future showLoadingBottomSheet(context, path) async {
//     showModalBottomSheet(
//       backgroundColor: Colors.transparent,
//       context: context,
//       isDismissible: false,
//       enableDrag: false,
//       builder: (BuildContext context) {
//         return WillPopScope(
//           onWillPop: () {
//             return Future.value();
//           },
//           child: Container(
//             color: Colors.black87.withOpacity(0.85),
//             width: w(100),
//             height: h(20),
//             child: Stack(
//               children: [
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     StreamBuilder(
//                       stream: indexController.stream,
//                       initialData: 0,
//                       builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
//                         return (snapshot.hasData && snapshot.data! < 100)
//                             ? Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   CircularProgressIndicator(
//                                     valueColor: new AlwaysStoppedAnimation<Color>(colorPrimary),
//                                   ),
//                                   5.height,
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       text('Downloading ', textColor: colorPrimary, fontFamily: fontBold, fontSize: 17.0),
//                                       10.width,
//                                       text(
//                                         snapshot.hasData ? '${snapshot.data} %' : '',
//                                         textColor: colorPrimary,
//                                         fontFamily: fontBold,
//                                         fontSize: 17.0,
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               )
//                             : SizedBox.shrink();
//                       },
//                     ),
//                     5.height,
//                     StreamBuilder(
//                       stream: indexController.stream,
//                       builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
//                         return (snapshot.hasData && snapshot.data == 100)
//                             ? Column(
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Row(
//                                       children: [
//                                         Expanded(
//                                           flex: 27,
//                                           child: text(
//                                             'File saved at:',
//                                             textColor: color_primary_light,
//                                             fontSize: 16.0,
//                                           ),
//                                         ),
//                                         Expanded(
//                                           flex: 73,
//                                           child: text(
//                                             '$path',
//                                             textColor: whiteColor,
//                                             fontFamily: fontMedium,
//                                             fontSize: 17.0,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   5.height,
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(10),
//                                       border: Border.all(
//                                         color: colorPrimary_light.withOpacity(0.15),
//                                         width: 2.5,
//                                       ),
//                                     ),
//                                     child: text(
//                                       'Open',
//                                       textColor: whiteColor,
//                                       fontFamily: fontBold,
//                                     ).paddingSymmetric(
//                                       vertical: 2,
//                                       horizontal: 10,
//                                     ),
//                                   ).onTap(() {
//                                     Get.back();
//                                     Get.toNamed(
//                                       'pdf-viewer',
//                                       arguments: path,
//                                     );
//                                   }),
//                                 ],
//                               )
//                             : SizedBox.shrink();
//                       },
//                     )
//                   ],
//                 ),
//                 Align(
//                   alignment: Alignment.topRight,
//                   child: Icon(
//                     Icons.cancel_presentation,
//                     color: red,
//                     size: 25,
//                   ).onTap(() {
//                     Get.back();
//                   }),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Future<bool> _checkPermission() async {
//     PermissionStatus status = await Permission.storage.status;
//     // Either the permission was already granted before or the user just granted it.
//     if (status.isGranted) {
//       return true;
//     } else {
//       bool permission = await Permission.storage.request().isGranted;
//       if (permission) {
//         return true;
//       } else {
//         return false;
//       }
//     }
//   }
//
//   static void downloadCallback(
//       String id,
//       int status,
//       int progress,
//       ) {
//     final SendPort? send = IsolateNameServer.lookupPortByName('invoice_send_port');
//     send!.send([id, status, progress]);
//   }
//
//
//   void dispose() {
//     IsolateNameServer.removePortNameMapping('invoice_send_port');
//
//     indexController.close();
//   }
//
//   _proceedDownload(url, path, context) async {
//     showLoadingBottomSheet(context, '$path/${url.split('/').last}');
//
//     await FlutterDownloader.enqueue(
//       url: url,
//       savedDir: path,
//       showNotification: true,
//       saveInPublicStorage: true,
//       openFileFromNotification: true,
//     );
//   }
//
//   Future checkIfFileExist(String url) {
//     return _checkPermission().then((hasGranted) async {
//       if (hasGranted) {
//         localPath = await _findLocalPath();
//         final savedDir = Directory(localPath);
//
//         bool hasExisted = await savedDir.exists();
//
//         if (!hasExisted) {
//           savedDir.create();
//         }
//         String pathOfFile = '$localPath/${url.split('/').last}';
//         File file = File(pathOfFile);
//         if (await file.exists()) {
//           return pathOfFile;
//         } else {
//           return null;
//         }
//       }
//     });
//   }
//
//   _performVersionSpecificOperation(File file, androidVersion, url, path, context) async {
//     if (androidVersion <= 9) {
//       try {
//         await file.delete();
//       } catch (e) {
//         return 0;
//       }
//       _proceedDownload(url, path, context);
//     } else if (androidVersion == 10) {
//       AppUtils.showErrorSnackBar('You have already downloaded this File');
//     } else {
//       _proceedDownload(url, path, context);
//     }
//   }
// }
