import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ShareHelper {
  static Future<void> shareOnWhatsApp(String text) async {
    final encodedText = Uri.encodeComponent(text);

    // For mobile: try to open WhatsApp with the "whatsapp://" scheme.
    final whatsappUrl = "whatsapp://send?text=$encodedText";

    // For web: fallback to wa.me
    final webUrl = "https://wa.me/?text=$encodedText";

    // Check if it's a mobile platform (Android/iOS) and try opening with the mobile URL scheme
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication);
    }
    // If mobile scheme fails, try the web scheme
    else if (await canLaunchUrl(Uri.parse(webUrl))) {
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    } else {
      print("Cannot launch WhatsApp");
    }
  }

  static Future<void> shareNetworkImage(String imageUrl, {String? text}) async {
    // download image
    final response = await http.get(Uri.parse(imageUrl));

    // save to temporary file
    final documentDirectory = await getTemporaryDirectory();
    final file = File('${documentDirectory.path}/accuchat_share.jpg');
    file.writeAsBytesSync(response.bodyBytes);

    // share now
    await Share.shareXFiles(
      [XFile(file.path)],
      text: text ?? "",
    );
  }

  static Future<void> shareNetworkFile(
    String fileUrl, {
    String? text,
    String? fileName, // optional: "invoice.pdf"
  }) async {
    final uri = Uri.parse(fileUrl);

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception("Download failed: ${res.statusCode}");
    }

    // 1) Detect content-type from headers (best)
    final contentType = res.headers['content-type'];

    String name = fileName ??
        (uri.pathSegments.isNotEmpty ? uri.pathSegments.last : "accuchat_file");

    // remove query-like junk if any
    name = name.split('?').first.split('#').first;

    // If filename has no extension, try to add it from content-type
    if (p.extension(name).isEmpty) {
      final extFromMime = _extFromContentType(contentType);
      if (extFromMime != null) name = "$name$extFromMime";
    }

    // If still no extension, try mime sniff from bytes
    if (p.extension(name).isEmpty) {
      final mimeFromBytes = lookupMimeType(name, headerBytes: res.bodyBytes);
      final extFromBytes = _extFromContentType(mimeFromBytes);
      if (extFromBytes != null) name = "$name$extFromBytes";
    }

    // Create a unique file name to avoid overwrite
    final ts = DateTime.now().millisecondsSinceEpoch;
    final safeName =
        "${p.basenameWithoutExtension(name)}_$ts${p.extension(name)}";

    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, safeName));

    // IMPORTANT: async write (don’t use writeAsBytesSync)
    await file.writeAsBytes(res.bodyBytes, flush: true);

    final mimeType = lookupMimeType(file.path) ?? contentType;

    await Share.shareXFiles(
      [XFile(file.path, mimeType: mimeType)],
      text: text ?? "",
    );
  }

  static String? _extFromContentType(String? contentType) {
    if (contentType == null) return null;
    final ct = contentType.split(';').first.trim().toLowerCase();

    // add more if needed
    const map = <String, String>{
      "application/pdf": ".pdf",
      "image/jpeg": ".jpg",
      "image/jpg": ".jpg",
      "image/png": ".png",
      "image/webp": ".webp",
      "application/msword": ".doc",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
          ".docx",
      "application/vnd.ms-excel": ".xls",
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet":
          ".xlsx",
      "application/vnd.ms-powerpoint": ".ppt",
      "application/vnd.openxmlformats-officedocument.presentationml.presentation":
          ".pptx",
      "text/plain": ".txt",
      "application/zip": ".zip",
      "audio/mpeg": ".mp3",
      "video/mp4": ".mp4",
    };

    return map[ct];
  }
}
