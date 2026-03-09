import 'dart:html' as html;
import 'dart:typed_data';

Future<void> downloadFileOnWeb(String url, String fileName) async {
  final request = await html.HttpRequest.request(
    url,
    method: 'GET',
    responseType: 'arraybuffer',
  );

  final data = request.response as ByteBuffer;
  final bytes = Uint8List.view(data);

  final blob = html.Blob([bytes]);
  final objectUrl = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: objectUrl)
    ..setAttribute('download', fileName)
    ..style.display = 'none';

  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();

  html.Url.revokeObjectUrl(objectUrl);
}