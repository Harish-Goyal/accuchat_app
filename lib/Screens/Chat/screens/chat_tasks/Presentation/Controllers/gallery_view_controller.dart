import 'dart:io';
import 'dart:typed_data';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart';
import 'package:dio/dio.dart' as multi;
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';

import '../../../../models/chat_history_response_model.dart';

class GalleryViewerController extends GetxController {
  final List<String> urls;
  final ChatHisList chathis;
  int index;
  bool saving = false;
  String? toast;

  GalleryViewerController({required this.urls,required this.chathis, this.index = 0});

  void setIndex(int i) {
    index = i;
    update();
  }


  bool isSaving = false;
  String progress = '';
  int savedCount = 0;
  int failedCount = 0;

  Future<void> saveOne(String imageUrl) async {
    final ok = await requestStoragePermission();
    if (!ok) {
      _toast('❌ Storage/Photos permission denied');
      return;
    }

    final success = await _saveToGalleryFromUrl("${ApiEnd.baseUrlMedia}$imageUrl");
    _toast(success ? '✅ Image saved to Gallery' : '❌ Failed to save image');
  }

  //Save all, sequential for stability
  Future<void> saveAll(List<String> imageUrls) async {
    if (imageUrls.isEmpty) return;

    final ok = await requestStoragePermission();
    if (!ok) {
      _toast('❌ Storage/Photos permission denied');
      return;
    }

    isSaving = true;
    savedCount = 0;
    failedCount = 0;
    progress = 'Starting...';
    update();

    for (var i = 0; i < imageUrls.length; i++) {
      final url = imageUrls[i];

      // ✅ IMPORTANT: pass the actual URL (adjust field name if yours differs)


      final success = await _saveToGalleryFromUrl("${ApiEnd.baseUrlMedia}$url");
      if (success) {
        savedCount++;
      } else {
        failedCount++;
      }
      progress = '$savedCount/${imageUrls.length} saved';
      update();
    }

    isSaving = false;
    update();

    if (failedCount == 0) {
      _toast('✅ All ${imageUrls.length} images saved!');
    } else {
      _toast('ℹ️ Saved $savedCount, Failed $failedCount');
    }
  }

  /// Permissions: iOS needs Photos add-only; Android ≤12 may prompt for storage.
  /// Android 13+ generally needs no permission to insert into MediaStore.
  Future<bool> _ensurePermission() async {
    if (Platform.isIOS) {
      final status = await Permission.photosAddOnly.request();
      return status.isGranted;
    }

    if (Platform.isAndroid) {
      // Try without asking first; if OEM requires it (≤12), request storage.
      var storage = await Permission.storage.status;
      if (!storage.isGranted && !storage.isLimited) {
        storage = await Permission.storage.request();
      }
      // Even if not granted, saving might still work on Android 13+, but
      // we return true if granted OR limited; else false.
      return storage.isGranted || storage.isLimited;
    }

    // Other platforms
    return true;
  }

  /// Core saver: downloads bytes and inserts directly into Gallery.
  /// Returns true on success.
  Future<bool> _saveToGalleryFromUrl(String url) async {
    if (url.isEmpty) return false;

    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final resp = await multi.Dio().get<List<int>>(
        url,
        options: multi.Options(responseType: multi.ResponseType.bytes, receiveTimeout: const Duration(minutes: 2)),
      );

      if (resp.statusCode == 200 && resp.data != null) {
        final ext = _inferExtFromUrl(url); // .jpg/.png …
        final name = 'AccuChat_$ts$ext';

        // final result = await ImageGallerySaver.saveImage(
        //   Uint8List.fromList(resp.data!),
        //   name: name,
        //   quality: 80,
        //   isReturnImagePathOfIOS: true, // gives local id/path on iOS
        // );

        // image_gallery_saver returns a map like {'isSuccess': true, 'filePath': '...'}
        // final ok = (result['isSuccess'] == true);
        // return ok;
      }
    } catch (e) {
      // You can log e if needed
    }
    return false;
  }

  String _inferExtFromUrl(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    if (path.endsWith('.png')) return '.png';
    if (path.endsWith('.webp')) return '.webp';
    if (path.endsWith('.jpeg')) return '.jpeg';
    if (path.endsWith('.jpg')) return '.jpg';
    return '.jpg';
  }


  void _toast(String msg) {
    // Plug your toast/snackbar here
    // e.g., Get.snackbar('Info', msg); or your existing toast()
    Get.snackbar('AccuChat', msg, snackPosition: SnackPosition.BOTTOM);
  }
  @override
  void onClose() {
    imageCache.clearLiveImages();
    imageCache.clear();
    super.onClose();
  }
}
