import 'dart:html' as html;
import 'dart:typed_data';

Future<void> saveImageImpl(String imageUrl) async {
  final request = await html.HttpRequest.request(
    imageUrl,
    responseType: 'arraybuffer',
  );

  final bytes = Uint8List.view(request.response);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..download = 'accu_image_${DateTime.now().millisecondsSinceEpoch}.jpg'
    ..click();

  html.Url.revokeObjectUrl(url);
}
