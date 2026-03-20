import 'package:AccuChat/Screens/Home/Models/get_folder_res_model.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/backappbar.dart';
import 'package:AccuChat/utils/common_textfield.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../Constants/assets.dart';
import '../../../../Constants/colors.dart';
import '../../../../utils/confirmation_dialog.dart';
import '../../../../utils/custom_container.dart';
import '../../../../utils/hover_glass_effect_widget.dart';
import '../../../../utils/loading_indicator.dart';
import '../../../../utils/networl_shimmer_image.dart';
import '../../../../utils/share_helper.dart';
import '../../../../utils/show_upload_option_galeery.dart';
import '../../../Chat/screens/chat_tasks/Presentation/Controllers/gallery_view_controller.dart';
import '../../../Chat/screens/chat_tasks/Presentation/Views/images_gallery_page.dart';
import '../Controller/galeery_item_controller.dart';
import 'gallery_view.dart';
import 'home_screen.dart';

class FolderItemsScreen extends GetView<GalleryItemController> {
  final FolderData? folderData;
  final String tagId;

  FolderItemsScreen({super.key, required this.folderData})
      : tagId = 'folder_${folderData?.userGalleryId}';

  @override
  Widget build(BuildContext context) {
    GalleryItemController controller = Get.find<GalleryItemController>(tag: tagId);
    return   WillPopScope(
      onWillPop: () async {
        if (Get.key.currentState?.canPop() ?? false) {
          Get.back();
        } else {
          Get.offAllNamed(AppRoutes.home);
        }
        return false;
      },
      child: Scaffold(
            appBar:_searchBarWidget(context,controller),
            body: Obx(() {
              final isLoading = controller.isLoadingItems.value;
              final items = controller.filterFolderItems; // RxList

              if (isLoading) return const IndicatorLoading();
              if (!isLoading && items.isEmpty) return const Center(child: Text("No items found"));


              return LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final crossAxisCount = _crossAxisCountForWidth(w);
                  final thumbHeight = _thumbHeightForWidth(w);

                  // ✅ Tile height = thumb + text area (fixed) -> no overflow
                  final tileHeight = thumbHeight + (w < 520 ? 108 : 116);

                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: const DecorationImage(image: AssetImage(appbarBG),fit: BoxFit.cover)
                    ),
                    child: GridView.builder(
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
                        bool isSelected = folderData?.userGalleryId == items[i].userGalleryId;
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

                        return HoverGlassEffect(
                          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          borderRadius: 12,
                          hoverScale: 1.04,
                          normalBlur: 3,
                          hoverBlur: 10,
                          // borderColor: greenside.withOpacity(.1),
                          // hoverBorderColor:greenside.withOpacity(.55)

                          child: _MediaCard(
                            thumbHeight: thumbHeight,
                            title: title,
                            keywords: kw,
                            thumbUrl: thumbUrl,
                            isImage: isImage,
                            fileName: fileName,
                            isSelected: isSelected,
                            createdOnText: _prettyDate(it.createdOn),
                            docIcon: _fileIcon(fileName),
                            onTap: () {
                              if(isDocument(it.filePath??'')){
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
                            }, onSharew: ()=>
                            _onShareWhatsapp(thumbUrl),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }),
          ),
    );

  }

  AppBar _searchBarWidget(context,GalleryItemController c) {
    return AppBar(
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.white,
      leading: backApp(context, '',onTap: (){
        Get.toNamed(AppRoutes.home);
        Get.find<DashboardController>().updateIndex(2);
      }),
      leadingWidth: 60,
      title:
          Obx(()=>
              c.isSearchingIconItem.value && !kIsWeb?TextField(
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
                coloricon: greenside,
              )
      ),

      actions: [
        Obx(()=>
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: Get.width*.3,
                padding: const EdgeInsets.all(0),
                decoration:BoxDecoration(
                  gradient: LinearGradient(colors: [
                    gallwhite,
                    perpleBg,
                  ]),
                  border: Border.all(color: Colors.white),
                  boxShadow: [BoxShadow(color:perpleBg,blurRadius: 8)],
                  borderRadius: BorderRadius.circular(40),
                ),
                child: TextField(
                  controller: c.itemSearchCtrl,
                  cursorColor: perpleBg,
                  textAlignVertical: TextAlignVertical.center,
                  maxLines: 1,

                  decoration:  InputDecoration(
                    enabledBorder:InputBorder.none,
                    disabledBorder:  InputBorder.none,
                    focusedBorder:  InputBorder.none,
                    border: InputBorder.none,
                    isDense: true,
                    hintText: 'Search folders, media by name ,keywords or user ...',
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    constraints: const BoxConstraints(maxHeight: 45),
                    prefixIcon: InkWell(
                        onTap: () {
                          c.isSearchingIconItem.value = !c.isSearchingIconItem.value;
                          c.isSearchingIconItem.refresh();
                          // c.resetPagination();
                          if (!c.isSearchingIconItem.value) {
                            c.itemQuery.value = '';
                            c.onSearchItem('',folderData);
                            c.itemSearchCtrl.clear();
                          }
                        },
                        child:c.isSearchingIconItem.value
                            ? const Icon(CupertinoIcons.clear,color: Colors.black45,)
                        // : Image.asset(searchPng, height: 25, width: 25))
                            : SvgPicture.asset(searchPng, height: 20, width: 20,color: Colors.black45,)).paddingOnly(left: 6)
                    ,prefixIconConstraints: const BoxConstraints(maxHeight: 20),
                  ),

                  autofocus: false,
                  style: const TextStyle(fontSize: 13, letterSpacing: 0.5),
                  onChanged: (val) {
                    c.resetPagination();
                    c.itemQuery.value = val;
                    c.onSearchItem(c.itemQuery.value,folderData);
                  },
                ).marginSymmetric(vertical: 0),
              ),
              c.isSearchingIconItem.value && !kIsWeb?     IconButton(
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
                  icon:CustomContainer(
                  color: perplebr.withOpacity(.1),
    brcolor: perplebr,
    vPadding: 8,
    hPadding: 8,
    childWidget: c.isSearchingIconItem.value
        ?  Icon(CupertinoIcons.clear_circled_solid,color: perplebr)
    // : Image.asset(searchPng, height: 25, width: 25))
        : SvgPicture.asset(searchPng, height: 20, width: 20,color: perplebr))



                  )
                  .paddingOnly(top: 0, right: 0) :const SizedBox(),
              c.isSearchingIconItem.value?const SizedBox():


              IconButton(
                  onPressed: () {
                    showUploadOptions(context,folder:folderData );
                  },
                  icon: CustomContainer(
                      color: perplebr.withOpacity(.1),
                      brcolor: perplebr,
                      vPadding: 8,
                      hPadding: 8,
                      childWidget: Icon(Icons.upload_outlined,
                          color: perplebr))),
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

  void _onShareWhatsapp(url)async{
    if (kIsWeb) {
      ShareHelper.shareOnWhatsApp(url);
    } else {
      await ShareHelper.shareNetworkFile(
        url,
        text: "From AccuChat",
        fileName: url, // optional if you store it
      );
    }
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
  final bool isSelected;
  final String fileName;
  final String createdOnText;
  final IconData docIcon;

  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onSharew;

  const _MediaCard({
    required this.thumbHeight,
    required this.title,
    required this.keywords,
    required this.thumbUrl,
    required this.isImage,
    required this.isSelected,
    required this.fileName,
    required this.createdOnText,
    required this.docIcon,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
    required this.onShare,
    required this.onSharew,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: isSelected ? appColorPerple.withOpacity(.1) : Colors.white,
        elevation: 8,
        shadowColor: perplebr,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: thumbHeight,
                    width: double.infinity,
                    child: isImage
                        ?thumbUrl.endsWith('gif')?  ClipRRect(
                      borderRadius: BorderRadius.circular(12),child:
                    RepaintBoundary(
                      child: Image(
                        image: NetworkImage(thumbUrl),
                        key:ValueKey(thumbUrl),
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                      ),
                    )

                    ):CustomCacheNetworkImage(
                      thumbUrl,
                      height: thumbHeight,
                      width: double.infinity,
                      radiusAll: 0,
                      boxFit: BoxFit.cover,
                      defaultImage: galleryIcon,
                      borderColor: Colors.transparent,
                    )
                        : _docPreview(),
                  ),
                ),

                const SizedBox(height: 5),

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

                        switch (action) {
                          case FolderMenuAction.rename:
                            onRename();
                            break;
                          case FolderMenuAction.delete:
                         onDelete();
                            break;
                          case FolderMenuAction.share:
                            break;
                          case FolderMenuAction.sharew:
                           onSharew();
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
                        PopupMenuItem(
                          value: FolderMenuAction.sharew,
                          child: Text("Share on Whatsapp"),
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

