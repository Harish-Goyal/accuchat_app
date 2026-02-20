import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/create_folder_dialog.dart';
import 'package:AccuChat/utils/custom_container.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:AccuChat/utils/data_not_found.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/confirmation_dialog.dart';
import '../../../../utils/show_upload_option_galeery.dart';
import '../../../Chat/helper/dialogs.dart';
import '../../../Chat/models/gallery_node.dart';
import '../../Models/get_folder_res_model.dart';
import '../Controller/galeery_item_controller.dart';
import '../Controller/gallery_controller.dart';
import 'folder_items_view.dart';
import 'gallery_search_result_widget.dart';
import 'home_screen.dart';

class GalleryTab extends GetView<GalleryController> {
  GalleryTab({super.key});
  GalleryController galleryController =
      Get.put<GalleryController>(GalleryController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder<GalleryController>(builder: (controller) {
        return Scaffold(
          appBar: _searchBarWidget(),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Colors.white,
            elevation: 1,
            onPressed: () async {
              final name = await showCreateFolderDialog();
              if (name != null) {
                Dialogs.showSnackbar(Get.context!, "Created  $name");
              }
            },
            icon: const Icon(Icons.create_new_folder_outlined),
            label:
                Text('New Folder', style: BalooStyles.baloosemiBoldTextStyle()),
          ),
          body: TabBarView(
            controller: controller.tabController,
            children: [
              GetBuilder<GalleryController>(
                builder: (c) {
                  return WillPopScope(
                    onWillPop: ()  {
                      Get.find<DashboardController>().updateIndex(0);
                      return Future.value(true);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!c.isSearching)
                          Row(
                            children: [
                              Expanded(
                                child: _GalleryHeader(
                                  isRoot: true,
                                  breadcrumbs:[],
                                  onBack:(){return true;},
                                  onRootTap: (){},
                                  onCrumbTap: (v){},
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    showUploadOptions(context);
                                  },
                                  icon: CustomContainer(
                                      color: appColorGreen.withOpacity(.1),
                                      brcolor: appColorGreen,
                                      vPadding: 8,
                                      hPadding: 8,
                                      childWidget: Icon(Icons.upload_outlined,
                                          color: appColorGreen)))
                            ],
                          ),

                        vGap(8),
                        Expanded(child: _listView()),
                      ],
                    ),
                  );
                },
              ),

              const Center(
                child: Text('Shared is Empty'),
              ),
            ],
          ),
        );
      }),
    );
  }

  AppBar _searchBarWidget() {
    return AppBar(      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.white,
      title: controller.isSearchingIcon
          ? TextField(
              controller: controller.searchCtrl,
              cursorColor: appColorGreen,
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search folders, media by name ,keywords or user ...',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  constraints: BoxConstraints(maxHeight: 45)),
              autofocus: true,
              style: const TextStyle(fontSize: 13, letterSpacing: 0.5),
              onChanged: (val) {
                controller.query = val;
                controller.onSearchChanged(val);
                controller
                    .hitApiToGetSearchResultItems(controller.query.trim());
              },
            ).marginSymmetric(vertical: 10)
          : const SectionHeader(
              title: 'Your Smart Gallery',
              icon: galleryIcon,
            ),
      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64), child: _beautifiedTabBar()),
      actions: [
        IconButton(
                onPressed: () {
                  controller.isSearchingIcon = !controller.isSearchingIcon;
                  controller.searchCtrl.clear();
                  controller.searchResults?.clear();
                  controller.update();
                },
                icon: controller.isSearchingIcon
                    ? const Icon(CupertinoIcons.clear_circled_solid)
                    : Image.asset(searchPng, height: 25, width: 25))
            .paddingOnly(top: 0, right: 10),
      ],
    );
  }

  Widget _beautifiedTabBar() {
    return Container(
      width: Get.width,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: controller.tabController,
        isScrollable: true,
        dividerColor: Colors.transparent,
        labelPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        splashFactory: NoSplash.splashFactory,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        labelColor: Theme.of(Get.context!).colorScheme.primary,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: BalooStyles.baloosemiBoldTextStyle(),
        unselectedLabelStyle: BalooStyles.balooregularTextStyle(),
        indicator: BoxDecoration(
            color: Theme.of(Get.context!).colorScheme.primary.withOpacity(.1),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: Theme.of(Get.context!).colorScheme.primary)),
        tabs: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder, size: 16),
              SizedBox(width: 6),
              Text('Folders'),
            ],
          ).paddingSymmetric(horizontal: 15, vertical: 3),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder_shared_outlined, size: 16),
              SizedBox(width: 6),
              Text('Shared'),
            ],
          ).paddingSymmetric(horizontal: 15, vertical: 3),
        ],
      ),
    );
  }

  _listView() {
    return Container(
      padding: const EdgeInsets.only(right: 12, left: 12, bottom: 80),
      child: controller.isSearching
          ? Obx(() {
              final items = controller.searchResults;
              return GalleryGlobalSearchResults(
                items: items ?? [],
                buildFileUrl: buildFileUrl,
                onOpenFolder: (folderName) {
                  controller.isSearchingIcon = false;
                  controller.searchCtrl.clear();
                  controller.searchResults?.clear();
                  Get.back();
                },
                onOpenMedia: (media) {
                  controller.isSearchingIcon = false;
                  controller.searchCtrl.clear();
                  controller.searchResults?.clear();
                  Get.to(()=>FolderItemsScreen(folderData: media),
                    binding: BindingsBuilder(() {
                      final tag = 'folder_${media.userGalleryId}';
                      if (Get.isRegistered<GalleryItemController>(tag: tag)) {
                        Get.delete<GalleryItemController>(tag: tag, force: true);
                      }
                      Get.lazyPut<GalleryItemController>(() => GalleryItemController(folderData: media), tag: tag);
                    }),);
                },
              );
            })
          : Obx(() => controller.isLoading.value
              ? const IndicatorLoading()
              :controller.folderList.isNotEmpty? _GalleryGrid(
                  items: controller.folderList ?? [],
                  onFolderTap: (v) {},
                  onLeafTap: (v) {},
                  controller: controller,
                ):AspectRatio(
          aspectRatio: .1,
          child: SizedBox(
            height: 100,
              width: 100,
              child: DataNotFoundText()))),
    );
  }
}

