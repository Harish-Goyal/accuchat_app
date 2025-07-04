import 'dart:math' as math;
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/Screens/Chat/screens/task_treads_screen.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../Constants/app_theme.dart';
import '../../../Constants/assets.dart';
import '../../../Constants/colors.dart';
import '../../../Services/APIs/local_keys.dart';
import '../../../utils/common_textfield.dart';
import '../../../utils/custom_dialogue.dart';
import '../../../utils/gradient_button.dart';
import '../../../utils/text_style.dart';
import '../api/apis.dart';
import '../helper/my_date_util.dart';
import '../../../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../screens/chat_screen.dart';
import 'all_users_dialog.dart';

class MessageCard extends StatefulWidget {
  MessageCard({
    super.key,
    required this.message,
    required this.senderName,
    required this.fromId,
    this.isGroupMessage = false,
    this.isForward = false,
    this.isUploading = false,
    this.user,
    required this.isTask,
  });

  final Message message;
  final String senderName;
  final bool isGroupMessage;
  final String fromId;
  bool isTask;
  bool isUploading;
  bool isForward;
  ChatUser? user;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  bool isVideoPlaying = false;
  String validString = '';
  DateTime? _newSelectedDate;
  TimeOfDay? _newSelectedTime;
  final _tasksFormKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  DateTime? newSelectedDateTime;

