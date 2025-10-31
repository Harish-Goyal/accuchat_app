import 'dart:async';
import 'dart:math' as math;
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/Screens/Chat/models/chat_history_response_model.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_home_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_screen_controller.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/custom_container.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // ✅ added: detect web
import 'package:flutter/gestures.dart'; // ✅ added: better web scrolling
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../../../Constants/app_theme.dart';
import '../../../../../../Constants/assets.dart';
import '../../../../../../Constants/colors.dart';
import '../../../../../../utils/common_textfield.dart';
import '../../../../../../utils/custom_dialogue.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../../utils/gradient_button.dart';
import '../../../../../../utils/product_shimmer_widget.dart';
import '../../../../../../utils/text_style.dart';
import '../../../../../Home/Presentation/Controller/socket_controller.dart';
import '../Widgets/reply_msg_widget.dart';
import '../Widgets/staggered_view.dart';
import '../../../../api/apis.dart';
import '../Controllers/gallery_view_controller.dart';
import '../Widgets/media_view.dart';
import 'images_gallery_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// -------------------------
/// Responsive helpers (added)
/// -------------------------
class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}

double _maxChatWidth(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  if (!kIsWeb) return double.infinity;
  // keep chat column pleasant on desktops
  if (w >= 1600) return 1600;
  if (w >= 1366) return 1300;
  if (w >= 1200) return 1200;
  return 900;
}

EdgeInsets _shellHPadding(BuildContext context) {
  if (!kIsWeb) return EdgeInsets.zero;
  final w = MediaQuery.of(context).size.width;
  if (w >= 1600) return const EdgeInsets.symmetric(horizontal: 24);
  if (w >= 1366) return const EdgeInsets.symmetric(horizontal: 20);
  if (w >= 1200) return const EdgeInsets.symmetric(horizontal: 16);
  return const EdgeInsets.symmetric(horizontal: 12);
}

double _avatarSize(BuildContext context) {
  final h = MediaQuery.of(context).size.height;
  if (!kIsWeb) return h * .05;
  return h.clamp(600, 1200) * .05; // scale safely on web heights
}

double _textScaleClamp(BuildContext context) {
  final t = MediaQuery.of(context).textScaleFactor;
  // prevent giant scaling on browser zoom
  return t.clamp(0.9, 1.2);
}

class ChatScreen extends GetView<ChatScreenController> {
  ChatScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatScreenController>(builder: (controller) {
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: WillPopScope(
            //if emojis are shown & back button is pressed then hide emojis
            //or else simple close current screen on back button click
            onWillPop: () {
              Get.find<ChatHomeController>().hitAPIToGetRecentChats();
              return Future.value(true);
            },
            child: SafeArea(
              child: Scaffold(
                //app bar
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  automaticallyImplyLeading: false,
                  flexibleSpace: MediaQuery( // ✅ clamp text scale for web
                    data: MediaQuery.of(context).copyWith(textScaleFactor: _textScaleClamp(context)),
                    child: _appBar(),
                  ),
                ),

                backgroundColor: const Color.fromARGB(255, 234, 248, 255),

                //body
                body: ScrollConfiguration( // ✅ nicer scrolling on web + no glow
                  behavior: const _NoGlowScrollBehavior(),
                  child: Center( // ✅ center content on wide screens
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: _maxChatWidth(context)),
                      child: Padding(
                        padding: _shellHPadding(context),
                        child: Column(
                          children: [

                            Expanded(child: RepaintBoundary(child: chatMessageBuilder())),
                            //chat input filed
                            //TODO
                            if (controller.replyToMessage != null)
                              Container(
                                padding: const EdgeInsets.all(8),
                                margin:
                                const EdgeInsets.only(bottom: 4, left: 8, right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white54,
                                  border: Border.all(color: appColorGreen, width: .4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.reply, color: appColorGreen),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: /*
                                        (controller.replyToMessage!.media.isNotEmpty)? Text(
                                          "${controller.replyToMessage!.originalSenderName}: ${extractFileNameFromUrl(controller.replyToMessage?.msg??'')}",
                                          style: themeData.textTheme.bodySmall?.copyWith(
                                            color:  getTaskStatusColor(
                                                controller.replyToMessage!.taskDetails?.taskStatus)
                                                .withOpacity(.2),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ):(controller.replyToMessage!.type == Type.doc)? Text(
                                          "${controller.replyToMessage!.originalSenderName}: ${extractFileNameFromUrl(controller.replyToMessage?.msg??'')}",
                                          style: themeData.textTheme.bodySmall?.copyWith(
                                            color:  getTaskStatusColor(
                                                controller.replyToMessage!.taskDetails?.taskStatus)
                                                .withOpacity(.2),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ):(controller.replyToMessage!.type == Type.text)?*/
                                      Text(
                                        "${controller.replyToMessage?.fromUser?.userId == controller.me?.userId ? 'You' : controller.user?.displayName ?? ''}: ${controller.replyToMessage?.message ?? ''}",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: themeData.textTheme.bodySmall
                                            ?.copyWith(color: greyText),
                                      ) /*:SizedBox()*/,
                                    ),
                                    IconButton(
                                        icon:  const Icon(
                                          Icons.close,
                                          color: blueColor,
                                        ),
                                        onPressed: () {
                                          controller.replyToMessage = null;
                                          controller.update();
                                        }),
                                  ],
                                ),
                              ),
                            if (controller.isUploading)
                              const Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 20),
                                      child:
                                      CircularProgressIndicator(strokeWidth: 2))),

                            (controller.uploadProgress > 0 &&
                                controller.uploadProgress < 100)
                                ? Column(
                              children: [
                                LinearProgressIndicator(
                                  value: controller.uploadProgress /
                                      100, // 0.0 → 1.0
                                  backgroundColor: Colors.grey[300],
                                  color: Colors.blue,
                                  minHeight: 6,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                    "${controller.uploadProgress.toStringAsFixed(0)}%"),
                              ],
                            )
                                : const SizedBox.shrink(),

                            _chatInput(),
                            //show emojis on keyboard emoji button click & vice versa
                            // if (_showEmoji)
                            // SizedBox(
                            //   height: mq.height * .35,
                            //   child: EmojiPicker(
                            //     textEditingController: _textController,
                            //     config: Config(
                            //       bgColor: const Color.fromARGB(255, 234, 248, 255),
                            //       columns: 8,
                            //       emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                            //     ),
                            //   ),
                            // )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget chatMessageBuilder() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        vGap(10),

        Expanded(
          child: shimmerEffectWidget(
            showShimmer: controller.showPostShimmer,
            shimmerWidget: shimmerlistView(
                child: ChatHistoryShimmer(
                  chatData: ChatHisList(),
                )),
            child: AnimationLimiter(child: groupListView()),
          ),
        ),
        // vGap(80)
      ],
    );
  }

