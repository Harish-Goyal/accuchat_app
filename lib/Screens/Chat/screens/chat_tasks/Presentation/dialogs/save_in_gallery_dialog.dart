import 'dart:io';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/Screens/Chat/helper/dialogs.dart';
import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/gallery_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/genere_controller.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../Constants/colors.dart';
import '../../../../../../Constants/themes.dart';
import '../../../../../../utils/common_textfield.dart';
import '../../../../../../utils/custom_dialogue.dart';
import '../../../../../../utils/gradient_button.dart';
import '../../../../../../utils/helper.dart';
import '../../../../../../utils/helper_widget.dart';
import '../../../../../../utils/text_style.dart';
import '../../../../../Home/Models/get_folder_res_model.dart';
import '../../../../../Home/Models/pickes_file_item.dart';
import '../../../../../Home/Presentation/Controller/galeery_item_controller.dart';
import '../../../../../Home/Presentation/View/create_folder_dialog.dart';
import '../../../../../Home/Presentation/View/genre_view.dart';
import '../Controllers/save_in_accuchat_gallery_controller.dart';

class SaveToCustomFolderDialog extends StatefulWidget {
  final dynamic user;
  final List<PickedFileItem> filesImages;
  final bool isImage;
  final bool isFromChat;
  final int? chatId;
  final bool? isDirect;
  final FolderData? folderData;

  const SaveToCustomFolderDialog({
    super.key,
    required this.user,
    required this.filesImages,
    required this.isImage,
    required this.isFromChat,
    required this.isDirect,
    required this.folderData,
    this.chatId,
  });

  @override
  State<SaveToCustomFolderDialog> createState() => _SaveToCustomFolderDialogState();
}

class _SaveToCustomFolderDialogState extends State<SaveToCustomFolderDialog> {
  final _formKey = GlobalKey<FormState>();
  late List<PickedFileItem> _items;
  late SaveToGalleryController c;

  @override
  void initState() {
    super.initState();
    c = Get.find<SaveToGalleryController>();
    _items = List<PickedFileItem>.from(widget.filesImages);
  }

