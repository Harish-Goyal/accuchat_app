// download_web.dart
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:dio/dio.dart';



String sanitizeFileName(String name) {
  return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
}

Future<void> downloadFile({
  required String url,
  required String saveAsName,
}) async {
  final dio = Dio();

  final response = await dio.get<List<int>>(
    url,
    options: Options(
      responseType: ResponseType.bytes,
    ),
  );

  final data = response.data;
  if (data == null || data.isEmpty) {
    throw Exception('No file bytes received');
  }

  final bytes = Uint8List.fromList(data);
  final safeName = sanitizeFileName(saveAsName);

  final blob = html.Blob([bytes]);
  final blobUrl = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: blobUrl)
    ..download = safeName
    ..style.display = 'none';

  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();

  html.Url.revokeObjectUrl(blobUrl);
}