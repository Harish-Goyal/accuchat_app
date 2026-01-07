import 'package:AccuChat/Screens/voice_to_texx/speach_abstract.dart';
import 'package:get/get.dart';

class SpeechControllerImpl extends SpeechController {
  final isListening = false.obs;
  final interimText = ''.obs;
  final finalText = ''.obs;

  bool get isSupported => false;

  String selectedLang = 'en-IN';

  void updateSelectedLang(String v) {
    selectedLang = v;
    update();
  }

  void setLanguage({required String langCode}) {}

  void toggle() {
    Get.snackbar('Not supported', 'Voice-to-text is only available on Web.');
  }

  void start() {
    Get.snackbar('Not supported', 'Voice-to-text is only available on Web.');
  }

  void stop() {}

  String getCombinedText() => '';
}
