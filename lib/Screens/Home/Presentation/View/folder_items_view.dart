import 'package:AccuChat/Screens/Chat/models/chat_history_response_model.dart';
import 'package:AccuChat/Screens/Home/Models/get_folder_res_model.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/utils/common_textfield.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/gallery_controller.dart';

import '../../../../Constants/assets.dart';
import '../../../../Constants/colors.dart';
import '../../../../utils/confirmation_dialog.dart';
import '../../../../utils/custom_container.dart';
import '../../../../utils/loading_indicator.dart';
import '../../../../utils/networl_shimmer_image.dart';
import '../../../../utils/show_upload_option_galeery.dart';
import '../../../Chat/screens/chat_tasks/Presentation/Controllers/gallery_view_controller.dart';
import '../../../Chat/screens/chat_tasks/Presentation/Views/images_gallery_page.dart';
import '../Controller/galeery_item_controller.dart';
import 'gallery_view.dart';
import 'home_screen.dart';

class FolderItemsScreen extends StatelessWidget {
  // final String folderName;
  final FolderData? folderData;
  FolderItemsScreen({super.key, required this.folderData});



  @override
  Widget build(BuildContext context) {
    final GalleryItemController controller = Get.put(GalleryItemController(folderData: folderData));
    return  Scaffold(
          appBar:_searchBarWidget(context,controller),
          body: Obx(() {
            final isLoading = controller.isLoadingItems.value;
            final items = controller.filterFolderItems ?? [];

            if (isLoading) return const Center(child: CircularProgressIndicator());
            if (items.isEmpty) return const Center(child: Text("No items found"));

            return LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final crossAxisCount = _crossAxisCountForWidth(w);
                final thumbHeight = _thumbHeightForWidth(w);

                // ✅ Tile height = thumb + text area (fixed) -> no overflow
                final tileHeight = thumbHeight + (w < 520 ? 108 : 116);

                return controller.isLoadingItems.value
                    ? IndicatorLoading()
                    :  GridView.builder(
                controller:   controller.scrollControllerItem,
                  padding: EdgeInsets.symmetric(
                    horizontal: w >= 900 ? 14 : 10,
                    vertical: 12,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    mainAxisExtent: tileHeight, // ✅ overflow FIX
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    if (i == items.length) {
                      return const IndicatorLoading();
                    }
                    final it = items[i];

                    final fileName = (it.fileName ?? "").trim();
                    final title = ((it.title ?? "").trim().isEmpty)
                        ? fileName
                        : (it.title ?? "").trim();
                    final kw = (it.keyWords ?? "").trim();

                    final thumbUrl = "${ApiEnd.baseUrlMedia}${it.filePath}";
                    final isImage = _isImage(it.mediaTypeId ?? 0, fileName);
                    final List<String> filePaths =
                    controller.filterFolderItems
                        .where((e) => e.filePath != null)
                        .map((e) => "${ApiEnd.baseUrlMedia}${e.filePath!}")
                        .toList();
                    return _MediaCard(
                      thumbHeight: thumbHeight,
                      title: title,
                      keywords: kw,
                      thumbUrl: thumbUrl,
                      isImage: isImage,
                      fileName: fileName,
                      createdOnText: _prettyDate(it.createdOn),
                      docIcon: _fileIcon(fileName),
                      onTap: () {
                        if(isDocument(it.filePath)){
                          openDocumentFromUrl("${ApiEnd.baseUrlMedia}${it.filePath!}");
                        }else{
                          Get.to(
                                () => GalleryViewerPage(
                              onReply: () {},

                            ),
                            binding: BindingsBuilder(() {
                              Get.put(GalleryViewerController(
                                  urls: filePaths,
                                  index: i,
                                  chathis: null));
                            }),
                            fullscreenDialog: true,
                            transition: Transition.fadeIn,
                          );
                        }

                      },
                      onRename: () => _openRenameDialog(context, it,controller),
                      onDelete: () => _openDeleteConfirm(context, it,controller),
                      onShare: () {
                        // c.shareMedia(it);
                      },
                    );
                  },
                );
              },
            );
          }),
        );

  }

  AppBar _searchBarWidget(context,GalleryItemController c) {
    return AppBar(
      title:
          Obx(()=>
              c.isSearchingIconItem.value?TextField(
                    controller: c.itemSearchCtrl,
                    cursorColor: appColorGreen,
                    decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Search media ...',
              contentPadding:
              EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              constraints: BoxConstraints(maxHeight: 45)),
                    autofocus: true,
                    style: const TextStyle(fontSize: 13, letterSpacing: 0.5),
                    onChanged: (val) {
                      c.resetPagination();
            c.itemQuery.value = val;
            c.onSearchItem(c.itemQuery.value,folderData);
                    },
                  ).marginSymmetric(vertical: 10)

          :  SectionHeader(
        title: folderData?.folderName??'',
        icon: openfolderPng,
              )
      ),

      actions: [
        Obx(()=>
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: () {
                    c.isSearchingIconItem.value = !c.isSearchingIconItem.value;
                    c.isSearchingIconItem.refresh();
                    // c.resetPagination();
                    if (!c.isSearchingIconItem.value) {
                      c.itemQuery.value = '';
                      c.onSearchItem('',folderData);
                      c.itemSearchCtrl.clear();
                    }
                  },
                  icon: c.isSearchingIconItem.value
                      ? const Icon(CupertinoIcons.clear_circled_solid)
                      : Image.asset(searchPng, height: 25, width: 25))
                  .paddingOnly(top: 0, right: 10),
              c.isSearchingIconItem.value?SizedBox():  IconButton(
                  onPressed: () {
                    showUploadOptions(context,folder:folderData );
                  },
                  icon: CustomContainer(
                      color: appColorGreen.withOpacity(.1),
                      brcolor: appColorGreen,
                      vPadding: 8,
                      hPadding: 8,
                      childWidget: Icon(Icons.upload_outlined,
                          color: appColorGreen))),
            ],
          ),
        )


      ],
    );
  }

  // ---------- Responsive helpers ----------
  int _crossAxisCountForWidth(double w) {
    if (w < 520) return 2;      // mobile
    if (w < 760) return 3;      // large phone / small tablet
    if (w < 1024) return 4;     // tablet / small web
    if (w < 1400) return 5;     // web
    return 6;                   // big web
  }

  double _thumbHeightForWidth(double w) {
    if (w < 520) return 110;
    if (w < 760) return 120;
    if (w < 1024) return 130;
    return 140;
  }

  // ---------- Dialogs (same as yours) ----------
  void _openRenameDialog(BuildContext context, dynamic it,c) {
    final ctrl = TextEditingController(text: (it.title ?? "").toString().trim());

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Rename media"),
        content:CustomTextField(
          controller: ctrl,
          hintText:"Enter media name",
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final newName = ctrl.text.trim();
              if (newName.isEmpty) return;
              // it.title = newName; // optimistic UI
              c.hitApiToEditFolderItems(folderData!,it.userGalleryId, newName);
              Get.back();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _openDeleteConfirm(BuildContext context, dynamic it,GalleryItemController controller) {
    showResponsiveConfirmationDialog(onConfirm: (){
      controller.hitApiToDeleteFolderItems(folderData!,it.userGalleryId);
    },title: "Confirm Delete",subtitle:"Delete ${it.title}. (Permanently Deleted)" )
    ;

  }

  // ---------- File helpers ----------
  static bool _isImage(int mediaTypeId, String fileName) {
    final lower = fileName.toLowerCase();
    return mediaTypeId == 1 ||
        lower.endsWith(".png") ||
        lower.endsWith(".jpg") ||
        lower.endsWith(".jpeg") ||
        lower.endsWith(".webp");
  }

  static String _prettyDate(dynamic createdOn) {
    try {
      final dt = createdOn is DateTime
          ? createdOn
          : DateTime.tryParse(createdOn?.toString() ?? "");
      if (dt == null) return "";
      return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
    } catch (_) {
      return "";
    }
  }

  static IconData _fileIcon(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith(".pdf")) return Icons.picture_as_pdf;
    if (lower.endsWith(".doc") || lower.endsWith(".docx")) return Icons.description;
    if (lower.endsWith(".xls") || lower.endsWith(".xlsx") || lower.endsWith(".csv")) return Icons.grid_on;
    if (lower.endsWith(".ppt") || lower.endsWith(".pptx")) return Icons.slideshow;
    if (lower.endsWith(".zip") || lower.endsWith(".rar") || lower.endsWith(".7z")) return Icons.folder_zip;
    if (lower.endsWith(".mp4") || lower.endsWith(".mov") || lower.endsWith(".mkv")) return Icons.movie;
    if (lower.endsWith(".mp3") || lower.endsWith(".wav") || lower.endsWith(".aac")) return Icons.audiotrack;
    return Icons.insert_drive_file;
  }
}


