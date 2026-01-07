import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateFolderDialogController extends GetxController {
  final TextEditingController nameController = TextEditingController();

  final RxBool isSaving = false.obs;
  final RxString error = ''.obs;

  void clearError() => error.value = '';

  Future<void> submit({
    required Future<void> Function(String name) onCreate,
  }) async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      error.value = "Folder name is required";
      return;
    }
    if (name.length < 2) {
      error.value = "Minimum 2 characters";
      return;
    }

    isSaving.value = true;
    error.value = '';
    try {
      await onCreate(name);
      Get.back(result: name);
    } catch (e) {
      error.value = "Failed to create folder";
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
