import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'dart:js' as js;


void initWebPasteListener() {
  print('calling setupImagePasteListener');
  js.context.callMethod('setupImagePasteListener');
}

void disposeWebPasteListener() {
  js.context.callMethod('removeImagePasteListener');
}
bool _isHandlingPaste = false;

void registerImagePasteHandlerImpl(
    void Function(XFile file) onImagePasted,
    ) {
  js.context['flutterImagePasteHandler'] = (dynamic data) async {
    if (_isHandlingPaste) return;
    _isHandlingPaste = true;

    try {
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
    } finally {
      Future.delayed(const Duration(milliseconds: 300), () {
        _isHandlingPaste = false;
      });
    }
  };
}

void unregister() {
  // Option 1: set to null
  js.context['flutterImagePasteHandler'] = null;

  // Option 2 (optional): delete the key (works in many cases)
  // js.context.deleteProperty('flutterImagePasteHandler');
}