  Future<void> _handleForward(
      Message originalMessage, isTask, TaskDetails? taskDetails) async {
    final selectedUser = await showDialog<ChatUser>(
      context: context,
      builder: (_) => const AllUserScreenDialog(),
    );

    if (selectedUser != null) {
      // Prepare forward trail
      List<Map<String, String>> trail =
          List<Map<String, String>>.from(originalMessage.forwardTrail ?? []);
      trail.add({
        'id': widget.fromId,
        'name': widget.senderName,
        'time': DateTime.now().toIso8601String()
      });

      final forwardMsg = Message(
          fromId: APIs.me.id,
          toId: selectedUser.id,
          msg: originalMessage.msg,
          type: originalMessage.type,
          companyId: APIs.me.selectedCompany?.id ?? '',
          sent: DateTime.now().millisecondsSinceEpoch.toString(),
          read: '',
          typing: false,
          originalSenderId:
              originalMessage.originalSenderId ?? originalMessage.fromId,
          originalSenderName:
              originalMessage.originalSenderName ?? APIs.me.name,
          forwardTrail: trail,
          isTask: isTask,
          taskDetails: taskDetails,
          replyToMsg: '',
          replyToSenderName: '',
          createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
          replyToType: null);

      // Send message and then navigatehrsR
      await APIs.sendForwardedMessage(selectedUser, forwardMsg);

      // Navigate to chat screen after sending
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(user: selectedUser)),
      );
    }
  }

  @override
  void initState() {
    _titleController.text = widget.message.taskDetails?.title ?? '';
    _descController.text = widget.message.taskDetails?.description ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
        onTap: () {
          if (!isTaskMode && widget.message.type == Type.doc) {
            openDocumentFromUrl(widget.message.msg);
          }
          print("sf");
        },
        onLongPress: () {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          if (mounted) {
            setState(() {
              // your logic here
            });
            _showBottomSheet(isMe);
          }
        },
        onDoubleTap: () {
          if (isTaskMode) {
            if (widget.message.taskDetails?.taskStatus !=
                TaskStatus.Completed.name) {
              if ((widget.message.isTask ?? true) &&
                  widget.message.fromId != APIs.me.id) {
                _showStatusPopup(context, false);
              } else {
                _showStatusPopup(context, true);
              }
            }
          }
        },
        child: isMe ? _greenMessage() : _blueMessage());
  }

  // sender or another user message
  Widget _blueMessage() {
    TaskDetails? task = widget.message.taskDetails;
    var title;
    var description;
    var time;
    var fileName;
    var icon;
    if (widget.message.taskDetails != null) {
      title = task?.title ?? 'Task';
      description = task?.description ?? '';
      time = task?.estimatedTime ?? '';
      icon = getIconForFile(widget.message.msg);
    }

    if (widget.message.msg != "" &&
        widget.message.msg.startsWith("https://firebasestorage")) {
      fileName = extractFileNameFromUrl(widget.message.msg);
      icon = getIconForFile(widget.message.msg);
    }

    // final title = task?.title ?? 'Task';
    // final description = task?.description ?? '';
    // final time = task?.estimatedTime ?? '';
    // final fileName =extractFileNameFromUrl(widget.message.msg);
    // final icon = getIconForFile(widget.message.msg);

    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((widget.message.replyToMsg ?? '').isNotEmpty)
              Container(
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.isTask
                      ? getTaskStatusColor(
                              widget.message.taskDetails?.taskStatus)
                          .withOpacity(.2)
                      : appColorGreen.withOpacity(.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: (widget.message.replyToType == Type.image)
                    ? Text(
                        "${widget.message.replyToSenderName}: ${extractFileNameFromUrl(widget.message.msg)}",
                        style: themeData.textTheme.bodySmall?.copyWith(
                          color: widget.isTask
                              ? getTaskStatusColor(
                                      widget.message.taskDetails?.taskStatus)
                                  .withOpacity(.2)
                              : appColorGreen,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : (widget.message.replyToType == Type.doc)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${widget.message.replyToSenderName}: ${extractFileNameFromUrl(widget.message.replyToMsg ?? '')}",
                                style: themeData.textTheme.bodySmall?.copyWith(
                                  color: widget.isTask
                                      ? getTaskStatusColor(widget
                                              .message.taskDetails?.taskStatus)
                                          .withOpacity(.2)
                                      : appColorGreen,
                                  fontStyle: FontStyle.italic,
                                ),
                              ).paddingOnly(left: 10),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.blue.shade200),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(icon, color: Colors.indigo, size: 40),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            // Uri.decodeFull((widget.message.replyToMsg??'').split('/').last.split('?').first),
                                            extractFileNameFromUrl(
                                                widget.message.replyToMsg ??
                                                    ''),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios,
                                        size: 16),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Text(
                            "${widget.message.replyToSenderName}: ${widget.message.replyToMsg}",
                            style: themeData.textTheme.bodySmall?.copyWith(
                              color: widget.isTask
                                  ? getTaskStatusColor(widget
                                          .message.taskDetails?.taskStatus)
                                      .withOpacity(.2)
                                  : appColorGreen,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: EdgeInsets.all(widget.message.type == Type.image ||
                                  widget.message.type == Type.video ||
                                  widget.message.type == Type.doc
                              ? mq.width * .01
                              : mq.width * .04),
                          margin: EdgeInsets.symmetric(
                              horizontal: mq.width * .04, vertical: 4),
                          decoration: BoxDecoration(
                              color: widget.isTask
                                  ? getTaskStatusColor(widget.message.taskDetails?.taskStatus)
                                      .withOpacity(.1)
                                  : appColorPerple.withOpacity(.1),
                              border: Border.all(
                                  color: widget.isTask
                                      ? getTaskStatusColor(widget
                                          .message.taskDetails?.taskStatus)
                                      : appColorPerple),
                              //making borders curved
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular((widget.message.type == Type.video || widget.message.type == Type.image || widget.message.type == Type.doc) ? 15 : 30),
                                  topRight: Radius.circular((widget.message.type == Type.video || widget.message.type == Type.image || widget.message.type == Type.doc) ? 15 : 30),
                                  bottomRight: Radius.circular((widget.message.type == Type.video || widget.message.type == Type.image || widget.message.type == Type.doc) ? 15 : 30))),
                          child: widget.message.type == Type.text
                              ?
                              //show text
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.isGroupMessage)
                                      widget.fromId == APIs.me.id
                                          ? Text(
                                              "You",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                      fontSize: 10,
                                                      color: appColorPerple),
                                            )
                                          : Text(
                                              widget.senderName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                      fontSize: 10,
                                                      color: appColorPerple),
                                            ).paddingOnly(bottom: 4),
                                    widget.isTask
                                        ? Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("📝 $title",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const SizedBox(height: 5),
                                              Text(
                                                description,
                                                style: themeData
                                                    .textTheme.bodySmall,
                                              ),
                                              if (time.isNotEmpty &&
                                                  time != null) ...[
                                                vGap(10),
                                                Text(
                                                    "⏱️ Est. Time: ${formatTaskTime(time, widget.message.createdAt)}",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: AppTheme
                                                            .redErrorColor)),
                                              ],
                                              vGap(8),
                                              widget.message.taskDetails
                                                          ?.attachments !=
                                                      null
                                                  ? buildTaskAttachments(widget
                                                          .message
                                                          .taskDetails
                                                          ?.attachments ??
                                                      [])
                                                  : SizedBox(),
                                            ],
                                          )
                                        : Text(
                                            widget.message.msg,
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black87),
                                          ),
                                    widget.isTask ? vGap(8) : const SizedBox(),
                                    widget.isTask
                                        ? divider()
                                        : const SizedBox(),
                                    widget.isTask ? vGap(8) : const SizedBox(),
                                    if (widget.message.originalSenderName !=
                                            null &&
                                        widget.message.originalSenderName != '')
                                      widget.isTask
                                          ? Text("Creator: ${widget.message.originalSenderName}",
                                                  style: themeData
                                                      .textTheme.bodySmall
                                                      ?.copyWith(fontSize: 12))
                                              .paddingOnly(left: 0)
                                          : const SizedBox(),
                                    hGap(2),
                                    if (widget.message.forwardTrail != null &&
                                        widget.message.forwardTrail!.isNotEmpty)
                                      Text("Forwarded by: ${widget.message.forwardTrail!.map((e) => e['name']).join(' → ')}",
                                              style: themeData
                                                  .textTheme.bodySmall
                                                  ?.copyWith(
                                                      fontSize: 12,
                                                      fontStyle:
                                                          FontStyle.italic))
                                          .paddingOnly(left: 15),
                                  ],
                                )
                              : /*widget.message.type == Type.video?Stack(
                          alignment: Alignment.center,
                          children: [
                            InkWell(
                              onTap:isVideoPlaying? (){
                                videoPlayerController?.pause();
                                setState(() {
                                  isVideoPlaying = false;
                                });
                              }:(){
                                videoPlayerController?.play();
                                setState(() {
                                  isVideoPlaying = true;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Color.fromRGBO(0, 0, 0, 0.3),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                                ),
                                height: mq.height * 0.32,
                                width: mq.width,
                                child:  widget.message.msg.isNotEmpty &&
                                    chewieController != null
                                    ? ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: Chewie(
                                      controller: chewieController!,
                                    ))
                                    : Container(),
                              ),
                            ),
                            InkWell(
                                onTap: (){
                                  videoPlayerController?.play();
                                  setState(() {
                                    isVideoPlaying = true;
                                  });
                                },
                                child:isVideoPlaying?Container(): Icon(Icons.play_circle,color: Colors.black,size: 35,))
                          ],
                        ):*/
                              //show image
                              widget.message.type == Type.image
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (widget.isGroupMessage)
                                          widget.fromId == APIs.me.id
                                              ? Text(
                                                  "You",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                          fontSize: 13,
                                                          color: appColorGreen),
                                                ).paddingAll(4)
                                              : Text(
                                                  widget.senderName,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                          fontSize: 13,
                                                          color:
                                                              appColorPerple),
                                                ).paddingAll(4),
                                        CustomCacheNetworkImage(
                                          widget.message.msg,
                                          radiusAll: 15,
                                          boxFit: BoxFit.contain,
                                          defaultImage: defaultGallery,
                                        ),
                                      ],
                                    )
                                  : FutureBuilder<String>(
                                      future: getFileSize(widget.message.msg),
                                      builder: (context, snapshot) {
                                        final sizeText = snapshot.data ?? '';

                                        return InkWell(
                                          onTap: () => openDocumentFromUrl(
                                              widget.message.msg),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (widget.isGroupMessage)
                                                widget.fromId == APIs.me.id
                                                    ? Text(
                                                        "You",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                                fontSize: 13,
                                                                color:
                                                                    appColorGreen),
                                                      ).paddingAll(4)
                                                    : Text(
                                                        widget.senderName,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                                fontSize: 13,
                                                                color:
                                                                    appColorPerple),
                                                      ).paddingAll(4),
                                              Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 8),
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color:
                                                          Colors.blue.shade200),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Icon(icon,
                                                        color: Colors.indigo,
                                                        size:
                                                            40), // 🟢 Dynamic icon
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            fileName,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Row(
                                                            children: [
                                                              const Text(
                                                                  "Tap to view",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey)),
                                                              if (sizeText
                                                                  .isNotEmpty)
                                                                Text(
                                                                    " • $sizeText",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .grey)),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    const Icon(
                                                        Icons.arrow_forward_ios,
                                                        size: 16),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )),
                      //message time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        // mainAxisSize: MainAxisSize.min,
                        children: [
                          if (storage.read(isFirstTimeChatKey) ??
                              true && isTaskMode)
                            Expanded(
                              child: AnimatedOpacity(
                                opacity:
                                    widget.message.isTask == true ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 2000),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 12.0, top: 4),
                                  child: Text(
                                    "👆 Double tap to update status",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: appColorGreen,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.only(left: mq.width * .04),
                            child: Text(
                              MyDateUtil.getFormattedTime(
                                  context: context, time: widget.message.sent),
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (widget.message.fromId != APIs.me.id ||
                    widget.message.fromId == widget.message.toId)
                  (widget.isForward ||
                          (widget.message.taskDetails?.taskStatus ==
                              TaskStatus.Completed.name))
                      ? SizedBox()
                      : InkWell(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.asset(forwardIcon,
                                  height: 20, color: appColorPerple)
                              .paddingAll(4),
                          onTap: () async {
                            await _handleForward(widget.message, widget.isTask,
                                widget.message.taskDetails);
                          },
                        ).paddingOnly(top: 9, right: 15),
              ],
            ),
            vGap(8),
          ],
        ),
        if ((widget.message.isTask ?? false))
          Positioned(
            left: 35,
            top: -8,
            child: Container(
              alignment: Alignment.center,
              padding:
                  const EdgeInsets.only(left: 12, right: 12, top: 2, bottom: 2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: getTaskStatusColor(
                      widget.message.taskDetails?.taskStatus?.capitalizeFirst)),
              child: Text(
                "${widget.message.taskDetails?.taskStatus}",
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        (isTaskMode &&
                (widget.message.taskDetails?.taskStatus?.toLowerCase() !=
                    TaskStatus.Completed.name.toLowerCase()))
            ? Positioned(
                top: -10,
                right: Get.width * .13,
                child: FutureBuilder<int>(
                  future: APIs.getThreadConversationTaskCount(
                      widget.fromId, widget.message.sent),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == 0)
                      return const SizedBox();

                    return InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        Get.to(() => TaskThreadScreen(
                            taskMessage: widget.message,
                            currentUser: widget.user!));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 15),
                        decoration: BoxDecoration(
                            color: appColorGreen,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            )),
                        child: Text(
                          '${snapshot.data}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  Widget buildTaskAttachments(List<Map<String, dynamic>> attachments) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: Colors.white),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: attachments.map((url) {
          final fileName =
              url['url'].split('/').last.replaceAll(RegExp(r'^DOC_\d+_'), '');
          final isImage = url['name'].endsWith('.png') ||
              url['name'].endsWith('.jpg') ||
              url['name'].endsWith('.jpeg');

          return GestureDetector(
            onTap: () async {
              if (isImage) {
                // Show image in dialog
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    backgroundColor: Colors.transparent,
                    child: InteractiveViewer(
                      child: CustomCacheNetworkImage(
                        url['url'],
                        radiusAll: 15,
                        boxFit: BoxFit.contain,
                        defaultImage: defaultGallery,
                      ),
                    ),
                  ),
                );
              } else {
                openDocumentFromUrl(url['url']);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isImage ? Icons.image : Icons.description,
                      color: Colors.blue),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      url['name'],
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month];
  }

  Future<String> getFileSize(String url) async {
    final ref = FirebaseStorage.instance.refFromURL(url);
    final metadata = await ref.getMetadata();
    final sizeInKB = (metadata.size ?? 0) / 1024;
    return "${sizeInKB.toStringAsFixed(2)} KB";
  }

  IconData getIconForFile(String url) {
    final ext = url.split('.').last.toLowerCase();

    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description; // document icon
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'txt':
        return Icons.text_snippet;
      case 'csv':
        return Icons.grid_on;
      default:
        return Icons.insert_drive_file;
    }
  }

  // our or user message
  Widget _greenMessage() {
    var title;
    var description;
    var time;
    var fileName;
    var icon;
    if (widget.message.taskDetails != null) {
      TaskDetails? task = widget.message.taskDetails;
      title = task?.title ?? 'Task';
      description = task?.description ?? '';
      time = task?.estimatedTime ?? '';
      // fileName =extractFileNameFromUrl(widget.message.msg);
      icon = getIconForFile(widget.message.msg);
    }

    if (widget.message.msg != "" &&
        widget.message.msg.startsWith("https://firebasestorage")) {
      fileName = extractFileNameFromUrl(widget.message.msg);
      icon = getIconForFile(widget.message.msg);
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if ((widget.message.replyToMsg ?? '').isNotEmpty)
              Container(
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.isTask
                      ? getTaskStatusColor(
                              widget.message.taskDetails?.taskStatus)
                          .withOpacity(.2)
                      : appColorGreen.withOpacity(.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: (widget.message.replyToType == Type.image)
                    ? Text(
                        "${widget.message.replyToSenderName}: ${extractFileNameFromUrl(widget.message.replyToMsg ?? '')}",
                        style: themeData.textTheme.bodySmall?.copyWith(
                          color: widget.isTask
                              ? getTaskStatusColor(
                                      widget.message.taskDetails?.taskStatus)
                                  .withOpacity(.2)
                              : appColorGreen,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : (widget.message.replyToType == Type.doc)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${widget.message.replyToSenderName}: ${extractFileNameFromUrl(widget.message.replyToMsg ?? '')}",
                                style: themeData.textTheme.bodySmall?.copyWith(
                                  color: widget.isTask
                                      ? getTaskStatusColor(widget
                                              .message.taskDetails?.taskStatus)
                                          .withOpacity(.2)
                                      : appColorGreen,
                                  fontStyle: FontStyle.italic,
                                ),
                              ).paddingOnly(left: 10),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.blue.shade200),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(icon,
                                        color: Colors.indigo,
                                        size: 40), // 🟢 Dynamic icon
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            // Uri.decodeFull((widget.message.replyToMsg??'').split('/').last.split('?').first),
                                            extractFileNameFromUrl(
                                                widget.message.replyToMsg ??
                                                    ''),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios,
                                        size: 16),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Text(
                            "${widget.message.replyToSenderName}: ${widget.message.replyToMsg}",
                            style: themeData.textTheme.bodySmall?.copyWith(
                              color: widget.isTask
                                  ? getTaskStatusColor(widget
                                          .message.taskDetails?.taskStatus)
                                      .withOpacity(.2)
                                  : appColorGreen,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisSize: MainAxisSize.min,
              children: [
                //message content
                if (isTaskMode)
                  (widget.isForward ||
                          (widget.message.taskDetails?.taskStatus ==
                              TaskStatus.Completed.name))
                      ? SizedBox()
                      : InkWell(
                          borderRadius: BorderRadius.circular(30),
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi),
                            child: Image.asset(forwardIcon,
                                    height: 20, color: appColorPerple)
                                .paddingAll(4),
                          ),
                          onTap: () async {
                            await _handleForward(widget.message, widget.isTask,
                                widget.message.taskDetails);
                          },
                        ).paddingOnly(top: 9, left: 15),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                          padding: EdgeInsets.all(widget.message.type == Type.image ||
                                  widget.message.type == Type.video ||
                                  widget.message.type == Type.doc
                              ? mq.width * .01
                              : mq.width * .04),
                          margin: EdgeInsets.symmetric(
                              horizontal: mq.width * .05,
                              vertical: mq.height * .01),
                          decoration: BoxDecoration(
                              color: widget.isTask
                                  ? getTaskStatusColor(widget.message.taskDetails?.taskStatus)
                                      .withOpacity(.1)
                                  : appColorGreen.withOpacity(.1),
                              border: Border.all(
                                  color: widget.isTask
                                      ? getTaskStatusColor(widget
                                          .message.taskDetails?.taskStatus)
                                      : appColorGreen),
                              //making borders curved
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular((widget.message.type == Type.video || widget.message.type == Type.image || widget.message.type == Type.doc) ? 15 : 30),
                                  topRight: Radius.circular((widget.message.type == Type.video || widget.message.type == Type.image || widget.message.type == Type.doc) ? 15 : 30),
                                  bottomLeft: Radius.circular((widget.message.type == Type.video || widget.message.type == Type.image || widget.message.type == Type.doc) ? 15 : 30))),
                          child: widget.message.type == Type.text
                              ?
                              //show text
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.isGroupMessage)
                                      widget.fromId == APIs.me.id
                                          ? Text(
                                              "You",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                      fontSize: 10,
                                                      color: appColorGreen),
                                            )
                                          : Text(
                                              widget.senderName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                      fontSize: 10,
                                                      color: appColorPerple),
                                            ).paddingOnly(bottom: 4),
                                    widget.isTask
                                        ? Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("📝 $title",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const SizedBox(height: 5),
                                              Text(description),
                                              if (time.isNotEmpty) ...[
                                                vGap(10),
                                                Text(
                                                    "⏱️ Est. Time: ${formatTaskTime(time, widget.message.createdAt)}",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: AppTheme
                                                            .redErrorColor)),
                                                vGap(8),
                                                widget.message.taskDetails
                                                            ?.attachments !=
                                                        null
                                                    ? buildTaskAttachments(
                                                        widget
                                                                .message
                                                                .taskDetails
                                                                ?.attachments ??
                                                            [])
                                                    : SizedBox(),
                                              ],
                                            ],
                                          )
                                        : Text(
                                            widget.message.msg,
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black87),
                                          ),
                                    widget.isTask ? vGap(8) : const SizedBox(),
                                    widget.isTask
                                        ? divider()
                                        : const SizedBox(),
                                    widget.isTask ? vGap(8) : const SizedBox(),
                                    if (widget.message.originalSenderName !=
                                            null &&
                                        widget.message.originalSenderName != '')
                                      widget.isTask
                                          ? Text("Creator: ${widget.message.originalSenderName}",
                                                  style: themeData
                                                      .textTheme.bodySmall
                                                      ?.copyWith(fontSize: 12))
                                              .paddingOnly(right: 15)
                                          : const SizedBox(),
                                    hGap(2),
                                    if (widget.message.forwardTrail != null &&
                                        widget.message.forwardTrail!.isNotEmpty)
                                      Text("Forwarded by: ${widget.message.forwardTrail!.map((e) => e['name']).join(' → ')}",
                                              style: themeData
                                                  .textTheme.bodySmall
                                                  ?.copyWith(
                                                      fontSize: 12,
                                                      fontStyle:
                                                          FontStyle.italic))
                                          .paddingOnly(right: 15),
                                  ],
                                )
                              : /*widget.message.type == Type.video?Stack(
                          alignment: Alignment.center,
                              children: [
                                InkWell(
                                  onTap:isVideoPlaying? (){
                                      videoPlayerController?.pause();
                                      setState(() {
                                        isVideoPlaying = false;
                                      });
                                  }:(){
                                    videoPlayerController?.play();
                                    setState(() {
                                      isVideoPlaying = true;
                                    });
                                  },
                                  child: Container(
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                                  color: Color.fromRGBO(0, 0, 0, 0.3),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                          ),
                          height: mq.height * 0.32,
                          width: mq.width,
                          child:  widget.message.msg.isNotEmpty &&
                                    chewieController != null
                                    ? ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: Chewie(
                                      controller: chewieController!,
                                    ))
                                    : Container(),
                        ),
                                ),
                                InkWell(
                                  onTap: (){
                                    videoPlayerController?.play();
                                    setState(() {
                                      isVideoPlaying = true;
                                    });
                                  },
                                    child:isVideoPlaying?Container(): Icon(Icons.play_circle,color: Colors.black,size: 35,))
                              ],
                            ):*/
                              //show image
                              widget.message.type == Type.image
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (widget.isGroupMessage)
                                          widget.fromId == APIs.me.id
                                              ? Text(
                                                  "You",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                          fontSize: 13,
                                                          color: appColorGreen),
                                                ).paddingAll(4)
                                              : Text(
                                                  widget.senderName,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                          fontSize: 13,
                                                          color:
                                                              appColorPerple),
                                                ).paddingAll(4),
                                        CustomCacheNetworkImage(
                                          widget.message.msg,
                                          radiusAll: 15,
                                          boxFit: BoxFit.contain,
                                          defaultImage: defaultGallery,
                                        ),
                                      ],
                                    )
                                  :
                                  /* Row(
                            children: [
                              const Icon(Icons.insert_drive_file, color: Colors.blueAccent),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  widget.message.msg.split('/').last, // optional: extract filename
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          )*/

                                  FutureBuilder<String>(
                                      future: getFileSize(widget.message.msg),
                                      builder: (context, snapshot) {
                                        final sizeText = snapshot.data ?? '';

                                        return InkWell(
                                          onTap: () => openDocumentFromUrl(
                                              widget.message.msg),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (widget.isGroupMessage)
                                                widget.fromId == APIs.me.id
                                                    ? Text(
                                                        "You",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                                fontSize: 13,
                                                                color:
                                                                    appColorGreen),
                                                      ).paddingAll(4)
                                                    : Text(
                                                        widget.senderName,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                                fontSize: 13,
                                                                color:
                                                                    appColorPerple),
                                                      ).paddingAll(4),
                                              Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 8),
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color:
                                                          Colors.blue.shade200),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Icon(icon,
                                                        color: Colors.indigo,
                                                        size:
                                                            40), // 🟢 Dynamic icon
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            fileName ?? '',
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Row(
                                                            children: [
                                                              const Text(
                                                                  "Tap to view",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey)),
                                                              if (sizeText
                                                                  .isNotEmpty)
                                                                Text(
                                                                    " • $sizeText",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .grey)),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    const Icon(
                                                        Icons.arrow_forward_ios,
                                                        size: 16),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )),

                      SizedBox(width: mq.width * .04),

                      //double tick blue icon for message read

                      //sent time
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isFirstTimeChat)
                            Expanded(
                              child: AnimatedOpacity(
                                opacity:
                                    widget.message.isTask == true ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 2000),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 12.0, top: 0),
                                  child: Text(
                                    "👆 Double tap to update status",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: appColorGreen,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Text(
                              MyDateUtil.getFormattedTime(
                                  context: context, time: widget.message.sent),
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54),
                            ),
                          ),
                          if (widget.message.read.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.only(right: 15.0),
                              child: Icon(Icons.done_all_rounded,
                                  color: Colors.blue, size: 20),
                            ),
                        ],
                      ).paddingOnly(bottom: 12),
                    ],
                  ),
                ),
              ],
            ),
            vGap(8),
          ],
        ),
        if ((widget.message.isTask ?? true))
          Positioned(
            right: 35,
            top: -5,
            child: Container(
              alignment: Alignment.center,
              padding:
                  const EdgeInsets.only(left: 12, right: 12, top: 2, bottom: 2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color:
                      getTaskStatusColor(widget.message.taskDetails?.taskStatus)
                  /* widget.message.taskDetails?.taskStatus ==
                          TaskStatus.Pending.name
                      ? appColorYellow
                      : widget.message.taskDetails?.taskStatus ==
                              TaskStatus.Done.name
                          ? blueColor
                          : widget.message.taskDetails?.taskStatus ==
                                  TaskStatus.Completed.name
                              ? appColorGreen
                              : AppTheme.appColor*/
                  ),
              child: Text(
                "${widget.message.taskDetails?.taskStatus}",
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        (isTaskMode &&
                (widget.message.taskDetails?.taskStatus?.toLowerCase() !=
                    TaskStatus.Completed.name.toLowerCase()))
            ? Positioned(
                top: -6,
                left: Get.width * .14,
                child: FutureBuilder<int>(
                  future: APIs.getThreadConversationTaskCount(
                      widget.fromId, widget.message.sent),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == 0)
                      return const SizedBox();

                    return InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        Get.to(() => TaskThreadScreen(
                            taskMessage: widget.message,
                            currentUser: widget.user!));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 15),
                        decoration: BoxDecoration(
                            color: appColorGreen,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                              bottomLeft: Radius.circular(30),
                            )),
                        child: Text(
                          '${snapshot.data}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),
              )
            : const SizedBox(),
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

  _updateTasksDialogWidget(userName, TaskDetails taskDetails) {
    return StatefulBuilder(builder: (context, setStateInside) {
      return CustomDialogue(
        title: "Update Task",
        isShowAppIcon: false,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Enter Task Details",
              style: BalooStyles.baloonormalTextStyle(),
              textAlign: TextAlign.center,
            ),
            Text(
              validString,
              style: BalooStyles.baloonormalTextStyle(
                  color: AppTheme.redErrorColor),
              textAlign: TextAlign.center,
            ),
            vGap(20),
            _taskInputArea(setStateInside, taskDetails),
            vGap(30),
            GradientButton(
              name: "Update",
              btnColor: AppTheme.appColor,
              vPadding: 8,
              onTap: () async {
                if (_tasksFormKey.currentState!.validate()) {
                  if (_getEstimatedTime(
                              setStateInside, taskDetails.estimatedTime) !=
                          "" &&
                      _newSelectedDate != null &&
                      _newSelectedTime != null) {
                    if (_getEstimatedTime(
                            setStateInside, taskDetails.estimatedTime) ==
                        "Oops! The selected time is in the past. Please choose a valid future time.") {
                      setStateInside(() {
                        validString =
                            "Please select valid time check AM PM correctly";
                      });
                    } else {
                      final currentStatus =
                          widget.message.taskDetails?.taskStatus ?? 'Pending';

                      if (['Done', 'Completed', 'Cancelled']
                          .contains(currentStatus)) {
                        toast(
                            "⛔ Task status is '$currentStatus' — update not allowed.");
                      } else {
                        await APIs.updateTaskMessage(
                                message: widget.message,
                                updatedTitle: _titleController.text,
                                updatedDescription: _descController.text,
                                updatedEstimatedTime: (_newSelectedTime !=
                                            null &&
                                        _newSelectedDate != null)
                                    ? newSelectedDateTime
                                        ?.millisecondsSinceEpoch
                                        .toString()
                                    : widget.message.taskDetails?.estimatedTime)
                            .whenComplete(() => Get.back());
                      }
                    }
                  } else {
                    final currentStatus =
                        widget.message.taskDetails?.taskStatus ?? 'Pending';

                    if (['Done', 'Completed', 'Cancelled']
                        .contains(currentStatus)) {
                      toast(
                          "⛔ Task status is '$currentStatus' — update not allowed.");
                    } else {
                      await APIs.updateTaskMessage(
                              message: widget.message,
                              updatedTitle: _titleController.text,
                              updatedDescription: _descController.text,
                              updatedEstimatedTime: (_newSelectedTime != null &&
                                      _newSelectedDate != null)
                                  ? newSelectedDateTime?.millisecondsSinceEpoch
                                      .toString()
                                  : widget.message.taskDetails?.estimatedTime)
                          .whenComplete(() => Get.back());
                    }
                  }
                }
              },
            )
          ],
        ),
        onOkTap: () {},
      );
    });
  }

  Widget _taskInputArea(setStateInside, TaskDetails taskDetails) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(
        int.parse(taskDetails.estimatedTime ?? '0'));
    return Form(
      key: _tasksFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTaskField("Title", _titleController, 1, 50),
          vGap(15),
          _buildTaskField("Description", _descController, 5, 300),
          vGap(8),
          InkWell(
            onTap: () async {
              _showDateTimePicker(setStateInside);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                  color: appColorGreen.withOpacity(.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                // mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      // Text(
                      //   "Selected Time: ${_selectedTime?.format(context) ?? 'Not selected'}",
                      //   style: const TextStyle(fontSize: 14),
                      // )

                      (time != null)
                          ? "Est. Time : ${_getEstimatedTime(setStateInside, taskDetails.estimatedTime)}"
                          : "Select task deadline",
                      style: themeData.textTheme.bodySmall?.copyWith(
                          color: _getEstimatedTime(setStateInside,
                                      taskDetails.estimatedTime) ==
                                  "Oops! The selected time is in the past. Please choose a valid future time."
                              ? AppTheme.redErrorColor
                              : Colors.black),
                    ).paddingAll(5),
                  ),
                  Icon(
                    Icons.access_time,
                    color: appColorGreen,
                  ).paddingOnly(right: 5, top: 5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _showDateTimePicker(setStateInside) async {
    // Pick Date
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setStateInside(() {
        _newSelectedDate = pickedDate;
      });
      // setState(() => _selectedDate = pickedDate);
    }

// Pick Time
//     final pickedTime = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setStateInside(() {
        _newSelectedTime = picked;
      });
      // setState(() => _selectedTime = picked);
      print("⏰ Selected time: ${picked.format(context)}");
    }
    setStateInside(() {
      validString = "";
      newSelectedDateTime = DateTime(
        _newSelectedDate!.year,
        _newSelectedDate!.month,
        _newSelectedDate!.day,
        _newSelectedTime!.hour,
        _newSelectedTime!.minute,
      );
    });
    // if (pickedTime != null) {
    //   setState(() => _selectedTime = pickedTime);
    // }
  }

  Widget _buildTaskField(
      String label, TextEditingController controller, maxLine, maxL) {
    return CustomTextField(
      controller: controller,
      labletext: label,
      hintText: label,

      minLines: maxLine,
      maxLines: maxLine,
      validator: (value) {
        return value?.isEmptyField(messageTitle: label);
      },
      // maxLength: maxL,
    );
  }

  String _getEstimatedTime(setStateInside, estimateTime) {
    DateTime estimate =
        DateTime.fromMillisecondsSinceEpoch(int.parse(estimateTime ?? 0));

    if (estimate == null) return "";

    final selectedDateTime =
        (_newSelectedTime != null && _newSelectedDate != null)
            ? DateTime(
                _newSelectedDate!.year,
                _newSelectedDate!.month,
                _newSelectedDate!.day,
                _newSelectedTime!.hour,
                _newSelectedTime!.minute,
              )
            : DateTime(
                estimate.year,
                estimate.month,
                estimate.day,
                estimate.hour,
                estimate.minute,
              );

    setStateInside(() {
      newSelectedDateTime = selectedDateTime;
    });

    final now = DateTime.now();
    final duration = selectedDateTime.difference(now);

    if (duration.isNegative) {
      return "Oops! The selected time is in the past. Please choose a valid future time.";
    }

    final hrs = duration.inHours;
    final mins = duration.inMinutes.remainder(60);
    return "⏳ $hrs hrs $mins mins remaining";
  }

  void _showStatusPopup(BuildContext context, bool isME) async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero, ancestor: overlay);

    final isCreator = widget.message.fromId == APIs.me.id;

    final List<Map<String, dynamic>> statusOptions = isME
        ? [
            {
              'value': TaskStatus.Completed.name,
              'label': '✔️ Completed',
              'color': appColorGreen
            },
            {
              'value': TaskStatus.Cancelled.name,
              'label': '❌ Cancelled',
              'color': AppTheme.redErrorColor
            },
          ]
        : [
            {
              'value': TaskStatus.Pending.name,
              'label': '🔵 Pending',
              'color': Colors.blue
            },
            {
              'value': TaskStatus.Running.name,
              'label': '🟣 Running',
              'color': appColorPerple
            },
            {'value': 'Done', 'label': '✔️ Done', 'color': appColorYellow},
            {
              'value': TaskStatus.Cancelled.name,
              'label': '❌ Cancelled',
              'color': AppTheme.redErrorColor
            },
          ];

    final result = await showMenu<dynamic>(
      context: context,
      color: Colors.white,
      position: RelativeRect.fromLTRB(position.dx, position.dy, 0, 0),
      items: statusOptions
          .map(
            (option) => PopupMenuItem(
              value: option['value'],
              child: Text(
                option['label'],
                style: TextStyle(color: option['color']),
              ),
            ),
          )
          .toList(),
    );

    if (result != null) {
      APIs.updateTaskStatus(widget.message, result, widget.fromId);

      if (mounted) {
        setState(() {
          isFirstTimeChat = false;
        });
        storage.write(isFirstTimeChatKey, isFirstTimeChat);
      }
    }
  }

  // bottom sheet for modifying message details
  void _showBottomSheet(bool isMe) async {
    await showModalBottomSheet(
        context: context,
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

              widget.message.type == Type.text
                  ?
                  //copy option
                  _OptionItem(
                      icon: const Icon(Icons.copy_all_rounded,
                          color: Colors.blue, size: 26),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          //for hiding bottom sheet
                          Navigator.pop(context);

                          // Dialogs.showSnackbar(context, 'Text Copied!');
                        });
                      })
                  :
                  //save option
                  _OptionItem(
                      icon: const Icon(Icons.download_rounded,
                          color: Colors.blue, size: 26),
                      name: 'Save Image',
                      onTap: () async {
                        try {
                          Get.back();
                          saveImageToGallery(
                            widget.message.msg,
                          );
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
              if (widget.message.type == Type.text && isMe && !widget.isForward)
                _OptionItem(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
                    name: 'Edit Message',
                    onTap: () {
                      //for hiding bottom sheet
                      Get.back();

                      final currentStatus =
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
                          : _showMessageUpdateDialog();
                    }),

              //delete option
              if (isMe && !widget.isForward)
                _OptionItem(
                    icon: const Icon(Icons.delete_forever,
                        color: Colors.red, size: 26),
                    name: 'Delete Message',
                    onTap: () async {
                      Navigator.pop(context);
                      await APIs.deleteMessage(widget.message).then((value) {
                        Get.back();
                      });
                    }),

              //separator or divider
              if (!widget.isForward)
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
                        'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
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
                    }),
            ],
          );
        });
  }

  //dialog for updating message content
  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;

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
            ));
  }
}

//custom options card (for copy, edit, delete, etc.)
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
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