  groupListView() {
    return controller.chatCatygory.isNotEmpty
        ? GroupedListView<GroupChatElement, DateTime>(
        shrinkWrap: false,
        padding: const EdgeInsets.only(bottom: 30),
        controller: controller.scrollController,
        elements: controller.chatCatygory,
        order: GroupedListOrder.DESC,
        reverse: true,
        floatingHeader: true,
        useStickyGroupSeparators: true,
        groupBy: (GroupChatElement element) => DateTime(
          element.date.year,
          element.date.month,
          element.date.day,
        ),
        groupHeaderBuilder: _createGroupHeader,
        indexedItemBuilder:
            (BuildContext context, GroupChatElement element, int index) {
          String formatatedTime = '';
          if (element.chatMessageItems.sentOn != null) {
            var timeString = element.chatMessageItems.sentOn ?? '';

            formatatedTime = convertUtcToIndianTime(timeString);
          }

          var userid = controller.me?.userId;
          return StaggeredAnimationListItem(
            index: index,
            child: SwipeTo(
              onRightSwipe: (detail) {
                if(element.chatMessageItems.isActivity == 1 ||(element.chatMessageItems.media??[]).isNotEmpty ){

                }else{
                  // Set the message being replied to
                  controller.refIdis = element.chatMessageItems.chatId;
                  controller.userIDSender =
                      element.chatMessageItems.fromUser?.userId;
                  controller.userNameReceiver =
                      element.chatMessageItems.toUser?.displayName ?? '';
                  controller.userNameSender =
                      element.chatMessageItems.fromUser?.displayName ?? '';
                  controller.userIDReceiver =
                      element.chatMessageItems.toUser?.userId;
                  controller.replyToMessage = element.chatMessageItems;
                  controller.update();
                }

              },
              child: _chatMessageTile(
                  data: element.chatMessageItems,
                  sentByMe: (userid
                      ?.toString() ==
                      element.chatMessageItems.fromUser?.userId
                          ?.toString()
                      ? true
                      : false),
                  formatedTime: formatatedTime),
            ),
          );
        })
        : const Center(
        child: Text('Say Hii! 👋', style: TextStyle(fontSize: 20)));
  }

