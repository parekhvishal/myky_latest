import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';

import 'file_download_controller.dart';

class PDFViewer extends StatefulWidget {
  const PDFViewer({Key? key}) : super(key: key);

  @override
  _PDFViewerState createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  var filePath;
  late PdfController pdfController;

  @override
  void initState() {
    filePath = Get.arguments;
    pdfController = PdfController(
      document: PdfDocument.openFile(filePath),
    );
    super.initState();
  }

  @override
  void dispose() {
    FileDownloadCtrl().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(filePath.split('/').last),
        actions: [
          if (filePath.toString().contains('http'))
            IconButton(
              onPressed: () {
                FileDownloadCtrl().download(
                  filePath,
                  context,
                );
              },
              icon: Icon(
                Icons.download,
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: (filePath.toString().contains('http'))
            ? PDF().cachedFromUrl(filePath)
            : PdfView(
                controller: pdfController,
              ),
      ),
    );
  }
}
