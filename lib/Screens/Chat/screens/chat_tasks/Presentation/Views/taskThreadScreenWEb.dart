import 'package:AccuChat/Screens/Chat/models/task_commets_res_model.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_thread_controller.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:dio/dio.dart' show Dio;
import 'package:flutter/foundation.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../Constants/app_theme.dart';
import '../../../../../../Constants/assets.dart';
import '../../../../../../Constants/colors.dart';
import '../../../../../../Constants/themes.dart';
import '../../../../../../main.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../../utils/emogi_checker.dart';
import '../../../../../../utils/emogi_picker_web.dart';
import '../../../../../../utils/helper_widget.dart';
import '../../../../../../utils/product_shimmer_widget.dart';
import '../../../../../Home/Presentation/Controller/socket_controller.dart';
import '../../../../../voice_to_texx/speech_controller_factory.dart';
import '../../../../helper/dialogs.dart';
import '../../../../models/chat_history_response_model.dart';
import '../../../../api/apis.dart';

class TaskThreadScreenWeb extends GetView<TaskThreadController> {
  TaskThreadScreenWeb({
    super.key,
  });
  final controller = Get.put<TaskThreadController>(TaskThreadController());
  final speechC = Get.put(SpeechControllerImpl());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskThreadController>(builder: (controller) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Task Reply",
                  style: BalooStyles.baloomediumTextStyle(color: appColorGreen),
                ),
              ),
              hGap(15),
              
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.currentUser?.userCompany?.displayName != null ? controller.currentUser?.userCompany?.displayName??'' :controller.currentUser?.userName !=null? controller.currentUser?.userName ?? ''
                        :controller.currentUser?.phone ?? '' ,
                    style: BalooStyles.balooboldTitleTextStyle(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  IconButton(onPressed: (){
                    // Get.find<TaskController>().page = 1;
                    // Get.find<TaskController>().taskHisList = []; // <--- MOST IMPORTANT
                    // Get.find<TaskController>().taskCategory = [];
                    // Get.find<TaskController>().hasMore = false;
                    final taskC= Get.find<TaskController>();
                    taskC.resetPaginationForNewChat();
                    taskC.searchQuery = '';
                    taskC.onSearch('');
                    taskC.seacrhCon.clear();
                    taskC.hitAPIToGetTaskHistory();
                    Get.back();
                  }, icon: Icon(Icons.clear,color: Colors.black87,)),
                ],
              )

            ],
          ),
          vGap(8),
          Container(
            width: Get.width,
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: getTaskStatusColor(controller
                        .taskMessage?.currentStatus?.name?.capitalizeFirst)
                    .withOpacity(.1),
                border: Border.all(
                    color: getTaskStatusColor(controller
                        .taskMessage?.currentStatus?.name?.capitalizeFirst)),
                //making borders curved
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(15))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultSelectionStyle(
                  selectionColor: appColorPerple.withOpacity(0.3),
                  cursorColor: appColorPerple,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_outlined, // <-- your title icon
                        size: 18,
                        color: appColorGreen,
                      ).paddingOnly(right: 6),

                      // Text + links
                      Expanded(
                        child: SelectableLinkify(
                          text: controller.taskMessage?.title ?? '',
                          onOpen: (link) {
                            launchUrl(
                              Uri.parse(link.url),
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          style: BalooStyles.baloosemiBoldTextStyle(
                            color: Colors.black87,
                            size: 15,
                          ),
                          linkStyle: BalooStyles.baloonormalTextStyle(
                            color: Colors.blue,
                            size: 15,
                          ),
                          linkifiers: const [
                            UrlLinkifier(),
                          ],
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                /* DefaultSelectionStyle(
                  selectionColor:
                      appColorPerple.withOpacity(0.3), // text select background
                  cursorColor: appColorPerple,
                  child: SelectableLinkify(
                    text: controller.taskMessage?.title ?? '',
                    onOpen: (link) {
                      launchUrl(Uri.parse(link.url),
                          mode: LaunchMode.externalApplication);
                    },
                    style: BalooStyles.baloosemiBoldTextStyle(
                      color: Colors.black87,
                      size: 15,
                    ),
                    linkStyle: BalooStyles.baloonormalTextStyle(
                      color: Colors.blue,
                      size: 15,
                    ),
                    linkifiers: const [
                      UrlLinkifier(), // <-- THIS handles multiple links inside single text
                    ],
                    maxLines: 1,
                  ),
                ),*/
                vGap(5),
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 60),
                        child: DefaultSelectionStyle(
                          selectionColor: appColorPerple
                              .withOpacity(0.3), // text select background
                          cursorColor: appColorPerple,
                          child: SelectableLinkify(
                            text: controller.taskMessage?.details ?? '',
                            onOpen: (link) {
                              launchUrl(Uri.parse(link.url),
                                  mode: LaunchMode.externalApplication);
                            },
                            style: BalooStyles.baloonormalTextStyle(
                              color: Colors.black87,
                            ),
                            linkStyle: BalooStyles.baloonormalTextStyle(
                              color: Colors.blue,
                            ),
                            linkifiers: const [
                              UrlLinkifier(), // <-- THIS handles multiple links inside single text
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if ((controller.taskMessage?.deadline ?? '').isNotEmpty) ...[
                  vGap(8),
                  Text(
                      "⏱️ Est. Time: ${estimateLabel(deadlineIso: controller.taskMessage?.deadline ?? '', createdIso: controller.taskMessage?.createdOn ?? '')}",
                      style:
                          BalooStyles.balooregularTextStyle(color: Colors.red)),
                ],
                vGap(8),
                Text("Member: ${controller.joined}",
                    style: BalooStyles.baloothinTextStyle()),
              ],
            ),
          ),
          Expanded(
            child: RepaintBoundary(child: chatMessageBuilder()),
          ),
          if (controller.isUploading)
            const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: CircularProgressIndicator(strokeWidth: 2))),
          _chatInput(context),
        ],
      ).paddingSymmetric(horizontal: 10, vertical: 8);
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
            )),
            child: groupListView(),
          ),
        ),
        // vGap(80)
      ],
    );
  }

  groupListView() {
    return controller.commentsCategory.isNotEmpty
        ?  NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification n) {
          // Only care about scroll updates
          if (n.metrics.pixels >= n.metrics.maxScrollExtent - 80) {
            if (!controller.isPageLoading && controller.hasMore) {
              controller.hitAPIToGetCommentsHistory();
            }
          }
          return false;
        },
          child: GroupedListView<GroupCommentsElement, DateTime>(
              shrinkWrap: false,
              padding: const EdgeInsets.only(bottom: 30),
              controller: controller.scrollController,
              elements: controller.commentsCategory,
              order: GroupedListOrder.DESC,
              reverse: true,
              floatingHeader: true,
              useStickyGroupSeparators: true,
              groupBy: (GroupCommentsElement element) => DateTime(
                    element.date.year,
                    element.date.month,
                    element.date.day,
                  ),
              groupHeaderBuilder: _createGroupHeader,
              indexedItemBuilder: (BuildContext context,
                  GroupCommentsElement element, int index) {
                String formatatedTime = '';
                if (element.comments.sentOn != null) {
                  var timeString = element.comments.sentOn ?? '';

                  formatatedTime = convertUtcToIndianTime(timeString);
                }
                final data = element.comments;
                var userid = APIs.me.userId;
                return SwipeTo(
                  key: ValueKey(element.comments.taskCommentId),
                  iconColor: appColorGreen,
                  onRightSwipe: (detail) {
                    final lockedData =data;
                    // Set the message being replied to
                    controller.refIdis = lockedData.taskCommentId;
                    controller.userIDSender = lockedData.fromUser?.userId;
                    controller.userNameReceiver = lockedData.toUser?.userCompany?.displayName ?? '';
                    controller.userNameSender = lockedData.fromUser?.userCompany?.displayName ?? '';
                    controller.userIDReceiver = lockedData.toUser?.userId;
                    controller.replyToMessage = lockedData;
                    controller.update();
                  },
                  child: _chatMessageTile(
                      data: element.comments,
                      sentByMe: (userid.toString() ==
                              element.comments.fromUser?.userId?.toString()
                          ? true
                          : false),
                      formatedTime: formatatedTime),
                );
              }),
        )
        : const Center(
            child: Text('Say Hii! 👋', style: TextStyle(fontSize: 20)));
  }

  Widget _createGroupHeader(GroupCommentsElement element) {
    return Container(
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(child: divider(color: appColorGreen.withOpacity(.3))),
          Text(DateFormat.yMMMd().format(element.date)),
          Expanded(child: divider(color: appColorGreen.withOpacity(.3))),
        ],
      ),
    );
  }

  Widget _chatMessageTile(
      {required TaskComments data, required bool sentByMe, formatedTime}) {
    return Column(
      crossAxisAlignment:
          sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        vGap(3),
        /*data.replyToId != null
            ? ReplyMessageWidget(
            isCancel: false,
            sentByMe: sentByMe,
            empIdsender: data.fromUser?.userId.toString(),
            chatdata: data,
            empIdreceiver: data.toUser?.userId.toString(),
            empName: data.fromUser?.userId.toString() ==
                controller.me?.userId?.toString()
                ? data.fromUser?.userName ?? ''
                : data.toUser?.userName ?? '',
            message: data.replyToText ?? '')
            .marginOnly(top: 4, bottom: 1)
            : SizedBox(),*/
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // (data.commentText != null &&
            //     (data.media ?? []).isNotEmpty &&
            //     sentByMe)
            //     ? IconButton(
            //     onPressed: () {
            //       // controller.handleForward(chatId: data.chatId);
            //     },
            //     icon: Transform(
            //         alignment: Alignment.center,
            //         transform: Matrix4.rotationX(math.pi),
            //         child: Image.asset(
            //           forwardIcon,
            //           height: 25,
            //         ))).paddingOnly(left: 10)
            //     : SizedBox(),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                    onDoubleTap: () {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      _showBottomSheet(sentByMe, data: data);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: (data.media ?? []).isNotEmpty ? 8 : 15,
                        vertical: (data.media ?? []).isNotEmpty ? 0 : 15,
                      ),
                      margin: sentByMe
                          ? const EdgeInsets.only(left: 15, top: 10, right: 15)
                          : const EdgeInsets.only(right: 15, top: 10, left: 15),
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
                                  sentByMe ? appColorGreen : appColorPerple),
                          //making borders curved
                          borderRadius: sentByMe
                              ? BorderRadius.only(
                                  topLeft: Radius.circular(
                                      (data.media ?? []).isNotEmpty ? 15 : 30),
                                  topRight: Radius.circular(
                                      (data.media ?? []).isNotEmpty ? 15 : 30),
                                  bottomLeft: Radius.circular(
                                      (data.media ?? []).isNotEmpty ? 15 : 30))
                              : BorderRadius.only(
                                  topLeft: Radius.circular(
                                      (data.media ?? []).isNotEmpty ? 15 : 30),
                                  topRight: Radius.circular(
                                      (data.media ?? []).isNotEmpty ? 15 : 30),
                                  bottomRight: Radius.circular(
                                      (data.media ?? []).isNotEmpty
                                          ? 15
                                          : 30))),
                      child: messageTypeView(data, sentByMe: sentByMe),
                    ).marginOnly(left: (0), top: 0),
                  ),
                ],
              ),
            ),
            // (data.commentText != null &&
            //     (data.media ?? []).isNotEmpty &&
            //     !sentByMe)
            //     ? IconButton(
            //     onPressed: () {
            //       // controller.handleForward(chatId: data.chatId);
            //     },
            //     icon: Transform(
            //         alignment: Alignment.center,
            //         transform: Matrix4.rotationY(math.pi),
            //         child: Image.asset(
            //           forwardIcon,
            //           height: 25,
            //         ))).paddingOnly(right: 10)
            //     : SizedBox()
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
            /* hGap(5),
            sentByMe?Icon(
              data.readOn != null ? Icons.done_all : Icons.done,
              size: 14,
              color: data.readOn != null ? Colors.blue : Colors.grey,
            ):SizedBox()*/
          ],
        ).marginOnly(left: 15, right: 15),
      ],
    );
  }

  messageTypeView(TaskComments data, {required bool sentByMe}) {
    final isEmojiMsg = isEmojiOnlyMessage(data.commentText??'');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                  data.fromUser?.userId == APIs.me.userId
                      ? "You"
                      : data.fromUser?.userCompany?.displayName !=
                      null
                      ? (data.fromUser?.userCompany
                      ?.displayName ??
                      '')
                      : data.fromUser?.userName != null
                      ? (data.fromUser?.userName ?? '')
                      : (data.fromUser?.phone ?? ''),
                  style: BalooStyles.baloonormalTextStyle(
                      color: data.fromUser?.userId ==
                          APIs.me?.userId
                          ? Colors.green
                          : Colors.purple),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)
                  .marginOnly(
                      left: sentByMe ? 0 : 0,
                      right: sentByMe ? 10 : 0,
                      bottom: 3,
                      top: 0),
            ),
          ],
        ),
        data.commentText != '' || data.commentText != null
            ? DefaultSelectionStyle(
                selectionColor:
                    appColorPerple.withOpacity(0.3), // text select background
                cursorColor: appColorPerple,
                child: SelectableLinkify(
                  text: data.commentText ?? '',
                  onOpen: (link) {
                    launchUrl(Uri.parse(link.url),
                        mode: LaunchMode.externalApplication);
                  },
                  style: BalooStyles.baloonormalTextStyle(
                    color: Colors.black87,
                    size: isEmojiMsg?50:15
                  ),
                  linkStyle: BalooStyles.baloonormalTextStyle(
                    color: Colors.blue,
                  ),
                  linkifiers: const [
                    UrlLinkifier(), // <-- THIS handles multiple links inside single text
                  ],
                ),
              )
            : const SizedBox(),
        /* ((data.media ?? []).isNotEmpty)
            ? ChatMessageMedia(
          chat: data,
          isGroupMessage: false,
          myId: (APIs.me?.userId ?? 0).toString(),
          fromId: (data.fromUser?.userId ?? 0).toString(),
          senderName: data.fromUser?.userName ?? '',
          baseUrl: ApiEnd.baseUrlMedia,
          defaultGallery: defaultGallery,
          onOpenDocument: (url) =>
              openDocumentFromUrl(url), // your existing function
          onOpenImageViewer: (urls, startIndex) {
            // push your gallery view
            // Get.to(() => ImageViewer(urls: urls, initialIndex: startIndex));
            Get.to(
                  () => GalleryViewerPage(),
              binding: BindingsBuilder(() {
                Get.put(GalleryViewerController(
                    urls: urls, index: startIndex));
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
            : SizedBox(),*/
      ],
    );
  }

  Future<void> openDocumentFromUrl(String url) async {
    customLoader.show();
    try {
      final dir = await getTemporaryDirectory();
      final fileName = url.split('/').last.split('?').first;
      final filePath = '${dir.path}/$fileName';

      // Download using Dio
      await Dio().download(url, filePath);
      customLoader.hide();
      await OpenFilex.open(filePath);
    } catch (e) {
      print("❌ Failed to open document: $e");
      customLoader.hide();
    }
  }


  // bottom chat input field
  Widget _chatInput(BuildContext context) {
    // ✅ don't put controller every rebuild


    void _appendSpeechToInput() {
      final text = speechC.getCombinedText();
      if (text.isEmpty) return;

      final old = controller.msgController.text.trim();
      controller.msgController.text = old.isEmpty ? text : '$old $text';

      controller.msgController.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.msgController.text.length),
      );

      speechC.finalText.value = '';
      speechC.interimText.value = '';
    }

    void _hardFocusBack() {
      FocusManager.instance.primaryFocus?.unfocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.messageParentFocus.canRequestFocus) {
          controller.messageParentFocus.requestFocus();
        }
      });
    }

    void _send() {
      if (kIsWeb && speechC.isListening.value) {
        speechC.stop();
        _appendSpeechToInput();
      }
      _sendThreadMessage();
      _hardFocusBack();
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
                            speechC.stop();
                            _appendSpeechToInput();
                            _hardFocusBack();
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
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _hardFocusBack, // web reattach fix
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
                            // ✅ Focus wrapper WITHOUT focusNode (prevents cycle)
                            child: Focus(
                              skipTraversal: true,
                              onKeyEvent: (node, event) {
                                if (!kIsWeb) return KeyEventResult.ignored;
                                if (event is! KeyDownEvent) return KeyEventResult.ignored;

                                if (event.logicalKey == LogicalKeyboardKey.enter) {
                                  final keys = HardwareKeyboard.instance.logicalKeysPressed;
                                  final shiftPressed =
                                      keys.contains(LogicalKeyboardKey.shiftLeft) ||
                                          keys.contains(LogicalKeyboardKey.shiftRight);

                                  if (shiftPressed) return KeyEventResult.ignored; // newline

                                  _sendThreadMessage();

                                  // ✅ hard reattach focus (web)
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    controller.messageParentFocus.requestFocus();
                                  });

                                  return KeyEventResult.handled;
                                }

                                return KeyEventResult.ignored;
                              },
                              child: TextFormField(
                                controller: controller.msgController,
                                focusNode: controller.messageParentFocus, // ✅ only here
                                autofocus: !kIsWeb, // web me autofocus glitch karta hai
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                maxLines: null,
                                minLines: 1,
                                // onTap: () {
                                //   // web reattach
                                //   WidgetsBinding.instance.addPostFrameCallback((_) {
                                //     controller.messageParentFocus.requestFocus();
                                //   });
                                // },
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

                          if (kIsWeb) _micButton(_appendSpeechToInput),

                   /*       if (!isTaskMode)
                            InkWell(
                              onTap: () async {
                                showUploadOptions(context);
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  controller.messageParentFocus.requestFocus();
                                });
                              },
                              child: IconButtonWidget(Icons.upload_outlined, isIcon: true),
                            ),*/


                            InkWell(
                              onTap: () async {
                                openWhatsAppEmojiPicker(
                                  context: context,
                                  textController: controller.msgController,
                                  onSend: () {
                                    controller.messageParentFocus.unfocus();
                                    if (controller.messageParentFocus.canRequestFocus) {
                                      controller.messageParentFocus.requestFocus();
                                    }
                                  },
                                  isMobile: false,
                                );

                              },
                              child: IconButtonWidget(emojiPng),
                            ),
                        ],
                      ),
                    ),
                  )
                  ,
                ),
              ],
            ),
          ),

          hGap(6),

          InkWell(
            onTap: _send,
            child: Container(
              padding: const EdgeInsets.all(12),
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

  // Widget _chatInput() {
  //
  //   void _appendSpeechToInput() {
  //     final text = speechC.getCombinedText();
  //     if (text.isEmpty) return;
  //
  //     final old = controller.msgController.text.trim();
  //     controller.msgController.text = old.isEmpty ? text : '$old $text';
  //
  //     controller.msgController.selection = TextSelection.fromPosition(
  //       TextPosition(offset: controller.msgController.text.length),
  //     );
  //
  //     // reset cached result so next time fresh start
  //     speechC.finalText.value = '';
  //     speechC.interimText.value = '';
  //   }
  //   return Container(
  //     padding: EdgeInsets.symmetric(
  //         vertical: mq.height * .01, horizontal: mq.width * .025),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.end,
  //       children: [
  //         //input field & buttons
  //         Expanded(
  //           child: SingleChildScrollView(
  //             child: Column(
  //               children: [
  //                 Shortcuts(
  //                   shortcuts: <ShortcutActivator, Intent>{
  //                     const SingleActivator(LogicalKeyboardKey.enter): const ActivateIntent(),
  //                   },
  //                   child: Actions(
  //                     actions: <Type, Action<Intent>>{
  //                       ActivateIntent: CallbackAction<Intent>(
  //                         onInvoke: (intent) {
  //                           if (!kIsWeb) return null;
  //
  //                           // If shift is pressed, let TextField handle newline naturally
  //                           final keys = HardwareKeyboard.instance.logicalKeysPressed;
  //                           final shiftPressed = keys.contains(LogicalKeyboardKey.shiftLeft) ||
  //                               keys.contains(LogicalKeyboardKey.shiftRight);
  //                           if (shiftPressed) return null;
  //
  //                           _sendThreadMessage();
  //                           controller.messageParentFocus.requestFocus(); // keep focus after send
  //                           return null;
  //                         },
  //                       ),
  //                     },
  //                     child: ConstrainedBox(
  //                       constraints: BoxConstraints(maxHeight: Get.height * .3, minHeight: 30),
  //                       child: Container(
  //                         margin: const EdgeInsets.symmetric(vertical: 4),
  //                         decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.circular(8),
  //                           border: Border.all(color: AppTheme.appColor.withOpacity(.2)),
  //                         ),
  //                         child: Row(
  //                           children: [
  //                             Expanded(
  //                               child: TextFormField(
  //                                 controller: controller.msgController,
  //                                 focusNode: controller.messageParentFocus,
  //                                 autofocus: true,
  //                                 keyboardType: TextInputType.multiline,
  //                                 textInputAction: TextInputAction.newline,
  //                                 maxLines: null,
  //                                 minLines: 1,
  //                                 decoration: InputDecoration(
  //                                   isDense: true,
  //                                   hintText: 'Type Something...',
  //                                   hintStyle: BalooStyles.baloonormalTextStyle(),
  //                                   hintMaxLines: 1,
  //                                   contentPadding: const EdgeInsets.all(8),
  //                                   border: InputBorder.none,
  //                                   enabledBorder: InputBorder.none,
  //                                   disabledBorder: InputBorder.none,
  //                                   errorBorder: InputBorder.none,
  //                                   focusedBorder: InputBorder.none,
  //                                 ),
  //
  //                               ),
  //                             ),
  //
  //                             if (kIsWeb) _micButton(_appendSpeechToInput),
  //
  //                             if (!isTaskMode)
  //                               Obx(() => Visibility(
  //                                 visible: controller.showUpload.value,
  //                                 child:InkWell(
  //                                   onTap: () => showUploadOptions(Get.context!),
  //                                   child: IconButtonWidget(Icons.upload_outlined,isIcon:true),
  //
  //                                 ),
  //                               )),
  //
  //                             if (!isTaskMode)
  //                               Obx(() => Visibility(
  //                                 visible: controller.showUpload.value,
  //                                 child: InkWell(
  //                                   onTap: () {
  //                                     openWhatsAppEmojiPicker(
  //                                         context: Get.context!, // prefer widget context, not Get.context!
  //                                         textController: controller.msgController,
  //                                         onSend: () => Get.back(),
  //                                         isMobile: false
  //                                     );
  //                                   },
  //                                   child: IconButtonWidget(emojiPng),
  //                                 ),
  //                               )),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //
  //
  //                /* Focus(
  //                   focusNode: controller.messageParentFocus,
  //                   autofocus: true,
  //                   onKeyEvent: (node, event) {
  //                     if (!kIsWeb) return KeyEventResult.ignored;
  //
  //                     if (event is KeyDownEvent &&
  //                         event.logicalKey == LogicalKeyboardKey.enter) {
  //                       final bool shiftPressed = HardwareKeyboard
  //                               .instance.logicalKeysPressed
  //                               .contains(LogicalKeyboardKey.shiftLeft) ||
  //                           HardwareKeyboard.instance.logicalKeysPressed
  //                               .contains(LogicalKeyboardKey.shiftRight);
  //
  //                       if (shiftPressed) {
  //                         // SHIFT + ENTER → new line
  //                         return KeyEventResult.ignored;
  //                       } else {
  //                         // ENTER → send
  //                         _sendThreadMessage();
  //                         return KeyEventResult.handled;
  //                       }
  //                     }
  //
  //                     return KeyEventResult.ignored;
  //                   },
  //                   child: ConstrainedBox(
  //                     constraints: BoxConstraints(
  //                         maxHeight: Get.height * .4, minHeight: 45),
  //                     child: Container(
  //                       // color: Colors.red,
  //                       decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.circular(8),
  //                           border: Border.all(
  //                               color: appColorGreen.withOpacity(.2))),
  //                       child: Row(
  //                         children: [
  //                           Expanded(
  //                             child: TextFormField(
  //                               controller: controller.msgController,
  //                               keyboardType: TextInputType.multiline,
  //                               textInputAction: TextInputAction.newline,
  //                               maxLines: null,
  //                               minLines: 1,
  //                               autofocus: true,
  //                               decoration: InputDecoration(
  //                                 isDense: true,
  //                                 hintText: 'Type Something...',
  //                                 hintStyle: themeData.textTheme.bodySmall,
  //                                 contentPadding: const EdgeInsets.all(8),
  //                                 border: InputBorder.none,
  //                                 enabledBorder: InputBorder.none,
  //                                 disabledBorder: InputBorder.none,
  //                                 errorBorder: InputBorder.none,
  //                                 focusedBorder: InputBorder.none,
  //                               ),
  //                               inputFormatters: [
  //                                 FilteringTextInputFormatter.allow(
  //                                   RegExp(r'[\s\S]'),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                           Visibility(
  //                             visible: controller.isVisibleUpload,
  //                             child: InkWell(
  //                               onTap: () => showUploadOptions(Get.context!),
  //                               child: Container(
  //                                 padding: const EdgeInsets.all(5),
  //                                 margin: const EdgeInsets.all(5),
  //                                 decoration: BoxDecoration(
  //                                   borderRadius: BorderRadius.circular(8),
  //                                   border: Border.all(color: appColorGreen),
  //                                   color: appColorGreen.withOpacity(.1),
  //                                 ),
  //                                 child: Icon(
  //                                   Icons.upload_outlined,
  //                                   color: appColorGreen,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 )*/
  //               ],
  //             ),
  //           ),
  //         ),
  //
  //         hGap(6),
  //         InkWell(
  //           onTap: () {
  //             _sendThreadMessage();
  //           },
  //           child: Container(
  //             padding: const EdgeInsets.all(12),
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(8),
  //               color: appColorGreen,
  //             ),
  //             child: const Icon(Icons.send, color: Colors.white),
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  //
  // }

  _micButton(Function() appendSpeechToInput){
    return  Obx(() {
      final listening = speechC.isListening.value;

      return Builder(
        builder: (micContext) {
          return InkWell(
            onTap: () {
              if (!speechC.isSupported) {
                Dialogs.showSnackbar(Get.context!,'Voice-to-text is not supported in this browser.');
                return;
              }

              speechC.setLanguage(langCode: speechC.selectedLang);

              if (listening) {
                speechC.stop();
                appendSpeechToInput();
              } else {
                speechC.start();
              }
            },

            onLongPress: () async {
              if (speechC.isListening.value) speechC.stop();

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

  void showUploadOptions(BuildContext context) {
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
                      source: ImageSource.camera, imageQuality: 50);
                  if (image != null) {
                    controller.isUploading = true;
                    controller.update();
                    // await APIs.sendChatImageThread(controller.currentUser!,File(image.path),controller.taskMessage?.sent);
                    controller.isUploading = false;
                    controller.update();
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
                      await picker.pickMultiImage(imageQuality: 50);

                  // uploading & sending image one by one
                  for (var i in images) {
                    print('Image Path: ${i.path}');
                    controller.isUploading = true;
                    controller.update();

                    // await APIs.sendChatImageThread(controller.currentUser!,File(i.path),controller.taskMessage?.sent);

                    controller.isUploading = false;
                    controller.update();
                  }
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

  void _sendThreadMessage() async {
    final text = controller.msgController.text;
    if (text.isEmpty) return;
    Get.find<SocketController>().sendTaskComments(
        toId: controller.taskMessage?.toUser?.userCompany?.userCompanyId ?? 0,
        message: controller.msgController.text.trim(),
        companyId: controller.myCompany?.companyId,
        taskId: controller.taskMessage?.taskId);
    controller.msgController.clear();
  }

  void _showBottomSheet(bool isMe, {required TaskComments data}) async {
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

              data.commentText != ''
                  ?
                  //copy option
                  _OptionItemCommnets(
                      icon: const Icon(Icons.copy_all_rounded,
                          color: Colors.blue, size: 18),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: data.commentText ?? ''))
                            .then((value) {
                          //for hiding bottom sheet
                          Get.back();

                          // Dialogs.showSnackbar(context, 'Text Copied!');
                        });
                      })
                  : (data.media ?? []).isNotEmpty
                      ?
                      //save option
                      _OptionItemCommnets(
                          icon: const Icon(Icons.download_rounded,
                              color: Colors.blue, size: 18),
                          name: 'Save Image',
                          onTap: () async {
                            try {
                              Get.back();
                              // controller.saveAll(
                              //   data.media ?? [],
                              // );
                            } catch (e) {
                              toast('Something went wrong!');
                            }
                          })
                      : const SizedBox(),

              _OptionItemCommnets(
                  icon: const Icon(Icons.download_rounded,
                      color: Colors.blue, size: 18),
                  name: 'Reply',
                  onTap: () async {
                    try {
                      Get.back();
                      controller.refIdis = data.taskCommentId;
                      controller.userIDSender = data.fromUser?.userId;
                      controller.userNameReceiver =
                          data.toUser?.userCompany?.displayName ?? '';
                      controller.userNameSender =
                          data.fromUser?.userCompany?.displayName ?? '';
                      controller.userIDReceiver = data.toUser?.userId;
                      controller.replyToMessage = data;

                      controller.update();
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
              if (isMe)
                _OptionItemCommnets(
                    icon: const Icon(Icons.delete_forever,
                        color: Colors.red, size: 18),
                    name: 'Delete Message',
                    onTap: () async {
                      Get.find<SocketController>().deleteMsgEmitter(
                        mode: "direct",
                        chatId: data.taskCommentId ?? 0,
                      );
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
}

class _OptionItemCommnets extends StatelessWidget {
  final Icon icon;
  final String name;
  final Function() onTap;

  const _OptionItemCommnets(
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
