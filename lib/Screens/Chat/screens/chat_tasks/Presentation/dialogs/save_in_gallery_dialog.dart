import 'dart:io';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/gallery_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/genere_controller.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
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
import '../../../../../../utils/networl_shimmer_image.dart';
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
  final bool? multi;
  final FolderData? folderData;

  const SaveToCustomFolderDialog({
    super.key,
    required this.user,
    required this.filesImages,
    required this.isImage,
    required this.isFromChat,
    required this.multi,
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
        width: 550,
        child: Material(
          type: MaterialType.transparency,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  divider().paddingSymmetric(horizontal: 40),
                  vGap(7),
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
                  const SizedBox(height: 15),

                 ! (widget.multi!)?   CustomTextField(
                    hintText: "Document Name",
                    controller: c.docNameController,
                    labletext: "Document Name",
                    validator: (value) =>
                        value?.isEmptyField(messageTitle: "Document Name"),
                  ):const SizedBox(),

                  const SizedBox(height: 12),

                  // ✅ PREVIEW GRID
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Preview",
                      style: BalooStyles.baloonormalTextStyle(size: 12),
                    ),
                  ),
                  const SizedBox(height: 6),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _items.map((PickedFileItem f) {
                      return _PreviewTile(
                        file: f,
                        onRemove: () {
                          setState(() => _items.remove(f));
                          // setState(() => galleryC.images.remove(file));
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 10),
                  GenreInputGetX(),
                  (widget.isDirect ?? false)
                      ? Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () async {
                        final name = await showCreateFolderDialog();
                        if (name != null) {
                          await c.hitApiToGetFolder(reset: true);
                        }
                      },
                      icon: const Icon(Icons.create_new_folder_outlined, size: 18),
                      label: const Text('Create new folder'),
                      style: TextButton.styleFrom(
                        foregroundColor: appColorPerple,
                      ),
                    ),
                  )
                      : const SizedBox(),

                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Choose Folder",
                      style: BalooStyles.baloonormalTextStyle(
                        size: 12,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
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


  Widget _folderListView() {
    if (!(widget.isDirect ?? false)) {
      return _SelectedFolderTile(
        folderName: widget.folderData?.folderName ?? '',
        folderId: widget.folderData?.userGalleryId,
        selectedFolderId: c.selectedFolderId,
        onTap: () {},
        onChanged: (_) {},
      );
    }

    return GetBuilder<SaveToGalleryController>(
      builder: (controller) {
        if (controller.isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: IndicatorLoading(),
          );
        }

        final list = controller.folderList ?? [];

        if (list.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.04),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(.08)),
            ),
            child: Row(
              children: [
                Icon(Icons.folder_open_rounded, color: appColorYellow, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "No folders found",
                    style: BalooStyles.baloonormalTextStyle(size: 12),
                  ),
                ),
              ],
            ),
          );
        }

        return AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Colors.white.withOpacity(.03),
              border: Border.all(
                color: appColorPerple.withOpacity(.12),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(list.length, (index) {
                final folder = list[index];
                final isSelected =
                    controller.selectedFolderId == folder.userGalleryId;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == list.length - 1 ? 0 : 8,
                  ),
                  child: _ModernFolderTile(
                    folderName: folder.folderName ?? '',
                    fileCount: folder.totalItems,
                    isSelected: isSelected,
                    onTap: () {
                      controller.selectFolder(folder.userGalleryId ?? 0);
                    },
                    onChanged: (_) {
                      controller.selectFolder(folder.userGalleryId ?? 0);
                    },
                    radioValue: "${folder.userGalleryId}",
                    groupValue: "${controller.selectedFolderId}",
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }


/*  _folderListView(){
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

              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300,minHeight: 50),
                child: ListView.separated(
                  // shrinkWrap: true,
                  controller: c.scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: (c.folderList??[]).length,
                  separatorBuilder: (_, __) => divider().paddingSymmetric(horizontal: 10),
                  itemBuilder: (context, index) {
                    final folder = (c.folderList??[])[index];
                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 50,minHeight: 40
                      ,maxWidth: 200),
                      child: ListTile(

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
                      ),
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

  }*/


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

  _onSave(SaveToGalleryController controller){
    final genController = Get.find<GenreController>();
    GalleryController? gallCon;
    GalleryItemController? itemCon;
    if(widget.folderData!=null){
      final tag = 'folder_${widget.folderData?.userGalleryId}';
      itemCon = Get.isRegistered<GalleryItemController>()?Get.find<GalleryItemController>(tag:'folder_${widget.folderData?.userGalleryId}' ):Get.put<GalleryItemController>(GalleryItemController(folderData: widget.folderData,),tag: tag);
    }else{
      gallCon = Get.find<GalleryController>();
    }

    final genre = Get.find<GenreController>();

    if(!widget.isFromChat) {
      if (widget.isImage) {
        if(widget.folderData!=null){
          itemCon?.uploadMediaApiCall(
            onProgress: (sent, total) {
              itemCon?.setUploadProgress(sent, total);
            },
            ctx: context,
            images: _items,
            folderName: controller.selectedFolder
                ?.folderName ?? '',
            title: controller.docNameController.text.trim(),
            keywords: genre.genresString.value,
            folder: controller.selectedFolder,
            isDirect: widget.folderData!=null?false:true,
          );
        }else{
          gallCon?.uploadMediaApiCall(
            onProgress: (sent, total) {
              gallCon?.setUploadProgress(sent, total);
            },
            ctx: context,
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
          itemCon?.uploadDocumentsApiCall(files: _items,
            folderName: controller.selectedFolder?.folderName ?? '',
            mediaTitle: controller.docNameController.text.trim(),
            folder: controller.selectedFolder,
            keywords:
            genre.genresString.value,
            ctx: context,
            isDirect: widget.folderData != null ? false : true,
          );
        }else {
          gallCon?.uploadDocumentsApiCall(files: _items,
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

    Future.delayed(const Duration(milliseconds: 500),(){
      controller.docNameController.clear();
      controller.removeSelectFolder();
      genController.genres.clear();
      genController.genresString.value='';
      _items.clear();
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
    // Mobile fallback: local file path
    // if (!kIsWeb && file.path != null && file.path!.isNotEmpty && !isImageVideo(file.path!)) {
    //   return _box(
    //     child: ClipRRect(
    //       borderRadius: BorderRadius.circular(8),
    //       child: Image.file(File(file.path!), fit: BoxFit.cover),
    //     ),
    //   );
    // }
    // ✅ IMAGE PREVIEW
      // ✅ IMAGE PREVIEW
      if (file.isImage) {

        // 1️⃣ Web / memory image
        if (file.byte != null) {
          return _box(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(file.byte!, fit: BoxFit.cover),
            ),
          );
        }

        // 2️⃣ Network image
        if (isNetworkImage(file.url)) {
          return _box(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomCacheNetworkImage(
                file.url!,
                radiusAll: 8,
                borderColor: greyText,
                boxFit: BoxFit.cover,
              ),
            ),
          );
        }

        // 3️⃣ Mobile local file
        if (!kIsWeb && isLocalFile(file.path)) {
          return _box(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(File(file.path!), fit: BoxFit.cover),
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

class _ModernFolderTile extends StatefulWidget {
  final String folderName;
  final String? fileCount;
  final bool isSelected;
  final VoidCallback onTap;
  final ValueChanged<String?> onChanged;
  final String radioValue;
  final String groupValue;

  const _ModernFolderTile({
    required this.folderName,
    required this.fileCount,
    required this.isSelected,
    required this.onTap,
    required this.onChanged,
    required this.radioValue,
    required this.groupValue,
  });

  @override
  State<_ModernFolderTile> createState() => _ModernFolderTileState();
}

class _ModernFolderTileState extends State<_ModernFolderTile> {
  bool _isHover = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.isSelected;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHover = true),
      onExit: (_) => setState(() => _isHover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: selected
              ? appColorPerple.withOpacity(.10)
              : _isHover
              ? Colors.white.withOpacity(.05)
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? appColorPerple.withOpacity(.45)
                : Colors.white.withOpacity(.08),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: selected
                          ? appColorYellow.withOpacity(.16)
                          : appColorYellow.withOpacity(.10),
                    ),
                    child: Icon(
                      selected
                          ? Icons.folder_open_rounded
                          : Icons.folder_outlined,
                      color: appColorYellow,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.folderName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: BalooStyles.baloonormalTextStyle(
                            size: 13,
                            weight: selected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        if ((widget.fileCount ?? '').isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            "${widget.fileCount} items",
                            style: BalooStyles.baloonormalTextStyle(
                              size: 11,
                              color: greyText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Radio<String>(
                    value: widget.radioValue,
                    groupValue: widget.groupValue,
                    activeColor: appColorGreen,
                    onChanged: widget.onChanged,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedFolderTile extends StatelessWidget {
  final String folderName;
  final int? folderId;
  final int? selectedFolderId;
  final VoidCallback onTap;
  final ValueChanged<String?> onChanged;

  const _SelectedFolderTile({
    required this.folderName,
    required this.folderId,
    required this.selectedFolderId,
    required this.onTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = folderId == selectedFolderId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: appColorPerple.withOpacity(.08),
        border: Border.all(color: appColorPerple.withOpacity(.18)),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: appColorYellow.withOpacity(.12),
            ),
            child: Icon(
              Icons.folder_open_rounded,
              size: 20,
              color: appColorYellow,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              folderName,
              style: BalooStyles.baloonormalTextStyle(
                size: 13,
                weight: FontWeight.w600,
              ),
            ),
          ),
          Radio<String>(
            value: "${folderId}",
            groupValue: "${selectedFolderId}",
            activeColor: appColorGreen,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
