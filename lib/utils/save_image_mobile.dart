import 'dart:io';
import 'package:dio/dio.dart';
import 'package:media_scanner/media_scanner.dart';

import 'custom_flashbar.dart';
import 'helper_widget.dart';

Future<void> saveImageImpl(String imageUrl) async {
  final permission = await requestStoragePermission();
  if (!permission) {
    errorDialog("❌ Storage permission denied");
    return;
  }

  // Step 2: Define gallery directory
  final directory = Directory('/storage/emulated/0/Pictures/AccuChat');
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  // Step 3: Define full file path
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final filePath = '${directory.path}/accu_image_$timestamp.jpg';

  // Step 4: Download the image using Dio
  try {
    final response = await Dio().download(imageUrl, filePath);
    if (response.statusCode == 200) {
      // Step 5: Trigger media scan to show in Gallery
      await MediaScanner.loadMedia(path: filePath);

      toast("✅ Image Saved!");
    } else {
      toast("❌ Failed to download image");
    }
  } catch (e) {
  }

}
