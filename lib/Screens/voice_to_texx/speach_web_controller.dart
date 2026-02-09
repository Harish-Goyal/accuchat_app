import 'dart:async';
import 'dart:html' as html;
import 'dart:ui';
import 'package:AccuChat/Screens/voice_to_texx/speach_abstract.dart';
import 'package:get/get.dart';
import 'package:js/js.dart';

import '../Chat/helper/dialogs.dart';

@JS('__speech__')
external _SpeechBridge? get _speech;

@JS()
@anonymous
class _SpeechBridge {
  external bool get isListening;
  external void start();
  external void stop();
  external void setLang(String lang);
  external bool blocked();
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

  bool _skipNextOnStopped = false;   // ✅ add this
  bool _disposed = false;

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

  String _lastFinalChunk = "";

  @override
  void onInit() {
    super.onInit();
    _subResult = html.window.on['speech-result'].listen((event) {
      final e = event as html.CustomEvent;
      final detail = e.detail as dynamic;

      final interim = (detail['interim'] ?? '').toString();
      final gotFinal = (detail['final'] ?? '').toString();

      // interim always latest
      interimText.value = interim;

      // final: only add if it's new (prevents duplicates)
      final chunk = gotFinal.trim();
      if (chunk.isNotEmpty && chunk != _lastFinalChunk) {
        _lastFinalChunk = chunk;

        final combined = (finalText.value.isEmpty)
            ? chunk
            : '${finalText.value} $chunk';

        finalText.value = combined.trim();
      }
    });
/*
    _subResult = html.window.on['speech-result'].listen((event) {
      final e = event as html.CustomEvent;
      final detail = e.detail as dynamic;

      interimText.value = (detail['interim'] ?? '').toString();
      final gotFinal = (detail['final'] ?? '').toString();

      if (gotFinal.trim().isNotEmpty) {
        finalText.value = ('${finalText.value} $gotFinal').trim();
      }
    });
*/

    _subError = html.window.on['speech-error'].listen((event) {
      final e = event as html.CustomEvent;
      final err = (e.detail ?? 'speech_error').toString();

      stop(skipOnStopped: true);   // stops + clears buffers now
      _skipNextOnStopped = false;  // safety

      Dialogs.showSnackbar(Get.context!, err);
    });


    _subEnd = html.window.on['speech-end'].listen((_) {
      isListening.value = false;

      // ✅ clear buffers on end
      clearSpeechBuffer();

      // ✅ if stop() asked to skip callback, skip once and reset flag
      if (_skipNextOnStopped) {
        _skipNextOnStopped = false;
        return;
      }

      onStopped?.call();
    });


    // add

  }

  @override
  void clearSpeechBuffer() {
    interimText.value = '';
    finalText.value = '';
    _lastFinalChunk = '';
  }

  @override
  void setLanguage({required String langCode}) {
    if (!isSupported) return;
    _speech!.setLang(langCode);
  }

  String combinedText() => ('${finalText.value} ${interimText.value}').trim();
  @override
  void toggle() {
    if (!isSupported) {
      Dialogs.showSnackbar(Get.context!, 'Voice-to-text is not supported in this browser.');
      return;
    }
    if (isListening.value) stop(); else start();
  }
  @override
  void start() {
    if (!isSupported) return;
    if (_speech!.blocked()) {
      isListening.value = false;
      Dialogs.showSnackbar(Get.context!, 'Microphone permission is blocked. Please allow it in browser settings.');
      return;
    }
    finalText.value = '';
    interimText.value = '';
    isListening.value = true;
    _speech!.start();
  }

  @override
  void stop({bool skipOnStopped = false}) {
    if (!isSupported) return;
    _skipNextOnStopped = skipOnStopped;
    isListening.value = false;
    clearSpeechBuffer();
    _speech?.stop();
  }

/*  @override
  void stop() {
    if (!isSupported) return;
    isListening.value = false;
    interimText.value = '';
    _speech!.stop();
  }
  */

  @override
  String getCombinedText() {
    final f = finalText.value.trim();
    final i = interimText.value.trim();

    if (f.isEmpty) return i;
    if (i.isEmpty) return f;
    return '$f $i'.trim();
  }

  // String getCombinedText() => ('${finalText.value} ${interimText.value}').trim();

  @override
  void onClose() {
    _disposed = true;
    onStopped = null;
    _subResult?.cancel();
    _subError?.cancel();
    _subEnd?.cancel();
    super.onClose();
  }
}
