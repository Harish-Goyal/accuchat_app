import 'package:AccuChat/Screens/Chat/models/task_commets_res_model.dart';
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
import '../../../../../../Constants/colors.dart';
import '../../../../../../Constants/themes.dart';
import '../../../../../../main.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../../utils/emogi_checker.dart';
import '../../../../../../utils/helper_widget.dart';
import '../../../../../../utils/product_shimmer_widget.dart';
import '../../../../../Home/Presentation/Controller/socket_controller.dart';
import '../../../../models/chat_history_response_model.dart';
import '../../../../api/apis.dart';
import '../Controllers/task_controller.dart';
import '../Widgets/staggered_view.dart';

class TaskThreadScreen extends GetView<TaskThreadController> {
  const TaskThreadScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskThreadController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
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
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _taskCard(),

                Expanded(
                  child:   chatMessageBuilder(),
                ),

                if (controller.isUploading)
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                          padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          child: CircularProgressIndicator(strokeWidth: 2))),
                _chatInput(),
              ],
            ),
          ),
        );
      }
    );
  }


  _taskCard(){
    return Container(
      width: Get.width,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(
          horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: getTaskStatusColor(
              controller.taskMessage?.currentStatus?.name?.capitalizeFirst)
              .withOpacity(.1),
          border: Border.all(
              color: getTaskStatusColor(
                  controller.taskMessage?.currentStatus?.name?.capitalizeFirst)),
          //making borders curved
          borderRadius:  const BorderRadius.only(
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
                    text: controller.taskMessage?.title??'',
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

          vGap(5),
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 60,
                  child:
                  SelectableLinkify(
                    text: controller.taskMessage?.details ?? '',
                    onOpen: (link) {
                      launchUrl(
                        Uri.parse(link.url),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    style: BalooStyles.baloonormalTextStyle(
                      color: Colors.black87,
                      size: 14,
                    ),
                    linkStyle: BalooStyles.baloonormalTextStyle(
                      color: Colors.blue,
                      size: 14,
                    ),
                    linkifiers: const [
                      UrlLinkifier(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if ((controller.taskMessage?.deadline ?? '')
              .isNotEmpty) ...[
            vGap(8),
            Text(
                "⏱️ Est. Time: ${estimateLabel(deadlineIso: controller.taskMessage?.deadline ?? '', createdIso: controller.taskMessage?.createdOn ?? '')}",
                style:BalooStyles.balooregularTextStyle(color: Colors.red)),
          ],
          vGap(8),
          Text("Member: ${controller.joined}",
              style: BalooStyles.baloothinTextStyle()),
        ],
      ),
    );
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
                child: ChatHistoryShimmer()),
            child: groupListView(),
          ),
        ),
        // vGap(80)
      ],
    );
  }

  groupListView() {
    return controller.commentsCategory.isNotEmpty
        ? NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n is ScrollEndNotification &&
            n.metrics.extentAfter <= 0 &&
            !controller.isPageLoading &&
            controller.hasMore) {
          controller.isPageLoading = true;
          controller.hitAPIToGetCommentsHistory();
        }

        return false;
      },
          child: GroupedListView<GroupCommentsElement, DateTime>(
          shrinkWrap: false,
          padding: const EdgeInsets.only(bottom: 30),
          controller: controller.scrollController2,
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
          indexedItemBuilder:
              (BuildContext context, GroupCommentsElement element, int index) {
            String formatatedTime = '';
            if (element.comments.sentOn != null) {
              var timeString = element.comments.sentOn ?? '';

              formatatedTime = convertUtcToIndianTime(timeString);
            }

            var userid = APIs.me.userId;
            return SwipeTo(
              iconColor: appColorGreen,
              onRightSwipe: (detail) {
                // Set the message being replied to
                controller.refIdis = element.comments.taskCommentId;
                controller.userIDSender =
                    element.comments.fromUser?.userId;
                controller.userNameReceiver =
                    element.comments.toUser?.userCompany?.displayName ?? '';
                controller.userNameSender =
                    element.comments.fromUser?.userCompany?.displayName ?? '';
                controller.userIDReceiver =
                    element.comments.toUser?.userId;
                controller.replyToMessage = element.comments;

                controller.update();

              },
              child: _chatMessageTile(
                  data: element.comments,
                  sentByMe: (userid.toString() ==
                      element.comments.fromUser?.userId
                          ?.toString()
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
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

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
                        horizontal:
                        (data.media ?? []).isNotEmpty ? 8 : 15,
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
            ? Text(data.commentText ?? '',
            textAlign: TextAlign.start,
            style: BalooStyles.baloonormalTextStyle(
              color: Colors.black87,
                size: isEmojiMsg?40:14
            ),
            overflow: TextOverflow.visible)
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
      debugPrint("❌ Failed to open document: $e");
      customLoader.hide();
    }
  }

  Widget _chatInput() {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
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
                          _sendThreadMessage();
                          return KeyEventResult.handled;
                        }
                      }

                      return KeyEventResult.ignored;
                    },
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: Get.height * .4, minHeight: 45),
                      child: Container(
                        // color: Colors.red,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color:appColorGreen .withOpacity(.2))
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller.msgController,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                maxLines: null,
                                minLines: 1,
                                autofocus: true,
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


                              Visibility(
                                visible: controller.isVisibleUpload,
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
          hGap(6),
          InkWell(
            onTap: () {
              _sendThreadMessage();
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16,left: 15,right: 15,bottom: 60),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: ()async {
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
                onTap: () async{
                  Get.back();
                  final ImagePicker picker = ImagePicker();

                  // Picking multiple images
                  final List<XFile> images =
                  await picker.pickMultiImage(imageQuality: 50);

                  // uploading & sending image one by one
                  for (var i in images) {
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
                onTap: (){
                  Get.back();
                  controller.pickDocument();
                } ,
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
      taskId: controller.taskMessage?.taskId
    );
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
                      controller.userIDSender =
                          data.fromUser?.userId;
                      controller.userNameReceiver =
                          data.toUser?.userCompany?.displayName ?? '';
                      controller.userNameSender =
                          data.fromUser?.userCompany?.displayName ?? '';
                      controller.userIDReceiver =
                          data.toUser?.userId;
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
