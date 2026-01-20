import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_screen_controller.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../../../../../Services/APIs/api_ends.dart';
import '../../../../../../utils/save_image.dart';
import '../../../../../../utils/share_helper.dart';
import '../../../../models/chat_history_response_model.dart';
import '../Controllers/gallery_view_controller.dart';
import '../dialogs/save_in_gallery_dialog.dart';

class GalleryViewerPage extends GetView<GalleryViewerController> {
  GalleryViewerPage({super.key,required this.onReply,this.isChat=false});
  Function() onReply;
  bool isChat;
  final PageController _pageController =
  PageController(initialPage: Get.find<GalleryViewerController>().index);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GalleryViewerController>(
      builder: (c) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text('${c.index + 1}/${c.urls.length}'),
            actions: [
              IconButton(
                tooltip: 'Save image',
                onPressed: c.saving ? null :() async {
                  await saveImage(c.urls[c.index]);},
                icon: const Icon(Icons.download),
              ),
              PopupMenuButton<String>(
                color: Colors.grey.shade900,
                iconColor: Colors.black87,
                onSelected: (v) async {
                  if (v == 'save_all'){
                    for(String url in c.urls ){
                      await saveImage(url);
                    }
                  }

                  if(v == 'share_this'){
                    if(kIsWeb){
                      ShareHelper.shareOnWhatsApp(c.urls[c.index]);
                    }else{
                      await ShareHelper.shareNetworkFile(
                        "${ApiEnd.baseUrlMedia}${c.urls[c.index]}",
                        text: "From AccuChat",
                      );
                      // ShareHelper.shareNetworkImage(c.urls[c.index]);
                    }

                  }
                  if (v == 'save_one') {
                    await saveImage(c.urls[c.index]);}

                  if(v=="reply"){
                    final chatC = Get.find<ChatScreenController>();
                    chatC.refIdis = c.chathis.chatId;
                    chatC.userIDSender =
                        c.chathis.fromUser?.userId;
                    chatC.userNameReceiver =
                        c.chathis.toUser?.userCompany?.displayName ?? '';
                    chatC.userNameSender =
                        c.chathis.fromUser?.userCompany?.displayName ?? '';
                    chatC.userIDReceiver =
                        c.chathis.toUser?.userId;

                    chatC.replyToMessage=
                        ChatHisList(
                            chatId:c.chathis.chatId,
                            fromUser:c.chathis.fromUser,
                            toUser:c.chathis.toUser,
                            message:c.urls[c.index],
                            // message:getFileNameFromUrl(c.urls[c.index]),
                            replyToId:c.chathis.chatId,
                            replyToText:c.urls[c.index],
                          replyToMedia: c.urls[c.index],
                            // replyToT0ext:getFileNameFromUrl(c.urls[c.index]),
                        );

                    chatC.update();
                    c.update();
                    Get.back();
                  }


                  if(v== "save_accuchat_this"){
                    showDialog(
                        context: Get.context!,
                        builder: (_) => SaveToCustomFolderDialog(user: UserDataAPI(),));
                  }
                },
                itemBuilder: (ctx) {

                  final List<PopupMenuEntry<String>> items = [];

                  if(isChat){
                    items.add(const PopupMenuItem(
                      value: 'save_one',
                      child: Text('Save', style: TextStyle(color: Colors.white)),
                    ));
                  }else{
                    items.add( PopupMenuItem(
                      value: 'save_one',
                      child: Text('Save', style:  BalooStyles.baloonormalTextStyle(color: Colors.white)),
                    )); items.add( PopupMenuItem(
                      value: 'save_all',
                      child: Text('Save all', style: BalooStyles.baloonormalTextStyle(color: Colors.white)),
                    )); items.add( PopupMenuItem(
                      value: 'reply',
                      child: Text('Reply', style:  BalooStyles.baloonormalTextStyle(color: Colors.white)),
                    ));

                     items.add( PopupMenuItem(
                      value: 'share_this',
                      child: Text('Share on WhatsApp', style:  BalooStyles.baloonormalTextStyle(color: Colors.white)),
                    )); items.add( PopupMenuItem(
                      value: 'save_accuchat_this',
                      child: Text('Save to Smart Gallery', style:  BalooStyles.baloonormalTextStyle(color: Colors.white)),
                    ));
                  }

                  return items;


                  }
              ),
              vGap(4),
            ],
          ),
          body: _mainBody(),
        );
      },
    );
  }


  _mainBody(){
    return Stack(
      children: [
        PhotoViewGallery.builder(
          pageController: _pageController,
          itemCount: controller.urls.length,
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          builder: (context, index) {
            final url = controller.urls[index];
            return PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(url),
              heroAttributes: PhotoViewHeroAttributes(tag: url),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3.0,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Image.asset(appIcon, fit: BoxFit.contain),
              ),
            );
          },
          onPageChanged: (i) => controller.setIndex(i),
          loadingBuilder: (_, __) => const Center(
            child: CircularProgressIndicator(),
          ),
        ),

        // Small bottom toast for status
        if (controller.toast != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  controller.toast!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
