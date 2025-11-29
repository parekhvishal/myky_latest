import 'dart:io';

import 'package:dio/dio.dart';

import 'api.dart';

class Vapor {
  static Future<dynamic> upload(
    File? file, {
    void Function(int? completed, int? total)? progressCallback,
    bool shouldShowLoader = true,
    Function? onConnectionLost,
  }) async {
    String fileName = file!.path.split(".").last;

    Dio dio = Dio();
    dio.options.headers = {
      'content-type': 'multipart/form-data',
      'content-length': file.lengthSync(),
    };

    MultipartFile multipartFile = await MultipartFile.fromFile(
      file.path,
      filename: fileName,
    );

    late Response<dynamic> uploadResponse;

    try {
      uploadResponse = await Api.http.post(
        'member/uploads/process',
        data: FormData.fromMap({'file': multipartFile}),
        onSendProgress: (completed, total) {
          if (progressCallback != null) progressCallback(completed, total);
        },
      );
      // Handle uploadResponse here
    } catch (error) {
      if (error is DioException) {
        // Now you can access the error property of DioError
        if (error.error is SocketException) {
          if (onConnectionLost != null) {
            onConnectionLost();
          }
        }
      }
      // Handle the error or perform any other actions here
    }

    if (uploadResponse.statusCode == 200) {
      return uploadResponse.data['data']['fileName'];
    }

    return false;
  }

  static Future<dynamic> uploadRegister(
    File? file, {
    void Function(int? completed, int? total)? progressCallback,
    bool shouldShowLoader = true,
    Function? onConnectionLost,
  }) async {
    String fileName = file!.path.split(".").last;

    Dio dio = Dio();
    dio.options.headers = {
      'content-type': 'multipart/form-data',
      'content-length': file.lengthSync(),
    };

    MultipartFile multipartFile = await MultipartFile.fromFile(
      file.path,
      filename: fileName,
    );

    late Response<dynamic> uploadResponse;

    try {
      uploadResponse = await Api.httpWithoutLoader.post(
        'shopping/uploads/process',
        data: FormData.fromMap({'file': multipartFile}),
        onSendProgress: (completed, total) {
          if (progressCallback != null) progressCallback(completed, total);
        },
      );
      // Handle uploadResponse here
    } catch (error) {
      if (error is DioException) {
        // Now you can access the error property of DioError
        if (error.error is SocketException) {
          if (onConnectionLost != null) {
            onConnectionLost();
          }
        }
      }
      // Handle the error or perform any other actions here
    }

    if (uploadResponse.statusCode == 200) {
      return uploadResponse.data['data']['fileName'];
    }

    return false;
  }

  static Future<dynamic> uploadWithoutLoaderRegister(
    File? file, {
    void Function(int? completed, int? total)? progressCallback,
    bool shouldShowLoader = true,
    Function? onConnectionLost,
  }) async {
    String fileName = file!.path.split(".").last;

    Dio dio = Dio();
    dio.options.headers = {
      'content-type': 'multipart/form-data',
      'content-length': file.lengthSync(),
    };

    MultipartFile multipartFile = await MultipartFile.fromFile(
      file.path,
      filename: fileName,
    );

    late Response<dynamic> uploadResponse;

    try {
      uploadResponse = await Api.httpWithoutLoader.post(
        'shopping/uploads/process',
        data: FormData.fromMap({'file': multipartFile}),
        onSendProgress: (completed, total) {
          if (progressCallback != null) progressCallback(completed, total);
        },
      );
      // Handle uploadResponse here
    } catch (error) {
      if (error is DioException) {
        // Now you can access the error property of DioError
        if (error.error is SocketException) {
          if (onConnectionLost != null) {
            onConnectionLost();
          }
        }
      }
      // Handle the error or perform any other actions here
    }

    if (uploadResponse.statusCode == 200) {
      return uploadResponse.data['data']['fileName'];
    }

    return false;
  }

  static Future<dynamic> uploadList(
    List<File> files, {
    required void Function(int completed, int total) progressCallback,
    bool shouldShowLoader = true,
    Function? onConnectionLost,
  }) async {
    List<String> fileNames = [];

    for (File file in files) {
      String fileName = file.path.split(".").last;

      Dio dio = Dio();
      dio.options.headers = {
        'content-type': 'multipart/form-data',
        'content-length': file.lengthSync(),
      };

      MultipartFile multipartFile = await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      );

      late Response<dynamic> uploadResponse;
      try {
        uploadResponse = await Api.http.post(
          'uploads/process',
          data: FormData.fromMap({'file': multipartFile}),
          onSendProgress: (completed, total) {
            progressCallback(completed, total);
          },
        );
        // Handle uploadResponse here
      } catch (error) {
        if (error is DioException) {
          // Now you can access the error property of DioError
          if (error.error is SocketException) {
            if (onConnectionLost != null) {
              onConnectionLost();
            }
          }
        }
        // Handle the error or perform any other actions here
      }

      if (uploadResponse.statusCode == 200) {
        fileNames.add(uploadResponse.data['data']['fileName']);
      }
    }

    return fileNames;
  }
}
