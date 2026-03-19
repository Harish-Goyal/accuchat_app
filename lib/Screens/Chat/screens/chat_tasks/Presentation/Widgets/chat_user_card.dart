import 'dart:ui';

import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_home_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_screen_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_home_controller.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../Constants/assets.dart';
import '../../../../../../utils/chat_presence.dart';
import '../../../../../../utils/helper_widget.dart';
import '../../../../../../utils/networl_shimmer_image.dart';
import '../../../../api/apis.dart';
import '../../../../helper/my_date_util.dart';
import '../../../../../../main.dart';
import '../../../auth/models/get_uesr_Res_model.dart';
import '../../../../models/recent_chat_user_res_model.dart';
import '../dialogs/profile_dialog.dart';

class ChatUserCard extends StatefulWidget with WidgetsBindingObserver {
  UserDataAPI? user;

  ChatUserCard({super.key, this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard>
    with WidgetsBindingObserver {
  bool isHover = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var homec;
    if (isTaskMode) {
      homec = Get.find<TaskHomeController>();
    } else {
      homec = Get.find<ChatHomeController>();
    }

    return Obx(() {
      bool isSelected =
          homec.selectedChat.value?.userId == widget.user?.userId;

      final usern = (widget.user?.userCompany?.displayName != null)
          ? widget.user?.userCompany?.displayName ?? ''
          : widget.user?.userName != null
          ? widget.user?.userName ?? ''
          : widget.user?.phone ?? '';

      return MouseRegion(
        onEnter: (_) => setState(() => isHover = true),
        onExit: (_) => setState(() => isHover = false),
        cursor: SystemMouseCursors.click,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,

          // ✅ REDUCED GAP
          margin: EdgeInsets.symmetric(
              horizontal: kIsWeb ? 12 : mq.width * .04,
              vertical: 3),

          transform: Matrix4.identity()
            ..translate(0.0, isHover ? -1 : 0.0),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? perplebr.withOpacity(.35)
                  :isHover? Colors.grey.withOpacity(.3):Colors.white.withOpacity(.3),
            ),
            gradient: isHover?   RadialGradient(
              center: const Alignment(-0.3, -0.3),
              radius: 1.2,
              colors: [
                Colors.black.withOpacity(0.07),
                Colors.black.withOpacity(0.03),
              ],
            ):isSelected?LinearGradient(colors: [
              perplebr.withOpacity(.2),
              perplebr.withOpacity(.4),
            ]):LinearGradient(colors: [
              Colors.white.withOpacity(.3),
              Colors.white.withOpacity(.35),
            ]),
          ),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: isHover ? 100 : 6,
                sigmaY: isHover ? 100 : 6,
              ),

              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,

                onTap: () {
                  if (isTaskMode) {
                    if (kIsWeb) {
                      final homec = Get.find<TaskHomeController>();
                      var newKey = widget.user?.userCompany?.userCompanyId;
                      final newTag = 'task_$newKey';
                      final oldKey = TaskPresence.activeTaskId.value;
                      final oldTag = 'task_$oldKey';
                      if (oldTag != newTag && Get.isRegistered<TaskController>(tag: oldTag)) {
                        Get.delete<TaskController>(tag: oldTag, force: true);
                      }
                      TaskPresence.activeTaskId.value = newKey;

                      final taskC = Get.isRegistered<TaskController>(tag: newTag)
                          ? Get.find<TaskController>(tag: newTag)
                          : Get.put(TaskController(user: widget.user), tag: newTag);
                      homec.selectedChat.value = widget.user;
                      taskC.user = widget.user;
                      taskC.textController.clear();
                      taskC.replyToMessage = null;
                      taskC.showPostShimmer = true;
                      taskC.getUserByIdApi(userId: widget.user?.userId);
                      homec.selectedChat.refresh();
                      taskC.update();
                      homec.update();
                    } else {
                      Get.toNamed(AppRoutes.tasks_li_r,
                          arguments: {'user': widget.user});
                    }
                  } else {
                    if (kIsWeb) {
                      final homec = Get.find<ChatHomeController>();

                      var newKey = widget.user?.userCompany?.userCompanyId;

                      final newTag = 'chat_$newKey';

                      // delete previous active controller (if different)
                      final oldKey = ChatPresence.activeChatId.value;
                      final oldTag = 'chat_$oldKey';

                      if (oldTag != newTag && Get.isRegistered<ChatScreenController>(tag: oldTag)) {
                        Get.delete<ChatScreenController>(tag: oldTag, force: true);
                      }

                      ChatPresence.activeChatId.value = newKey;
                      final chatc = Get.isRegistered<ChatScreenController>(tag: newTag)
                          ? Get.find<ChatScreenController>(tag: newTag)
                          : Get.put(ChatScreenController(user: widget.user), tag: newTag);
                      homec.selectedChat.value = widget.user;
                      chatc.user = widget.user;
                      chatc.update();
                      chatc.textController.clear();
                      chatc.replyToMessage = null;
                      chatc.showPostShimmer = true;
                      chatc.getUserByIdApi(userId: widget.user?.userId);
                      homec.selectedChat.refresh();
                      chatc.update();
                      homec.update();

                    } else {
                      Get.toNamed(
                        AppRoutes.chats_li_r,
                        arguments: {'user': widget.user},
                      );
                    }
                  }
                },

                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

                  child: Row(
                    children: [
                      /// 🔥 AVATAR WITH SOFT GLOW
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            if (isHover)
                              BoxShadow(
                                color: appColorPerple.withOpacity(.25),
                                blurRadius: 12,
                              ),
                          ],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(100),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) =>
                                  ProfileDialog(user: widget.user),
                            );
                          },
                          child: widget.user?.userImage != null
                              ? CustomCacheNetworkImage(
                            radiusAll: 100,
                            "${ApiEnd.baseUrlMedia}${widget.user?.userImage ?? ''}",
                            height: 40,
                            width: 40,
                            boxFit: BoxFit.cover,
                            borderColor: greyText,
                            defaultImage:
                            widget.user?.userCompany?.isGroup == 1
                                ? groupIcn
                                : widget.user?.userCompany?.isBroadcast ==
                                1
                                ? broadcastIcon
                                : ICON_profile,
                          )
                              : CircleAvatar(
                            radius: 20,
                            backgroundColor: perpleBg.withOpacity(.7),
                            child: Text(
                              getInitials(usern),
                              style:
                              BalooStyles.baloosemiBoldTextStyle(
                                  color: perplebr),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    (widget.user?.userId ==
                                        APIs.me.userId)
                                        ? "Me"
                                        : usern,
                                    style: BalooStyles
                                        .baloosemiBoldTextStyle(size: 13.5),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.user?.lastMessage?.message ?? '',
                              maxLines: 1,
                              style:
                              BalooStyles.balooregularTextStyle(
                                  color:isSelected?veryDarkGreyColor: greyText, size: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      /// 🔥 RIGHT SIDE
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isTaskMode &&
                              widget.user?.pendingCount != null &&
                              widget.user!.pendingCount != 0)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.shade400,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                "${widget.user?.pendingCount}",
                                style: BalooStyles.baloonormalTextStyle(
                                    color: Colors.white, size: 10),
                              ),
                            ),

                          const SizedBox(height: 4),

                          Text(
                            MyDateUtil.getLastMessageTime(
                              context: context,
                              time:
                              widget.user?.lastMessage?.messageTime ?? '',
                            ),
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

/*class ChatUserCard extends StatefulWidget with WidgetsBindingObserver {
  UserDataAPI? user;

  ChatUserCard({super.key, this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard>
    with WidgetsBindingObserver {
  RecentChatUserList? _message;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App is in the foreground
        // APIs.updateActiveStatus(true);
        break;
      case AppLifecycleState.paused:
        // App is in the background
        // APIs.updateActiveStatus(false);
        // APIs.updateTypingStatus(false);
        break;
      case AppLifecycleState.detached:
        // App is terminated
        // APIs.updateActiveStatus(false);
        // APIs.updateTypingStatus(false);
        break;
      case AppLifecycleState.inactive:
        // APIs.updateTypingStatus(false);
        // This state is not commonly used for online/offline status handling
        break;
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
      // throw UnimplementedError();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    var homec;
    if (isTaskMode) {
      homec = Get.find<TaskHomeController>();
    } else {
      homec = Get.find<ChatHomeController>();
    }
    return Container(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.symmetric(
          horizontal: kIsWeb ? 14 : mq.width * .04, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Obx(() {
        bool isSelected =
            homec.selectedChat.value?.userId == widget.user?.userId;
        final usern = (widget.user?.userCompany?.displayName != null)
            ? widget.user?.userCompany?.displayName ?? ''
            :widget.user?.userName!=null?widget.user?.userName ?? '':widget.user?.phone ?? '';
        bool isRegistered=false;
        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
              borderRadius: BorderRadius.circular(15),
              hoverColor: perplebr,
              splashColor: perplebr,
              highlightColor: perplebr,
              onTap: () {
                if (isTaskMode) {
                  if (kIsWeb) {
                    final homec = Get.find<TaskHomeController>();
                    var newKey = widget.user?.userCompany?.userCompanyId;
                    final newTag = 'task_$newKey';

                    final oldKey = TaskPresence.activeTaskId.value;
                    final oldTag = 'task_$oldKey';

                    if (oldTag != newTag && Get.isRegistered<TaskController>(tag: oldTag)) {
                      Get.delete<TaskController>(tag: oldTag, force: true);
                    }

                    TaskPresence.activeTaskId.value = newKey;

                    final taskC = Get.isRegistered<TaskController>(tag: newTag)
                        ? Get.find<TaskController>(tag: newTag)
                        : Get.put(TaskController(user: widget.user), tag: newTag);
                    homec.selectedChat.value = widget.user;
                    taskC.user = widget.user;
                    taskC.textController.clear();
                    taskC.replyToMessage = null;
                    taskC.showPostShimmer = true;
                    taskC.getUserByIdApi(userId: widget.user?.userId);
                    homec.selectedChat.refresh();
                    taskC.update();
                    homec.update();
                  } else {
                    Get.toNamed(AppRoutes.tasks_li_r,
                        arguments: {'user': widget.user});
                  }
                } else {
                  if (kIsWeb) {
                    final homec = Get.find<ChatHomeController>();

                    var newKey = widget.user?.userCompany?.userCompanyId;

                    final newTag = 'chat_$newKey';

          // delete previous active controller (if different)
                    final oldKey = ChatPresence.activeChatId.value;
                    final oldTag = 'chat_$oldKey';

                    if (oldTag != newTag && Get.isRegistered<ChatScreenController>(tag: oldTag)) {
                      Get.delete<ChatScreenController>(tag: oldTag, force: true);
                    }

                    ChatPresence.activeChatId.value = newKey;

                    final chatc = Get.isRegistered<ChatScreenController>(tag: newTag)
                        ? Get.find<ChatScreenController>(tag: newTag)
                        : Get.put(ChatScreenController(user: widget.user), tag: newTag);
                    homec.selectedChat.value = widget.user;
                    chatc.user = widget.user;
                    chatc.update();
                    chatc.textController.clear();
                    chatc.replyToMessage = null;
                    chatc.showPostShimmer = true;
                    chatc.getUserByIdApi(userId: widget.user?.userId);

                    homec.selectedChat.refresh();
                    chatc.update();
                    homec.update();

                  } else {
                    Get.toNamed(
                      AppRoutes.chats_li_r,
                      arguments: {'user': widget.user},
                    );
                  }
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected
                      ? chatcardt
                      : whiteselected.withOpacity(.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  hoverColor: perplebr,
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 3),
                  leading: InkWell(
                    borderRadius: BorderRadius.circular(100),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (_) => ProfileDialog(user: widget.user));
                    },
                    child:widget.user?.userImage !=null? CustomCacheNetworkImage(
                      radiusAll: 100,
                      "${ApiEnd.baseUrlMedia}${widget.user?.userImage ?? ''}",
                      height:40,
                      width: 40,
                      boxFit: BoxFit.cover,
                      borderColor: greyText,
                      defaultImage: widget.user?.userCompany?.isGroup == 1
                          ? groupIcn
                          : widget.user?.userCompany?.isBroadcast == 1
                              ? broadcastIcon
                              : ICON_profile,
                      color: Colors.grey,
                    ):CircleAvatar(
                      backgroundColor: perpleBg,
                      child: Text(getInitials(usern),style: BalooStyles.baloosemiBoldTextStyle(color: perplebr),),
                    ),
                  ),

                  //user name
                  title: (widget.user?.userCompany?.isGroup == 1 ||
                          widget.user?.userCompany?.isBroadcast == 1)
                      ? Text(
                          (widget.user?.userId == APIs.me.userId)
                              ? "Me"
                              : (widget.user?.userName == '' ||
                                      widget.user?.userName == null)
                                  ? widget.user?.phone ?? ''
                                  : widget.user?.userName ?? '',
                          style: BalooStyles.baloonormalTextStyle(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          (widget.user?.userId == APIs.me.userId)
                              ? "Me"
                              : (widget.user?.userCompany?.displayName != null)
                                  ? widget.user?.userCompany?.displayName ?? ''
                                  : widget.user?.userName != null
                                      ? widget.user?.userName ?? ''
                                      : widget.user?.phone ?? '',
                          style: BalooStyles.baloonormalTextStyle(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                  //last message
                  subtitle: Text(
                    widget.user?.lastMessage?.message ?? '',
                    maxLines: 1,
                    style: BalooStyles.balooregularTextStyle(
                        color: greyText, size: 13),
                    overflow: TextOverflow.ellipsis,
                  ),

                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      !isTaskMode
                          ? (widget.user?.pendingCount != null &&
                                  widget.user?.pendingCount != 0
                              ? CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.greenAccent.shade400,
                                  child: Text(
                                    "${widget.user?.pendingCount}",
                                    style: BalooStyles.baloonormalTextStyle(
                                        color: Colors.white, size: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              : const SizedBox())
                          : const SizedBox(),
                      widget.user?.pendingCount != null &&
                              widget.user?.pendingCount != 0
                          ? const Spacer()
                          : const SizedBox(),
                      widget.user?.open_count != null &&
                              widget.user?.open_count != 0
                          ? const Spacer()
                          : const SizedBox(),
                      Text(
                        MyDateUtil.getLastMessageTime(
                            context: context,
                            time: widget.user?.lastMessage?.messageTime ?? ''),
                        style: const TextStyle(color: Colors.black54),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ).paddingOnly(bottom: 2),
                    ],
                  ),
                  //message sent time
                ),
              )),
        );
      }),
    );
  }
}*/
