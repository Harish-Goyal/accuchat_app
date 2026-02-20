import 'dart:async';
import 'dart:math' as math;
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/Screens/Chat/models/chat_history_response_model.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_home_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_screen_controller.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/custom_container.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:AccuChat/Screens/voice_to_texx/speech_controller_factory.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
import '../../../../../../utils/emogi_checker.dart';
import '../../../../../../utils/emogi_picker_web.dart';
import '../../../../../../utils/gradient_button.dart';
import '../../../../../../utils/share_helper.dart';
import '../../../../../../utils/text_button.dart';
import '../../../../../../utils/text_style.dart';
import '../../../../../Home/Models/pickes_file_item.dart';
import '../../../../../Home/Presentation/Controller/socket_controller.dart';
import '../../../../api/apis.dart';
import '../../../../helper/dialogs.dart';
import '../../../auth/models/get_uesr_Res_model.dart';
import '../Controllers/add_group_mem_controller.dart';
import '../Controllers/save_in_accuchat_gallery_controller.dart';
import '../Widgets/reply_msg_widget.dart';
import '../Controllers/gallery_view_controller.dart';
import '../Widgets/media_view.dart';
import '../dialogs/save_in_gallery_dialog.dart';
import 'add_group_members_screens.dart';
import 'images_gallery_page.dart';

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

class ChatScreenMobile extends StatefulWidget {
  ChatScreenMobile({super.key});

  @override
  State<ChatScreenMobile> createState() => _ChatScreenMobileState();
}

class _ChatScreenMobileState extends State<ChatScreenMobile> {
  final speechC = Get.put(SpeechControllerImpl());
  late ChatScreenController controller;
  SaveToGalleryController galleryController= Get.put(SaveToGalleryController());
  late final ItemScrollController itemScrollController;
  late final ItemPositionsListener itemPositionsListener;
  @override
  void initState() {
    super.initState();
    itemScrollController = ItemScrollController();
    itemPositionsListener = ItemPositionsListener.create();
    // controller.itemScrollController = ItemScrollController();
    // controller.itemPositionsListener = ItemPositionsListener.create();

    _attachPaginationListener();

    if (Get.isRegistered<ChatScreenController>()) {
      controller = Get.find<ChatScreenController>();
    } else {
      controller = Get.put(ChatScreenController());
    }

  }

  @override
  void dispose() {
    try {
      itemPositionsListener.itemPositions
          .removeListener(onPositionsChanged);
    } catch (_) {}
    if (Get.isRegistered<ChatScreenController>()) {
      Get.delete<ChatScreenController>(force: true);
    }
    super.dispose();
  }

  Future<void> jumpToRepliedMessage(int targetChatId) async {
    /// Load more pages if message not found
    if (!controller.chatIdIndexMap.containsKey(targetChatId)) {
      await _loadUntilFound(targetChatId);
      controller.rebuildFlatRows();
    }

    final index = controller.chatIdIndexMap[targetChatId];
    if (index == null) return;

    itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      alignment: 0.15,
    );

    // highlight effect
    controller.highlightedChatId = targetChatId;
    controller.update();

