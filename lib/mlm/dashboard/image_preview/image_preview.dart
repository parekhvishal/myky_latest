import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview({super.key});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  String? arg;

  @override
  void initState() {
    arg = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: arg != null
          ? Image.network(
              arg!,
              // "https://i.postimg.cc/rFB31k5g/download.jpg",
              fit: BoxFit.contain,
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
