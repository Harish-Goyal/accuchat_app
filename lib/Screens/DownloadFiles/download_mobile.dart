// download_mobile.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

Future<void> downloadFile({
  required String url,
  required String saveAsName,
}) async {
  try {
    final dio = Dio();

    Directory dir;

    if (Platform.isAndroid) {
      dir = await getApplicationDocumentsDirectory();
    } else if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
    }

    final filePath = '${dir.path}/$saveAsName';

    await dio.download(url, filePath);

    print('File saved at: $filePath');
  } catch (e) {
    rethrow;
  }
}