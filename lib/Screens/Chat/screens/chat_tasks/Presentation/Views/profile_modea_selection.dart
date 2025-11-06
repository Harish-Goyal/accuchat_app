import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Chat/models/chat_history_response_model.dart';
import 'package:flutter/cupertino.dart';
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

    return // Inside your ViewProfileScreen build (after About section)
      DefaultTabController(
        length: 2,
        child: Builder(
          builder: (context) {
            // hook the TabController to GetX controller (once)

              final tabCtrl = DefaultTabController.of(context);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.attachTabController(tabCtrl);
              });


            return Column(
              children: [
                // your header + chips (optional source filter using controller.sourceFilter)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
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
                    tabs: [
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
                      // MEDIA GRID (uses controller.profileMediaList)
                      Obx(() => _MediaGrid(
                        baseUrl: ApiEnd.baseUrlMedia,
                        onTapF: (){},
                        controller: controller,
                        items: controller.profileMediaList
                            .where((m) => controller.isImageOrVideo(m)) // if _isImageOrVideo is private, duplicate logic here
                            .toList(),
                      )),

                      // DOC LIST
                      Obx(() => _DocsList(
                        baseUrl: ApiEnd.baseUrlMedia,
                        items: controller.profileMediaList
                            .where((m) => controller.isDoc(m))
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

  Widget _mediaGrid(List<Items> media) {
    if (media.isEmpty) {
      return Center(child: Text('No media found', style: BalooStyles.baloonormalTextStyle()));
    }
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4,
      ),
      itemCount: media.length,
      itemBuilder: (context, i) {
        final m = media[i];
        final url = '$baseUrl${m.fileName ?? ''}';
        return GestureDetector(
          onTap: () {
            // Get.toNamed(AppRoutes.media_viewer, arguments: {'url': url, 'item': m});
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomCacheNetworkImage(
              url,
              height: double.infinity,
              width: double.infinity,
              boxFit: BoxFit.cover,
              radiusAll: 0,
            ),
          ),
        );
      },
    );
  }

  Widget _docsList(List<Items> docs) {
    if (docs.isEmpty) {
      return Center(child: Text('No documents found', style: BalooStyles.baloonormalTextStyle()));
    }
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: docs.length,
      separatorBuilder: (_, __) => Divider(color: Colors.grey.shade300, height: 1),
      itemBuilder: (context, i) {
        final d = docs[i];
        final url = '$baseUrl${d.fileName ?? ''}';
        final name = (d.fileName ?? '').split('/').last;
        final ext = name.split('.').last.toUpperCase();
        final icon = _docIcon(ext);

        return ListTile(
          leading: Container(
            width: 42, height: 42, alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: Colors.black87, size: 22),
          ),
          title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: BalooStyles.baloonormalTextStyle()),
          subtitle: Text(
            (d.mediaType?.name ?? 'Document') + (d.source != null ? ' · ${d.source}' : ''),
            style: BalooStyles.baloonormalTextStyle(size: 12, color: Colors.black54),
          ),
          trailing: const Icon(Icons.open_in_new),
          onTap: () async {
            // url_launcher or in-app viewer
            // await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          },
        );
      },
    );
  }

  IconData _docIcon(String ext) {
    switch (ext) {
      case 'PDF': return Icons.picture_as_pdf;
      case 'XLS':
      case 'XLSX': return Icons.grid_on;
      case 'DOC':
      case 'DOCX': return Icons.description_outlined;
      case 'PPT':
      case 'PPTX': return Icons.slideshow;
      case 'CSV': return Icons.table_chart_outlined;
      default: return Icons.insert_drive_file_outlined;
    }
  }
}


class _MediaGrid extends StatelessWidget {
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomCacheNetworkImage(
              url,
              height: double.infinity,
              width: double.infinity,
              boxFit: BoxFit.cover,
              radiusAll: 0,
            ),
          ),
        );
      },
    );
  }
}

class _DocsList extends StatelessWidget {
  final String baseUrl;
  final List<Items> items;
  const _DocsList({required this.baseUrl, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text('No documents found', style: BalooStyles.baloonormalTextStyle()));
    }
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => Divider(color: Colors.grey.shade300, height: 1),
      itemBuilder: (_, i) {
        final d = items[i];
        final url = '$baseUrl${d.fileName ?? ''}';
        final name = (d.fileName ?? '').split('/').last;
        final ext = name.split('.').last.toUpperCase();
        return ListTile(
          leading: const Icon(Icons.insert_drive_file_outlined),
          title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: BalooStyles.baloonormalTextStyle()),
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
