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
        border: Border.all(
            color: isTaskMode
                ? appColorYellow.withOpacity(.1)
                : appColorGreen.withOpacity(.1)),
      ),
      child: Obx(() {
        bool isSelected =
            homec.selectedChat.value?.userId == widget.user?.userId;
        bool isRegistered=false;
        return InkWell(
            hoverColor: appColorPerple.withOpacity(.25),
            // overlayColor: WidgetStatePropertyAll(appColorPerple.withOpacity(.12)),
            borderRadius: BorderRadius.circular(15),
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
                  print("chats  carrd tag====$newTag");
                  homec.selectedChat.value = widget.user;
                  chatc.user = widget.user;
                  chatc.update();
                  chatc.textController.clear();
                  chatc.replyToMessage = null;
                  chatc.showPostShimmer = true;

                  chatc.getUserByIdApi(userId: widget.user?.userId);
                  // chatc.openConversation(widget.user);

                  // final pending = widget.user?.pendingCount ?? 0;
                  // if (pending != 0) {
                  //   chatc.markAllVisibleAsReadOnOpen(
                  //     APIs.me.userCompany?.userCompanyId,
                  //     widget.user?.userCompany?.userCompanyId,
                  //     widget.user?.userCompany?.isGroup == 1 ? 1 : 0,
                  //   );
                  // }

                  homec.selectedChat.refresh();
                  chatc.update();
                  homec.update();

                  //  final homec = Get.find<ChatHomeController>();
                 //
                 //  final activePreTag = ChatPresence.activeChatId.value;
                 //  final preTag = "chat_$activePreTag";
                 //
                 //  if(Get.isRegistered<ChatScreenController>(tag: preTag)){
                 //    Get.delete<ChatScreenController>(tag: preTag,force: true);
                 //  }
                 //  final chatId = widget.user?.userCompany?.userCompanyId ?? 'mobile';
                 //  final tag = 'chat_$chatId';
                 //  ChatScreenController? chatc;
                 //  if (Get.isRegistered<ChatScreenController>(tag: tag)) {
                 //    isRegistered =true;
                 //    print("$isRegistered ========01");
                 //    chatc = Get.find<ChatScreenController>(tag: tag);
                 //  } else {
                 //    print("$isRegistered ========00");
                 //    isRegistered =false;
                 //    chatc = Get.put(ChatScreenController(user: widget.user),
                 //        tag: tag);
                 //  }
                 //
                 // chatc?.textController.clear();
                 // chatc?.replyToMessage = null;
                 // chatc?.showPostShimmer = true;
                 // print(widget.user?.userId);
                 // homec.selectedChat.value = widget.user;
                 // chatc?.user = homec.selectedChat.value;
                 // print(homec.selectedChat.value?.userId);
                 // print(chatc?.user?.userId);
                 //  // isRegistered?  chatc?.openConversation(homec.selectedChat.value) :null;
                 //  ChatPresence.activeChatId.value =homec.selectedChat.value?.userCompany?.userCompanyId;
                 // chatc?.openConversation(homec.selectedChat.value) ;
                 //  if (homec.selectedChat.value?.pendingCount != 0) {
                 //    chatc?.markAllVisibleAsReadOnOpen(
                 //        APIs.me.userCompany?.userCompanyId,
                 //        chatc.user?.userCompany?.userCompanyId,
                 //        chatc.user?.userCompany?.isGroup == 1 ? 1 : 0);
                 //  }
                 //  homec.update();
                 //  homec.selectedChat.refresh();
                 //  chatc?.update();
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
                    ? appColorPerple.withOpacity(.25)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                hoverColor: appColorPerple.withOpacity(.15),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                leading: InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) => ProfileDialog(user: widget.user));
                  },
                  child: CustomCacheNetworkImage(
                    radiusAll: 100,
                    "${ApiEnd.baseUrlMedia}${widget.user?.userImage ?? ''}",
                    height: mq.height * .06,
                    width: mq.height * .06,
                    boxFit: BoxFit.cover,
                    borderColor: greyText,
                    defaultImage: widget.user?.userCompany?.isGroup == 1
                        ? groupIcn
                        : widget.user?.userCompany?.isBroadcast == 1
                            ? broadcastIcon
                            : ICON_profile,
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
                            : const SizedBox()) /* : widget.user?.open_count!=null&&widget.user?.open_count!=0  ? CircleAvatar(
                                           radius: 10,
                                           backgroundColor: Colors.greenAccent.shade400,
                                           child: Text(
                       "${widget.user?.open_count}",
                       style: BalooStyles.baloonormalTextStyle(color: Colors.white,size: 12),
                       maxLines: 1,
                       overflow: TextOverflow.ellipsis,
                                           ),
                                         )*/
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
            ));
      }),
    );
  }
}
