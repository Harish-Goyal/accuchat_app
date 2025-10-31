import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_home_controller.dart';
import 'package:AccuChat/Services/storage_service.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:AccuChat/Screens/Chat/models/chat_history_response_model.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:dio/dio.dart';
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
import '../../../../../../Constants/app_theme.dart';
import '../../../../../../Constants/assets.dart';
import '../../../../../../Constants/colors.dart';
import '../../../../../../Services/APIs/local_keys.dart';
import '../../../../../../utils/common_textfield.dart';
import '../../../../../../utils/custom_dialogue.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../../utils/gradient_button.dart';
import '../../../../../../utils/helper.dart';
import '../../../../../../utils/product_shimmer_widget.dart';
import '../../../../../../utils/text_style.dart';
import '../../../../../Home/Presentation/Controller/socket_controller.dart';
import '../../../../models/task_res_model.dart';
import '../../../../models/task_status_res_model.dart';
import '../Controllers/task_controller.dart';
import '../Widgets/staggered_view.dart';
import '../../../../api/apis.dart';
import '../Controllers/gallery_view_controller.dart';
import '../Widgets/media_view.dart';
import 'images_gallery_page.dart';
import 'package:path_provider/path_provider.dart';

/// -------------------------
/// Responsive helpers (added)
/// -------------------------
class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
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
  if (w >= 1600) return 1200;
  if (w >= 1366) return 1100;
  if (w >= 1200) return 1000;
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

