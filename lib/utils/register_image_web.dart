import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'dart:js' as js;

void registerImagePasteHandlerImpl(
    void Function(XFile file) onImagePasted,
    ) {
  js.context['flutterImagePasteHandler'] = (dynamic data) {
    final String name = data['name'];
    final String type = data['type'];
    final List bytesList = data['bytes'];

    final Uint8List bytes = Uint8List.fromList(bytesList.cast<int>());

    final file = XFile.fromData(
      bytes,
      name: name,
      mimeType: type,
    );

    onImagePasted(file);
  };
}