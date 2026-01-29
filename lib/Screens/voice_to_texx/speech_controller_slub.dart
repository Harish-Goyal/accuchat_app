import 'package:AccuChat/Screens/voice_to_texx/speach_abstract.dart';
import 'package:get/get.dart';

class SpeechControllerImpl extends SpeechController {
  @override final isListening = false.obs;
  @override final interimText = ''.obs;
  @override final finalText = ''.obs;

  @override bool get isSupported => false;

  @override String selectedLang = 'en-IN';

  @override void updateSelectedLang(String v) { selectedLang = v; update(); }

  @override void setLanguage({required String langCode}) {}

  @override void start() => Get.snackbar('Not supported', 'Voice-to-text is disabled on mobile.');
  @override void stop() {}
  @override void toggle() => start();

  @override String getCombinedText() => '';
}
