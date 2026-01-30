import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Chat/models/chat_history_response_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../Services/APIs/api_ends.dart';
import '../../../../../../utils/helper_widget.dart';
import '../../../../../../utils/networl_shimmer_image.dart';
import '../../../../../../utils/text_style.dart';
import '../../../../models/all_media_res_model.dart';
import '../Controllers/gallery_view_controller.dart';
import '../Controllers/view_profile_controller.dart';
import 'images_gallery_page.dart';

class ProfileMediaSectionGetX extends StatelessWidget {
  final String baseUrl; // e.g., ApiEnd.baseUrlMedia
  const ProfileMediaSectionGetX({super.key, required this.baseUrl});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ViewProfileController>();

    return
      DefaultTabController(
        length: 2,
        child: Builder(
          builder: (context) {
              final tabCtrl = DefaultTabController.of(context);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.attachTabController(tabCtrl);
              });

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:TabBar(
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color:appColorGreen)
                    ),
                    indicatorPadding: EdgeInsets.zero,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black54,
                    padding: EdgeInsets.zero,
                    tabs: const [
                      Tab(text: 'Photos & Videos'),
                      Tab(text: 'Documents'),
                    ],
                  )
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 400,
                  child: TabBarView(
                    children: [
                      Obx(() => _MediaGrid(
                        baseUrl: ApiEnd.baseUrlMedia,
                        onTapF: (){},
                        controller: controller,
                        items: controller.profileMediaList
                            .where((m) => isImageOrVideo(m))
                            .toList(),
                      )),

                      Obx(() => _DocsList(
                        baseUrl: ApiEnd.baseUrlMedia,
                        controller: controller,
                        items: controller.profileMediaList
                            .where((m) => isDoc(m))
                            .toList(),
                      )),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      )
    ;
  }
}


class _MediaGrid extends StatelessWidget {
  final String baseUrl;
  final List<Items> items;
  final Function() onTapF;
  final ViewProfileController controller;
  const _MediaGrid({required this.baseUrl, required this.items,required this.controller, required this.onTapF});

  int _columnsForWidth(double w) {
    // tweak breakpoints as you like
    if (w < 480) return 3;        // phones
    if (w < 720) return 4;        // small tablets
    if (w < 1024) return 5;       // large tablets
    if (w < 1440) return 6;       // small desktops
    if (w < 1920) return 8;       // desktops
    return 10;                    // big screens/4K
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text('No media found', style: BalooStyles.baloonormalTextStyle()));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = _columnsForWidth(constraints.maxWidth);

        // remove glow + use platform-appropriate physics (bouncing on mobile, clamping on web)
        return GridView.builder(
          physics: kIsWeb ? const ClampingScrollPhysics() : const BouncingScrollPhysics(),
          controller: controller.scrollController,
          padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8, top: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1, // keep squares; adjust if you want cards
          ),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final m = items[i];
            final url = '$baseUrl${m.fileName ?? ''}';
            return InkWell(
              onTap: (){
                Get.to(
                      () => GalleryViewerPage(
                    isChat: true,
                    onReply: (){

                      Get.back();
                      // controller.refIdis = data.chatId;
                      // controller.userIDSender =
                      //     data.fromUser?.userId;
                      // controller.userNameReceiver =
                      //     data.toUser?.displayName ?? '';
                      // controller.userNameSender =
                      //     data.fromUser?.displayName ?? '';
                      // controller.userIDReceiver =
                      //     data.toUser?.userId;
                      // controller.replyToMessage =data;
                    },),
                  binding: BindingsBuilder(() {
                    Get.put(GalleryViewerController(
                        urls: items.map((v)=>"${ApiEnd.baseUrlMedia}${v.fileName}").toList()
                        , index: i,
                        chathis: ChatHisList()));
                  }),
                  fullscreenDialog: true,
                  transition: Transition.fadeIn,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color:greyColor, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: CustomCacheNetworkImage(
                  url,
                  height: double.infinity,
                  width: double.infinity,
                  borderWidth: 3,
                  boxFit: BoxFit.cover,
                  borderColor: Colors.red,
                  radiusAll: 8,
                ),
              ),
            );
          },
        );
      },
    );
  }
}


/*class _MediaGrid extends StatelessWidget {
  final String baseUrl;
  final List<Items> items;
  final Function() onTapF;
  final ViewProfileController controller;
  const _MediaGrid({required this.baseUrl, required this.items,required this.controller, required this.onTapF});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text('No media found', style: BalooStyles.baloonormalTextStyle()));
    }
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      controller: controller.scrollController,
      padding: const EdgeInsets.only(bottom: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final m = items[i];
        final url = '$baseUrl${m.fileName ?? ''}';
        return InkWell(
          onTap: (){
            Get.to(
                  () => GalleryViewerPage(
                    isChat: true,
                    onReply: (){

                Get.back();
                // controller.refIdis = data.chatId;
                // controller.userIDSender =
                //     data.fromUser?.userId;
                // controller.userNameReceiver =
                //     data.toUser?.displayName ?? '';
                // controller.userNameSender =
                //     data.fromUser?.displayName ?? '';
                // controller.userIDReceiver =
                //     data.toUser?.userId;
                // controller.replyToMessage =data;
              },),
              binding: BindingsBuilder(() {
                Get.put(GalleryViewerController(
                    urls: controller.profileMediaList.map((v)=>"${ApiEnd.baseUrlMedia}${v.fileName??''}").toList(), index: i,
                    chathis: ChatHisList()));
              }),
              fullscreenDialog: true,
              transition: Transition.fadeIn,
            );
          },
          child: CustomCacheNetworkImage(
            url,
            height: double.infinity,
            width: double.infinity,
            borderWidth: 3,
            boxFit: BoxFit.cover,
            borderColor: Colors.red,
            radiusAll: 8,
          ),
        );
      },
    );
  }
}*/

class _DocsList extends StatelessWidget {
  final String baseUrl;
  final List<Items> items;
  final ViewProfileController controller;
  const _DocsList({required this.baseUrl, required this.items,required this.controller});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text('No documents found', style: BalooStyles.baloonormalTextStyle()));
    }
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      controller: controller.scrollController2,
      separatorBuilder: (_, __) => Divider(color: Colors.grey.shade300, height: 1),
      itemBuilder: (_, i) {
        final d = items[i];
        final url = '$baseUrl${d.fileName ?? ''}';
        final name = (d.fileName ?? '').split('/').last;
        final ext = name.split('.').last.toUpperCase();
        final orgName = d.orgFileName??'';
        return ListTile(
          leading: const Icon(Icons.insert_drive_file_outlined),
          title: Text(orgName, maxLines: 1, overflow: TextOverflow.ellipsis, style: BalooStyles.baloonormalTextStyle()),
          subtitle: Text((d.mediaType?.name ?? 'Document') + (d.source != null ? ' · ${d.source}' : ''),
            style: BalooStyles.baloonormalTextStyle(size: 12, color: Colors.black54),
          ),
          trailing: const Icon(Icons.open_in_new),
          onTap: () { openDocumentFromUrl(url);},
        );
      },
    );
  }
}
