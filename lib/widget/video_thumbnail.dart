import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class Thumbnail {
  static String? thumbnailPath;

  static Future<String?> getThumbnailFromUrl(String url) async {
    await setPathForThumbnail();
    var thumbnailPathToStore = await VideoThumbnail.thumbnailFile(
      video: url,
      thumbnailPath: thumbnailPath!,
      imageFormat: ImageFormat.JPEG,
      quality: 75,
    );
    return thumbnailPathToStore;
  }

  static Future<String?> getThumbnailFromFile(File file) async {
    await setPathForThumbnail();
    var uInt8list = await VideoThumbnail.thumbnailData(
      video: file.path,
      imageFormat: ImageFormat.JPEG,
      quality: 75,
    );

    final image = await File('$thumbnailPath/image${DateTime.now().millisecond}.JPEG').create();
    await image.writeAsBytes(uInt8list!);
    return image.path;
  }

  static setPathForThumbnail() async {
    thumbnailPath = (await getTemporaryDirectory()).path;
  }
}