class TaskScreen extends GetView<TaskController> {
  final GlobalKey _menuKey = GlobalKey();
  TaskScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskController>(builder: (controller) {
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: WillPopScope(
            //if emojis are shown & back button is pressed then hide emojis
            //or else simple close current screen on back button click
            onWillPop: () {
              Get.find<TaskHomeController>().hitAPIToGetRecentTasksUser();
              return Future.value(true);
            },
            child: SafeArea(
              child: Scaffold(
                //app bar
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  automaticallyImplyLeading: false,
                  flexibleSpace: MediaQuery(
                    // ✅ clamp text scale for web
                    data: MediaQuery.of(context)
                        .copyWith(textScaleFactor: _textScaleClamp(context)),
                    child: _appBar(),
                  ),
                ),

                backgroundColor: const Color.fromARGB(255, 234, 248, 255),

                //body
                body: ScrollConfiguration(
                  // ✅ nicer scrolling on web + no glow
                  behavior: const _NoGlowScrollBehavior(),
                  child: Center(
                    // ✅ center content on wide screens
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: _maxChatWidth(context)),
                      child: Padding(
                        padding: _shellHPadding(context),
                        child: Column(
                          children: [
                            Expanded(child:  RepaintBoundary(child: chatMessageBuilder())),

                            //TODO
                            if (controller.replyToMessage != null)
                              Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.only(
                                    bottom: 4, left: 8, right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white54,
                                  border: Border.all(
                                      color: appColorGreen, width: .4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.reply, color: appColorGreen),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "${controller.replyToMessage?.fromUser?.userId == controller.me?.userId ? 'You' : controller.user?.displayName ?? ''}: ${controller.replyToMessage?.message ?? ''}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: themeData.textTheme.bodySmall
                                            ?.copyWith(color: greyText),
                                      ) /*:SizedBox()*/,
                                    ),
                                    IconButton(
                                        icon: const Icon(
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
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))),

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
    return controller.taskCategory.isNotEmpty &&( controller.taskHisList??[]).isNotEmpty
        ? GroupedListView<GroupTaskElement, DateTime>(
            shrinkWrap: false,
            padding: const EdgeInsets.only(bottom: 30),
            controller: controller.scrollController,
            elements: controller.taskCategory,
            order: GroupedListOrder.DESC,
            reverse: true,
            floatingHeader: true,
            useStickyGroupSeparators: true,
            groupBy: (GroupTaskElement element) => DateTime(
                  element.date.year,
                  element.date.month,
                  element.date.day,
                ),
            groupHeaderBuilder: _createGroupHeader,
            indexedItemBuilder:
                (BuildContext context, GroupTaskElement element, int index) {
              String formatatedTime = '';
              if (element.taskMsg.createdOn != null) {
                var timeString = element.taskMsg.createdOn ?? '';

                formatatedTime = controller.convertUtcToIndianTime(timeString);
              }

              var userid = controller.me?.userId;
              return StaggeredAnimationListItem(
                index: index,
                child: SwipeTo(
                  onRightSwipe: (detail) {
                    controller.goToTaskThread(element);
                    // Get.find<SocketController>().joinTaskEmitter(taskId: element.taskMsg.taskId??0);
                    //
                    // // Set the message being replied to
                    // controller.refIdis = element.taskMsg.taskId;
                    // controller.userIDSender = element.taskMsg.fromUser?.userId;
                    // controller.userNameReceiver =
                    //     element.taskMsg.toUser?.userName ?? '';
                    // controller.userNameSender =
                    //     element.taskMsg.fromUser?.userName ?? '';
                    // controller.userIDReceiver = element.taskMsg.toUser?.userId;
                    // // controller.replyToMessage = element.taskMsg;
                    //
                    // controller.update();
                    //
                    // if(kIsWeb){
                    //   Get.toNamed("${AppRoutes.task_threads}?currentUserId=${controller.user?.userId.toString()}&taskMsgId=${element.taskMsg.taskId.toString()}"
                    //     );
                    //
                    // }else{
                    //   Get.toNamed(AppRoutes.task_threads,
                    //       arguments: {
                    //         'taskMsg':  element.taskMsg, 'currentUser': controller.user!
                    //       });
                    // }


                  },
                  child: _chatMessageTile(
                  element,
                      data: element.taskMsg,
                      sentByMe: (userid.toString() ==
                              element.taskMsg.fromUser?.userId?.toString()
                          ? true
                          : false),
                      formatedTime: formatatedTime,
                      contexts: context),
                ),
              );
            })
        : const Center(
            child: Text('Task Send as Chat!', style: TextStyle(fontSize: 20)));
  }

  Widget _createGroupHeader(GroupTaskElement element) {
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

  Widget _chatMessageTile(GroupTaskElement element,{
    required TaskData data,
    required bool sentByMe,
    formatedTime,
    required BuildContext contexts,

  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // makes the whole area tappable
      onTapUp: (details) {
        _showStatusPopup(
          isME: sentByMe,
          task: data,
          contextt: contexts, // use the local BuildContext
          globalPos: details.globalPosition, // from TapUpDetails
        );
      },
      onLongPress: () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        _showBottomSheet(sentByMe,element ,data: data);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment:
                sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (sentByMe)
                      ? IconButton(
                          onPressed: () {
                            controller.handleForward( taskData: data);
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
                    child: Container(
                      alignment: sentByMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      padding: EdgeInsets.only(
                          top: 4,
                          left: (sentByMe ? 0 : 15),
                          right: (sentByMe ? 15 : 0)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: sentByMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 15,
                            ),
                            margin: sentByMe
                                ? const EdgeInsets.only(left: 15, top: 0)
                                : const EdgeInsets.only(right: 15, top: 3),
                            decoration: BoxDecoration(
                                color:
                                    getTaskStatusColor(data.currentStatus?.name)
                                        .withOpacity(.1),
                                border: Border.all(
                                    color: getTaskStatusColor(
                                        data.currentStatus?.name)),
                                //making borders curved
                                borderRadius: sentByMe
                                    ? const BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        topRight: Radius.circular(30),
                                        bottomLeft: Radius.circular(30))
                                    : const BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        topRight: Radius.circular(30),
                                        bottomRight: Radius.circular(30))),
                            child: _taskCard(message: data),
                          ).marginOnly(left: (0), top: 0),
                        ],
                      ),
                    ),
                  ),
                  (data.title != null &&
                          (data.media ?? []).isNotEmpty &&
                          !sentByMe)
                      ? IconButton(
                          onPressed: () {
                            controller.handleForward(taskData: data);
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
              if ((StorageService.checkFirstTimeTask()) && isTaskMode)
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 2000),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0, top: 4),
                    child: Text(
                      "👆 Double tap to update status",
                      style: TextStyle(
                        fontSize: 12,
                        color: appColorGreen,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ).paddingSymmetric(horizontal: 15),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatedTime ?? '',
                    textAlign: TextAlign.start,
                    style: BalooStyles.baloonormalTextStyle(
                        color: Colors.grey, size: 13),
                  ).marginOnly(left: 15, right: 15),
                ],
              ),
              vGap(15),
            ],
          ),
          Positioned(
            right: sentByMe ? 22 : null,
            left: sentByMe ? null : 22,
            top: -8,
            child:  statusHistroryPopUp(status: data.currentStatus,statusHis:data.statusHistory)

          ),
        ],
      ),
    );
  }


  statusHistroryPopUp({ List<StatusHistory>? statusHis,  CurrentStatus? status}){
    return PopupMenuButton<int>(
      tooltip: 'Status history',
      elevation: 2,
      offset: const Offset(0, 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => _buildMenuItems(statusHis??[], APIs.me.displayName??''),
      child: Container(
        // alignment: Alignment.center,
        padding:
        const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: getTaskStatusColor(
                status?.name?.capitalizeFirst)),
        child: Text(
          "${status?.name} /${statusHis?.length??0}",
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 13,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
}


  List<PopupMenuEntry<int>> _buildMenuItems(
      List<StatusHistory> history,
      String  resolveName,
      ) {
    if (history.isEmpty) {
      return const [
        PopupMenuItem<int>(
          enabled: false,
          child: Text('No status history'),
        ),
      ];
    }

    // Sort ASC and collapse consecutive same statuses
    final items = [...history]..sort((a, b) =>
        DateTime.parse(a.createdOn??'').compareTo(DateTime.parse(b.createdOn??'')));
    final cleaned = <StatusHistory>[];
    for (final e in items) {
      final m = e; StatusHistory;
      if (cleaned.isEmpty || cleaned.last.taskStatusId != m.taskStatusId) {
        cleaned.add(m);
      }
    }

    final list = <PopupMenuEntry<int>>[
       PopupMenuItem<int>(
        enabled: false,
        child: Text('Status History', style: BalooStyles.baloosemiBoldTextStyle()),
      ),
    ];

    // Show latest first
    for (final e in cleaned.reversed) {
      final id = e.taskStatusId as int;
      final statusName = (e.statusName??'');
      final by =  resolveName;
      final when = controller.formatWhen(e.createdOn??'');

      list.add(PopupMenuItem<int>(
        enabled: false,
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Status changed to $statusName',
            style: BalooStyles.balooregularTextStyle( italicFontStyle: true,),

          ),
          subtitle: Text('by $by at $when',
            style: BalooStyles.balooregularTextStyle(),),
        ),
      ));
    }

    return list;
  }


  _taskCard({required TaskData message}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("📝 ${message?.title}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        vGap(5),
        Text(
          message?.details ?? '',
          style: themeData.textTheme.bodySmall,
        ),
        if ((message?.deadline ?? '').isNotEmpty) ...[
          vGap(10),
          Text(
              "⏱️ Est. Time: ${estimateLabel(deadlineIso: message.deadline ?? '', createdIso: message.createdOn ?? '')}",
              style: TextStyle(fontSize: 14, color: AppTheme.redErrorColor)),
        ],
        vGap(8),
        (message.media) != null
            ? buildTaskAttachments(message.media)
            : const SizedBox(),
      ],
    );
  }


  Future<void> openDocumentFromUrl(String url) async {
    customLoader.show();
    if (kIsWeb) {
      // Web: just open in a new tab (downloads or previews based on file type/server headers)
      customLoader.hide();
      final ok = await launchUrlString(
        url,
        mode: LaunchMode.externalApplication, // opens new tab
      );
      if (!ok) throw 'Could not open $url';
      return;
    }
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




  Map<String, dynamic>? _extractTaskDetails(String message) {
    final taskRegex = RegExp(r'task:\s*(.+)', caseSensitive: false);
    final timeRegex = RegExp(r'time:\s*(.+)', caseSensitive: false);

    final taskMatch = taskRegex.firstMatch(message);
    final timeMatch = timeRegex.firstMatch(message);

    if (taskMatch != null) {
      return {
        'title': taskMatch.group(1)?.trim() ?? '',
        'description': message,
        'estimatedTime': timeMatch?.group(1)?.trim() ?? ''
      };
    }

    return null;
  }



  void _showStatusPopup({
    required bool isME,
    required TaskData task,
    required BuildContext contextt,
    required Offset globalPos,
  }) async {
    final overlay =
    Overlay.of(contextt).context.findRenderObject() as RenderBox;

    final result = await showMenu<dynamic>(
      context: contextt,
      color: Colors.white,
      position: RelativeRect.fromLTRB(
        globalPos.dx,
        globalPos.dy,
        overlay.size.width - globalPos.dx,
        overlay.size.height - globalPos.dy,
      ),
      items: controller.taskStatus
          .map(
            (option) => PopupMenuItem(
          value: option.taskStatusId,
          child: Text(
            option.status ?? '',
            style: TextStyle(
                color: getTaskStatusColor(option.status?.capitalizeFirst)),
          ),
        ),
      )
          .toList(),
    );
    if (result != null) {
      controller.updateTaskApiCall(taskStatusId: result,task:task);
      isFirstTimeChat = false;
      controller.update();
      StorageService.setFirstTimeTask(isFirstTimeChat);
    }
  }
  DashboardController dashboardController = Get.put(DashboardController());

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
                      Get.find<TaskHomeController>().hitAPIToGetRecentTasksUser();

                      if (isTaskMode) {
                        dashboardController.updateIndex(1);
                      } else {
                        dashboardController.updateIndex(0);
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

                    controller.user?.displayName != null
                        ? Text(
                            controller.user?.displayName ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: themeData.textTheme.titleMedium,
                          )
                        : Text(
                            controller.user?.phone ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: themeData.textTheme.titleMedium,
                          ),

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
                    Get.toNamed(AppRoutes.member_sr,
                        arguments: {'user': controller.user});
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
                        const Text('Add Member'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'Exit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.exit_to_app_rounded,
                          color: appColorGreen,
                          size: 18,
                        ),
                        hGap(5),
                        const Text('Exit'),
                      ],
                    ),
                  ),
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
                        const Text('Edit'),
                      ],
                    ),
                  ),
                ],
              )
            : const SizedBox(),
        GetBuilder<TaskController>(
          id: 'statusMenu',
          builder: (controller) {
            // Loading state
            if (controller.isLoadings && controller.taskStatus.isEmpty) {
              return PopupMenuButton(
                enabled: false,
                icon: const Icon(Icons.filter_alt_outlined,
                    color: Colors.black87),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    enabled: false,
                    child: SizedBox(
                      height: 24,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ],
              );
            }

            return PopupMenuButton<dynamic>(
              color: Colors.white,
              icon:
                  const Icon(Icons.filter_alt_outlined, color: Colors.black87),
              onSelected: (v) {
                final taskcon = Get.find<TaskController>();
                taskcon.page=1;
                taskcon.update();
                if(v=='all'){
                  Get.find<TaskController>().hitAPIToGetTaskHistory(isFilter: true);
                }else if(v==TimeFilter.today || v==TimeFilter.thisMonth||v==TimeFilter.thisWeek){
                  final now = DateTime.now();
                  final r = rangeFor(v);
                  Get.find<TaskController>().hitAPIToGetTaskHistory(isFilter: true
                  ,
                  fromDate: r.fromUtc.toIso8601String(),
                  toDate: r.toUtc.toIso8601String());


                }else{
                  Get.find<TaskController>().hitAPIToGetTaskHistory(statusId: v,isFilter: true);
                }
              },
              itemBuilder: (context) {
                final items = <PopupMenuEntry<dynamic>>[
                   PopupMenuItem(value: 'all', child: Text('All Tasks',style: BalooStyles.baloonormalTextStyle())),
                  const PopupMenuDivider(),
                  // --- Dynamic statuses from API ---
                  ...controller.taskStatus.map((s) => PopupMenuItem(
                        value: s.taskStatusId, // pass ID to onSelected
                        child: Text(s.status ?? 'Unknown',style: BalooStyles.baloonormalTextStyle()),
                      )),
                 const PopupMenuDivider(),



                  PopupMenuItem(value: TimeFilter.today,     child: Text('Today',style: BalooStyles.baloonormalTextStyle(),)),
                  PopupMenuItem(value: TimeFilter.thisWeek,  child: Text('This Week',style: BalooStyles.baloonormalTextStyle())),
                  PopupMenuItem(value: TimeFilter.thisMonth, child: Text('This Month',style: BalooStyles.baloonormalTextStyle())),
                ];
                return items;
              },
            );
          },
        )
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
                                      // if (_showEmoji)
                                      //   setState(() => _showEmoji = !_showEmoji);

                                      if (isTaskMode) {
                                        showDialog(
                                            context: Get.context!,
                                            builder: (_) =>
                                                _createTasksDialogWidget(
                                                    controller.user?.displayName ??
                                                        '')).then((pickedTime) {
                                          if (pickedTime != null) {
                                            controller.update();
                                            // _selectedTime = pickedTime;
                                          }
                                        });
                                      }
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
                  print(controller.textController.text);
                  Get.find<SocketController>().sendMessage(
                    receiverId: controller.user?.userId ?? 0,
                    message: controller.textController.text.trim(),
                    isGroup: 0,
                    type: "direct",
                    companyId: controller.user?.userCompany?.companyId,
                    alreadySave: false,
                    replyToId: controller.replyToMessage
                        ?.chatId, // working for reply if  replyToMessage not null than send msg is work for reply msf
                  );
                  controller.textController.clear();
                  controller.replyToMessage = null;
                  controller.update();
                }

                Get.find<TaskController>().hitAPIToGetTaskHistory();

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

  void showUploadOptionsForTask(BuildContext context, setStateInside) {
    if (kIsWeb) {
      // Web: use a simple dialog + file_picker
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: const Text('Add Attachments'),
          content: const Text('Select images or documents from your computer.'),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.photo),
              label: const Text('Select Images'),
              onPressed: () async {
                Navigator.of(context).pop();
                await controller.pickWebImagesForTask(setStateInside);
              },
            ),
            TextButton.icon(
              icon:  Icon(Icons.picture_as_pdf),
              label:  Text('Select Documents',style: BalooStyles.baloomediumTextStyle(),),
              onPressed: () async {
                Navigator.of(context).pop();
                await controller.pickWebDocsForTask(setStateInside);
              },
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:  Text('Cancel',style: BalooStyles.baloomediumTextStyle()),
            ),
          ],
        ),
      );
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
                  setStateInside(() {
                    controller.isUploadingTaskDoc = true;
                  });
                  Get.back();

                  try {
                    final ImagePicker picker = ImagePicker();
                    // Pick an image
                    final XFile? image = await picker.pickImage(
                        source: ImageSource.camera, imageQuality: 50);
                    if (image != null) {
                      final file = File(image.path);
                      final fileName =
                          'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';
                      controller.attachedFiles.add({
                        'url': file,
                        'type': 'image',
                        'name': fileName,
                        'isLocal': true,
                        'isDelete': false
                      });
                      controller.update();
                    }
                  } catch (e) {
                    print(e.toString());
                    setStateInside(() {
                      controller.isUploadingTaskDoc = true;
                    });
                  }
                  setStateInside(() {
                    controller.isUploadingTaskDoc = false;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () async {
                  setStateInside(() {
                    controller.isUploadingTaskDoc = true;
                  });
                  Get.back();
                  try {
                    final ImagePicker picker = ImagePicker();

                    final List<XFile> images =
                        await picker.pickMultiImage(imageQuality: 50, limit: 3);
                    final remainingSlots = 3 - controller.attachedFiles.length;
                    if (images.length > remainingSlots) {
                      images.removeRange(remainingSlots, images.length);
                    }
                    for (var i in images) {
                      final file = File(i.path);

                      final fileName =
                          'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';

                      setStateInside(() {
                        controller.attachedFiles.add(
                            {'url': file, 'type': 'image', 'name': fileName,'isLocal':true,'isDelete':false});
                      });
                    }
                  } catch (e) {
                    print(e.toString());
                    setStateInside(() {
                      controller.isUploadingTaskDoc = true;
                    });
                  }
                  setStateInside(() {
                    controller.isUploadingTaskDoc = false;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text("Document"),
                onTap: () {
                  Get.back();
                  controller.pickDocumentForTask(setStateInside);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // bottom sheet for modifying message details
  void _showBottomSheet(bool isMe,GroupTaskElement element, {required TaskData data}) async {
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

              //copy option
              _OptionItem(
                  icon: const Icon(Icons.copy_all_rounded,
                      color: Colors.blue, size: 18),
                  name: 'Reply',
                  onTap: () async {
                    Get.back();
                    controller.goToTaskThread(element);
                    // Dialogs.showSnackbar(context, 'Text Copied!');
                  }),

              //separator or divider
              if (isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * .04,
                  indent: mq.width * .04,
                ),

              //edit option
              if (isMe)
                _OptionItem(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                    name: 'Edit',
                    onTap: () {
                      //for hiding bottom sheet
                      Get.back();

                      final currentStatus =
                          data.currentStatus?.name?.toLowerCase() ?? 'Pending';

                      (['Done', 'Completed', 'Cancelled']
                              .contains(currentStatus))
                          ? toast(
                              "⛔ Task status is '$currentStatus' — update not allowed.")
                          : openUpdateTaskDialog(data);
                    }),

              // delete option
              if ((controller.me?.userId == controller.myCompany?.createdBy))
                _OptionItem(
                    icon: const Icon(Icons.delete_forever,
                        color: Colors.red, size: 18),
                    name: 'Delete',
                    onTap: () async {
                      if(data.currentStatus?.name == "Pending"){
                        Get.find<SocketController>().deleteTaskEmitter(
                            taskId: data.taskId ?? 0,
                            comid: controller.myCompany?.companyId
                        );
                      }else{
                        Get.back();
                        toast("Status have changed! you cannot delete this task");
                      }


                    }),
            ],
          );
        });
  }

  void openUpdateTaskDialog(TaskData task) {
    // reset UI list first
    controller.titleController.text = task.title ?? '';
    controller.descController.text = task.details ?? '';
    controller.attachedFiles = [];

    // hydrate from server media -> attachedFiles
    for (TaskMedia m in (task.media ?? [])) {
      controller.attachedFiles.add({
        'type': (m.mediaType?.mediaType ?? '').toLowerCase() == 'image'
            ? 'image'
            : 'doc',
        'name': m.fileName ?? '',
        'url': m.fileName ?? m.fileName,
        'isLocal': false,
        'isDelete': false
      });
    }

    showDialog(
      context: Get.context!,
      builder: (_) => _updateTasksDialogWidget(task),
    );
  }

  _createTasksDialogWidget(String userName) {
    return LayoutBuilder(
        builder: (context, constraints) {
          final w = MediaQuery.of(context).size.width;
          final h = MediaQuery.of(context).size.height;

          final bool isDesktop = w >= 1024;
          final bool isTablet  = w >= 700 && w < 1024;

          // Web par dialog ki max width/height clamp
          final double maxW = isDesktop ? 700 : (isTablet ? 720 : w * 0.95);
          final double maxH = h * (kIsWeb ? 0.9 : 0.95);
          return StatefulBuilder(builder: (context, setStateInside) {
          return CustomDialogue(
            title:
                "Create Task for ${controller.user?.userId == APIs.me.userId ? 'You' : userName.isEmpty ? controller.user?.phone : userName}",
            isShowAppIcon: false,
            // content: Column(
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //     Text(
            //       "Enter Task Details",
            //       style: BalooStyles.baloonormalTextStyle(),
            //       textAlign: TextAlign.center,
            //     ),
            //     Text(
            //       controller.validString,
            //       style: BalooStyles.baloonormalTextStyle(
            //           color: AppTheme.redErrorColor),
            //       textAlign: TextAlign.center,
            //     ),
            //     vGap(10),
            //     _taskInputArea(setStateInside),
            //     vGap(10),
            //     const Text("Attachments",
            //         style: TextStyle(fontWeight: FontWeight.bold)),
            //     vGap(10),
            //     if (controller.isUploadingTaskDoc) const IndicatorLoading(),
            //     Wrap(
            //       spacing: 8,
            //       runSpacing: 8,
            //       children: controller.attachedFiles.map((file) {
            //         final String type = file['type'];
            //         final String name = file['name'];
            //         final url = file['url'];
            //
            //         Widget preview;
            //
            //         if (type == 'image') {
            //           preview = url != null
            //               ? /*url.startWith('http')?  CustomCacheNetworkImage(
            //             url,
            //             radiusAll: 8,
            //             width: 75,
            //             height: 75,
            //             boxFit: BoxFit.cover,
            //             defaultImage: defaultGallery,
            //           ):*/
            //               ClipRRect(
            //                   borderRadius: BorderRadius.circular(8),
            //                   child: Image.file(
            //                     url,
            //                     width: 75,
            //                     height: 75,
            //                     fit: BoxFit.cover,
            //                   ),
            //                 )
            //               : const SizedBox();
            //         } else if (type == 'doc') {
            //           IconData icon;
            //           if (name.endsWith('.pdf')) {
            //             icon = Icons.picture_as_pdf;
            //           } else if (name.endsWith('.doc') || name.endsWith('.docx')) {
            //             icon = Icons.description;
            //           } else if (name.endsWith('.txt')) {
            //             icon = Icons.note;
            //           } else {
            //             icon = Icons.insert_drive_file;
            //           }
            //
            //           preview = Container(
            //             width: 75,
            //             height: 75,
            //             padding: const EdgeInsets.symmetric(horizontal: 2),
            //             decoration: BoxDecoration(
            //               border: Border.all(color: Colors.grey.shade400),
            //               borderRadius: BorderRadius.circular(8),
            //             ),
            //             child: Column(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: [
            //                 Icon(icon, size: 30, color: Colors.grey),
            //                 Text(name,
            //                     textAlign: TextAlign.center,
            //                     maxLines: 2,
            //                     overflow: TextOverflow.ellipsis,
            //                     style: const TextStyle(fontSize: 10)),
            //               ],
            //             ),
            //           );
            //         } else {
            //           preview = const SizedBox();
            //         }
            //
            //         return Stack(
            //           alignment: Alignment.topRight,
            //           clipBehavior: Clip.none,
            //           children: [
            //             preview,
            //             Positioned(
            //               top: -5,
            //               right: -5,
            //               child: GestureDetector(
            //                 onTap: () {
            //                   setStateInside(() {
            //                     controller.attachedFiles.remove(file);
            //                   });
            //                   controller.update();
            //                 },
            //                 child: const CircleAvatar(
            //                   radius: 13,
            //                   backgroundColor: Colors.red,
            //                   child:
            //                       Icon(Icons.close, size: 12, color: Colors.white),
            //                 ),
            //               ),
            //             ),
            //           ],
            //         );
            //       }).toList(),
            //     ),
            //     vGap(10),
            //     GestureDetector(
            //       onTap: () => controller.attachedFiles.length < 3
            //           ? showUploadOptionsForTask(context, setStateInside)
            //           : toast("You can upload upto 3 attachments only"),
            //       child: const Chip(
            //         avatar: Icon(Icons.attach_file),
            //         label: Text("Add Attachments"),
            //         backgroundColor: Colors.white,
            //       ),
            //     ),
            //     vGap(20),
            //     GradientButton(
            //       name:
            //           "Send Task to ${controller.user?.userId == controller.me?.userId ? 'You' : userName.isEmpty ? controller.user?.phone : userName}",
            //       btnColor: AppTheme.appColor,
            //       vPadding: 8,
            //       onTap: () {
            //         if (controller.tasksFormKey.currentState!.validate()) {
            //           if (controller.getEstimatedTime(setStateInside) != "" &&
            //               controller.selectedDate != null &&
            //               controller.selectedTime != null) {
            //             if (controller.getEstimatedTime(setStateInside) ==
            //                 "Oops! The selected time is in the past. Please choose a valid future time.") {
            //               setStateInside(() {
            //                 controller.validString =
            //                     "Please select valid time check AM PM correctly";
            //               });
            //             } else {
            //               if (!controller.isUploadingTaskDoc) {
            //                 controller.sendTaskApiCall();
            //               } else {
            //                 toast("Please wait");
            //               }
            //             }
            //           } else {
            //             if (!controller.isUploadingTaskDoc) {
            //               controller.sendTaskApiCall();
            //             } else {
            //               toast("Please wait");
            //             }
            //           }
            //         }
            //       },
            //     )
            //   ],
            // ),

            content:  Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxW,
                  // Agar content zyada ho jaye to vertical scroll allow
                  maxHeight: maxH,
                ),
                child: Scrollbar(
                  thumbVisibility: kIsWeb, // web par scrollbar visible
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Enter Task Details",
                          style: BalooStyles.baloonormalTextStyle(),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          controller.validString,
                          style: BalooStyles.baloonormalTextStyle(
                              color: AppTheme.redErrorColor),
                          textAlign: TextAlign.center,
                        ),
                        vGap(10),
                        _taskInputArea(setStateInside),
                        vGap(10),
                        const Text("Attachments",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        vGap(10),
                        if (controller.isUploadingTaskDoc) const IndicatorLoading(),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: controller.attachedFiles.map((file) {
                            print(controller.attachedFiles.map((v)=>v));
                            final String type = file['type'];
                            final String name = file['name'];
                            final url = file['url'];

                            Widget preview;

                            if (type == 'image') {
                              // On mobile: we stored a File in 'file'
                              // On web: we stored Uint8List in 'bytes'
                              final fileis = file['url'];          // File? (mobile)
                              final bytes = file['bytes'];        // Uint8List? (web)

                              if (kIsWeb && bytes != null) {
                                preview =Container(
                                  width: 75,
                                  height: 75,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      bytes,
                                      width: 75,
                                      height: 75,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              } else if (!kIsWeb && file != null) {
                                preview = Container(
                                  width: 75,
                                  height: 75,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      fileis,
                                      width: 75,
                                      height: 75,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              } else {
                                preview = const SizedBox();
                              }
                            }
                            else if (type == 'doc') {
                              IconData icon;
                              if (name.endsWith('.pdf')) {
                                icon = Icons.picture_as_pdf;
                              } else if (name.endsWith('.doc') || name.endsWith('.docx')) {
                                icon = Icons.description;
                              } else if (name.endsWith('.txt')) {
                                icon = Icons.note;
                              } else {
                                icon = Icons.insert_drive_file;
                              }

                              preview = Container(
                                width: 75,
                                height: 75,
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(icon, size: 30, color: Colors.grey),
                                    Text(name,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 10)),
                                  ],
                                ),
                              );
                            } else {
                              preview = const SizedBox();
                            }

                            return Stack(
                              alignment: Alignment.topRight,
                              clipBehavior: Clip.none,
                              children: [
                                preview,
                                Positioned(
                                  top: -5,
                                  right: -5,
                                  child: GestureDetector(
                                    onTap: () {
                                      setStateInside(() {
                                        controller.attachedFiles.remove(file);
                                      });
                                      controller.update();
                                    },
                                    child: const CircleAvatar(
                                      radius: 13,
                                      backgroundColor: Colors.red,
                                      child:
                                      Icon(Icons.close, size: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        vGap(10),
                        GestureDetector(
                          onTap: () => controller.attachedFiles.length < 3
                              ? showUploadOptionsForTask(context, setStateInside)
                              : toast("You can upload upto 3 attachments only"),
                          child: const Chip(
                            avatar: Icon(Icons.attach_file),
                            label: Text("Add Attachments"),
                            backgroundColor: Colors.white,
                          ),
                        ),
                        vGap(20),
                        GradientButton(
                          name:
                          "Send Task to ${controller.user?.userId == controller.me?.userId ? 'You' : userName.isEmpty ? controller.user?.phone : userName}",
                          btnColor: AppTheme.appColor,
                          vPadding: 8,
                          onTap: () {
                            if (controller.tasksFormKey.currentState!.validate()) {
                              if (controller.getEstimatedTime(setStateInside) != "" &&
                                  controller.selectedDate != null &&
                                  controller.selectedTime != null) {
                                if (controller.getEstimatedTime(setStateInside) ==
                                    "Oops! The selected time is in the past. Please choose a valid future time.") {
                                  setStateInside(() {
                                    controller.validString =
                                    "Please select valid time check AM PM correctly";
                                  });
                                } else {
                                  if (!controller.isUploadingTaskDoc) {
                                    controller.sendTaskApiCall();
                                  } else {
                                    toast("Please wait");
                                  }
                                }
                              } else {
                                if (!controller.isUploadingTaskDoc) {
                                  controller.sendTaskApiCall();
                                } else {
                                  toast("Please wait");
                                }
                              }
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

            onOkTap: () {},
          );
        });
      }
    );
  }

  Widget _taskInputArea(setStateInside, {TaskData? taskDetails}) {
    return Form(
      key: controller.tasksFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTaskField("Title", controller.titleController, 1, 50),
          vGap(15),
          _buildTaskField("Description", controller.descController, 5, 300),
          vGap(8),
         //TODO
          taskDetails==null?    InkWell(
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

                      (controller.selectedDate != null &&
                              controller.selectedTime != null)
                          ? "Est. Time : ${controller.getEstimatedTime(setStateInside)}"
                          : "Select task deadline",
                      style: themeData.textTheme.bodySmall?.copyWith(
                          color: controller.getEstimatedTime(setStateInside) ==
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
          ):SizedBox(),
        ],
      ),
    );
  }


  Widget _buildTaskField(
      String label, TextEditingController controller, maxLine, maxL) {
    return CustomTextField(
      controller: controller,
      labletext: label,
      hintText: label,
      minLines: maxLine,

      maxLines: maxLine,
      textInputType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      validator: (value) {
        return value?.isEmptyField(messageTitle: label);
      },
      // maxLength: maxL,
    );
  }

  Widget buildTaskAttachments(List<TaskMedia>? attachments) {
    return Container(
      // padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: Colors.white),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: (attachments ?? []).map((att) {
          final fileName = (att.fileName ?? '')
              .split('/')
              .last
              .replaceAll(RegExp(r'^DOC_\d+_'), '');
          final isImage = (att.fileName ?? '').endsWith('.png') ||
              (att.fileName ?? '').endsWith('.jpg') ||
              (att.fileName ?? '').endsWith('.jpeg');

          return GestureDetector(
            onTap: () async {
              if (isImage) {
                // Show image in dialog
                showDialog(
                  context: Get.context!,
                  builder: (_) => Dialog(
                    backgroundColor: Colors.transparent,
                    child: InteractiveViewer(
                      child: CustomCacheNetworkImage(
                        "${ApiEnd.baseUrlMedia}/${att.fileName ?? ''}",
                        radiusAll: 15,
                        boxFit: BoxFit.contain,
                        defaultImage: defaultGallery,
                      ),
                    ),
                  ),
                );
              } else {
                openDocumentFromUrl(
                    "${ApiEnd.baseUrlMedia}${att.fileName ?? ''}");
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              margin:
              const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
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
                      fileName,
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

  _updateTasksDialogWidget(TaskData taskDetails) {
    bool hydrated = false;
    return StatefulBuilder(builder: (context, setStateInside) {
      // if (!hydrated) {
      //   controller.attachedFiles = [];
      //   for (TaskMedia m in (taskDetails.media ?? [])) {
      //     controller.attachedFiles.add({
      //       'type'    : (m.mediaType?.mediaType ?? '').toLowerCase() == 'image' ? 'image' : 'doc',
      //       'name'    : m.fileName ?? '',
      //       'url'     : m.fileName ?? m.fileName,
      //     });
      //   }
      //   hydrated = true;
      // }
      return CustomDialogue(
        title: "Update Task",
        isShowAppIcon: false,
        // content: Column(
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     Text(
        //       "Enter Task Details",
        //       style: BalooStyles.baloonormalTextStyle(),
        //       textAlign: TextAlign.center,
        //     ),
        //     Text(
        //       controller.validString,
        //       style: BalooStyles.baloonormalTextStyle(
        //           color: AppTheme.redErrorColor),
        //       textAlign: TextAlign.center,
        //     ),
        //     vGap(20),
        //     _taskInputArea(setStateInside, taskDetails: taskDetails),
        //    //TODO
        //    /* vGap(10),
        //     const Text("Attachments",
        //         style: TextStyle(fontWeight: FontWeight.bold)),
        //     vGap(10),
        //     if (controller.isUploadingTaskDoc) const IndicatorLoading(),
        //     Wrap(
        //       spacing: 8,
        //       runSpacing: 8,
        //       children: controller.attachedFiles.map((file) {
        //         final String type = file['type'];
        //         final String name = file['name'];
        //         final url = file['url'];
        //
        //         Widget preview;
        //
        //         if (type == 'image') {
        //           preview = url != null
        //               ? url is File
        //                   ? ClipRRect(
        //                       borderRadius: BorderRadius.circular(8),
        //                       child: Image.file(url,
        //                           width: 75, height: 75, fit: BoxFit.cover),
        //                     )
        //                   : url is String && url.isNotEmpty
        //                       ? CustomCacheNetworkImage(
        //                           "${ApiEnd.baseUrlMedia}$url",
        //                           radiusAll: 8,
        //                           width: 75,
        //                           height: 75,
        //                           boxFit: BoxFit.cover,
        //                           defaultImage: defaultGallery,
        //                         )
        //                       : const SizedBox()
        //               : const SizedBox();
        //         } else if (type == 'doc') {
        //           IconData icon;
        //           if (name.endsWith('.pdf')) {
        //             icon = Icons.picture_as_pdf;
        //           } else if (name.endsWith('.doc') || name.endsWith('.docx')) {
        //             icon = Icons.description;
        //           } else if (name.endsWith('.txt')) {
        //             icon = Icons.note;
        //           } else {
        //             icon = Icons.insert_drive_file;
        //           }
        //
        //           preview = Container(
        //             width: 75,
        //             height: 75,
        //             padding: const EdgeInsets.symmetric(horizontal: 2),
        //             decoration: BoxDecoration(
        //               border: Border.all(color: Colors.grey.shade400),
        //               borderRadius: BorderRadius.circular(8),
        //             ),
        //             child: Column(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               children: [
        //                 Icon(icon, size: 30, color: Colors.grey),
        //                 Text(name,
        //                     textAlign: TextAlign.center,
        //                     maxLines: 2,
        //                     overflow: TextOverflow.ellipsis,
        //                     style: const TextStyle(fontSize: 10)),
        //               ],
        //             ),
        //           );
        //         } else {
        //           preview = const SizedBox();
        //         }
        //
        //         return Stack(
        //           alignment: Alignment.topRight,
        //           clipBehavior: Clip.none,
        //           children: [
        //             preview,
        //             Positioned(
        //               top: -5,
        //               right: -5,
        //               child: GestureDetector(
        //                 onTap: () {
        //                   setStateInside(() {
        //                     controller.attachedFiles.remove(file);
        //                   });
        //                   controller.update();
        //                 },
        //                 child: const CircleAvatar(
        //                   radius: 13,
        //                   backgroundColor: Colors.red,
        //                   child:
        //                       Icon(Icons.close, size: 12, color: Colors.white),
        //                 ),
        //               ),
        //             ),
        //           ],
        //         );
        //       }).toList(),
        //     ),
        //     vGap(10),
        //     GestureDetector(
        //       onTap: () => controller.attachedFiles.length < 3
        //           ? showUploadOptionsForTask(context, setStateInside)
        //           : toast("You can upload upto 3 attachments only"),
        //       child: const Chip(
        //         avatar: Icon(Icons.attach_file),
        //         label: Text("Add Attachments"),
        //         backgroundColor: Colors.white,
        //       ),
        //     ),*/
        //     vGap(30),
        //     GradientButton(
        //       name: "Update",
        //       btnColor: AppTheme.appColor,
        //       vPadding: 8,
        //       onTap: () async {
        //         if (controller.tasksFormKey.currentState!.validate()) {
        //           if (controller.getEstimatedTime(setStateInside) != "" &&
        //               controller.selectedDate != null &&
        //               controller.selectedTime != null) {
        //             if (controller.getEstimatedTime(setStateInside) ==
        //                 "Oops! The selected time is in the past. Please choose a valid future time.") {
        //               setStateInside(() {
        //                 controller.validString =
        //                     "Please select valid time check AM PM correctly";
        //               });
        //             } else {
        //               if (!controller.isUploadingTaskDoc) {
        //                 controller.updateTaskApiCall(task:taskDetails);
        //               } else {
        //                 toast("Please wait");
        //               }
        //             }
        //           } else {
        //             if (!controller.isUploadingTaskDoc) {
        //               controller.updateTaskApiCall(task:taskDetails);
        //             } else {
        //               toast("Please wait");
        //             }
        //           }
        //         }
        //       },
        //     )
        //   ],
        // ),
        content: LayoutBuilder(
          builder: (context, constraints) {
            final w = MediaQuery.of(context).size.width;
            final h = MediaQuery.of(context).size.height;

            final bool isDesktop = w >= 1024;
            final bool isTablet  = w >= 700 && w < 1024;

            final double maxW = isDesktop ? 900 : (isTablet ? 720 : w * 0.95);
            final double maxH = h * (kIsWeb ? 0.9 : 0.95);

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxW,
                  maxHeight: maxH,
                ),
                child: Scrollbar(
                  thumbVisibility: kIsWeb,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Enter Task Details",
                          style: BalooStyles.baloonormalTextStyle(),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          controller.validString,
                          style: BalooStyles.baloonormalTextStyle(
                              color: AppTheme.redErrorColor),
                          textAlign: TextAlign.center,
                        ),
                        vGap(20),
                        _taskInputArea(setStateInside, taskDetails: taskDetails),
                        // (attachments section commented by you — left untouched)
                        vGap(30),
                        GradientButton(
                          name: "Update",
                          btnColor: AppTheme.appColor,
                          vPadding: 8,
                          onTap: () async {
                            if (controller.tasksFormKey.currentState!.validate()) {
                              if (controller.getEstimatedTime(setStateInside) != "" &&
                                  controller.selectedDate != null &&
                                  controller.selectedTime != null) {
                                if (controller.getEstimatedTime(setStateInside) ==
                                    "Oops! The selected time is in the past. Please choose a valid future time.") {
                                  setStateInside(() {
                                    controller.validString =
                                    "Please select valid time check AM PM correctly";
                                  });
                                } else {
                                  if (!controller.isUploadingTaskDoc) {
                                    controller.updateTaskApiCall(task:taskDetails);
                                  } else {
                                    toast("Please wait");
                                  }
                                }
                              } else {
                                if (!controller.isUploadingTaskDoc) {
                                  controller.updateTaskApiCall(task:taskDetails);
                                } else {
                                  toast("Please wait");
                                }
                              }
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        onOkTap: () {},
      );
    });
  }

  _showDateTimePicker(setStateInside) async {
    final now = DateTime.now();

    // Pick Date
    final pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    setStateInside(() {
      controller.selectedDate = pickedDate;
    });

    // Pick Time
    final picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    // --- Validation: Disallow past time if selected date is today ---
    final selectedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      picked.hour,
      picked.minute,
    );

    if (selectedDateTime.isBefore(now)) {
      // Show error and don’t save
      Get.snackbar("Invalid Time", "You cannot select past time!");
      return;
    }

    // Save valid time
    setStateInside(() {
      controller.selectedTime = picked;
      controller.validString = "";
    });
  }

  String _getEstimatedTime(setStateInside, estimateTime) {
    DateTime estimate =
        DateTime.fromMillisecondsSinceEpoch(int.parse(estimateTime ?? 0));

    if (estimate == null) return "";

    final selectedDateTime = (controller.newSelectedTime != null &&
            controller.newSelectedDate != null)
        ? DateTime(
            controller.newSelectedDate!.year,
            controller.newSelectedDate!.month,
            controller.newSelectedDate!.day,
            controller.newSelectedTime!.hour,
            controller.newSelectedTime!.minute,
          )
        : DateTime(
            estimate.year,
            estimate.month,
            estimate.day,
            estimate.hour,
            estimate.minute,
          );

    setStateInside(() {
      controller.newSelectedDateTime = selectedDateTime;
    });
    controller.update();

    final now = DateTime.now();
    final duration = selectedDateTime.difference(now);

    if (duration.isNegative) {
      return "Oops! The selected time is in the past. Please choose a valid future time.";
    }

    final hrs = duration.inHours;
    final mins = duration.inMinutes.remainder(60);
    return "⏳ $hrs hrs $mins mins remaining";
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
