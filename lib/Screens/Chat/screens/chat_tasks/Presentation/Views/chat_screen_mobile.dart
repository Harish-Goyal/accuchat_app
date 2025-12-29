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
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import '../../../../../../Constants/app_theme.dart';
import '../../../../../../Constants/assets.dart';
import '../../../../../../Constants/colors.dart';
import '../../../../../../utils/common_textfield.dart';
import '../../../../../../utils/custom_dialogue.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../../utils/gradient_button.dart';
import '../../../../../../utils/product_shimmer_widget.dart';
import '../../../../../../utils/share_helper.dart';
import '../../../../../../utils/text_button.dart';
import '../../../../../../utils/text_style.dart';
import '../../../../../Home/Presentation/Controller/socket_controller.dart';
import '../Controllers/task_controller.dart';
import '../Controllers/task_home_controller.dart';
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

double _maxContentWidth(double w) {
  if (w >= 1400) return 920; // large desktop
  if (w >= 1100) return 820; // desktop
  if (w >= 900) return 720;  // small desktop / landscape tablet
  if (w >= 600) return 560;  // portrait tablet
  return w; // phones -> full width (preserves mobile UI)
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

class ChatScreenMobile extends GetView<ChatScreenController> {
  ChatScreenMobile({super.key});
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
              Get.find<ChatHomeController>().localPage = 1;
              Get.find<ChatHomeController>().hitAPIToGetRecentChats(page: 1);
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
                                padding: const EdgeInsets.all(2),
                                margin:
                                const EdgeInsets.only(bottom: 0, left: 10, right: 63),
                                decoration: BoxDecoration(
                                  color: Colors.white54,
                                  border: Border.all(color: appColorGreen, width: .4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 3,
                                      color: appColorYellow,
                                    ),
                                    Icon(Icons.reply, color: appColorGreen,size: 18,),

                                    Expanded(
                                      child:
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${controller.replyToMessage?.fromUser?.userId == controller.me?.userId ? 'You' : controller.user?.displayName ?? ''}",
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: themeData.textTheme.bodySmall
                                                      ?.copyWith(color: greyText),
                                                ),

                                                controller.isImageOrVideo(controller.replyToMessage?.message??'')?  Text(
                                                  "Media",
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: themeData.textTheme.bodySmall
                                                      ?.copyWith(color: greyText),
                                                ):SizedBox()
                                              ],
                                            ).paddingSymmetric(horizontal: 4),
                                          ),

                                          Text(
                                            " : ",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: themeData.textTheme.bodySmall
                                                ?.copyWith(color: appColorYellow),
                                          ),

                                          !controller.isImageOrVideo(controller.replyToMessage?.message??'')? Flexible(
                                            flex: 2,
                                            child: Text(
                                              controller.replyToMessage?.message ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: themeData.textTheme.bodySmall
                                                  ?.copyWith(color: greyText),
                                            ),
                                          ):Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: appColorGreen,width: .3)),
                                              child: CustomCacheNetworkImage(controller.replyToMessage?.message??'',
                                                width: 50,
                                                height: 50,
                                                radiusAll: 8,
                                                borderColor: appColorGreen,
                                                boxFit: BoxFit.cover,
                                              )),
                                        ],
                                      ) ,
                                    ),
                                    IconButton(
                                        icon:  const Icon(
                                          Icons.close,
                                          color: blueColor,
                                          size: 18,
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

  Widget groupListView() {
    // final initialIndex = (controller.flatRows.isEmpty)
    //     ? 0
    //     : controller.flatRows.length - 1;
 return   controller.chatCatygory != [] ||
        (controller.chatCatygory ?? []).isNotEmpty
        ? GroupedListView<GroupChatElement, DateTime>(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 30),
        controller: controller.scrollController2,
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
              iconColor: appColorGreen,
              onRightSwipe: element.chatMessageItems.isActivity == 1
                  ? (v) {}
                  : (detail) {
                if (element.chatMessageItems.isActivity == 1 ||
                    (element.chatMessageItems.media ?? [])
                        .isNotEmpty) {
                } else {

                  final media = element.chatMessageItems.media;

                  if (media == null || media.isEmpty) {
                    controller.refIdis = element.chatMessageItems.chatId;
                    controller.userIDSender = element.chatMessageItems.fromUser?.userId;
                    controller.userNameReceiver =
                        element.chatMessageItems.toUser?.userCompany?.displayName ?? '';
                    controller.userNameSender =
                        element.chatMessageItems.fromUser?.userCompany?.displayName ?? '';
                    controller.userIDReceiver = element.chatMessageItems.toUser?.userId;
                    controller.replyToMessage = element.chatMessageItems;
                    controller.update();
                    controller.messageInputFocus.requestFocus();
                  } else {
                    final firstMedia = media.first;
                    controller.refIdis = element.chatMessageItems.chatId;
                    controller.userIDSender = element.chatMessageItems.fromUser?.userId;
                    controller.userNameReceiver = element.chatMessageItems.toUser?.userCompany?.displayName ?? '';
                    controller.userNameSender = element.chatMessageItems.fromUser?.userCompany?.displayName ?? '';
                    controller.userIDReceiver = element.chatMessageItems.toUser?.userId;

                    controller.replyToImage = firstMedia.orgFileName;

                    final isDoc = firstMedia.mediaType?.mediaCode == "DOC";
                    final msg = isDoc
                        ? (firstMedia.orgFileName ?? '')
                        : "${ApiEnd.baseUrlMedia}${firstMedia.fileName ?? ''}";

                    controller.replyToMessage = ChatHisList(
                      chatId: element.chatMessageItems.chatId,
                      fromUser: element.chatMessageItems.fromUser,
                      toUser: element.chatMessageItems.toUser,
                      message: msg,
                      replyToId: element.chatMessageItems.chatId,
                      replyToText: firstMedia.orgFileName,
                    );

                    controller.update();
                    controller.messageInputFocus.requestFocus();
                  }


                  // // Set the message being replied to
                  // controller.refIdis =
                  //     element.chatMessageItems.chatId;
                  // controller.userIDSender =
                  //     element.chatMessageItems.fromUser?.userId;
                  // controller.userNameReceiver =
                  //     element.chatMessageItems.toUser?.userCompany?.displayName ??
                  //         '';
                  // controller.userNameSender = element
                  //         .chatMessageItems.fromUser?.userCompany?.displayName ??
                  //     '';
                  // controller.userIDReceiver =
                  //     element.chatMessageItems.toUser?.userId;
                  // controller.replyToMessage =
                  //     element.chatMessageItems;
                  // controller.update();
                  // controller.messageInputFocus.requestFocus();
                }
              },
              child: _chatMessageTile(
                  data: element.chatMessageItems,
                  sentByMe: (userid?.toString() ==
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



/*    ScrollablePositionedList.builder(
      itemScrollController: controller.itemScrollController,
      itemPositionsListener: controller.itemPositionsListener,
      initialScrollIndex: initialIndex,        // start at bottom (chat-like)
      initialAlignment: 1.0,
      shrinkWrap: true,// align bottom
      padding: const EdgeInsets.only(bottom: 30),
      itemCount: controller.flatRows.length,
      itemBuilder: (context, index) {
        final row = controller.flatRows[index];

        if (row is ChatHeaderRow) {
          // reuse your header builder
          return _createGroupHeader(row.date); // adapt signature if needed
        }

        if (row is ChatMessageRow) {
          final element = row.element;

          String formattedTime = '';
          if (element.chatMessageItems.sentOn != null) {
            final timeString = element.chatMessageItems.sentOn!;
            formattedTime = convertUtcToIndianTime(timeString);
          }

          final userid = controller.me?.userId;
          final sentByMe = (userid?.toString() ==
              element.chatMessageItems.fromUser?.userId?.toString());

          final chatId = element.chatMessageItems.chatId;
          final isHighlighted = chatId != null &&
              controller.highlighted.contains(chatId);

          return StaggeredAnimationListItem(
            index: index,
            child: SwipeTo(
              onRightSwipe: (detail) {
                if (element.chatMessageItems.isActivity == 1 ||
                    (element.chatMessageItems.media ?? []).isNotEmpty) {
                  // ignore reply on activities/media if that’s your rule
                } else {
                  controller.refIdis = element.chatMessageItems.chatId;
                  controller.userIDSender = element.chatMessageItems.fromUser?.userId;
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
              child: Container(
                // optional highlight
                color: isHighlighted
                    ? const Color(0xFFFFFF00).withOpacity(0.2)
                    : null,
                child: _chatMessageTile(
                  data: element.chatMessageItems,
                  sentByMe: sentByMe,
                  formatedTime: formattedTime,
                ),
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    )
        : const Center(
        child: Text('Say Hii! 👋', style: TextStyle(fontSize: 20)));*/
  }


  Widget _createGroupHeader(GroupChatElement element) {
    final isToday = DateUtils.isSameDay(element.date, DateTime.now());
    final dateText =
    isToday ? "Today" : DateFormat.yMMMd().format(element.date);
    return Container(
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(child: divider(color: appColorGreen.withOpacity(.3))),
          CustomContainer(
            elevation: 2,
            vPadding: 3,
            hPadding: 7,
            color: AppTheme.whiteColor,
            childWidget: Text(
              dateText,
              style: BalooStyles.balooregularTextStyle(size: 12.5),
            ),
          ),
          Expanded(child: divider(color: appColorGreen.withOpacity(.3))),
        ],
      ),
    );
  }
 /* Widget _createGroupHeader(date) {
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
            childWidget: Text(DateFormat.yMMMd().format(date),
              // childWidget: Text(DateFormat.yMMMd().format(element.date),
              style: BalooStyles.balooregularTextStyle(),),
          ),
          Expanded(child: divider(color: appColorGreen.withOpacity(.3))),
        ],
      ),
    );
  }*/

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
          Text(data.message ?? '',
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
                    transform: Matrix4.rotationY(math.pi),
                    child: Image.asset(
                      forwardIcon,
                      height: 20,
                    ))).paddingOnly(left: 8)
                : const SizedBox(),
            Align(
              alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Get.width * (kIsWeb ? 0.45 : 0.75),
                ),
                child: Column(
                  // mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: sentByMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      borderRadius:sentByMe
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
                          bottomRight: Radius.circular((data.media ?? []).isNotEmpty ? 15 : 30)),
                      // mouseCursor: SystemMouseCursors.click,
                      onDoubleTap: () {
                        SystemChannels.textInput
                            .invokeMethod('TextInput.hide');
                        if (!isTaskMode) {
                            _showBottomSheet(sentByMe, data: data);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                          (data.media ?? []).isNotEmpty ? 8 : 15,
                          vertical:
                          (data.media ?? []).isNotEmpty ? 0 : 15,
                        ),
                        margin: sentByMe
                            ? const EdgeInsets.only(left: 15, top: 10,right: 15)
                            : const EdgeInsets.only(right: 15, top: 10,left: 15),

                        decoration: BoxDecoration(
                            color: sentByMe
                                ? appColorGreen.withOpacity(.1)
                                : appColorPerple.withOpacity(.1),
                            border: Border.all(
                                color:  sentByMe
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
                    ),
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
                    transform: Matrix4.rotationX(math.pi),
                    child: Image.asset(
                      forwardIcon,
                      height: 20,
                    ))).paddingOnly(right: 8)
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
    return Container(
      key: ValueKey('msg-${data.chatId}'),
      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          data.replyToId != null
              ? ReplyMessageWidget(
              isCancel: false,
              sentByMe: sentByMe,
              empIdsender: data.fromUser?.userId.toString(),
              chatdata: data,
              empIdreceiver: data.toUser?.userId.toString(),
              empName: data.isGroupChat == 1
                  ? data.fromUser?.userCompany?.displayName ?? ''
                  : data.fromUser?.userId.toString() ==
                  controller.me?.userId?.toString()
                  ? data.fromUser?.userCompany?.displayName ?? ''
                  : data.toUser?.userCompany?.displayName ?? '',
              message: data.replyToText ?? '',
              orignalMsg: data.replyToText ?? '')
              .paddingOnly(bottom: 4)
              : const SizedBox(),
          controller.user?.userCompany?.isGroup == 1
              ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [

              Flexible(
                child: Text(
                    data.fromUser?.userId == controller.me?.userId
                        ? "You"
                        :
                    data.fromUser?.userCompany?.displayName!=null?  (data.fromUser?.userCompany?.displayName ?? ''):data.fromUser?.userName!=null? (data.fromUser?.userName ?? ''):(data.fromUser?.phone??''),
                    style: BalooStyles.baloonormalTextStyle(
                        color:
                        data.fromUser?.userId == controller.me?.userId
                            ? Colors.green
                            : Colors.purple),
                    textAlign: TextAlign.end, maxLines: 1,
                    overflow: TextOverflow.ellipsis
                ).marginOnly(
                    right: sentByMe ? 1 : 5,
                    left: sentByMe ? 1 : 5,
                    bottom: 1,
                    top: 4),
              ),
            ],
          )
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
                  senderName:data.fromUser?.displayName!=null? data.fromUser?.displayName ?? '':data.fromUser?.userName??'',
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
                            controller.userIDSender = data.fromUser?.userId;
                            controller.userNameReceiver =
                                data.toUser?.userCompany?.displayName ?? '';
                            controller.userNameSender =
                                data.fromUser?.userCompany?.displayName ?? '';
                            controller.userIDReceiver = data.toUser?.userId;
                            controller.replyToMessage = data;
                            controller.replyToImage =
                                data.media?[startIndex].orgFileName ?? '';
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
      ),
    );
  }

  // app bar widget
  Widget _appBar() {
    return Row(
      children: [
        controller.isSearching
            ? Expanded(
          child: TextField(
            controller: controller.seacrhCon,
            cursorColor: appColorGreen,
            decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search Chats ...',
                contentPadding: EdgeInsets.symmetric(
                    vertical: 0, horizontal: 10),
                constraints: BoxConstraints(maxHeight: 45)),
            autofocus: true,
            style: const TextStyle(
                fontSize: 13, letterSpacing: 0.5),
            onChanged: (val) {
              controller.searchQuery = val;
              controller.onSearch(val);
            },
          ).marginSymmetric(vertical: 10),
        )
            : Expanded(
          child: InkWell(
            onTap: () {
              if (!(controller.user?.userCompany?.isGroup == 1 ||
                  controller.user?.userCompany?.isBroadcast == 1)) {

                if(kIsWeb){
                  Get.toNamed(
                    "${AppRoutes.view_profile}?userId=${controller.user?.userId}",
                  );
                }
                else{
                  Get.toNamed(AppRoutes.view_profile,
                      arguments: {'user': controller.user});
                }
              } else {
                if(kIsWeb){
                  Get.toNamed(
                    "${AppRoutes.member_sr}?userId=${controller.user?.userId}",
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
                      if (Get.previousRoute.isNotEmpty) {
                        Get.back();
                      } else {
                        Get.offAllNamed(AppRoutes.home); // or your main route
                      }
                      if(!kIsWeb) {
                        Get.find<ChatHomeController>().localPage = 1;
                        Get.find<ChatHomeController>().hitAPIToGetRecentChats(page: 1);
                        if (isTaskMode) {
                          Get.find<DashboardController>().updateIndex(1);
                        } else {
                          Get.find<DashboardController>().updateIndex(0);
                        }
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
                  borderColor: greyText,
                ),

                //for adding some space
               hGap(8),

                //user name & last seen time
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //user name
                      (controller.user?.userCompany?.isGroup == 1 ||
                          controller.user?.userCompany?.isBroadcast == 1)
                          ? Text(
                        (controller.user?.userName == '' ||
                            controller.user?.userName == null)
                            ? controller.user?.phone ?? ''
                            : controller.user?.userName ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: themeData.textTheme.titleMedium,
                      )
                          : Text(
                        (controller.user?.userCompany?.displayName !=null)
                            ? controller.user?.userCompany?.displayName ?? ''
                            :controller.user?.userName!=null? controller.user?.userName?? '': controller.user?.phone??'',
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
                ),


              ],
            ),
          ),
        ),

        controller.isSearching?SizedBox():  (controller.user?.userCompany?.isBroadcast==1 ||controller.user?.userCompany?.isGroup==1) ?SizedBox():  CustomTextButton(onTap: (){
          // isTaskMode = true;
          // Get.find<DashboardController>().updateIndex(1);
          Get.toNamed(AppRoutes.tasks_li_r,arguments: {'user':controller.user});
          // Get.back();
        }, title: "Go to Task"),
        controller.isSearching?SizedBox():  hGap(10),
        IconButton(
            onPressed: () {
              controller.isSearching = !controller.isSearching;
              controller.update();
              if(!controller.isSearching){
                controller.searchQuery = '';
                controller.onSearch('');
                controller.seacrhCon.clear();
              }
              controller.update();
            },
            icon:  controller.isSearching?  const Icon(
                CupertinoIcons.clear_circled_solid)
                : Image.asset(searchPng,height:25,width:25)
        ).paddingOnly(top: 0, right: 0),
        controller.isSearching?SizedBox():hGap(10),
        controller.isSearching?SizedBox(): (controller.user?.userCompany?.isGroup == 1 ||
            controller.user?.userCompany?.isBroadcast == 1)
            ? PopupMenuButton<String>(
          color: Colors.white,
          iconColor: Colors.black87,
          onSelected: (value) {
            if (value == 'AddMember') {
              if (kIsWeb) {
                Get.toNamed(
                  "${AppRoutes.add_group_member}?groupChatId=${controller.user?.userId.toString()}",
                );
              } else {
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
              if (kIsWeb) {
                Get.toNamed(
                  "${AppRoutes.member_sr}?userId=${controller.user?.userId.toString()}",
                );
              } else {
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
                  Text('Add Member',
                      style: BalooStyles.baloonormalTextStyle()),
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
                  Text(
                    'Edit',
                    style: BalooStyles.baloonormalTextStyle(),
                  ),
                ],
              ),
            ),
          ],
        )
            : const SizedBox(),
        hGap(8)
      ],
    );
  }

  bool isVisibleUpload = true;

  // bottom chat input field
  Widget _chatInput() {
    return Container(
      // height: Get.height*.4,
      padding: EdgeInsets.symmetric(
          vertical: mq.height * 0, horizontal: mq.width * .025),
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
                        Focus(
                          focusNode: controller.messageParentFocus,
                          autofocus: true,
                          onKeyEvent: (node, event) {
                            if (!kIsWeb) return KeyEventResult.ignored;

                            if (event is KeyDownEvent &&
                                event.logicalKey == LogicalKeyboardKey.enter) {

                              final bool shiftPressed =
                                  HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftLeft) ||
                                      HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftRight);

                              if (shiftPressed) {
                                // SHIFT + ENTER → new line
                                return KeyEventResult.ignored;
                              } else {
                                // ENTER → send
                                _sendMessage();
                                return KeyEventResult.handled;
                              }
                            }

                            return KeyEventResult.ignored;
                          },
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: Get.height * .3,
                              minHeight: 30,
                            ),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: AppTheme.appColor.withOpacity(.2)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: controller.textController,
                                      keyboardType: TextInputType.multiline,
                                      focusNode: controller.messageInputFocus,
                                      textInputAction: TextInputAction.newline,
                                      maxLines: null,
                                      minLines: 1,
                                      autofocus: true,
                                      onTap: (){
                                        controller.messageInputFocus.requestFocus();
                                      },
                                      decoration: InputDecoration(
                                        isDense: true,
                                        hintText: 'Type Something...',
                                        hintStyle:
                                        themeData.textTheme.bodySmall,
                                        contentPadding: const EdgeInsets.all(8),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'[\s\S]'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isTaskMode)
                                    Visibility(
                                      visible: isVisibleUpload,
                                      child: InkWell(
                                        onTap: () =>
                                            showUploadOptions(Get.context!),
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          margin: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(8),
                                            border: Border.all(
                                                color: appColorGreen),
                                            color:
                                            appColorGreen.withOpacity(.1),
                                          ),
                                          child: Icon(
                                            Icons.upload_outlined,
                                            color: appColorGreen,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        )
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
              _sendMessage();
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




  _sendMessage() {
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
            replyToId: controller.replyToMessage?.chatId,
            replyToText: controller.replyToImage);
        controller.textController.clear();
        controller.replyToMessage = null;
        controller.replyToImage = null;
        controller.update();
      }

      controller.update();
      // APIs.updateTypingStatus(false);
    }
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
      backgroundColor: Colors.white,
      builder: (_) => SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.only(top: 16, left: 15, right: 15, bottom: 60),
          child: Wrap(
            children: [
              ListTile(
                leading:  Icon(Icons.camera_alt_outlined,size: 20,),
                title:  Text("Camera",style: BalooStyles.baloomediumTextStyle(),),
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
                leading:  Icon(Icons.photo_library_outlined,size: 20,),
                title:  Text("Gallery",style: BalooStyles.baloomediumTextStyle(),),
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
                leading:  Icon(Icons.picture_as_pdf_outlined,size: 20,),
                title:  Text("Document",style: BalooStyles.baloomediumTextStyle(),),
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Upload files'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'On web, use your computer’s picker to select images or documents.\n'
                  'You can choose max 10 images at once.',
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
    DateTime msg  = DateTime.parse(data.sentOn??'');
    DateTime nowtime = DateTime.now();

    int diffMinutes = nowtime.difference(msg).inMinutes;
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
              !((data.media ?? []).isNotEmpty)
                  ? _OptionItem(
                  icon: Icon(Icons.download_rounded,
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
                  : const SizedBox()
                  : const SizedBox(),

              (!(data.media ?? []).isNotEmpty || data.media?.length == 1)
                  ? _OptionItem(
                  icon: Icon(Icons.reply, color: appColorGreen, size: 18),
                  name: 'Reply',
                  onTap: () async {
                    final media = data.media;
                    if (media == null || media.isEmpty) {
                      controller.refIdis = data.chatId;
                      controller.userIDSender = data.fromUser?.userId;
                      controller.userNameReceiver =
                          data.toUser?.userCompany?.displayName ?? '';
                      controller.userNameSender =
                          data.fromUser?.userCompany?.displayName ?? '';
                      controller.userIDReceiver = data.toUser?.userId;
                      controller.replyToMessage = data;
                      controller.update();
                      controller.messageInputFocus.requestFocus();
                    } else {
                      final firstMedia = media.first;
                      controller.refIdis = data.chatId;
                      controller.userIDSender = data.fromUser?.userId;
                      controller.userNameReceiver = data.toUser?.userCompany?.displayName ?? '';
                      controller.userNameSender = data.fromUser?.userCompany?.displayName ?? '';
                      controller.userIDReceiver = data.toUser?.userId;

                      controller.replyToImage = firstMedia.orgFileName;

                      final isDoc = firstMedia.mediaType?.mediaCode == "DOC";
                      final msg = isDoc
                          ? (firstMedia.orgFileName ?? '')
                          : "${ApiEnd.baseUrlMedia}${firstMedia.fileName ?? ''}";

                      controller.replyToMessage = ChatHisList(
                        chatId: data.chatId,
                        fromUser: data.fromUser,
                        toUser: data.toUser,
                        message: msg,
                        replyToId: data.chatId,
                        replyToText: firstMedia.orgFileName,
                      );

                      controller.update();
                      controller.messageInputFocus.requestFocus();
                    }
                  })
                  : const SizedBox(),

              /*_OptionItem(
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
                    }),*/

              //separator or divider
              if (isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * .04,
                  indent: mq.width * .04,
                ),

              //edit option

              if (data.message != "" && isMe && diffMinutes <= 15 )
                _OptionItem(
                    icon:  Icon(Icons.edit, color: appColorGreen,  size: 18),
                    name: 'Edit Message',
                    onTap: () {
                      Get.back();
                      _showMessageUpdateDialog(data,Get.context!);
                    }),

              /*if ((APIs.me?.userCompany?.company?.createdBy ==data.fromUser?.userCompany?.company?.createdBy))
                _OptionItem(
                    icon:  Icon(Icons.edit, color: appColorGreen,  size: 18),
                    name: 'Edit Message',
                    onTap: () {
                      Get.back();
                      _showMessageUpdateDialog(data,Get.context!);
                    }),*/

              // delete option
              if (controller.me?.userId == controller.myCompany?.createdBy && isMe)
                _OptionItem(
                    icon: const Icon(Icons.delete_forever,
                        color: Colors.red, size: 18),
                    name: 'Delete Message',
                    onTap: () async {
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

              (data.message!=null&&(data.media?.isEmpty??true))?

              _OptionItem(
                  icon:  Icon(Icons.share,
                      color: appColorGreen, size: 18),
                  name: 'Share on WhatsApp',
                  onTap: () async {
                    if(kIsWeb){
                      final msg = data.message ?? '';
                      ShareHelper.shareOnWhatsApp(msg);
                    }
                  }):SizedBox()
              //separator or divider
              /* if (!widget.isForward)
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
                                    controller.onTapSaveToFolder(Get.context!,controller.user);
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
  void _showMessageUpdateDialog(ChatHisList message,context) {
    controller.updateMsgController.text = message.message??'';
    showDialog(
        context: context,

        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.only(
              left: 24, right: 24, top: 20, bottom: 10),

          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),

          //title
          title:  Row(
            children: [
              Icon(
                Icons.message,
                color: appColorGreen,
                size: 20,
              ),
              hGap(5),
              Text('Update Message',style: BalooStyles.baloosemiBoldTextStyle(),)
            ],
          ),

          //content
          content: TextFormField(
            controller: controller.updateMsgController ,
            maxLines: null,
            onChanged: (value) => message.message = value,
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

            CustomTextButton(onTap: (){
              try {
                Get.find<SocketController>().updateChatMessage(
                    chatId: message.chatId,
                    toUcId: message.toUser?.userCompany?.userCompanyId,
                    message: controller.updateMsgController.text.trim()
                );
                Get.back();
              }catch(e){
                toast(e.toString());
              }
            }, title: 'Update')

          ],
        ));
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
