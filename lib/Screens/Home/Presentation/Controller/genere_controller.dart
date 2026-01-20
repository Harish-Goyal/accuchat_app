import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GenreController extends GetxController {
  final textController = TextEditingController();
  final focusNode = FocusNode();

  final RxList<String> genres = <String>[].obs;
  final RxString genresString = ''.obs;

  void _syncString() {
    genresString.value = genres.join(',');
  }

  void addGenre([String? raw]) {
    final value = (raw ?? textController.text).trim();

    if (value.isEmpty) return;
    if (genres.length >= 5) return;

    final exists = genres.any((e) => e.toLowerCase() == value.toLowerCase());
    if (exists) {
      textController.clear();
      return;
    }

    genres.add(value);
    textController.clear();
    _syncString();

    focusNode.requestFocus();
  }

  void removeGenre(String g) {
    genres.remove(g);
    _syncString();
  }

  @override
  void onClose() {
    // textController.dispose();
    // focusNode.dispose();
    super.onClose();
  }
}
