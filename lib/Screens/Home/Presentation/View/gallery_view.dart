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
import '../../../../utils/hover_glass_effect_widget.dart';
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
          appBar:kIsWeb? _searchBarWidget(context):_searchBarWidgetMob(context),

          body: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: Get.height,
                width:Get.width,
              decoration:const BoxDecoration(
                  image: DecorationImage(image: AssetImage(darkbg),fit: BoxFit.cover,opacity: .5)
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
                                mainAxisAlignment:kIsWeb? MainAxisAlignment.end: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Expanded(
                                  //   child: _GalleryHeader(
                                  //     isRoot: true,
                                  //     breadcrumbs:[],
                                  //     onBack:(){return true;},
                                  //     onRootTap: (){},
                                  //     onCrumbTap: (v){},
                                  //   ),
                                  // ),
                                  InkWell(
                                      onTap: () async {
                                        final name = await showCreateFolderDialog();
                                        if (name != null) {
                                          toast( "Created  $name");
                                        }
                                      },
                                      child:HoverGlassEffect(
                                        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                        borderRadius: 12,
                                        hoverScale: 1.05,
                                        normalBlur: 3,
                                        hoverBlur: 10,
                                        child: CustomContainer(
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
                                            )),
                                      )),
                                  InkWell(
                                      onTap: () {
                                        showUploadOptions(context);
                                      },
                                      child:HoverGlassEffect(
                                        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                        borderRadius: 12,
                                        hoverScale: 1.05,
                                        normalBlur: 3,
                                        hoverBlur: 10,
                                        child: CustomContainer(
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
                                            )),
                                      ))
                                ],
                              ).marginSymmetric(horizontal: 10),

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
            ],
          ),
        );
      }),
    );
  }
  AppBar _searchBarWidgetMob(context) {
    return AppBar(
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: MediaQuery(
        data: MediaQuery.of(Get.context!)
            .copyWith(textScaleFactor: _textScaleClamp(Get.context!)),
        child:  _flexibleSpaceMob(),
      ),


      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60), child: Container(
          decoration:const BoxDecoration(
              image: DecorationImage(image: AssetImage(appbarBG),fit: BoxFit.cover)
          ),
          child: _beautifiedTabBar(context))),
      actions: [
        IconButton(
            onPressed: () {
              controller.isSearchingIcon = !controller.isSearchingIcon;
              controller.searchCtrl.clear();
              controller.searchResults?.clear();
              controller.update();
            },
            icon:GradientContainer(
              color1: greenside,
                color2: greenside.withOpacity(.4),
                child:  controller.isSearchingIcon
                ? const Icon(CupertinoIcons.clear_circled_solid)
            // : Image.asset(searchPng, height: 25, width: 25))
                : SvgPicture.asset(searchPng, height: 20, width: 20,color: Colors.white,)))
            .paddingOnly(top: 0, right: 10),
      ],
    );
  }


  _flexibleSpaceMob(){
    return
      Container(
        width: Get.width*.7,
        constraints: BoxConstraints(minHeight: 64,maxWidth: Get.width*.7),
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage(appbarBG),fit: BoxFit.cover)
        ),
        child: controller.isSearchingIcon
            ? TextField(
                      controller: controller.searchCtrl,
                      cursorColor: perplebr,
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
                    ).marginSymmetric(vertical: 10,horizontal: 15)
            :  Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              margin: EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,boxShadow: [
                BoxShadow(color: greenside.withOpacity(.5),blurRadius: 5)
              ]
              ),
              child:  controller.myCompany?.logo!=null? CustomCacheNetworkImage(
                "${ApiEnd.baseUrlMedia}${controller.myCompany?.logo ?? ''}",
                radiusAll: 100,
                height: 40,
                width: 40,
                borderColor: appColorYellow,
                defaultImage: appIcon,
                boxFit: BoxFit.cover,
                isApp: true,
              ):CircleAvatar(
                // radius: 45,
                backgroundColor: Colors.white,
                child: Text(getInitials(controller.myCompany?.companyName ?? ''),style: BalooStyles.baloosemiBoldTextStyle(color: greenside,size: 20),),
              ),            ).paddingAll(3),
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
      );
  }
























  AppBar _searchBarWidget(context) {
    return AppBar(
      backgroundColor: recentBg,
      elevation: 10,
      scrolledUnderElevation: 0,
      surfaceTintColor:recentBg,
      automaticallyImplyLeading: false,
      flexibleSpace: _flexibleSpace(),


      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60), child: Container(
        width: Get.width,
    alignment: Alignment.centerLeft,
    decoration: BoxDecoration(
      color:recentBg
    // image: DecorationImage(image: AssetImage(appbarBG),fit: BoxFit.cover)
    ),
          child: _beautifiedTabBar(context))),
    );
  }


  _flexibleSpace(){
    return
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.shade300,blurRadius: 10)]
        ),
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  child: controller.myCompany?.logo!=null? CustomCacheNetworkImage(
                    "${ApiEnd.baseUrlMedia}${controller.myCompany?.logo ?? ''}",
                    radiusAll: 100,
                    height: 40,
                    width: 40,
                    borderColor: appColorYellow,
                    defaultImage: appIcon,
                    boxFit: BoxFit.cover,
                    isApp: true,
                  ):CircleAvatar(
                    // radius: 45,
                    backgroundColor: Colors.white,
                    child: Text(getInitials(controller.myCompany?.companyName ?? ''),style: BalooStyles.baloosemiBoldTextStyle(color: greenside,size: 20),),
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
    final items = controller.searchResults;
    return Container(
      padding: const EdgeInsets.only(right:kIsWeb? 12:3, left:kIsWeb? 12:1,),
      child: controller.isSearching
          ? GalleryGlobalSearchResults(
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
              )
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
        bool isWide = constraints.maxWidth > 600;
        return RefreshIndicator(
            onRefresh: () async => controller.refreshGallery(),
            child: Container(
              height:isWide ? Get.height*.65:Get.height*.7,
              child: GridView.builder(
                padding:  const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                controller: controller.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:isWide? cross:3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: isWide?0.9:.9,
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
      child: HoverGlassEffect(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        borderRadius: 12,
        hoverScale: 1.04,
        normalBlur: 3,
        hoverBlur: 5,
        borderColor: Colors.white.withOpacity(.1),
        hoverBorderColor: Colors.grey.withOpacity(.3),
        hoverGradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 1.2,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.2),
          ],
        ),
        gradient:  LinearGradient(
          colors: [
          gallwhite,
          whiteselected,
        ]
        ),
        // hoverShadow: [ BoxShadow(color:perplebr.withOpacity(.5),blurRadius: 10)],
        // borderColor: greenside.withOpacity(.1),
        // hoverBorderColor:greenside.withOpacity(.55)

        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4,vertical: 4),
          // decoration:BoxDecoration(
          //   gradient: LinearGradient(colors: [
          //     gallwhite,
          //     whiteselected,
          //   ]),
          //
          //   boxShadow: [ BoxShadow(color:perplebr.withOpacity(.5),blurRadius: 10)],
          //   borderRadius: BorderRadius.circular(12),
          // ),
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