/// ✅ Responsive Media Card (works for web + mobile)
class _MediaCard extends StatelessWidget {
  final double thumbHeight;
  final String title;
  final String keywords;
  final String thumbUrl;
  final bool isImage;
  final String fileName;
  final String createdOnText;
  final IconData docIcon;

  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const _MediaCard({
    required this.thumbHeight,
    required this.title,
    required this.keywords,
    required this.thumbUrl,
    required this.isImage,
    required this.fileName,
    required this.createdOnText,
    required this.docIcon,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click, // ✅ web
      child: Material(
        color: Colors.white,
        elevation: 2.5,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Full-width preview
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: thumbHeight,
                    width: double.infinity,
                    child: isImage
                        ? CustomCacheNetworkImage(
                      thumbUrl,
                      height: thumbHeight,
                      width: double.infinity,
                      radiusAll: 0,
                      boxFit: BoxFit.cover,
                      defaultImage: defaultGallery,
                      borderColor: Colors.transparent,
                    )
                        : _docPreview(),
                  ),
                ),

                const SizedBox(height: 10),

                // Title + menu
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                   /* PopupMenuButton<String>(
                      tooltip: "Actions",
                      onSelected: (v) {
                        if (v == "rename") onRename();
                        if (v == "share") onShare();
                        if (v == "delete") onDelete();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: "rename", child: Text("Rename")),
                        PopupMenuItem(value: "share", child: Text("Share")),
                        PopupMenuItem(value: "delete", child: Text("Delete")),
                      ],
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.more_vert, size: 18),
                      ),
                    ),*/

                    PopupMenuButton<FolderMenuAction>(
                      tooltip: "More",
                      padding: EdgeInsets.zero,
                      position: PopupMenuPosition.under,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      onSelected: (action) {
                     /* if (action == "rename") onRename();
                        if (action == "share") onShare();
                        if (action == "delete") onDelete();*/
                        switch (action) {
                          case FolderMenuAction.rename:
                            onRename();
                          // controller.startRename(id: node.id??'', currentName: node.name??'');
                            break;
                          case FolderMenuAction.delete:
                          // showResponsiveConfirmationDialog(onConfirm:  () async {
                          //   Get.back();
                          // },title: "Delete ${node.name} Folder(Permanently Deleted)");
                         onDelete();
                            break;
                          case FolderMenuAction.share:
                          // onShare?.call(node);
                            break;
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: FolderMenuAction.rename,
                          child: Text("Rename"),
                        ),
                        PopupMenuItem(
                          value: FolderMenuAction.share,
                          child: Text("Share"),
                        ),
                        PopupMenuDivider(),
                        PopupMenuItem(
                          value: FolderMenuAction.delete,
                          child: Text("Delete"),
                        ),
                      ],
                      child: InkWell(
                        // important: tap on menu should NOT open folder
                        onTap: null,
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                            padding: const EdgeInsets.all(4),
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.shade200, blurRadius: 10)
                                ]),
                            child: const Icon(
                              Icons.more_vert,
                              size: 18,
                              color: Colors.black87,
                            )),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 6),

                if (keywords.isNotEmpty)
                  Text(
                    keywords,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),

                const Spacer(), // ✅ pushes date row to bottom (no overflow)

                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.black45),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        createdOnText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5, color: Colors.black45),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _docPreview() {
    return Container(
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(docIcon, size: 48, color: Colors.black54),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

