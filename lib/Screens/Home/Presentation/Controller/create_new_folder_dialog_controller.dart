import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../main.dart';
import '../../../../utils/custom_flashbar.dart';

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

  hitApiToCreateFolder() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    customLoader.show();
    var reqData = {
      "name":nameController,
      "user_company_id": 1,
      "key_words": "Gallery,Test2"
    };

    Get.find<PostApiServiceImpl>()
        .createRoleApiCall(dataBody: reqData)
        .then((value) {
      customLoader.hide();
      Get.back();
      toast(value.message??'');
      update();
    }).onError((error, stackTrace) {
      update();
      Get.back();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }



  @override
  void onClose() {
    // nameController.dispose();
    super.onClose();
  }
}
