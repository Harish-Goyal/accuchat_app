import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';



class ShareHelper {
  static Future<void> shareOnWhatsApp(String text) async {
    final encodedText = Uri.encodeComponent(text);

    final url = "https://wa.me/?text=$encodedText"; // works on Web + Mobile

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
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
}