    Future.delayed(const Duration(seconds: 2), () {
      if (controller.highlightedChatId == targetChatId) {
        controller.highlightedChatId = null;
        controller.update();
      }
    });
  }
  Future<void> _loadUntilFound(int targetChatId) async {
    int safety = 0;
    while (!controller.chatIdIndexMap.containsKey(targetChatId) &&
        controller.hasMore &&
        !controller.isPageLoading) {
      safety++;
      if (safety > 50) break;

      await controller.hitAPIToGetChatHistory("_loadUntilFound", user: controller.user!);
      controller.rebuildFlatRows();

      if (controller.chatIdIndexMap.containsKey(targetChatId)) break;
    }
  }
  bool _paginationListenerAttached = false;
  void _attachPaginationListener() {
    if (_paginationListenerAttached) return;  // ✅ prevents duplicate attach
    _paginationListenerAttached = true;

    itemPositionsListener.itemPositions.addListener(onPositionsChanged);

  }

  void onPositionsChanged() {

    if (controller.isPageLoading || !controller.hasMore) return;

    final positions = itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;
    // When reverse:true, loading older messages happens when you reach the "top".
    // In practice: the highest index becomes visible.
    final maxVisibleIndex = positions
        .where((p) => p.itemTrailingEdge > 0) // visible
        .map((p) => p.index)
        .reduce((a, b) => a > b ? a : b);

    // near the end (top side in reverse list)
    if (maxVisibleIndex >= controller.chatRows.length - 4) {
      controller.hitAPIToGetChatHistory("pagination", user: controller.user!);
    }
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatScreenController>(builder: (controller) {
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: WillPopScope(
            onWillPop: () {
              // Get.find<ChatHomeController>().localPage.value = 1;
              // Get.find<ChatHomeController>().hitAPIToGetRecentChats(page: 1);
              return Future.value(true);
            },
            child: SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  scrolledUnderElevation: 0,
                  surfaceTintColor: Colors.white,
                  backgroundColor: Colors.white,
                  automaticallyImplyLeading: false,
                  flexibleSpace: MediaQuery( // ✅ clamp text scale for web
                    data: MediaQuery.of(context).copyWith(textScaleFactor: _textScaleClamp(context)),
                    child: _appBar(),
                  ),
                ),
                backgroundColor: const Color.fromARGB(255, 234, 248, 255),
                body: ScrollConfiguration(
                  behavior: const _NoGlowScrollBehavior(),
                  child: _mainBody(context),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _mainBody(context){
    final  username =controller.user?.userCompany?.displayName!=null?controller.user?.userCompany?.displayName ?? '':controller.user?.userName!=null?controller.user?.userName?? '':controller.user?.phone?? '';
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _maxChatWidth(Get.context!)),
        child: Padding(
          padding: _shellHPadding(Get.context!),
          child: Column(
            children: [
              Expanded(child: RepaintBoundary(child: chatMessageBuilder())),
              if (controller.replyToMessage != null)
                _replyMessageWidgetCancel(username),
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
              if (kIsWeb) _chatInput(context) else _chatInputMobile(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _replyMessageWidgetCancel(username){
    return  Container(
      padding: const EdgeInsets.all(6),
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
            height: 45,
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
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${controller.replyToMessage?.fromUser?.userId == APIs.me?.userId ? 'You' : username}",
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: themeData
                          .textTheme.bodySmall
                          ?.copyWith(
                          color: greyText),
                    ),
                  ],
                ).paddingSymmetric(
                    horizontal: 4),

                Text(
                  " : ",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: themeData.textTheme.bodySmall
                      ?.copyWith(color: appColorYellow),
                ),

                isDocument(controller
                    .replyToMessage
                    ?.message??'')? Text(
                  controller.replyToMessage
                      ?.replyToText ??
                      '',
                  maxLines: 2,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style: themeData
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                      color:
                      greyText),
                ):

                controller.isImageOrVideo(controller
                    .replyToMessage
                    ?.message??'')? Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius
                            .circular(8),
                        border: Border.all(
                            color:
                            appColorGreen,
                            width: .3)),
                    child: CustomCacheNetworkImage(
                      controller
                          .replyToMessage
                          ?.message??'',
                      width: 50,
                      height: 50,
                      radiusAll: 8,
                      borderColor:
                      appColorGreen,
                      boxFit: BoxFit.cover,
                    )
                ):Flexible(
                  child: Text(
                    controller.replyToMessage
                        ?.message ??
                        '',
                    maxLines: 2,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style: themeData
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                        color:
                        greyText),
                  ),
                )
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
    );
  }

  Widget chatMessageBuilder() {
    return  groupListView();
  }

  groupListView() {
   return controller.showPostShimmer?const IndicatorLoading(): (controller.chatRows ?? []).isNotEmpty
        ? ScrollablePositionedList.builder(
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        itemCount: controller.chatRows.length,
        reverse: true,
        padding: const EdgeInsets.only(bottom: 30),
        itemBuilder: (context, index) {
          final row = controller.chatRows[index];
          if (row is ChatHeaderRow) {
            return _createGroupHeader(row.date);
          }
          final msgRow = row as ChatMessageRow;
          final element = msgRow.element;
          final msg = element.chatMessageItems;
          final chatId = msg.chatId ?? 0;
          String formatedTime = '';
          if (msg.sentOn != null && msg.sentOn!.isNotEmpty) {
            formatedTime = convertUtcToIndianTime(msg.sentOn!);
          }

          final isHighlighted = controller.highlightedChatId == chatId;
          final userid = APIs.me?.userId;
          final data = element.chatMessageItems;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            color: isHighlighted ? appColorGreen.withOpacity(.3) : null,
            child: SwipeTo(
              iconColor: appColorGreen,
              key: ValueKey(element.chatMessageItems.chatId),
              onRightSwipe: element.chatMessageItems.isActivity == 1
                  ? (v) {}
                  : (detail) async {
                final lockedData = data;
                final media = lockedData.media;
                if (media == null || media.isEmpty) {
                  controller.refIdis = lockedData.chatId;
                  controller.userIDSender = lockedData.fromUser?.userId;
                  controller.userNameReceiver = lockedData.toUser?.userCompany?.displayName ?? '';
                  controller.userNameSender =lockedData.fromUser?.userCompany?.displayName ?? '';
                  controller.userIDReceiver = lockedData.toUser?.userId;
                  controller.replyToMessage = lockedData;
                  controller.update();
                  controller.messageParentFocus.unfocus();
                  if (controller.messageParentFocus.canRequestFocus) {
                    controller.messageParentFocus.requestFocus();
                  }
                } else {
                  final firstMedia = media.first;
                  controller.refIdis = lockedData.chatId;
                  controller.userIDSender = lockedData.fromUser?.userId;
                  controller.userNameReceiver = lockedData.toUser?.userCompany?.displayName ?? '';
                  controller.userNameSender = lockedData.fromUser?.userCompany?.displayName ?? '';
                  controller.userIDReceiver = lockedData.toUser?.userId;
                  controller.replyToImage = firstMedia.orgFileName;
                  final isDoc = firstMedia.mediaType?.mediaCode == "DOC";
                  final msg = isDoc
                      ? (firstMedia.orgFileName ?? '')
                      : "${ApiEnd.baseUrlMedia}${firstMedia.fileName ?? ''}";
                  controller.replyToMessage = ChatHisList(
                    chatId: lockedData.chatId,
                    fromUser: lockedData.fromUser,
                    toUser: lockedData.toUser,
                    message: msg,
                    replyToId: lockedData.chatId,
                    replyToText: firstMedia.orgFileName,
                    replyToMedia:msg,
                  );
                  controller.update();
                  controller.messageParentFocus.unfocus();
                  if (controller.messageParentFocus.canRequestFocus) {
                    controller.messageParentFocus.requestFocus();
                  }
                }
              },
              child: _chatMessageTile(
                  data: element.chatMessageItems,
                  sentByMe: (userid?.toString() ==
                      element.chatMessageItems.fromUser?.userId
                          ?.toString()
                      ? true
                      : false),
                  formatedTime: formatedTime),
            ),
          );
        })
        : const Center(
        child: Text('Say Hii! 👋', style: TextStyle(fontSize: 20)));
  }

  Widget _createGroupHeader(DateTime date) {
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final dateText =
    isToday ? "Today" : DateFormat.yMMMd().format(date);
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

/*  Widget groupListView() {
    // final initialIndex = (controller.flatRows.isEmpty)
    //     ? 0
    //     : controller.flatRows.length - 1;
 return   controller.chatCatygory != [] ||
        (controller.chatCatygory ?? []).isNotEmpty
        ? NotificationListener<ScrollNotification>(
   onNotification: (n) {

     if (n is ScrollEndNotification &&
         n.metrics.extentAfter <= 0 &&
         !controller.isPageLoading &&
         controller.hasMore) {

       controller.isPageLoading = true;
       controller.hitAPIToGetChatHistory("groupListView");
     }

     return false;
   },
          child: GroupedListView<GroupChatElement, DateTime>(
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
            var userid = APIs.me?.userId;
            return  SwipeTo(
              iconColor: appColorGreen,
              onRightSwipe: element.chatMessageItems.isActivity == 1
                  ? (v) {
              }
                  : (detail) {

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
                    controller.messageParentFocus.requestFocus();
                  } else {
                    if (media.length == 1) {
                      final firstMedia = media.first;
                      controller.refIdis = element.chatMessageItems.chatId;
                      controller.userIDSender =
                          element.chatMessageItems.fromUser?.userId;
                      controller.userNameReceiver =
                          element.chatMessageItems.toUser?.userCompany
                              ?.displayName ?? '';
                      controller.userNameSender =
                          element.chatMessageItems.fromUser?.userCompany
                              ?.displayName ?? '';
                      controller.userIDReceiver =
                          element.chatMessageItems.toUser?.userId;

                      controller.replyToImage = firstMedia.orgFileName;

                      final isDoc = firstMedia.mediaType?.mediaCode == "DOC";
                      final msg = isDoc
                          ? (firstMedia.orgFileName ?? '')
                          : "${ApiEnd.baseUrlMedia}${firstMedia.fileName ??
                          ''}";

                      controller.replyToMessage = ChatHisList(
                        chatId: element.chatMessageItems.chatId,
                        fromUser: element.chatMessageItems.fromUser,
                        toUser: element.chatMessageItems.toUser,
                        message: msg,
                        replyToId: element.chatMessageItems.chatId,
                        replyToText: firstMedia.orgFileName,
                      );

                      controller.update();
                      controller.messageParentFocus.requestFocus();
                    }
                    else {
                      toast("Tap to enter details and than can reply over image");
                    }
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
            );
          }),
        )
        : const Center(
        child: Text('Say Hii! 👋', style: TextStyle(fontSize: 20)));



*/
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
                  controller.handleForwardMobile(chatId: data.chatId);
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
                  maxWidth: (kIsWeb ? 250 : Get.width*0.75),
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
                          (data.media ?? []).isNotEmpty ? 12 : 15,
                          vertical:
                          (data.media ?? []).isNotEmpty ? 0 : 10,
                        ),
                        margin: sentByMe
                            ? const EdgeInsets.only(
                            left: 6, top: 10, right: 6)
                            : const EdgeInsets.only(
                            right: 6, top: 10, left: 6),

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
                  controller.handleForwardMobile(chatId: data.chatId);
                },
                icon: Image.asset(
                  forwardIcon,
                  height: 20,
                ))
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
    final isEmojiMsg = isEmojiOnlyMessage(data.message??'');
    return Container(
      key: ValueKey('msg-${data.chatId}'),
      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          data.replyToId != null
              ? ReplyMessageWidget(
              isCancel: false,
              sentByMe: sentByMe,
              onReplu: (){
                final int? replyId = data.replyToId; // confirm field name
                if (replyId != null) {
                  // controller.jumpToRepliedMessage(replyId);
                }
              },
              empIdsender: data.fromUser?.userId.toString(),
              chatdata: data,
              empIdreceiver: data.toUser?.userId.toString(),
              empName: data.isGroupChat == 1
                  ? data.fromUser?.userCompany?.displayName ?? ''
                  : data.fromUser?.userId.toString() ==
                  APIs.me?.userId?.toString()
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
                    data.fromUser?.userId == APIs.me?.userId
                        ? "You"
                        :
                    data.fromUser?.userCompany?.displayName!=null?  (data.fromUser?.userCompany?.displayName ?? ''):data.fromUser?.userName!=null? (data.fromUser?.userName ?? ''):(data.fromUser?.phone??''),
                    style: BalooStyles.baloonormalTextStyle(
                        color:
                        data.fromUser?.userId == APIs.me?.userId
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
            top: 8,

          )
              : const SizedBox(),
          data.message != '' || data.message != null
              ? Text(data.message ?? '',
              textAlign: TextAlign.start,
              style: BalooStyles.baloonormalTextStyle(
                color: Colors.black87,
                size:isEmojiMsg?40: 15,
              ),
              overflow: TextOverflow.visible)
              : const SizedBox(),
          ((data.media ?? []).isNotEmpty)
              ? ChatMessageMedia(
                  chat: data,
                  isGroupMessage: data.isGroupChat==1?true:false,
                  myId: (APIs.me?.userId ?? 0).toString(),
                  fromId: (data.fromUser?.userId ?? 0).toString(),
                  senderName:data.fromUser?.userCompany?.displayName!=null? data.fromUser?.userCompany?.displayName ?? '':data.fromUser?.userName??'',
                  baseUrl: ApiEnd.baseUrlMedia,
                  defaultGallery: defaultGallery,
                  onOpenDocument: (url) =>
                      openDocumentFromUrl(url), // your existing function
                  onOpenImageViewer: (mediaurls, startIndex) {
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

                  },
                  onOpenAudio: (url) {
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
              controller.onSearch(val, controller.user!);
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
            },
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      if (Get.previousRoute.isNotEmpty) {
                        Get.back();
                      } else {
                        Get.offAllNamed(AppRoutes.home); // or your main route
                      }
                      if(!kIsWeb) {
                        // Get.find<ChatHomeController>().localPage.value = 1;
                        // Get.find<ChatHomeController>().hitAPIToGetRecentChats(page: 1);
                        // if (isTaskMode) {
                        //   Get.find<DashboardController>().updateIndex(1);
                        // } else {
                        //   Get.find<DashboardController>().updateIndex(0);
                        // }
                      }
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

               hGap(8),

                //user name & last seen time
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

        controller.isSearching?const SizedBox():  (controller.user?.userCompany?.isBroadcast==1 ||controller.user?.userCompany?.isGroup==1) ?const SizedBox():  CustomTextButton(onTap: (){
          final u = controller.user;
          if(kIsWeb){
            Get.toNamed(
              '${AppRoutes.tasks_li_r}?userId=${u?.userId}',
            );
          }else{
            Get.toNamed(AppRoutes.tasks_li_r,arguments: {'user':controller.user});
          }


        }, title: "Go to Task"),
        controller.isSearching?const SizedBox():  hGap(10),
        IconButton(
            onPressed: () {
              controller.isSearching = !controller.isSearching;
              controller.update();
              if(!controller.isSearching){
                controller.searchQuery = '';
                controller.onSearch('', controller.user!);
                controller.seacrhCon.clear();
              }
              controller.update();
            },
            icon:  controller.isSearching?  const Icon(
                CupertinoIcons.clear_circled_solid)
                : Image.asset(searchPng,height:25,width:25)
        ).paddingOnly(top: 0, right: 0),
        controller.isSearching?const SizedBox():hGap(10),
        controller.isSearching?const SizedBox(): (controller.user?.userCompany?.isGroup == 1 ||
            controller.user?.userCompany?.isBroadcast == 1)
            ? PopupMenuButton<String>(
          color: Colors.white,
          iconColor: Colors.black87,
          onSelected: (value) {
            if (value == 'AddMember') {
              if (kIsWeb) {
                openAllUserDialog(controller.user);
              } else {
                openAllUserDialog(controller.user);
                // Get.toNamed(
                //   AppRoutes.add_group_member,
                //   arguments: {'groupChat': controller.user},
                // );
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

  Future<void> openAllUserDialog(UserDataAPI? user) async {
    if (Get.isRegistered<AddGroupMemController>()) {
      Get.delete<AddGroupMemController>(force: true);
    }

    final c = Get.put(AddGroupMemController());
    c.setGroupChat(user);

    try {
      await Get.dialog(
        Dialog(
          insetPadding: const EdgeInsets.all(12),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SizedBox(
            width: Get.width * 0.8,
            height: Get.height * 0.9,
            child: const AddGroupMembersScreen(),
          ),
        ),
        barrierDismissible: true,
      );
    } finally {
      if (Get.isRegistered<AddGroupMemController>()) {
        Get.delete<AddGroupMemController>();
      }
    }
  }

  _changeLanguage(){
    return PopupMenuButton<String>(
      color: Colors.white,
      tooltip: 'Voice language',
      onSelected: (v) {
        speechC.updateSelectedLang(v);
        controller.update();
      },
      itemBuilder: (_) =>  [
        PopupMenuItem(value: 'en-IN', child: Text('English',style: BalooStyles.baloonormalTextStyle(),)),
        PopupMenuItem(value: 'hi-IN', child: Text('Hindi',style: BalooStyles.baloonormalTextStyle())),
      ],
      child:  Image.asset(translationPng, height: 20,color:speechC.selectedLang=="hi-IN"? appColorGreen:appColorYellow,),
    );
  }

  _micButton(Function() appendSpeechToInput){
    return  Obx(() {
      final listening = speechC.isListening.value;
      return Builder(
        builder: (micContext) {
          return InkWell(
            onTap: () {
              if (!speechC.isSupported) {
                Dialogs.showSnackbar(Get.context!, 'Voice-to-text is not supported in this browser.');
                return;
              }

              speechC.setLanguage(langCode: speechC.selectedLang);

              if (listening) {
                speechC.stop(skipOnStopped:true);
                appendSpeechToInput();
              } else {
                speechC.start();
              }
            },

            onLongPress: () async {
              if (speechC.isListening.value) speechC.stop(skipOnStopped:true);

              final RenderBox button = micContext.findRenderObject() as RenderBox;
              final RenderBox overlay =
              Overlay.of(micContext).context.findRenderObject() as RenderBox;

              final RelativeRect position = RelativeRect.fromRect(
                Rect.fromPoints(
                  button.localToGlobal(Offset.zero, ancestor: overlay),
                  button.localToGlobal(button.size.bottomRight(Offset.zero),
                      ancestor: overlay),
                ),
                Offset.zero & overlay.size,
              );

              final selected = await showMenu<String>(
                context: micContext,
                position: position,
                color: Colors.white,
                items:  [
                  PopupMenuItem(value: 'en-IN', child: Text('English',style: BalooStyles.baloonormalTextStyle(),)),
                  PopupMenuItem(value: 'hi-IN', child: Text('Hindi',style: BalooStyles.baloonormalTextStyle())),
                ],
              );

              if (selected != null) {
                speechC.updateSelectedLang(selected);
                controller.update();
              }
            },

            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: listening
                      ? Colors.red.withOpacity(.35)
                      : AppTheme.appColor.withOpacity(.3),
                ),
                color: listening
                    ? Colors.red.withOpacity(.08)
                    : AppTheme.appColor.withOpacity(.05),
              ),
              child: Image.asset(
                listening ? pausePng : micPng,
                color: listening ? Colors.red : AppTheme.appColor,
                height: 20,
              ),
            ),
          );
        },
      );
    })
    ;

  }

  bool isVisibleUpload = true;

  Widget _chatInput(BuildContext context) {
  void appendSpeechToInput() {
      final text = speechC.getCombinedText();
      if (text.isEmpty) return;
      final old = controller.textController.text.trim();
      controller.textController.text = old.isEmpty ? text : '$old $text';
      controller.textController.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.textController.text.length),
      );
      speechC.finalText.value = '';
      speechC.interimText.value = '';
    }

    // void _hardFocusBack() {
    //   FocusManager.instance.primaryFocus?.unfocus();
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (controller.messageParentFocus.canRequestFocus) {
    //       controller.messageParentFocus.requestFocus();
    //     }
    //   });
    // }

    void _send() {
      if (kIsWeb && speechC.isListening.value) {
        speechC.stop(skipOnStopped:true);
        appendSpeechToInput();
      }
      _sendMessage();
      // _hardFocusBack();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _changeLanguage(),
          hGap(10),

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Listening strip
                Obx(() {
                  if (!kIsWeb || !speechC.isListening.value) {
                    return const SizedBox.shrink();
                  }

                  final live = speechC.getCombinedText();
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.appColor.withOpacity(.15)),
                      color: AppTheme.appColor.withOpacity(.04),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.graphic_eq, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            live.isEmpty ? 'Listening...' : live,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: themeData.textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            speechC.stop(skipOnStopped:true);
                            appendSpeechToInput();
                            // _hardFocusBack();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.red.withOpacity(.10),
                              border: Border.all(color: Colors.red.withOpacity(.25)),
                            ),
                            child: const Text('Stop', style: TextStyle(color: Colors.red)),
                          ),
                        )
                      ],
                    ),
                  );
                }),

                // ✅ Input Row (field + icons)
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: Get.height * .3, minHeight: 30),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.appColor.withOpacity(.2)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          // ✅ Focus wrapper WITHOUT focusNode (prevents cycle)
                          child: Focus(
                            // skipTraversal: true,
                            onKeyEvent: (node, event) {
                              if (!kIsWeb) return KeyEventResult.ignored;
                              if (event is! KeyDownEvent) return KeyEventResult.ignored;

                              if (event.logicalKey == LogicalKeyboardKey.enter) {
                                final keys = HardwareKeyboard.instance.logicalKeysPressed;
                                final shiftPressed =
                                    keys.contains(LogicalKeyboardKey.shiftLeft) ||
                                        keys.contains(LogicalKeyboardKey.shiftRight);

                                if (shiftPressed) return KeyEventResult.ignored; // newline

                                _sendMessage();

                                // ✅ hard reattach focus (web)
                                // FocusManager.instance.primaryFocus?.unfocus();
                                // WidgetsBinding.instance.addPostFrameCallback((_) {
                                //   controller.messageParentFocus.requestFocus();
                                // });

                                return KeyEventResult.handled;
                              }

                              return KeyEventResult.ignored;
                            },
                            child: TextFormField(
                              controller: controller.textController,
                              focusNode: controller.messageParentFocus, // ✅ only here
                              autofocus: !kIsWeb, // web me autofocus glitch karta hai
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              maxLines: null,
                              minLines: 1,
                              onTap: () {
                                // web reattach
                                // WidgetsBinding.instance.addPostFrameCallback((_) {
                                //   controller.messageParentFocus.requestFocus();
                                // });
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Type Something...',
                                hintStyle: BalooStyles.baloonormalTextStyle(),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,

                              ),
                            ),
                          ),
                        ),

                        if (kIsWeb) _micButton(appendSpeechToInput),

                        if (!isTaskMode)
                          InkWell(
                            onTap: () async {
                              showUploadOptions(context);
                              // WidgetsBinding.instance.addPostFrameCallback((_) {
                              //   controller.messageParentFocus.requestFocus();
                              // });
                            },
                            child: IconButtonWidget(Icons.upload_outlined, isIcon: true),
                          ),

                        if (!isTaskMode)
                          InkWell(
                            onTap: () async {
                              openWhatsAppEmojiPicker(
                                context: context,
                                textController: controller.textController,
                                onSend:() {
                                  // WidgetsBinding.instance.addPostFrameCallback((_) {
                                  //   controller.messageParentFocus.requestFocus();
                                  // });
                                } ,
                                isMobile: false,
                              );
                            },
                            child: IconButtonWidget(emojiPng),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          hGap(6),
          InkWell(
            onTap: _send,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: appColorGreen,
              ),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ).marginOnly(bottom: 4, top: 4),
        ],
      ),
    );
  }