class _GalleryHeader extends StatelessWidget {
  final bool isRoot;
  final List<FolderData> breadcrumbs;
  final bool Function() onBack;
  final VoidCallback onRootTap;
  final void Function(int index) onCrumbTap;
  const _GalleryHeader({
    required this.isRoot,
    required this.breadcrumbs,
    required this.onBack,
    required this.onRootTap,
    required this.onCrumbTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.only(left: 0, right: 12, top: 12, bottom: 4),
      child: Row(
        children: [
          if (!isRoot)
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Colors.black,
              ),
              tooltip: 'Back',
            )
          else
            const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: onRootTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (breadcrumbs.isEmpty
                            ? appColorPerple.withOpacity(0.12)
                            : appColorPerple.withOpacity(0.6)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Root',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: breadcrumbs.isEmpty
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  for (int i = 0; i < breadcrumbs.length; i++) ...[
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Colors.black87,
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => onCrumbTap(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: (i == breadcrumbs.length - 1
                              ? appColorPerple.withOpacity(0.12)
                              : theme.colorScheme.surfaceVariant
                                  .withOpacity(0.6)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          breadcrumbs[i].folderName ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: (i == breadcrumbs.length - 1)
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryGrid extends StatelessWidget {
  final List<FolderData> items;
  final void Function(GalleryNode folder) onFolderTap;
  final void Function(GalleryNode node) onLeafTap;
  final GalleryController controller;
  const _GalleryGrid({
    required this.items,
    required this.onFolderTap,
    required this.onLeafTap,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cross = (constraints.maxWidth ~/120).clamp(2, 12);
        return Obx(
          () => RefreshIndicator(
            onRefresh: () async => controller.refreshGallery(),
            child: GridView.builder(
              // padding: const EdgeInsets.only(bottom: 12, top: 4),
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:(kIsWeb&&Get.width>600)? cross:4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: items.length + (controller.hasMore.value ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == items.length) {
                  return const IndicatorLoading();
                }
                final node = items[i];
                return _GalleryTile(
                  folder: node,
                  onTap:(){
                    Get.to(()=>FolderItemsScreen(folderData: node),
                      binding: BindingsBuilder(() {
                        final tag = 'folder_${node.userGalleryId}';
                        if (Get.isRegistered<GalleryItemController>(tag: tag)) {
                          Get.delete<GalleryItemController>(tag: tag, force: true);
                        }
                        Get.lazyPut<GalleryItemController>(() => GalleryItemController(folderData: node), tag: tag);

                      }),);
                  } ,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

enum FolderMenuAction { rename, share,sharew, delete }

class _GalleryTile extends StatelessWidget {
  // final GalleryNode node;
  final FolderData folder;
  final VoidCallback onTap;

  const _GalleryTile({required this.folder, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<GalleryController>();

    Widget preview;
    /*  if (node.type == NodeType.image && node.thumbnail != null) {
      preview = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.network(node.thumbnail!, fit: BoxFit.cover),
        ),
      );
    } else if (node.type == NodeType.doc) {
      preview = _IconPreview(icon: Icons.description_rounded, color: theme.colorScheme.tertiary);
    } else {*/
    preview = _IconPreview(
        icon: Icons.folder_rounded, color: theme.colorScheme.primary);
    // }

    return InkWell(
      onTap: onTap, // open folder / preview
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border:
              Border.all(color: theme.colorScheme.outlineVariant, width: .5),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 2),
              color: Colors.black.withOpacity(0.06),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Expanded(child: preview),
                  vGap(5),
                  // Obx(() {
                  // final isRenaming = controller.renamingId.value == node.id; // ✅ node must have unique id
                  // if (!isRenaming) {
                  /* return */
                  Text(
                    folder.folderName ?? '',
                    maxLines: 21,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: BalooStyles.balooregularTextStyle(),
                  )

                  /*         final ctrl = controller.textCtrlFor(node.id??'', node.name??'');
                    final focus = controller.focusNodeFor(node.id??'');*/

                  /* return Focus(
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) {
                          controller.submitRename(
                            id: node.id??'',
                            oldName: node.name??'',
                            onRename: (newName) async {
                              // ✅ your API / update logic
                              await controller.renameFolder(node.id??'', newName);
                            },
                          );
                        }
                      },
                      child: TextField(
                        controller: ctrl,
                        focusNode: focus,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          controller.submitRename(
                            id: node.id??'',
                            oldName: node.name??"",
                            onRename: (newName) async {
                              await controller.renameFolder(node.id??'', newName);
                            },
                          );
                        },
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        ),
                      ),
                    );*/
                  // }),
                  /*if (node.isFolder) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${node.children.length} items',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],*/
                ],
              ),
            ),

            // Top-right menu (only for folder)
            // if (node.isFolder)
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: Colors.transparent,
                child: PopupMenuButton<FolderMenuAction>(
                  tooltip: "More",
                  padding: EdgeInsets.zero,
                  position: PopupMenuPosition.under,
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  onSelected: (action) {
                    switch (action) {
                      case FolderMenuAction.rename:
                        toast("Under Development!");
                        // controller.startRename(id: folder.userGalleryId??0, currentName: folder.folderName??'');
                        break;
                      case FolderMenuAction.delete:
                        // showResponsiveConfirmationDialog(onConfirm:  () async {
                        //   Get.back();
                        // },title: "Delete ${node.name} Folder(Permanently Deleted)");
                        showResponsiveConfirmationDialog(
                            onConfirm: () {
                              controller.hitApiToDeleteFolder(folder.userGalleryId);
                            },
                            title: "Confirm Delete",
                            subtitle:
                                "Delete ${folder.folderName} (Permanently Deleted)");
                        break;
                      case FolderMenuAction.share:
                        controller.handleOnShareWithinAccuchat(context: context);
                        break;
                      case FolderMenuAction.sharew:
                        toast("Under Development!");
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconPreview extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconPreview({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(child: Icon(icon, size: 48, color: color));
  }
}
