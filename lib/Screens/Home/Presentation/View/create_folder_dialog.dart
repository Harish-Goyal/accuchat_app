import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/gallery_controller.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Constants/colors.dart';
import '../../../../utils/common_textfield.dart';
import '../Controller/create_new_folder_dialog_controller.dart';
import 'genre_view.dart';

Future<String?> showCreateFolderDialog() async {
  final controller = Get.put(GalleryController());
  final _folderKey = GlobalKey<FormState>();
  final res = await Get.dialog<String>(
    WillPopScope(
      onWillPop: () async => !controller.isSaving.value,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: Colors.white,
        child: Container(
          width: 420,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxW = constraints.maxWidth;
              final dialogWidth = maxW > 520 ? 420.0 : double.infinity; // web clamp

              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: dialogWidth),
                child: Obx(() {
                  return Form(
                    key: _folderKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Row(
                          children: [
                            Icon(Icons.create_new_folder_outlined,color: Colors.black87,),
                            const SizedBox(width: 10),
                             Expanded(
                              child: Text(
                                "Create Folder",
                                style: BalooStyles.baloosemiBoldTextStyle(),
                              ),
                            ),
                            IconButton(
                              onPressed: controller.isSaving.value ? null : () => Get.back(),
                              icon: const Icon(Icons.close,color: Colors.black87,),
                              splashRadius: 18,
                            ),
                          ],
                        ),

                        vGap(30),

                        // Your custom field
                        CustomTextField(
                          hintText: "Enter folder name",
                          labletext: "Folder Name",
                          controller: controller.nameController,
                          prefix: Icon(Icons.folder, color: appColorPerple),
                          onChangee: (v) {
                            controller.clearError();
                          },
                          validator: (value) {
                            // keep your existing validator style if you want
                            return value?.isEmptyField(messageTitle: "Folder name");
                          },
                        ),
                        vGap(12),
                        GenreInputGetX(),
                        vGap(12),

                       Spacer(),

                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(Colors.white),
                                  foregroundColor: WidgetStateProperty.all(Colors.white),
                                  overlayColor: WidgetStateProperty.all(Colors.white),
                                ),
                                onPressed: controller.isSaving.value ? null : () => Get.back(),
                                child:  Text("Cancel",style: BalooStyles.baloonormalTextStyle(),),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: controller.isSaving.value
                                    ? null
                                    : (){
                                  if(_folderKey.currentState!.validate()){
                                    controller.hitApiToCreateFolder();
                                  }
                                },
                                child: controller.isSaving.value
                                    ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                                    : const Text("Create"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ).paddingOnly(left: 16,
                        right: 16,
                        top: 16,
                        bottom: 16),
                  );
                }),
              );
            },
          ),
        ),
      ),
    ),
    barrierDismissible: true,
  );

  return res;
}
