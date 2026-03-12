import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/create_folder_dialog.dart';
import 'package:AccuChat/utils/custom_container.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:AccuChat/utils/data_not_found.dart';
import 'package:AccuChat/utils/gradient_button.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../Services/APIs/api_ends.dart';
import '../../../../utils/circleContainer.dart';
import '../../../../utils/confirmation_dialog.dart';
import '../../../../utils/networl_shimmer_image.dart';
import '../../../../utils/show_upload_option_galeery.dart';
import '../../../Chat/models/gallery_node.dart';
import '../../Models/get_folder_res_model.dart';
import '../Controller/galeery_item_controller.dart';
import '../Controller/gallery_controller.dart';
import 'folder_items_view.dart';
import 'gallery_search_result_widget.dart';

class GalleryTab extends GetView<GalleryController> {
  GalleryTab({super.key});
  GalleryController galleryController =
      Get.put<GalleryController>(GalleryController());
  double _textScaleClamp(BuildContext context) {
    final t = MediaQuery.of(context).textScaleFactor;
    return t.clamp(0.9, 1.2);
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder<GalleryController>(builder: (controller) {
        return Scaffold(
          appBar: _searchBarWidget(context),

          body: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: Get.height,
                width:Get.width,
              decoration:const BoxDecoration(
                  image: DecorationImage(image: AssetImage(darkbg),fit: BoxFit.cover)
              ),
              ),
              TabBarView(
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
                                      onPressed: () async {
                                        final name = await showCreateFolderDialog();
                                        if (name != null) {
                                          toast( "Created  $name");
                                        }
                                      },
                                      icon: CustomContainer(
                                          color: perplebr,
                                          brcolor: Colors.white,
                                          sColor: perplebr,
                                          elevation: 10,
                                          vPadding: 4,
                                          radius: 30,
                                          hPadding: 20,
                                          childWidget: Row(
                                            children: [
                                              const Icon(Icons.add,
                                                  size: 20,
                                                  color: Colors.white),
                                              hGap(3),
                                              Text("Create new folder",style: BalooStyles.baloonormalTextStyle(color: Colors.white),)
                                            ],
                                          ))),
                                  IconButton(
                                      onPressed: () {
                                        showUploadOptions(context);
                                      },
                                      icon: CustomContainer(
                                          color: perplebr,
                                          brcolor: Colors.white,
                                          sColor: perplebr,
                                          elevation: 10,
                                          vPadding: 4,
                                          radius: 30,
                                          hPadding: 20,

                                          childWidget: Row(
                                            children: [
                                              SvgPicture.asset(uploadsvg,
                                                  color: Colors.white,height: 20,) ,
                                              hGap(3),
                                              Text("Upload",style: BalooStyles.baloonormalTextStyle(color: Colors.white),)
                                            ],
                                          )))
                                ],
                              ),

                            vGap(8),
                            (controller.folderList??[]).isNotEmpty ? Expanded(child: _listView()):_listView(),
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
            ],
          ),
        );
      }),
    );
  }

  AppBar _searchBarWidget(context) {
    return AppBar(
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      elevation: 0,
      flexibleSpace: MediaQuery(
        data: MediaQuery.of(Get.context!)
            .copyWith(textScaleFactor: _textScaleClamp(Get.context!)),
        child:  _flexibleSpace(),
      ),


      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60), child: Container(
        width: Get.width,
    decoration:const BoxDecoration(
    image: DecorationImage(image: AssetImage(appbarBG),fit: BoxFit.cover)
    ),
          child: _beautifiedTabBar(context))),
    );
  }


  _flexibleSpace(){
    return
      Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage(appbarBG),fit: BoxFit.cover)
        ),
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [

          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40,
                  child: CustomCacheNetworkImage(
                    "${ApiEnd.baseUrlMedia}${controller.myCompany?.logo ?? ''}",
                    radiusAll: 100,
                    height: 40,
                    width: 40,
                    borderColor: appColorYellow,
                    defaultImage: appIcon,
                    boxFit: BoxFit.cover,
                    isApp: true,
                  ),
                ).paddingAll(3),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Smart Gallery',
                        style: BalooStyles.baloomediumTextStyle(
                            size: 14),
                      ).paddingOnly(left: 4, top: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          CircleContainer(colorIS: Colors.greenAccent,setSize: 5.0,),
                          Text(
                            (controller.myCompany?.companyName ?? ''),
                            style: BalooStyles.baloomediumTextStyle(
                              color: appColorYellow,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ).paddingOnly(left: 4, top: 2),
                        ],
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),


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
              controller: controller.searchCtrl,
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
                      controller.isSearchingIcon = !controller.isSearchingIcon;
                      controller.searchCtrl.clear();
                      controller.searchResults?.clear();
                      controller.update();
                    },
                    child:controller.isSearchingIcon
                        ? const Icon(CupertinoIcons.clear,color: Colors.black45,)
                    // : Image.asset(searchPng, height: 25, width: 25))
                        : SvgPicture.asset(searchPng, height: 20, width: 20,color: Colors.black45,)).paddingOnly(left: 6)
                  ,prefixIconConstraints: const BoxConstraints(maxHeight: 20),
              ),

              autofocus: false,
              style: const TextStyle(fontSize: 13, letterSpacing: 0.5),
              onChanged: (val) {
                controller.query = val;
                controller.onSearchChanged(val);
                controller
                    .hitApiToGetSearchResultItems(controller.query.trim());
              },
            ).marginSymmetric(vertical: 0),
                  )

        ],
      ).marginOnly(right: 10),
    );
  }

  Widget _beautifiedTabBar(ctx) {
    final primary = whiteColor;
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
        labelColor: perplebr,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: BalooStyles.baloosemiBoldTextStyle(),
        unselectedLabelStyle: BalooStyles.balooregularTextStyle(),
        indicator: BoxDecoration(
            color: primary.withOpacity(.1),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: primary),
          // boxShadow: [BoxShadow(
          //   color: Colors.white,blurRadius: 4
          // )]
        ),
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
      padding: const EdgeInsets.only(right: 12, left: 12,),
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
                onOpenMedia: (media) async {
                  if (Get.isRegistered<GalleryController>()) {
                    await  Get.delete<GalleryController>( force: true);
                  }
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
                ):Center(child: SizedBox(
        height: Get.height*.4,
          child: DataNotFoundText(height: 150,)))),
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
                          // color: (i == breadcrumbs.length - 1
                          //     ? appColorPerple.withOpacity(0.12)
                          //     : theme.colorScheme.surfaceVariant
                          //         .withOpacity(0.6)),
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
        return RefreshIndicator(
            onRefresh: () async => controller.refreshGallery(),
            child: Container(
              height:kIsWeb &&Get.width>500? Get.height*.65:Get.height*.8,
              child: GridView.builder(
                padding:  const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                controller: controller.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:(kIsWeb&&Get.width>600)? cross:3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  childAspectRatio: (kIsWeb && Get.width>600)?1:1,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  if (i == items.length) {
                    return const IndicatorLoading();
                  }
                  final node = items[i];
                  return _GalleryTile(
                    folder: node,
                    onTap:() async {
                      if (Get.isRegistered<GalleryController>()) {
                       await Get.delete<GalleryController>( force: true);
                      }

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
    preview = Container(
      decoration:BoxDecoration(
        color: gallwhite.withOpacity(.1),
        // boxShadow: [BoxShadow(color:perplebr,blurRadius: 10)],
      ),
      child: SvgPicture.asset(
          folderpng,height: 40),
    ).paddingAll(12).marginOnly();
    // }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4,vertical: 4),
        decoration:BoxDecoration(
          gradient: LinearGradient(colors: [
            gallwhite,
            chatcardt,
          ]),

          boxShadow: [ BoxShadow(color:perplebr,blurRadius: 15)],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,

              children: [
                SizedBox(
                  height: 75,
                    child: preview),

                // Obx(() {
                // final isRenaming = controller.renamingId.value == node.id; // ✅ node must have unique id
                // if (!isRenaming) {
                /* return */
                Text(
                  folder.folderName ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: BalooStyles.balooregularTextStyle(),
                )

              ],
            ),

            Positioned(
              top: 4,
              right: 0,
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  height: 34,
                  width: 34,
                  child: PopupMenuButton<FolderMenuAction>(
                    tooltip: "More",
                    padding: EdgeInsets.zero,
                    position: PopupMenuPosition.under,
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    onSelected: (action) {
                      switch (action) {
                        case FolderMenuAction.rename:
                          toast("Under Development!");
                          break;
                        case FolderMenuAction.delete:
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
