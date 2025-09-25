import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PickedFileData {
  final String name;
  final String? extension;
  final int? size;
  final Uint8List bytes;
  final bool isImage;

  const PickedFileData({
    required this.name,
    this.extension,
    this.size,
    required this.bytes,
    required this.isImage,
  });
}

class UniversalPicker {
  static bool get isWeb => kIsWeb;

  /// Single image (WEB ONLY)
  static Future<PickedFileData?> pickImageSingleWeb() async {
    if (!kIsWeb) return null; // do not touch mobile flow
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (res == null || res.files.isEmpty) return null;
    final f = res.files.first;
    if (f.bytes == null) return null;
    return PickedFileData(
      name: f.name,
      extension: f.extension,
      size: f.size,
      bytes: f.bytes!,
      isImage: true,
    );
  }

  /// MULTI images (WEB ONLY)
  static Future<List<PickedFileData>> pickImagesMultiWeb() async {
    if (!kIsWeb) return [];
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (res == null || res.files.isEmpty) return [];
    return res.files
        .where((f) => f.bytes != null)
        .map((f) => PickedFileData(
      name: f.name,
      extension: f.extension,
      size: f.size,
      bytes: f.bytes!,
      isImage: true,
    ))
        .toList();
  }

  /// MULTI docs (WEB ONLY) — customize extensions if needed
  static Future<List<PickedFileData>> pickDocsMultiWeb({
    List<String>? allowedExtensions,
  }) async {
    if (!kIsWeb) return [];
    final res = await FilePicker.platform.pickFiles(
      type: allowedExtensions == null ? FileType.any : FileType.custom,
      allowedExtensions: allowedExtensions,
      allowMultiple: true,
      withData: true,
    );
    if (res == null || res.files.isEmpty) return [];
    return res.files
        .where((f) => f.bytes != null)
        .map((f) {
      final ext = (f.extension ?? '').toLowerCase();
      final isImg = RegExp(r'^(png|jpe?g|webp|gif)$').hasMatch(ext);
      return PickedFileData(
        name: f.name,
        extension: f.extension,
        size: f.size,
        bytes: f.bytes!,
        isImage: isImg,
      );
    })
        .toList();
  }

  /// Single doc (WEB ONLY) – optional
  static Future<PickedFileData?> pickDocSingleWeb({
    List<String>? allowedExtensions,
  }) async {
    if (!kIsWeb) return null;
    final res = await FilePicker.platform.pickFiles(
      type: allowedExtensions == null ? FileType.any : FileType.custom,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
      withData: true,
    );
    if (res == null || res.files.isEmpty) return null;
    final f = res.files.first;
    if (f.bytes == null) return null;
    final ext = (f.extension ?? '').toLowerCase();
    final isImg = RegExp(r'^(png|jpe?g|webp|gif)$').hasMatch(ext);
    return PickedFileData(
      name: f.name,
      extension: f.extension,
      size: f.size,
      bytes: f.bytes!,
      isImage: isImg,
    );
  }
}
