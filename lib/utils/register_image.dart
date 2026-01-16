import 'package:image_picker/image_picker.dart';

import 'register_image_mobile.dart'
if (dart.library.js) 'register_image_web.dart';

Future<void> registerImage(Function(XFile file) onImagePasted) async {
  return registerImagePasteHandlerImpl(onImagePasted);
}
