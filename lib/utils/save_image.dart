import 'save_image_mobile.dart'
if (dart.library.html) 'save_image_web.dart';

Future<void> saveImage(String imageUrl) {
  return saveImageImpl(imageUrl);
}
