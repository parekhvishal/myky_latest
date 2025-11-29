import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoZoom extends StatefulWidget {
  @override
  _PhotoZoomState createState() => _PhotoZoomState();
}

class _PhotoZoomState extends State<PhotoZoom> {
  @override
  Widget build(BuildContext? context) {
    Map? photoUrl = ModalRoute.of(context!)!.settings.arguments as Map?;

    return Container(
      child: PhotoView(
        imageProvider: NetworkImage(photoUrl!['url']),
      ),
    );
  }
}
