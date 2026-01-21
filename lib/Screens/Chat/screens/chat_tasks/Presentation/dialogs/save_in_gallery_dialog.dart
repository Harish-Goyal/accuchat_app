import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/Screens/Chat/helper/dialogs.dart';
import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../Constants/colors.dart';
import '../../../../../../Constants/themes.dart';
import '../../../../../../utils/common_textfield.dart';
import '../../../../../../utils/custom_dialogue.dart';
import '../../../../../../utils/gradient_button.dart';
import '../../../../../../utils/helper_widget.dart';
import '../../../../../../utils/text_style.dart';
import '../../../../../Home/Presentation/View/create_folder_dialog.dart';
import '../Controllers/save_in_accuchat_gallery_controller.dart';

class SaveToCustomFolderDialog extends StatelessWidget {
  final dynamic user; // keep as your type
   SaveToCustomFolderDialog({super.key, required this.user});


  @override
  Widget build(BuildContext context) {
    final c = Get.find<SaveToGalleryController>();
    final _formKeyDoc = GlobalKey<FormState>();
    return _mainBody(_formKeyDoc,c);
  }


  _mainBody(fKey,SaveToGalleryController controller){
    return CustomDialogue(
      title: "Save In Accuchat's Smart Gallery",
      isShowAppIcon: true,
      isShowActions: false,
      content: SizedBox(
        width: 500,
        child: Material(
          // keeps proper text scaling/ink on web
          type: MaterialType.transparency,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            child: Form(
              key: fKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  divider().paddingSymmetric(horizontal: 40),
                  // vGap(12),
                  Text(
                    "This media will be saved in your AccuChat Gallery under the selected folder.",
                    style: BalooStyles.baloonormalTextStyle(size: 13),
                    textAlign: TextAlign.center,
                  ),
                  vGap(3),
                  Text(
                    "Search your media by Name, Date and User Individuals",
                    style: BalooStyles.baloonormalTextStyle(size: 12),
                    textAlign: TextAlign.center,
                  ),

                  vGap(30),

                  /// Document name
                  CustomTextField(
                    hintText: "Document Name",
                    controller: controller.docNameController,
                    labletext: "Document Name",
                    validator: (value) =>
                        value?.isEmptyField(messageTitle: "Document Name"),
                  ),

                  vGap(12),

                  IconButton(
                    onPressed: () async {
                      final name = await showCreateFolderDialog();

                      if (name != null) {
                        controller.hitApiToGetFolder();
                        // success
                        Dialogs.showSnackbar(Get.context!,"Created  $name");
                      }
                    },
                    icon:    Text('Create a new folder'),

                  ),

                  vGap(12),

                  /// ===================== FOLDER LIST =====================
                  _folderListView(),
                  vGap(12),

                  /// ===================== ACTION BUTTONS =====================
                  _buttomAction(fKey,controller),
                ],
              ).paddingSymmetric(horizontal: 8),
            ),
          ),
        ),
      ),
      onOkTap: () {},
    );
  }


  _folderListView(){
    return GetBuilder<SaveToGalleryController>(
      builder: (c) {
        if ((c.folderList??[]).isEmpty) {
          return  Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text("No folders found",style: BalooStyles.baloonormalTextStyle()),
          );
        }

        return c.isLoading?IndicatorLoading(): SizedBox(
          height: Get.height * .35,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: (c.folderList??[]).length,
            separatorBuilder: (_, __) => divider().paddingSymmetric(horizontal: 10),
            itemBuilder: (context, index) {
              final folder = (c.folderList??[])[index];
              return ListTile(
                leading:
                Icon(Icons.folder_outlined,size: 18,color: appColorYellow,),
                title: Text(folder.folderName??'',style: BalooStyles.baloonormalTextStyle(),),
                /// RADIO → select folder
                trailing: Radio<String>(
                  value: "${folder.userGalleryId}",
                  activeColor: appColorGreen,

                  groupValue: "${c.selectedFolderId}",
                  onChanged: (val) {
                    c.selectFolder(int.parse(val??''));
                  },
                ),
                /// TAP TILE → navigate inside folder
                onTap: () {
                  // c.openFolder(folder);
                },
              );
            },
          ),
        );
      },
    );

  }


  _buttomAction(formKey,controller){
    return Row(
      children: [
        Expanded(
          child: GradientButton(
            name: "Save",
            btnColor: appColorYellow,
            gradient: LinearGradient(
                colors: [appColorYellow, appColorYellow]),
            vPadding: 10,
            onTap: () async {
              if (formKey.currentState!.validate()) {
                if (controller.selectedFolderId == null) {
                  Get.snackbar(
                    "Folder required",
                    "Please select a folder",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }

                controller.onTapSaveToFolder(
                    Get.context!,
                    user
                );
              }
            },
          ),
        ),
        hGap(15),
        Expanded(
          child: GradientButton(
            name: "Cancel",
            btnColor: Colors.black,
            color: greyText,
            gradient: LinearGradient(
              colors: [AppTheme.whiteColor, AppTheme.whiteColor],
            ),
            vPadding: 10,
            onTap: () => Get.back(),
          ),
        ),
      ],
    );
  }
}