  Widget _createGroupHeader(GroupChatElement element) {
    return Container(
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(child: divider(color: appColorGreen.withOpacity(.3))),
          CustomContainer(
            elevation: 2,
              vPadding: 3,
              hPadding: 7,
              color: AppTheme.whiteColor.withOpacity(.6),
              childWidget: Text(DateFormat.yMMMd().format(element.date),
              style: BalooStyles.balooregularTextStyle(),),
          ),
          Expanded(child: divider(color: appColorGreen.withOpacity(.3))),
        ],
      ),
    );
  }

  Widget _chatMessageTile(
      {required ChatHisList data, required bool sentByMe, formatedTime}) {
    return data.isActivity == 1
        ? Center(
      child: CustomContainer(
          elevation: 0,
          vPadding: 4,
          hPadding: 8,
          color: appColorGreen.withOpacity(.1),
          childWidget:
          Text((data.message ?? '').capitalizeFirst ?? '',
              textAlign: TextAlign.start,
              style: BalooStyles.baloothinTextStyle(
                color: Colors.black54,
                size: 13,
              ),
              overflow: TextOverflow.visible))
          .marginSymmetric(horizontal: 5, vertical: 4),
    )
        :  Column(
        crossAxisAlignment:
        sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [

          data.replyToId != null
              ? ReplyMessageWidget(
              isCancel: false,
              sentByMe: sentByMe,
              empIdsender: data.fromUser?.userId.toString(),
              chatdata: data,
              empIdreceiver: data.toUser?.userId.toString(),
              empName:data.isGroupChat ==1
                  ? data.fromUser?.displayName ?? ''
                  : data.fromUser?.userId.toString() ==
                  controller.me?.userId?.toString()
                  ? data.fromUser?.displayName ?? ''
                  : data.toUser?.displayName ?? '',
              message: data.replyToText ?? '')
              .marginOnly(top: 8, bottom: 0)
              : const SizedBox(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              (data.message != null &&
                  (data.media ?? []).isNotEmpty &&
                  sentByMe)
                  ? IconButton(
                  onPressed: () {
                    controller.handleForward(chatId: data.chatId);
                  },
                  icon: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationX(math.pi),
                      child: Image.asset(
                        forwardIcon,
                        height: 25,
                      ))).paddingOnly(left: 10)
                  : const SizedBox(),
              Expanded(
                child:InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  mouseCursor: SystemMouseCursors.click,
                  onLongPress: () {
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                    if (!isTaskMode) {
                      _showBottomSheet(sentByMe, data: data);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: sentByMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        // alignment: sentByMe
                        //     ? Alignment.centerRight
                        //     : Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(
                          horizontal:
                          (data.media ?? []).isNotEmpty ? 16 : 15,
                          vertical:
                          (data.media ?? []).isNotEmpty ? 0 : 15,
                        ),
                        margin: sentByMe
                            ? const EdgeInsets.only(left: 15, top: 10,right: 15)
                            : const EdgeInsets.only(right: 15, top: 10,left: 15),

                        decoration: BoxDecoration(
                            color: /* widget.isTask
                                          ? getTaskStatusColor(widget.message.taskDetails?.taskStatus)
                                          .withOpacity(.1)
                                          : */

                            sentByMe
                                ? appColorGreen.withOpacity(.1)
                                : appColorPerple.withOpacity(.1),
                            border: Border.all(
                                color: /*widget.isTask
                                              ? getTaskStatusColor(widget
                                              .message.taskDetails?.taskStatus)
                                              :*/
                                sentByMe
                                    ? appColorGreen
                                    : appColorPerple),
                            //making borders curved
                            borderRadius: sentByMe
                                ? BorderRadius.only(
                                topLeft: Radius.circular(
                                    (data.media ?? []).isNotEmpty
                                        ? 15
                                        : 30),
                                topRight: Radius.circular(
                                    (data.media ?? []).isNotEmpty
                                        ? 15
                                        : 30),
                                bottomLeft: Radius.circular(
                                    (data.media ?? []).isNotEmpty
                                        ? 15
                                        : 30))
                                : BorderRadius.only(
                                topLeft: Radius.circular(
                                    (data.media ?? []).isNotEmpty ? 15 : 30),
                                topRight: Radius.circular((data.media ?? []).isNotEmpty ? 15 : 30),
                                bottomRight: Radius.circular((data.media ?? []).isNotEmpty ? 15 : 30))),
                        child: messageTypeView(data, sentByMe: sentByMe),
                      ).marginOnly(left: (0), top: 0),
                    ],
                  ),
                ),
              ),
              (data.message != null &&
                  (data.media ?? []).isNotEmpty &&
                  !sentByMe)
                  ? IconButton(
                  onPressed: () {
                    controller.handleForward(chatId: data.chatId);
                  },
                  icon: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: Image.asset(
                        forwardIcon,
                        height: 25,
                      ))).paddingOnly(right: 10)
                  : const SizedBox()
            ],
          ),
          vGap(3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatedTime ?? '',
                textAlign: TextAlign.start,
                style: BalooStyles.baloonormalTextStyle(
                    color: Colors.grey, size: 13),
              ),
              hGap(5),
              sentByMe?Icon(
                data.readOn != null ? Icons.done_all : Icons.done,
                size: 14,
                color: data.readOn != null ? Colors.blue : Colors.grey,
              ):const SizedBox()
            ],
          ).marginOnly(left: 15, right: 15),
        ],
      )
    ;
  }

  messageTypeView(ChatHisList data, {required bool sentByMe}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        controller.user?.userCompany?.isGroup == 1
            ? Text(
            sentByMe
                ? (data.fromUser?.displayName != null
                ? data.fromUser?.displayName ?? ''
                : data.fromUser?.phone ?? '')
                : (data.fromUser?.displayName != null
                ? data.fromUser?.displayName ?? ''
                : data.fromUser?.phone ?? ''),
            textAlign: TextAlign.start,
            style: BalooStyles.baloothinTextStyle(
              color: Colors.black54,
              size: 13,
            ),
            overflow: TextOverflow.visible)
            .marginOnly(
            left: sentByMe ? 0 : 0,
            right: sentByMe ? 10 : 0,
            bottom: 3)
            : const SizedBox(),

        data.isForwarded == 1
            ? Text("Forwarded",
            textAlign: TextAlign.start,
            style: BalooStyles.baloonormalTextStyle(
                color: Colors.grey,
                size: 13,
                fontstyle: FontStyle.italic),
            overflow: TextOverflow.visible)
            .marginOnly(
          left: sentByMe ? 0 : 10,
          right: sentByMe ? 10 : 0,
        )
            : const SizedBox(),
        data.message != '' || data.message != null
            ? Text(data.message ?? '',
            textAlign: TextAlign.start,
            style: BalooStyles.baloonormalTextStyle(
              color: Colors.black87,
              size: 15,
            ),
            overflow: TextOverflow.visible)
            : const SizedBox(),
        ((data.media ?? []).isNotEmpty)
            ? ChatMessageMedia(
          chat: data,
          isGroupMessage: data.isGroupChat==1?true:false,
          myId: (controller.me?.userId ?? 0).toString(),
          fromId: (data.fromUser?.userId ?? 0).toString(),
          senderName: data.fromUser?.displayName ?? '',
          baseUrl: ApiEnd.baseUrlMedia,
          defaultGallery: defaultGallery,
          onOpenDocument: (url) =>
              openDocumentFromUrl(url), // your existing function
          onOpenImageViewer: (mediaurls, startIndex) {
            // push your gallery view
            // Get.to(() => ImageViewer(urls: urls, initialIndex: startIndex));
            Get.to(
                  () => GalleryViewerPage(onReply: (){
                    Get.back();
                    controller.refIdis = data.chatId;
                    controller.userIDSender =
                        data.fromUser?.userId;
                    controller.userNameReceiver =
                        data.toUser?.displayName ?? '';
                    controller.userNameSender =
                        data.fromUser?.displayName ?? '';
                    controller.userIDReceiver =
                        data.toUser?.userId;
                    controller.replyToMessage =data;
                  },),
              binding: BindingsBuilder(() {
                Get.put(GalleryViewerController(
                    urls: mediaurls, index: startIndex,
                chathis: data));
              }),
              fullscreenDialog: true,
              transition: Transition.fadeIn,
            );
          },
          onOpenVideo: (url) {
            // open video player route/sheet if available
          },
          onOpenAudio: (url) {
            // open audio player route/sheet if available
          },
        )
            : const SizedBox(),
      ],
    );
  }

  // app bar widget
  Widget _appBar() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              if (!(controller.user?.userCompany?.isGroup == 1 ||
                  controller.user?.userCompany?.isBroadcast == 1)) {

                if(kIsWeb){
                  Get.toNamed(
                    "${AppRoutes.view_profile}?userId=${controller.user?.userId.toString()}",
                  );
                }
                else{
                  Get.toNamed(AppRoutes.view_profile,
                      arguments: {'user': controller.user});
                }
              } else {
                if(kIsWeb){
                  Get.toNamed(
                    "${AppRoutes.member_sr}?userId=${controller.user?.userId.toString()}",
                  );
                }
                else{
                  Get.toNamed(AppRoutes.member_sr,
                      arguments: {'user': controller.user});
                }


              }
              // APIs.updateActiveStatus(false);
            },
            child: Row(
              children: [
                //back button
                IconButton(
                    onPressed: () {
                      Get.back();
                      Get.find<ChatHomeController>().hitAPIToGetRecentChats();
                      if (isTaskMode) {
                        Get.find<DashboardController>().updateIndex(1);
                      } else {
                        Get.find<DashboardController>().updateIndex(0);
                      }

                      // APIs.updateActiveStatus(false);
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.black54)),

                CustomCacheNetworkImage(
                  radiusAll: 100,
                  "${ApiEnd.baseUrlMedia}${controller.user?.userImage ?? ''}",
                  height: _avatarSize(Get.context!), // ✅ responsive avatar
                  width: _avatarSize(Get.context!),
                  boxFit: BoxFit.cover,
                  defaultImage: controller.user?.userCompany?.isGroup == 1
                      ? groupIcn
                      : controller.user?.userCompany?.isBroadcast == 1
                      ? broadcastIcon
                      : ICON_profile,
                ),

                //for adding some space
                const SizedBox(width: 10),

                //user name & last seen time
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //user name
                    (controller.user?.userCompany?.isGroup==1|| controller.user?.userCompany?.isBroadcast==1)? Text(
                       (controller.user?.userName==''||controller.user?.userName==null)?controller.user?.phone??'':controller.user?.userName??'',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: themeData.textTheme.titleMedium,
                    ):

                    Text(
                      (controller.user?.displayName==''||controller.user?.displayName==null)?controller.user?.phone??'':controller.user?.displayName??'',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: themeData.textTheme.titleMedium,
                    ),
                    controller.user?.userCompany?.isGroup == 1 ||
                        controller.user?.userCompany?.isBroadcast == 1
                        ? Text('${controller.members.length} members',
                        style: BalooStyles.baloonormalTextStyle())
                        : const SizedBox(),

                    vGap(2),
                    //for adding some space

                    //last seen time of user
                    //TODO
                    /* Text(
                              list.isNotEmpty
                                  ? list[0].isOnline && !list[0].isTyping
                                  ? 'Online'
                                  : list[0].isTyping && list[0].isOnline
                                  ? "Typing..."
                                  : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive:
                                  list[0].lastActive.toString())
                                  : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive:
                                  (controller.user?.lastActive??'').toString()),
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54)),*/
                  ],
                ),
              ],
            ),
          ),
        ),
        /*(controller.me?.userId == controller.user?.createdby || controller.me?.userCompany?.isAdmin==1)
            ? */
        /*: SizedBox()*/

        (controller.user?.userCompany?.isGroup == 1 ||
            controller.user?.userCompany?.isBroadcast == 1)
            ? PopupMenuButton<String>(
          color: Colors.white,
          iconColor: Colors.black87,
          onSelected: (value) {
            if (value == 'AddMember') {

              if(kIsWeb){
                Get.toNamed(
                  "${AppRoutes.add_group_member}?groupChatId=${controller.user?.userId.toString()}",
                );
              }else{
                Get.toNamed(
                  AppRoutes.add_group_member,
                  arguments: {'groupChat': controller.user},
                );
              }
            }
            if (value == 'Exit') {
              toast("Under development");
            }
            if (value == 'Edit') {
              if(kIsWeb){
                Get.toNamed(
                  "${AppRoutes.member_sr}?userId=${controller.user?.userId.toString()}",
                );
              }
              else{
                Get.toNamed(AppRoutes.member_sr,
                    arguments: {'user': controller.user});
              }
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'AddMember',
              child: Row(
                children: [
                  Icon(
                    Icons.person_add_alt,
                    color: appColorGreen,
                    size: 18,
                  ),
                  hGap(5),
                  Text('Add Member',style: BalooStyles.baloonormalTextStyle()),
                ],
              ),
            ),
            /*PopupMenuItem(
              value: 'Exit',
              child: Row(
                children: [
                  Icon(
                    Icons.exit_to_app_rounded,
                    color: appColorGreen,
                    size: 18,
                  ),
                  hGap(5),
                  Text('Exit',style: BalooStyles.baloonormalTextStyle()),
                ],
              ),
            ),*/
            PopupMenuItem(
              value: 'Edit',
              child: Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: appColorGreen,
                    size: 18,
                  ),
                  hGap(5),
                  Text('Edit',style: BalooStyles.baloonormalTextStyle(),),
                ],
              ),
            ),
          ],
        )
            : const SizedBox(),
      ],
    );
  }

  bool isVisibleUpload = true;

  // bottom chat input field
  Widget _chatInput() {
    return Container(
      // height: Get.height*.4,
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          //input field & buttons
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                //emoji button
                /* IconButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            setState(() => _showEmoji = !_showEmoji);
                          },
                          icon: const Icon(Icons.emoji_emotions,
                              color: Colors.blueAccent, size: 25)),*/

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                              maxHeight: Get.height * .4, minHeight: 40),
                          child: Container(
                            // color: Colors.red,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: AppTheme.appColor.withOpacity(.2))),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: controller.textController,
                                    keyboardType: TextInputType.multiline,
                                    cursorColor: AppTheme.appColor,
                                    maxLines: null,
                                    onChanged: (text) {
                                      // if (text.isNotEmpty) {
                                      //   list[0].isTyping = true;
                                      //   APIs.updateTypingStatus(true);
                                      //   if(isVisibleUpload){
                                      //
                                      //     isVisibleUpload = false;
                                      //     controller.update();
                                      //   }
                                      // } else {
                                      //   list[0].isTyping = false;
                                      //   APIs.updateTypingStatus(false);
                                      //   if(!isVisibleUpload){
                                      //
                                      //     isVisibleUpload = true;
                                      //     controller.update();
                                      //   }
                                      // }
                                    },
                                    onTap: () {
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Type Something...',
                                      hintStyle: themeData.textTheme.bodySmall,
                                      contentPadding: const EdgeInsets.all(8),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                  ),
                                ),
                                if (!isTaskMode)
                                  Visibility(
                                      visible: isVisibleUpload,
                                      child: InkWell(
                                        onTap: () =>
                                            showUploadOptions(Get.context!),
                                        child: const Icon(
                                          Icons.upload_outlined,
                                          color: Colors.black54,
                                        ),
                                      ).paddingAll(3))
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          /*hGap(6),
                Card(
                  clipBehavior: Clip.none,
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      //pick image from gallery button
                        IconButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();

                            // Picking multiple images
                            final List<XFile> imgs =
                            await picker.pickMultiImage(imageQuality: 70);
                              controller.images.addAll(imgs);

                          },
                          icon: const Icon(Icons.image,
                              color: Colors.blueAccent, size: 26)),

                      //take image from camera button
                      IconButton(
                          onPressed: () async {
                            // final ImagePicker picker = ImagePicker();
                            // // Pick an image
                            // final XFile? image = await picker.pickImage(
                            //     source: ImageSource.camera, imageQuality: 70);
                            // if (image != null) {
                            //   // log('Image Path: ${image.path}');
                            //   setState(() => _isUploading = true);
                            //
                            //   await APIs.sendChatImage(
                            //       widget.user, File(image.path));
                            //   setState(() => _isUploading = false);
                            // }
                            controller.chooseMediaSource();
                          },
                          tooltip: "Choose image from Gallery or Camera",
                          padding: EdgeInsets.all(0),
                          splashRadius: 1,
                          icon: const Icon(Icons.camera_alt_outlined,
                              color: Colors.blueAccent, size: 26)),
                    ],
                  ),
                ),*/

          hGap(6),
          InkWell(
            onTap: () async {
              if (controller.textController.text.isNotEmpty) {
                if (controller.user?.userCompany?.isGroup == 1) {
                  Get.find<SocketController>().sendMessage(
                    receiverId: controller.user?.userId ?? 0,
                    message: controller.textController.text.trim(),
                    groupId: controller.user?.userCompany?.userCompanyId ?? 0,
                    type: "group",
                    isGroup: 1,
                    companyId: controller.user?.userCompany?.companyId,
                    alreadySave: false,
                    replyToId: controller.replyToMessage?.chatId,
                  );
                  controller.textController.clear();
                  controller.replyToMessage = null;
                  controller.update();
                } else if (controller.user?.userCompany?.isBroadcast == 1) {
                  Get.find<SocketController>().sendMessage(
                    receiverId: controller.user?.userId ?? 0,
                    message: controller.textController.text.trim(),
                    brID: controller.user?.userCompany?.userCompanyId ?? 0,
                    isGroup: 0,
                    type: "broadcast",
                    companyId: controller.user?.userCompany?.companyId,
                    alreadySave: false,
                  );
                  controller.textController.clear();
                  controller.replyToMessage = null;
                  controller.update();
                } else {
                  Get.find<SocketController>().sendMessage(
                    receiverId: controller.user?.userId ?? 0,
                    message: controller.textController.text.trim(),
                    isGroup: 0,
                    type: "direct",
                    companyId: controller.user?.userCompany?.companyId,
                    alreadySave: false,
                    replyToId: controller.replyToMessage
                        ?.chatId,

                  );
                  controller.textController.clear();
                  controller.replyToMessage = null;
                  controller.update();
                }



                // APIs.updateTypingStatus(false);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: appColorGreen,
              ),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  void showUploadOptions(BuildContext context) {
    if (kIsWeb) {
      showUploadOptionsWeb(context);
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.only(top: 16, left: 15, right: 15, bottom: 60),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () async {
                  Get.back();
                  final ImagePicker picker = ImagePicker();
                  // Pick an image
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 40,
                  );
                  if (image != null) {
                    controller.images.add(image);
                    controller.update();
                    controller.uploadMediaApiCall(
                        type: ChatMediaType.IMAGE.name);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () async {
                  Get.back();
                  final ImagePicker picker = ImagePicker();

                  // Picking multiple images
                  final List<XFile> images =
                  await picker.pickMultiImage(imageQuality: 40, limit: 10);

                  // uploading & sending image one by one
                  controller.images.addAll(images);
                  controller.update();
                  controller.uploadMediaApiCall(type: ChatMediaType.IMAGE.name);
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text("Document"),
                onTap: () {
                  Get.back();
                  controller.pickDocument();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


  void showUploadOptionsWeb(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Upload files'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'On web, use your computer’s picker to select images or documents.\n'
                  'You can choose multiple images at once.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // IMAGES (multiple)
              final images = await _pickWebImages(maxFiles: 10);
              if (images.isNotEmpty) {
                controller.images.addAll(images);
                controller.update();
                controller.uploadMediaApiCall(type: ChatMediaType.IMAGE.name);
              }
              Navigator.of(ctx).pop();
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.photo), SizedBox(width: 8), Text('Select Images')],
            ),
          ),
          TextButton(
            onPressed: () async {
              // DOCUMENTS (pdf/office/etc.)
              final docs = await _pickWebDocs();
              if (docs.isNotEmpty) {
                // see helper you’ll paste into your controller below
                await controller.receivePickedDocuments(docs);
              }
              Navigator.of(ctx).pop();
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.picture_as_pdf), SizedBox(width: 8), Text('Select Documents')],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// ====== HELPERS (WEB) ======

  Future<List<XFile>> _pickWebImages({int maxFiles = 10}) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
      withData: true, // we need bytes for XFile.fromData
      withReadStream: false,
    );

    if (result == null || result.files.isEmpty) return [];

    final files = result.files.take(maxFiles).where((f) => f.bytes != null);
    final xfiles = <XFile>[];
    for (final f in files) {
      final String name = f.name;
      final Uint8List bytes = f.bytes!;
      // best effort mime guess
      final String mime = _guessImageMime(name);
      xfiles.add(XFile.fromData(
        bytes,
        name: name,
        mimeType: mime,
        // length: bytes.length, // optional
      ));
    }
    return xfiles;
  }

  Future<List<PlatformFile>> _pickWebDocs() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const [
        'pdf', 'doc', 'docx', 'xls', 'xlsx', 'csv', 'txt'
      ],
      withData: true,
      withReadStream: false,
    );
    if (result == null || result.files.isEmpty) return [];
    return result.files;
  }

  String _guessImageMime(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    return 'image/*';
  }



  // bottom sheet for modifying message details
  void _showBottomSheet(bool isMe, {required ChatHisList data}) async {
    await showModalBottomSheet(
        context: Get.context!,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              //black divider
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),

              data.message != ''
                  ?
              //copy option
              _OptionItem(
                  icon: const Icon(Icons.copy_all_rounded,
                      color: Colors.blue, size: 18),
                  name: 'Copy Text',
                  onTap: () async {
                    await Clipboard.setData(
                        ClipboardData(text: data.message ?? ''))
                        .then((value) {
                      //for hiding bottom sheet
                      Get.back();

                      // Dialogs.showSnackbar(context, 'Text Copied!');
                    });
                  })
                  : (data.media ?? []).isNotEmpty
                  ?
              //save option
              _OptionItem(
                  icon:  Icon(Icons.download_rounded,
                      color: appColorYellow, size: 18),
                  name: 'Save Image',
                  onTap: () async {
                    try {
                      Get.back();
                      controller.saveAll(
                        data.media ?? [],
                      );
                    } catch (e) {
                      toast('Something went wrong!');
                    }
                  })
                  : const SizedBox(),


                _OptionItem(
                    icon:  Icon(Icons.reply,
                        color: appColorYellow, size: 18),
                    name: 'Reply',
                    onTap: () async {
                      try {
                        Get.back();
                        controller.refIdis = data.chatId;
                        controller.userIDSender =
                            data.fromUser?.userId;
                        controller.userNameReceiver =
                            data.toUser?.displayName ?? '';
                        controller.userNameSender =
                            data.fromUser?.displayName ?? '';
                        controller.userIDReceiver =
                            data.toUser?.userId;
                        controller.replyToMessage = data;


                        controller.update();
                      } catch (e) {
                        toast('Something went wrong!');
                      }
                    }),

              _OptionItem(
                    icon:  Icon(Icons.document_scanner,
                        color: appColorYellow, size: 18),
                    name: 'Save in Accuchat Gallery',
                    onTap: () async {
                      try {
                        Get.back();


                        showDialog(
                            context: Get.context!,
                            builder: (_) => _saveDocumentsDialog());
                      } catch (e) {
                        toast('Something went wrong!');
                      }
                    }),

              //separator or divider
              if (isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * .04,
                  indent: mq.width * .04,
                ),

              //edit option
              /*  if (data.message != "" && isMe)
                _OptionItem(
                    icon: const Icon(Icons.edit, color: Colors.blue,  size: 18),
                    name: 'Edit Message',
                    onTap: () {
                      //for hiding bottom sheet
                      Get.back();

                      */ /* final currentStatus =
                          widget.message.taskDetails?.taskStatus ?? 'Pending';

                      isTaskMode && !widget.isForward
                          ? (['Done', 'Completed', 'Cancelled']
                                  .contains(currentStatus))
                              ? toast(
                                  "⛔ Task status is '$currentStatus' — update not allowed.")
                              : showDialog(
                                  context: Get.context!,
                                  builder: (_) => _updateTasksDialogWidget(
                                      userName, widget.message.taskDetails!))
                          : */ /*
                      _showMessageUpdateDialog();
                    }),*/

              // delete option
              if (controller.me?.userId == controller.myCompany?.createdBy)
                _OptionItem(
                    icon: const Icon(Icons.delete_forever,
                        color: Colors.red, size: 18),
                    name: 'Delete Message',
                    onTap: () async {
                      print("sdfsdfsf${data.chatId ?? 0}");
                      Get.find<SocketController>().deleteMsgEmitter(
                          mode: controller.user?.userCompany?.isGroup == 1
                              ? "group"
                              : controller.user?.userCompany?.isBroadcast == 1
                              ? "broadcast"
                              : "direct",
                          chatId: data.chatId ?? 0,
                          groupId: controller.user?.userCompany?.isGroup == 1
                              ? controller.user?.userCompany?.userCompanyId
                              : null);
                    }),
              //separator or divider
              /*  if (!widget.isForward)
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * .04,
                  indent: mq.width * .04,
                ),

              //sent time
              if (!widget.isForward)
                _OptionItem(
                    icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                    name:
                        'Sent At: ${MyDateUtil.getMessageTime(context: Get.context!, time: widget.message.sent)}',
                    onTap: () {
                      Get.back();
                    }),

              //read time
              if (!widget.isForward)
                _OptionItem(
                    icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                    name: widget.message.read.isEmpty
                        ? 'Read At: Not seen yet'
                        : 'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                    onTap: () {
                      Get.back();
                    }),*/
            ],
          );
        });
  }

  final _formKeyDoc = GlobalKey<FormState>();
  _saveDocumentsDialog() {
    return CustomDialogue(
      title: "Documents",
      isShowAppIcon: false,
      // ⬇️ Add a responsive wrapper so the dialog doesn't take full web width/height
      content: LayoutBuilder(
        builder: (context, constraints) {
          final screenW = MediaQuery.of(context).size.width;
          final screenH = MediaQuery.of(context).size.height;

          // Sensible responsive max width for the dialog
          final double maxDialogWidth = screenW >= 1440
              ? 560
              : screenW >= 1024
              ? 520
              : screenW >= 768
              ? 500
              : screenW * 0.92;

          // Keep height comfortable and scroll if needed
          final double maxDialogHeight = screenH * 0.9;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxDialogWidth,
                maxHeight: maxDialogHeight,
              ),
              child: Material( // keeps proper text scaling/ink on web
                type: MaterialType.transparency,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenW >= 768 ? 16 : 12,
                    vertical: 12,
                  ),
                  child: Form(
                    key: _formKeyDoc,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        vGap(20),
                        Text(
                          "This document or image has been securely saved in your AccuChat Gallery under a custom folder. You can easily access it anytime by searching its name.",
                          style: BalooStyles.baloonormalTextStyle(),
                          textAlign: TextAlign.center,
                        ),

                        vGap(30),

                        CustomTextField(
                          hintText: "Document Name",
                          controller: controller.docNameController,
                          focusNode: FocusNode(),
                          onFieldSubmitted: (String? value) {
                            FocusScope.of(Get.context!).unfocus();
                          },
                          labletext: "Document Name",
                          validator: (value) =>
                              value?.isEmptyField(messageTitle: "Document Name"),
                        ),
                        vGap(40),
                        Row(
                          children: [
                            Expanded(
                              child: GradientButton(
                                name: "Save",
                                btnColor: appColorYellow,
                                gradient: LinearGradient(colors: [appColorYellow, appColorYellow]),
                                vPadding: 6,
                                onTap: () async {
                                  if (_formKeyDoc.currentState!.validate()) {
                                    controller.onTapSaveToFolder(Get.context!);
                                  }
                                  // logoutLocal();
                                },
                              ),
                            ),
                            hGap(15),
                            Expanded(
                              child: GradientButton(
                                name: "Cancel",
                                btnColor: Colors.black,
                                color: Colors.black,
                                gradient: LinearGradient(colors: [AppTheme.whiteColor, AppTheme.whiteColor]),
                                vPadding: 6,
                                onTap: () {
                                  Get.back();
                                },
                              ),
                            ),
                          ],
                        )
                        // Text(STRING_logoutHeading,style: BalooStyles.baloomediumTextStyle(),),
                      ],
                    ).paddingSymmetric(horizontal: 8),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      onOkTap: () {},
    );
  }


  Widget buildMessageBubble(ChatHisList msg, {required bool isMine}) {
    final bool isDeleted = (msg.message == null || msg.message!.isEmpty);
    String formatatedTime = '';
    if (msg.sentOn != null) {
      var timeString = msg.sentOn ?? '';
      formatatedTime = convertUtcToIndianTime(timeString);
    }

    if (isDeleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'This message was deleted',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    // ... your normal bubble
    return _chatMessageTile(
        data: msg,
        sentByMe: (controller.me?.userId.toString() ==
            msg.fromUser?.userId?.toString()
            ? true
            : false),
        formatedTime: formatatedTime);
  }

  //dialog for updating message content
  void _showMessageUpdateDialog() {
/*    String updatedMsg = widget.message.msg;

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: const Row(
                children: [
                  Icon(
                    Icons.message,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text(' Update Message')
                ],
              ),

              //content
              content: TextFormField(
                initialValue: updatedMsg,
                maxLines: null,
                onChanged: (value) => updatedMsg = value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Get.back();
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    )),

                //update button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      APIs.updateMessage(widget.message, updatedMsg)
                          .whenComplete(() {
                        Get.back();
                      });
                    },
                    child: const Text(
                      'Update',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));*/
  }
}

//custom options card (for copy, edit, delete, etc.)
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final Function() onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(
              left: mq.width * .05,
              top: mq.height * .015,
              bottom: mq.height * .015),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('    $name',
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        letterSpacing: 0.5)))
          ]),
        ));
  }
}