  @override
  Widget build(BuildContext context) {

    final galleryC = Get.find<GalleryController>();
    return CustomDialogue(
      title: "Save In Accuchat's Smart Gallery",
      isShowAppIcon: true,
      isShowActions: false,
      content: SizedBox(
        width: 500,
        child: Material(
          type: MaterialType.transparency,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  divider().paddingSymmetric(horizontal: 40),
                  Text(
                    "This media will be saved in your AccuChat Gallery under the selected folder.",
                    style: BalooStyles.baloonormalTextStyle(size: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "Search your media by Name, Date and User Individuals",
                    style: BalooStyles.baloonormalTextStyle(size: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    hintText: "Document Name",
                    controller: c.docNameController,
                    labletext: "Document Name",
                    validator: (value) =>
                        value?.isEmptyField(messageTitle: "Document Name"),
                  ),

                  const SizedBox(height: 12),

                  // ✅ PREVIEW GRID
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Preview",
                      style: BalooStyles.baloonormalTextStyle(size: 12),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _items.map((file) {
                      return _PreviewTile(
                        file: file,
                        onRemove: () {
                          setState(() => _items.remove(file));
                          // setState(() => galleryC.images.remove(file));
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),
                  GenreInputGetX(),
                  const SizedBox(height: 12), (widget.isDirect!)?    IconButton(
                    onPressed: () async {
                      final name = await showCreateFolderDialog();
                      if (name != null) {
                        await c.hitApiToGetFolder(reset: true);
                        setState(() {});
                      }
                    },
                    icon: const Text('Create a new folder'),
                  ):const SizedBox(),

                  const SizedBox(height: 12),
                  _folderListView(),
                  const SizedBox(height: 12),

                  _buttomAction(_formKey, c, _items),
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
    if(!(widget.isDirect!)){
      c.selectFolder(widget.folderData?.userGalleryId);
    }

    return  (widget.isDirect!) ?StatefulBuilder(
        builder: (context,setstate) {
          return GetBuilder<SaveToGalleryController>(
            init: SaveToGalleryController(),
            builder: (c) {
              if (c.isLoading) {
                return const IndicatorLoading();
              }

              final list = c.folderList ?? [];
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text("No folders found", style: BalooStyles.baloonormalTextStyle()),
                );
              }

              return SizedBox(
                height: Get.height * .35,
                child: ListView.separated(
                  shrinkWrap: true,
                  controller: c.scrollController,
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
                          setstate((){});

                        },
                      ),
                      /// TAP TILE → navigate inside folder
                      onTap: () {
                        c.selectFolder(folder.userGalleryId??0);
                        setstate((){});
                      },
                    );
                  },
                ),
              );
            },
          );
        }
    ):ListTile(
      leading:
      Icon(Icons.folder_outlined,size: 18,color: appColorYellow,),
      title: Text(widget.folderData?.folderName??'',style: BalooStyles.baloonormalTextStyle(),),
      /// RADIO → select folder
      trailing: Radio<String>(
        value: "${widget.folderData?.userGalleryId}",
        activeColor: appColorGreen,
        groupValue: "${c.selectedFolderId}",
        onChanged: (val) {

        },
      ),
      /// TAP TILE → navigate inside folder
      onTap: () {},
    );

  }


  _buttomAction(formKey,SaveToGalleryController controller,filesImages){
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
                _onSave(controller);


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

  _onSave(controller){
    final genController = Get.find<GenreController>();
    final gallCon = Get.find<GalleryController>();
    final itemCon = Get.find<GalleryItemController>();
    final genre = Get.find<GenreController>();

    if(!widget.isFromChat) {
      if (widget.isImage) {
        if(widget.folderData!=null){
          itemCon.uploadMediaApiCall(
            onProgress: (sent, total) {
              itemCon.setUploadProgress(sent, total);
            },
            images: _items,
            folderName: controller.selectedFolder
                ?.folderName ?? '',
            title: controller.docNameController.text
                .trim(),
            keywords: genre.genresString.value,
            folder: controller.selectedFolder,
            isDirect: widget.folderData!=null?false:true,

          );
        }else{
          gallCon.uploadMediaApiCall(
            onProgress: (sent, total) {
              gallCon.setUploadProgress(sent, total);
            },
            images: _items,
            folderName: controller.selectedFolder
                ?.folderName ?? '',
            title: controller.docNameController.text
                .trim(),
            keywords: genre.genresString.value,
            folder: controller.selectedFolder,
            isDirect: widget.folderData!=null?false:true,

          );
        }

      } else {
        if(widget.folderData!=null){
          itemCon.uploadDocumentsApiCall(files: _items,
            folderName: controller.selectedFolder?.folderName ?? '',
            mediaTitle: controller.docNameController.text.trim(),
            folder: controller.selectedFolder,
            keywords:
            genre.genresString.value,
            isDirect: widget.folderData != null ? false : true,
          );
        }else {
          gallCon.uploadDocumentsApiCall(files: _items,
            folderName: controller.selectedFolder?.folderName ?? '',
            mediaTitle: controller.docNameController.text.trim(),
            folder: controller.selectedFolder,
            keywords:
            genre.genresString.value,
            isDirect: widget.folderData != null ? false : true,
          );
        }
      }
    }
    else{
      controller.hitApiToSaveMediaFromChatApiCall(chatId:widget.chatId,folderName: controller.selectedFolder?.folderName ?? '',
        keywords:genre.genresString.value,

      );
    }

    Future.delayed(const Duration(milliseconds: 400),(){
      controller.docNameController.clear();
      controller.removeSelectFolder();
      genController.genres.clear();
      genController.genresString.value='';
    });

  }
}

class _PreviewTile extends StatelessWidget {
  final PickedFileItem file;
  final VoidCallback onRemove;

  const _PreviewTile({
    required this.file,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    Widget preview = _buildPreview();

    return Stack(
      alignment: Alignment.topRight,
      clipBehavior: Clip.none,
      children: [
        preview,
        Positioned(
          top: -5,
          right: -5,
          child: GestureDetector(
            onTap: onRemove,
            child: const CircleAvatar(
              radius: 13,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    final name = file.name;

    // ✅ IMAGE PREVIEW
    if (file.isImage) {
      // Prefer bytes if available (web + sometimes mobile withData:true)
      if (file.byte != null) {
        return _box(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(file.byte!, fit: BoxFit.cover),
          ),
        );
      }

      // Mobile fallback: local file path
      if (!kIsWeb && file.path != null && file.path!.isNotEmpty) {
        return _box(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(File(file.path!), fit: BoxFit.cover),
          ),
        );
      }

      // Network fallback (chat media)
      if (file.url != null && file.url!.isNotEmpty) {
        return _box(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(file.url!, fit: BoxFit.cover),
          ),
        );
      }

      return _box(child: const Icon(Icons.broken_image));
    }

    // ✅ DOCUMENT PREVIEW (tile)
    if (file.isDocument || isDocumentName(name)) {
      final icon = docIconByExt(name);
      return _box(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.grey),
            const SizedBox(height: 6),
            Row(
              children: [
                Flexible(
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // default
    return _box(child: const Icon(Icons.insert_drive_file));
  }

  Widget _box({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: 80,
      height: 80,
      padding: padding,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }





}
