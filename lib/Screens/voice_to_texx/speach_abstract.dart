import 'dart:ui';

import 'package:get/get.dart';

abstract class SpeechController extends GetxController {
  RxBool get isListening;
  RxString get interimText;
  RxString get finalText;

  bool get isSupported;

  String get selectedLang;
  void updateSelectedLang(String v);

  void setLanguage({required String langCode});
  void start();
  void stop({bool skipOnStopped = false});
  void toggle();
  VoidCallback? onStopped;
  String getCombinedText();
}