/*  Widget _chatInput(context) {
    final speechC = Get.put(SpeechControllerImpl(), permanent: true);
    void _appendSpeechToInput() {
      final text = speechC.getCombinedText();
      if (text.isEmpty) return;

      final old = controller.textController.text.trim();
      controller.textController.text = old.isEmpty ? text : '$old $text';

      controller.textController.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.textController.text.length),
      );

      // reset cached result so next time fresh start
      speechC.finalText.value = '';
      speechC.interimText.value = '';
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: mq.width * .025),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _changeLanguage(),
          hGap(4),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✅ Listening strip (premium feel)
                        Obx(() {
                          if (!kIsWeb) return const SizedBox.shrink();
                          if (!speechC.isListening.value) return const SizedBox.shrink();

                          final live = speechC.getCombinedText();
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.appColor.withOpacity(.15)),
                              color: AppTheme.appColor.withOpacity(.04),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.graphic_eq, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    live.isEmpty ? 'Listening...' : live,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: themeData.textTheme.bodySmall,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    speechC.stop();
                                    _appendSpeechToInput();
                                    speechC.update();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.red.withOpacity(.10),
                                      border: Border.all(color: Colors.red.withOpacity(.25)),
                                    ),
                                    child: const Text('Stop', style: TextStyle(color: Colors.red)),
                                  ),
                                )
                              ],
                            ),
                          );
                        }),

                       */
  Widget _chatInputMobile(context) {
    return Container(
      // height: Get.height*.4,
      padding: const EdgeInsets.symmetric(
          vertical: 4, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          //input field & buttons
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        /*Focus(
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
                                      onChanged: (v){
                                        if(controller.textController.text!=''){
                                          isVisibleUpload = false;
                                        }else{
                                          isVisibleUpload = true;
                                        }
                                        controller.update();
                                      },
                                      decoration: InputDecoration(
                                        isDense: true,
                                        hintText: 'Type Something...',
                                        hintMaxLines: 1,
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
                        )*/
                        Shortcuts(
                          shortcuts: <ShortcutActivator, Intent>{
                            const SingleActivator(LogicalKeyboardKey.enter): const ActivateIntent(),
                          },
                          child: Actions(
                            actions: <Type, Action<Intent>>{
                              ActivateIntent: CallbackAction<Intent>(
                                onInvoke: (intent) {
                                  if (!kIsWeb) return null;
                                  // If shift is pressed, let TextField handle newline naturally
                                  final keys = HardwareKeyboard.instance.logicalKeysPressed;
                                  final shiftPressed = keys.contains(LogicalKeyboardKey.shiftLeft) ||
                                      keys.contains(LogicalKeyboardKey.shiftRight);
                                  if (shiftPressed) return null;

                                  _sendMessage();
                                  // controller.messageParentFocus.requestFocus(); // keep focus after send
                                  return null;
                                },
                              ),
                            },
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: Get.height * .3, minHeight: 30),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.appColor.withOpacity(.2)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: controller.textController,
                                        focusNode: controller.messageParentFocus,
                                        autofocus: false,
                                        keyboardType: TextInputType.multiline,
                                        textInputAction: TextInputAction.newline,
                                        maxLines: null,
                                        minLines: 1,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          hintText: 'Type Something...',
                                          hintStyle: BalooStyles.baloonormalTextStyle(),
                                          hintMaxLines: 1,
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
                                      Obx(() => Visibility(
                                        visible: controller.showUpload.value,
                                        child:InkWell(
                                          onTap: () => showUploadOptions(Get.context!),
                                          child: IconButtonWidget(Icons.upload_outlined,isIcon:true),

                                        ),
                                      )),

 if (!isTaskMode)
                                      InkWell(
                                        onTap: () async {
                                          openWhatsAppEmojiPicker(
                                            context: context,
                                            textController: controller.textController,
                                            onSend:() {
                                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                                controller.messageParentFocus.requestFocus();
                                              });
                                            },
                                            isMobile: false,
                                          );

                                        },
                                        child: IconButtonWidget(emojiPng),
                                      ),
                                  ],
                                ),
                              ),
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
          hGap(6),
          InkWell(
            onTap: () async {
              _sendMessage();
            },
            child: Container(
              padding: const EdgeInsets.all(10),
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
      isVisibleUpload =true;
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
                leading:  const Icon(Icons.camera_alt_outlined,size: 20,),
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
                leading:  const Icon(Icons.photo_library_outlined,size: 20,),
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
                leading:  const Icon(Icons.picture_as_pdf_outlined,size: 20,),
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
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'txt',
        'xls',
        'xlsx',
        'csv',
        'xml',
        'json',
        'ppt',
        'pptx',
        'zip',
        'html',
        'php',
        'js',
        'jsx',
        'css',
        'rar',
        'PDF',
        'DOC',
        'HTML',
        'PHP',
        'JS',
        'JSX',
        'CSS',
        'DOCX',
        'TXT',
        'XLS',
        'XLSX',
        'CSV',
        'XML',
        'JSON',
        'PPT',
        'PPTX',
        'ZIP',
        'RAR',
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

              (((data.media ?? []).isNotEmpty && data.media?.length == 1) ||data.message!='')
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
                      controller.messageParentFocus.unfocus();
                      if (controller.messageParentFocus.canRequestFocus) {
                        controller.messageParentFocus.requestFocus();
                      }
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
                      controller.messageParentFocus.unfocus();
                      if (controller.messageParentFocus.canRequestFocus) {
                        controller.messageParentFocus.requestFocus();
                      }
                    }
                  })
                  : const SizedBox(),
              ((data.media ?? []).isNotEmpty && data.media?.length == 1)?
              _OptionItem(
                  icon:  Icon(Icons.document_scanner,
                      color: appColorYellow, size: 18),
                  name: 'Save to Smart Gallery',
                  onTap: () async {
                    try {
                      final mediachat  = data.media?.first;
                      Get.back();
                      final saveC = Get.isRegistered<SaveToGalleryController>()
                          ? Get.find<SaveToGalleryController>()
                          : Get.put(SaveToGalleryController());

                      await saveC.hitApiToGetFolder();

                      final picked=  [PickedFileItem(
                        name: mediachat?.orgFileName??'',
                        // byte: image.bytes,         // web always, mobile if withData true
                        path: "${ApiEnd.baseUrlMedia}${mediachat?.fileName}",          // mobile path
                        kind: PickedKind.image,
                        url: "${ApiEnd.baseUrlMedia}${mediachat?.fileName}",
                      )];
                      saveC.docNameController.text = mediachat?.orgFileName??'';
                      showDialog(
                          context: Get.context!,
                          builder: (_) => SaveToCustomFolderDialog(
                            isDirect: true,
                            multi: false,
                            user: controller.user,filesImages: picked,isImage: true, isFromChat: true,
                            chatId: mediachat?.chatMediaId, folderData: null,));
                    } catch (e) {
                      toast('Something went wrong!');
                    }
                  }):const SizedBox(),
              /*_OptionItem(
                    icon:  Icon(Icons.document_scanner,
                        color: appColorYellow, size: 18),
                    name: 'Save to Smart Gallery',
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

              // delete option
              if (APIs.me?.userId == controller.myCompany?.createdBy && isMe)
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

              (
                  (data.media?.length == 1) ||
                      ((data.media == null || data.media!.isEmpty) && (data.message?.isNotEmpty ?? false))
              )

                  ? _OptionItem(
                  icon: Icon(Icons.share, color: appColorGreen, size: 16),
                  name: 'Share on WhatsApp',
                  onTap: () async {
                    if (kIsWeb) {
                      final msg = data.message ?? '';
                      if(msg!='') {
                        print("Sharing");
                        ShareHelper.shareOnWhatsApp(msg);
                      }else{
                        ShareHelper.shareOnWhatsApp("${ApiEnd.baseUrlMedia}${data.media?.first.fileName??''}");
                      }

                    }else{
                      final msg = data.message ?? '';
                      if(msg!='') {
                        print("printing.........$msg");
                        ShareHelper.shareOnWhatsApp(msg);
                      }else{
                      await ShareHelper.shareNetworkFile(
                        "${ApiEnd.baseUrlMedia}${data.media?.first.fileName??''}",
                        text: "From AccuChat",
                        fileName: data.media?.first.orgFileName??'', // optional if you store it
                      );
                      // ShareHelper.shareNetworkImage("${ApiEnd.baseUrlMedia}${data.media?.first.fileName??''}",);
                    }
                    }
                  })
                  : const SizedBox(),
              if ((data.message?.isNotEmpty ?? false)|| (data.media ?? []).isNotEmpty)
                _OptionItem(
                    icon:  Image.asset(
                forwardIcon,
          height: 17,
          ),
                    name:
                    'Forward',
                    onTap: () {
                      Get.back();
                      controller.handleForwardMobile(chatId: data.chatId);
                    }),
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

          final saveGcon = Get.find<SaveToGalleryController>();

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
                          controller: saveGcon.docNameController,
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
                                    saveGcon.onTapSaveToFolder(Get.context!,controller.user);
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
      onOkTap: () {}, isShowActions: false,
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
        sentByMe: (APIs.me?.userId.toString() ==
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
                if (controller.updateMsgController.text.trim().isNotEmpty) {
                Get.find<SocketController>().updateChatMessage(
                    chatId: message.chatId,
                    toUcId: message.toUser?.userCompany?.userCompanyId,
                    message: controller.updateMsgController.text.trim()
                );
                Get.back();
    }else{
                  Get.back();
                  Dialogs.showSnackbar(context, "Message cannot be blank");
    }
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
  final Widget icon;
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
          child: Row(
            children: [
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
