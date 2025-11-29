import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FreeCashGiveaway extends StatelessWidget {
  const FreeCashGiveaway({super.key});

  Future<void> _shareImage(BuildContext context) async {
    try {
      const String assetPath = 'assets/images/giveaway.jpeg';
      const String message =
          '🎉 Free Cash Giveaway! Don’t miss out on this amazing opportunity. Join now and win exciting rewards! 💸';

      // Load the image from assets
      final byteData = await rootBundle.load(assetPath);

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/giveaway.jpeg');

      // Write the image bytes to the temporary file
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // Share image + message
      await Share.shareXFiles(
        [XFile(file.path)],
        text: message,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _shareImage(context);
      },
      child: Image.asset(
        "assets/images/giveaway.jpeg",
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
