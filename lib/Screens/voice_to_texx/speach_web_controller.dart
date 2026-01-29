import 'dart:async';
import 'dart:html' as html;
import 'dart:ui';
import 'package:AccuChat/Screens/voice_to_texx/speach_abstract.dart';
import 'package:get/get.dart';
import 'package:js/js.dart';

@JS('__speech__')
external _SpeechBridge? get _speech;

@JS()
@anonymous
class _SpeechBridge {
  external bool get isListening;
  external void start();
  external void stop();
  external void setLang(String lang);
}

class SpeechControllerImpl  extends SpeechController{
  @override
  final isListening = false.obs;
  @override
  final interimText = ''.obs;
  @override
  final finalText = ''.obs;

  StreamSubscription<html.Event>? _subResult;
  StreamSubscription<html.Event>? _subError;
  StreamSubscription<html.Event>? _subEnd;

  @override
  bool get isSupported => _speech != null;

  @override
  String selectedLang = 'en-IN';
  @override
  void updateSelectedLang(String v) {
    selectedLang = v;
    update();
  }
  @override
  VoidCallback? onStopped;
  @override
  void onInit() {
    super.onInit();

    _subResult = html.window.on['speech-result'].listen((event) {
      final e = event as html.CustomEvent;
      final detail = e.detail as dynamic;

      interimText.value = (detail['interim'] ?? '').toString();
      final gotFinal = (detail['final'] ?? '').toString();

      if (gotFinal.trim().isNotEmpty) {
        finalText.value = (finalText.value + ' ' + gotFinal).trim();
      }
    });

    _subError = html.window.on['speech-error'].listen((event) {
      final e = event as html.CustomEvent;
      final err = (e.detail ?? 'speech_error').toString();
      stop();
      Get.snackbar('Voice input error', err);
    });

    _subEnd = html.window.on['speech-end'].listen((_) {
      isListening.value = false;
      interimText.value = '';
      onStopped?.call();
    });

    // add

  }

  @override
  void setLanguage({required String langCode}) {
    if (!isSupported) return;
    _speech!.setLang(langCode);
  }

  String combinedText() => (finalText.value + ' ' + interimText.value).trim();
  @override
  void toggle() {
    if (!isSupported) {
      Get.snackbar('Not supported', 'Voice-to-text is not supported in this browser.');
      return;
    }
    if (isListening.value) stop(); else start();
  }
  @override
  void start() {
    if (!isSupported) return;
    finalText.value = '';
    interimText.value = '';
    isListening.value = true;
    _speech!.start();
  }
  @override
  void stop() {
    if (!isSupported) return;
    isListening.value = false;
    interimText.value = '';
    _speech!.stop();
  }
  @override
  String getCombinedText() => (finalText.value + ' ' + interimText.value).trim();

  @override
  void onClose() {
    _subResult?.cancel();
    _subError?.cancel();
    _subEnd?.cancel();
    super.onClose();
  }
}
