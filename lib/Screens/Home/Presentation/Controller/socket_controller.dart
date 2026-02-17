import 'dart:convert';
import 'package:AccuChat/Screens/Chat/models/task_attachment_res_model.dart';
import 'package:AccuChat/Screens/Chat/models/task_commets_res_model.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_home_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_home_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_thread_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../Services/APIs/api_ends.dart';
import '../../../../Services/storage_service.dart';
import '../../../../utils/chat_presence.dart';
import '../../../Chat/api/apis.dart';
import '../../../Chat/models/chat_history_response_model.dart';
import '../../../Chat/models/task_res_model.dart';
import '../../../Chat/screens/auth/models/get_uesr_Res_model.dart';
import '../../../Chat/screens/chat_tasks/Presentation/Controllers/chat_screen_controller.dart';
import 'company_service.dart';

enum ChType {
  group,
  broadcast,
  direct,
}

class RecentGuard {
  static int? lastGroupMessageId;
  static DateTime? lastGroupTime;

  static void remember(int? id) {
    lastGroupMessageId = id;
    lastGroupTime = DateTime.now();
  }

  static bool isDuplicateOfRecentGroup(int? id) {
    if (id == null || lastGroupMessageId == null) return false;

    final within2Sec = lastGroupTime != null &&
        DateTime.now().difference(lastGroupTime!).inSeconds <= 2;

    return within2Sec && id == lastGroupMessageId;
  }
}


class SocketController extends GetxController with WidgetsBindingObserver {
  late IO.Socket? socket;
  bool initialized = false;
  final isConnected = false.obs;
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // _getMe();
    if (!initialized) {
      initialized = true;
      initSocket();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final svc = CompanyService.to;
      final myCompany = svc.selected;
      // Ensure an active transport
      if (!(socket?.connected ?? false)) {
        try {
          socket?.connect();
        } catch (_) {}
      }
      // Idempotently re-wire listeners and re-select company on resume
      // allListerer();           // ensures .off() then .on() again
      connectUserEmitter(myCompany?.companyId); // re-emit company context
    }
  }

  Future<void> initSocket() async {
    initial();
    final svc = CompanyService.to;
    final myCompany = svc.selected;
    connectUserEmitter(myCompany?.companyId); // already in your code
    // allListerer();
  }

  initial() {
    try {
      // If an old socket instance exists, dispose it safely (keeps us single-instance)
      try {
        socket?.dispose();
      } catch (_) {} // ← ADD
      if (socket?.connected ?? false) {
        socket
            ?.disconnect(); // ← ADD (your line socket?.disconnected was a no-op)
      }
    } catch (e) {}
    final token = StorageService.getToken();

    socket = IO.io(
      ApiEnd.baseUrlMedia,
      IO.OptionBuilder()
          // Allow polling + websocket – more reliable behind proxies
          .setTransports(['websocket', 'polling'])
          .enableForceNew()
          .setAuth({'token': token})
          .enableReconnection()
          .enableAutoConnect()
          .setPath('/socket.io/') // must match server/proxy location
          .setTimeout(20000)
          .setReconnectionDelay(2000)
          .setReconnectionAttempts(20)
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    socket?.connect();

    socket?.onConnect((_) {
      isConnected.value = true;
      attachListenersOnce();
    });

    socket?.onReconnectAttempt((_) {
      debugPrint("🔄 Trying to reconnect...");
    });

    socket?.onReconnect((_) {
      // Re-attach handlers & re-emit company selection after reconnection
      // allListerer();
      // ← ADD
      // final svc = CompanyService.to;
      // final myCompany =svc.selected;
      // connectUserEmitter(myCompany?.companyId);   // ← ADD
    });

    socket?.onDisconnect((v) {
      isConnected.value = false;
      debugPrint("Socket disconnected $v");
    });
    socket?.onConnectError((e) => debugPrint('Connect error: $e'));
    socket?.onError((error) {
      debugPrint("Socket disconnected $error");
    });
  }

  // UserDataAPI? me = UserDataAPI();
  // _getMe() {
  //   me = getUser();
  // }

  void disconnect() {
    try {
      socket?.offAny();
      socket?.disconnect();
      socket?.destroy();
    } catch (_) {}
    socket = null;
    isConnected.value = false;
  }

  bool listenersAttached = false;
  void attachListenersOnce() {
    if (listenersAttached) return;
    listenersAttached = true;
    allListerer();
  }

  allListerer() {
    socket?.off('send_message_listener');
    socket?.on('send_message_listener', (messages) {
      debugPrint("send_message_listener ${jsonEncode(messages.toString())}");
      try {
        ChatHomeController homeController = Get.find<ChatHomeController>();
        ChatHisList receivedMessageDataModal = ChatHisList.fromJson(messages);

        final meId = APIs.me?.userId?.toString();
        final msgFrom = receivedMessageDataModal.fromUser?.userId?.toString();
        final msgTo = receivedMessageDataModal.toUser?.userId?.toString();
        final _tagid = ChatPresence.activeChatId.value;
        final _tag = "chat_${_tagid ?? 'mobile'}";
        ChatScreenController? chatDetailController;
        if(!kIsWeb || Get.width<600){
          chatDetailController =
              Get.find<ChatScreenController>();
        }else{
          if (Get.isRegistered<ChatScreenController>(tag: _tag)) {
            chatDetailController =
                Get.find<ChatScreenController>(tag: _tag);
          }
        }


        final key = chatDetailController!.msgKey(receivedMessageDataModal);
        if (!chatDetailController.markOnce(key)) {
          debugPrint("Duplicate message ignored: $key");
          return;
        }
        final selectedUserId = chatDetailController?.user?.userId
            ?.toString(); // 1-1 userId OR group userId
        final incomingIsGroup = receivedMessageDataModal.isGroupChat == 1;
        final activeCompanyId = APIs.me.userCompany?.companyId;
        final msgCompanyId = receivedMessageDataModal.fromUser?.userCompany?.companyId;

        if (activeCompanyId == null || msgCompanyId == null) return;
        if (activeCompanyId != msgCompanyId) return;

        String? incomingGroupId;
        if (incomingIsGroup) {
          final toIsGroup =
              (receivedMessageDataModal.toUser?.userCompany?.isGroup ==
                  1);
          final fromIsGroup =
              (receivedMessageDataModal.fromUser?.userCompany?.isGroup == 1);

          if (toIsGroup) {
            incomingGroupId =
                receivedMessageDataModal.toUser?.userId?.toString();
          } else if (fromIsGroup) {
            incomingGroupId =
                receivedMessageDataModal.fromUser?.userId?.toString();
          } else {
            // fallback (agar kabhi backend group user flag na bheje)
            incomingGroupId = msgTo; // mostly group id yahi hoga
          }
        }

        final selectedIsGroup =
            chatDetailController?.user?.userCompany?.isGroup ==
                1; // selected chat is group?

        final isMessageForThisChat = incomingIsGroup
            ? (selectedIsGroup &&
                incomingGroupId != null &&
                incomingGroupId == selectedUserId)
            : (!selectedIsGroup &&
                ((msgFrom == selectedUserId && msgTo == meId) ||
                    (msgFrom == meId && msgTo == selectedUserId)));

        if (isMessageForThisChat) {
          // safe to insert the message
          ChatHisList chatMessageItems = ChatHisList(
            chatId: receivedMessageDataModal.chatId,
            fromUser: receivedMessageDataModal.fromUser,
            toUser: receivedMessageDataModal.toUser,
            message: receivedMessageDataModal.message,
            isActivity: receivedMessageDataModal.isActivity,
            isForwarded: receivedMessageDataModal.isForwarded,
            sentOn: receivedMessageDataModal.sentOn,
            readOn: receivedMessageDataModal.readOn,
            pendingCount: receivedMessageDataModal.pendingCount,
            isGroupChat: receivedMessageDataModal.isGroupChat,
            broadcastUserId: receivedMessageDataModal.broadcastUserId,
            replyToId: receivedMessageDataModal.replyToId,
            replyToText: receivedMessageDataModal.replyToText,
            replyToMedia: receivedMessageDataModal.replyToMedia,
            replyToTime: receivedMessageDataModal.replyToTime,
            replyToName: receivedMessageDataModal.replyToName,
            media: receivedMessageDataModal.media,
          );
          final alreadyInList = chatDetailController?.chatHisList?.any((x) =>
          (x.chatId == chatMessageItems.chatId) &&
              (x.sentOn == chatMessageItems.sentOn) &&
              (x.fromUser?.userId == chatMessageItems.fromUser?.userId) &&
              (x.toUser?.userId == chatMessageItems.toUser?.userId) &&
              (x.message == chatMessageItems.message)
          ) ?? false;

          if (alreadyInList) return;
          chatDetailController?.chatHisList?.insert(0, chatMessageItems);
          chatDetailController?.chatCatygory
              .insert(0, GroupChatElement(DateTime.now(), chatMessageItems));
          chatDetailController?.rebuildFlatRows();
          chatDetailController?.update();
        }


        final fromUcId =
            receivedMessageDataModal.fromUser?.userCompany?.userCompanyId;

        final toUcId =
            receivedMessageDataModal.toUser?.userCompany?.userCompanyId;

        final fromIsGroupUc = receivedMessageDataModal.fromUser?.userCompany?.isGroup == 1;
        final toIsGroupUc   = receivedMessageDataModal.toUser?.userCompany?.isGroup == 1;

// ✅ For home list + active chat matching, decide the “thread UC” correctly
        final int? threadUcId = incomingIsGroup
            ? (toIsGroupUc ? toUcId : (fromIsGroupUc ? fromUcId : toUcId)) // fallback to toUcId
            : fromUcId;

// ✅ Now find/update the correct thread only
        final index = homeController.filteredList.indexWhere(
              (e) => e.userCompany?.userCompanyId == threadUcId,
        );

// ✅ open chat check must also use threadUcId (not fromUcId)
        final isThisChatOpen = ChatPresence.activeChatId.value == threadUcId;


        if (isThisChatOpen &&
            receivedMessageDataModal.toUser?.userId == APIs.me.userId) {
          readMsgEmitter(
              toucID:
                  receivedMessageDataModal.toUser?.userCompany?.userCompanyId ??
                      0,
              fromUcID: fromUcId,
              companyId: APIs.me.userCompany?.companyId,
              is_group_chat:
                  receivedMessageDataModal.fromUser?.userCompany?.isGroup == 0
                      ? 0
                      : 1);
        }

        if (index != -1) {
          // 🔥 CHAT IS OPEN → FORCE unread = 0
          if (isMessageForThisChat) {
            // connectUserEmitter(receivedMessageDataModal.fromUser?.userCompany?.userCompanyId);
            // readMsgEmitter(
            //     ucID: receivedMessageDataModal.toUser?.userCompany?.userCompanyId??0,
            //     fromUcID: receivedMessageDataModal.fromUser?.userCompany?.userCompanyId??0,
            //     companyId: receivedMessageDataModal.fromUser?.userCompany?.companyId,
            //     is_group_chat: receivedMessageDataModal.toUser?.userCompany?.isGroup == 1
            //         ? 1
            //         : 0);
          }

          // Update last message preview
          homeController.filteredList[index].lastMessage = LastMessage(
            message: receivedMessageDataModal.message,
            messageTime: receivedMessageDataModal.sentOn,
          );

          homeController.filteredList.refresh();
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    });

    socket?.off('send_message_error');
    socket?.on('send_message_error', (messages) {
      debugPrint("send_message_error ${jsonEncode(messages.toString())}");
    });

    if (kIsWeb) {
      updateResentWeb();
    } else {
      registerUpdateRecentListListenerMobile();
    }

    if (kIsWeb) {
      updateResentTaskWeb();
    } else {
      registerUpdateRecentTaskUserListenerMobile();
    }

    socket?.off('send_task_listener');
    socket?.on('send_task_listener', (messages) {
      debugPrint("Listing task......4");
      debugPrint("send_task_listener ${jsonEncode(messages.toString())}");
      try {

        final _tagid = TaskPresence.activeTaskId.value;
        final _tag = "task_${_tagid ?? 'mobile'}";
        TaskController? taskController;
        if(!kIsWeb || Get.width<600){
          taskController =
              Get.find<TaskController>();
        }else{
          if (Get.isRegistered<TaskController>(tag: _tag)) {
            taskController =
                Get.find<TaskController>(tag: _tag);
          }
        }

        TaskData receivedMessageDataModal = TaskData.fromJson(messages);
        final selectedUserId = taskController?.user?.userId?.toString();
        final meId = APIs.me.userId?.toString();
        final msgFrom = receivedMessageDataModal.fromUser?.userId?.toString();
        final msgTo = receivedMessageDataModal.toUser?.userId?.toString();
        final activeCompanyId = APIs.me.userCompany?.companyId;
        final msgCompanyId = receivedMessageDataModal.fromUser?.userCompany?.companyId;

        if (activeCompanyId == null || msgCompanyId == null) return;
        if (activeCompanyId != msgCompanyId) {
          // AppBadgeController.to.markOtherCompany(BadgeType.task, msgCompanyId);
          return;
        }
        var dashCon;
        if(Get.isRegistered<DashboardController>()){
          dashCon = Get.find<DashboardController>();
        }
        final isMessageForThisChat =
            (msgFrom == selectedUserId && msgTo == meId) ||
                (msgFrom == meId && msgTo == selectedUserId);
        if (isMessageForThisChat) {
          TaskData chatMessageItems = TaskData(
            taskId: receivedMessageDataModal.taskId,
            fromUser: receivedMessageDataModal.fromUser,
            toUser: receivedMessageDataModal.toUser,
            title: receivedMessageDataModal.title,
            details: receivedMessageDataModal.details,
            createdOn: receivedMessageDataModal.createdOn,
            startDate: receivedMessageDataModal.startDate,
            endDate: receivedMessageDataModal.endDate,
            deadline: receivedMessageDataModal.deadline,
            commentCount: receivedMessageDataModal.commentCount,
            media: receivedMessageDataModal.media,
            currentStatus: receivedMessageDataModal.currentStatus,
            statusHistory: receivedMessageDataModal.statusHistory,
            members: receivedMessageDataModal.members,
          );
          taskController?.taskHisList?.insert(0, chatMessageItems);
          taskController?.taskCategory
              .insert(0, GroupTaskElement(DateTime.now(), chatMessageItems));
          // }
          dashCon.newTask.value=true;
          taskController?.update();
        }
        Get.find<TaskHomeController>().hitAPIToGetRecentTasksUser();
      } catch (e) {
        debugPrint(e.toString());
      }
    });

    socket?.off('company_joined');
    socket?.on('company_joined', (messages) {
      debugPrint("company_joined ${messages}");
    });

    socket?.off('add_task_comment_listener');
    socket?.on('add_task_comment_listener', (messages) {
      debugPrint(
          "add_task_comment_listener ${jsonEncode(messages.toString())}");
      try {
        TaskComments receivedMessageDataModal = TaskComments.fromJson(messages);
        final meId = APIs.me?.userId?.toString();
        final msgFrom = receivedMessageDataModal.fromUser?.userId?.toString();
        final msgTo = receivedMessageDataModal.toUser?.userId?.toString();
        TaskThreadController? threadController;
        if (Get.isRegistered<TaskThreadController>()){
          threadController =
              Get.find<TaskThreadController>();
        }

        final key = threadController!.msgKey(receivedMessageDataModal);
        if (!threadController.markOnce(key)) {
          debugPrint("Duplicate message ignored: $key");
          return;
        }
        final selectedUserId = threadController?.currentUser?.userId
            ?.toString(); // 1-1 userId OR group userId
        final activeCompanyId = APIs.me.userCompany?.companyId;
        final msgCompanyId = receivedMessageDataModal.fromUser?.userCompany?.companyId;
        if (activeCompanyId == null || msgCompanyId == null) return;
        if (activeCompanyId != msgCompanyId) return;
        final isMessageForThisChat =((msgFrom == selectedUserId && msgTo == meId) ||
                (msgFrom == meId && msgTo == selectedUserId));
        if (isMessageForThisChat) {
          // safe to insert the message
          TaskComments taskComments = TaskComments(
            taskCommentId: receivedMessageDataModal.taskCommentId,
            fromUser: receivedMessageDataModal.fromUser,
            toUser: receivedMessageDataModal.toUser,
            commentText: receivedMessageDataModal.commentText,
            sentOn: receivedMessageDataModal.sentOn,
            isDeleted: receivedMessageDataModal.isDeleted,
            media: receivedMessageDataModal.media,
          );
          final alreadyInList = threadController?.commentsList?.any((x) =>
          (x.taskCommentId == taskComments.taskCommentId) &&
              (x.sentOn == taskComments.sentOn) &&
              (x.fromUser?.userId == taskComments.fromUser?.userId) &&
              (x.toUser?.userId == taskComments.toUser?.userId) &&
              (x.commentText == taskComments.commentText)
          ) ?? false;

          if (alreadyInList) return;
          threadController?.commentsList?.insert(0, taskComments);
          threadController?.commentsCategory
              .insert(0, GroupCommentsElement(DateTime.now(), taskComments));
          threadController?.update();
        }

      } catch (e) {
        debugPrint(e.toString());
      }
    });


/*  socket?.on('add_task_comment_listener', (messages) {
      debugPrint("Comments Listing task......4");
      debugPrint(
          "add_task_comment_listener ${jsonEncode(messages.toString())}");
      try {
        TaskThreadController threadController =
            Get.find<TaskThreadController>();
        TaskComments receivedMessageDataModal = TaskComments.fromJson(messages);

        // if ((receivedMessageDataModal.fromUser?.userId.toString() ==
        //         (me?.userId).toString()) ||
        //     (receivedMessageDataModal.toUser?.userId.toString() ==
        //         (threadController.taskMessage?.fromUser?.userId.toString()))) {
        TaskComments taskComments = TaskComments(
          taskCommentId: receivedMessageDataModal.taskCommentId,
          fromUser: receivedMessageDataModal.fromUser,
          toUser: receivedMessageDataModal.toUser,
          commentText: receivedMessageDataModal.commentText,
          sentOn: receivedMessageDataModal.sentOn,
          isDeleted: receivedMessageDataModal.isDeleted,
          media: receivedMessageDataModal.media,
        );
        threadController.commentsList?.insert(0, taskComments);
        threadController.commentsCategory
            .insert(0, GroupCommentsElement(DateTime.now(), taskComments));
        // }
        threadController.update();
      } catch (e) {
        debugPrint(e.toString());
      }
    });*/

    socket?.off('update_message_error');
    socket?.on('update_message_error', (payload) {
      debugPrint("Listing update message......8");
      errorDialog('Time Exceeded');
    });

    socket?.off('update_message_listener');
    socket?.on('update_message_listener', (payload) {
      debugPrint("Listing update message......8");
      debugPrint("update message listener ${jsonEncode(payload.toString())}");
      try {

        final updated = ChatHisList.fromJson(payload);

        final meId = APIs.me.userId?.toString();
        final fromId = updated.fromUser?.userId?.toString();
        final toId = updated.toUser?.userId?.toString();
        final _tagid = ChatPresence.activeChatId.value;
        final _tag = "chat_${_tagid ?? 'mobile'}";
        final chatController = Get.find<ChatScreenController>(tag: _tag);
        if (fromId == meId || toId == meId) {
          final list = chatController.chatHisList ?? [];
          final idx = list.indexWhere((t) => t.chatId == updated.chatId);

          if (idx != -1) {
            final old = list[idx];
            old.chatId = updated.chatId ?? old.chatId;
            old.fromUser = updated.fromUser ?? old.fromUser;
            old.toUser = updated.toUser ?? old.toUser;
            old.message = updated.message ?? old.message;
            old.isActivity = updated.isActivity ?? old.isActivity;
            old.isForwarded = updated.isForwarded ?? old.isForwarded;
            old.sentOn = updated.sentOn ?? old.sentOn;
            old.readOn = updated.readOn ?? old.readOn;
            old.pendingCount = updated.pendingCount ?? old.pendingCount;
            old.isGroupChat = updated.isGroupChat ?? old.isGroupChat;
            old.broadcastUserId =
                updated.broadcastUserId ?? old.broadcastUserId;
            old.replyToId = updated.replyToId ?? old.replyToId;
            old.replyToText = updated.replyToText ?? old.replyToText;
            old.replyToTime = updated.replyToTime ?? old.replyToTime;
            old.replyToMedia = updated.replyToMedia ?? old.replyToMedia;
            old.replyToName = updated.replyToName ?? old.replyToName;
            old.media = (updated.media?.isNotEmpty ?? false)
                ? updated.media
                : old.media;
            chatController.update();
            final gIdx = chatController.chatCatygory
                .indexWhere((g) => g.chatMessageItems.chatId == updated.chatId);
            if (gIdx != -1) {
              chatController.chatCatygory[gIdx].chatMessageItems.chatId =
                  old.chatId;
            }
          } else {
            list.insert(0, updated);
            chatController.update();
          }
        }
      } catch (e) {
        debugPrint('update_task_listener error: $e');
      }
    });

    socket?.off('update_task_listener');
    socket?.on('update_task_listener', (payload) {
      debugPrint("Listing task message listener......9");
      debugPrint("update task  listener ${jsonEncode(payload.toString())}");

      try {
        final _tagid = TaskPresence.activeTaskId.value;
        final _tag = "task_${_tagid ?? 'mobile'}";
        TaskController? taskController;
        if(!kIsWeb || Get.width<600){
          taskController =
              Get.find<TaskController>();
        }else{
          if (Get.isRegistered<TaskController>(tag: _tag)) {
            taskController =
                Get.find<TaskController>(tag: _tag);
          }
        }
        final updated = TaskData.fromJson(payload);

        final meId = APIs.me.userId?.toString();
        final fromId = updated.fromUser?.userId?.toString();
        final toId = updated.toUser?.userId?.toString();

        if (fromId == meId || toId == meId) {
          final list = taskController?.taskHisList ?? [];
          final idx = list.indexWhere((t) => t.taskId == updated.taskId);

          if (idx != -1) {
            // ✅ UPDATE IN PLACE — NO INSERT
            final old = list[idx];

            // Agar aapke model me copyWith nahi hai, to fields assign kar do:
            old.taskId = updated.taskId ?? old.taskId;
            old.title = updated.title ?? old.title;
            old.details = updated.details ?? old.details;
            old.deadline = updated.deadline ?? old.deadline;
            old.startDate = updated.startDate ?? old.startDate;
            old.endDate = updated.endDate ?? old.endDate;
            old.currentStatus = updated.currentStatus ?? old.currentStatus;
            old.statusHistory = (updated.statusHistory?.isNotEmpty ?? false)
                ? updated.statusHistory
                : old.statusHistory;
            old.media = (updated.media?.isNotEmpty ?? false)
                ? updated.media
                : old.media;
            old.fromUser = updated.fromUser ?? old.fromUser;
            old.toUser = updated.toUser ?? old.toUser;

            // RxList ho to:
            // taskController.taskHisList![idx] = old;
            // taskController.taskHisList!.refresh();

            // Sirf usi card ko rebuild karo:
            taskController?.update();

            // (optional) Agar grouped list bhi maintain karte ho:
            final gIdx = taskController?.taskCategory
                .indexWhere((g) => g.taskMsg.taskId == updated.taskId);
            if (gIdx != -1) {
              taskController?.taskCategory[gIdx!].taskMsg.taskId = old.taskId;
              // targeted update same id se ho jayega
            }
          } else {
            // ❓ Not found = naya task aaya? Tab hi insert karo.
            list.insert(0, updated);
            taskController?.update(); // list-container ke liye alag id
          }
        }
      } catch (e) {
        debugPrint('update_task_listener error: $e');
      }
    });

    setupSocketListeners();
    _registerDeleteListener();
    _registerDeleteListenerTask();

    socket?.off('joined_task');
    socket?.on('joined_task', (data) {
      try {
        debugPrint("Joined task listen");
      } catch (e) {
        debugPrint("Something went wrong Joined task");
      }
    });
  }

  String buildChatTagFromMessage(ChatHisList m) {
    final meId = APIs.me?.userId?.toString();
    final fromId = m.fromUser?.userId?.toString();
    final toId   = m.toUser?.userId?.toString();

    // for 1-1: other side id
    final otherId = (fromId == meId) ? toId : fromId;

    return "chat_${otherId ?? 'mobile'}";
  }


  void updateResentWeb() {
    socket?.off('update_recent_list');

    socket?.on('update_recent_list', (messages) {
      debugPrint("update_recent_list listener......");
      debugPrint("update_recent_list  listener ${jsonEncode(messages.toString())}");
      try {
        final updated = UserDataAPI.fromJson(messages);

        final activeCompanyId = APIs.me.userCompany?.companyId;
        final msgCompanyId = updated.userCompany?.companyId;

        if (activeCompanyId == null || msgCompanyId == null) return;
        if (activeCompanyId != msgCompanyId) return;

        if (!Get.isRegistered<ChatHomeController>()) return;
        final chatController = Get.find<ChatHomeController>();


        final list = chatController.filteredList;

        final isGroupRow = updated.userCompany?.isGroup == 1;

        final msgId = updated.lastMessage?.id;

        if (isGroupRow) {
          // Remember that a group update just came
          RecentGuard.remember(msgId);
        } else {
          // If this user-row update is same as a recent group message → ignore
          if (RecentGuard.isDuplicateOfRecentGroup(msgId)) {
            return;
          }
        }



        final key = updated.userCompany?.userCompanyId;
        final index =
            list.indexWhere((e) => e.userCompany?.userCompanyId == key);

        // ✅ 2) If chat is currently open for same user => reset pendingCount
        final selectedUcId =
            chatController.selectedChat.value?.userCompany?.userCompanyId;

        final isCurrentlyOpen =
        (selectedUcId != null &&
            selectedUcId == updated.userCompany?.userCompanyId);


        if (index != -1) {
          final existing = list[index];

          existing.lastMessage = updated.lastMessage;
          var dashCon;
          if(Get.isRegistered<DashboardController>()){
            dashCon = Get.find<DashboardController>();
          }
          if (isCurrentlyOpen) {
            existing.pendingCount = 0;
            dashCon.newCompanyChat.value=false;
            dashCon.newChat.value=false;
          } else {
            // keep server count if available
            existing.pendingCount =
                updated.pendingCount ?? existing.pendingCount;
          }

          // Move to top
          if (index != 0) {
            list.removeAt(index);
            list.insert(0, existing);
          }
        } else {
          if (isCurrentlyOpen) updated.pendingCount = 0;
          list.insert(0, updated);
        }

        list.refresh();
        final totalUnread = chatController.filteredList
            .fold<int>(0, (sum, e) => sum + (e.pendingCount ?? 0));

        // AppBadgeController.to.setCurrentCounts(chat: totalUnread);
      } catch (e) {
        debugPrint("recent update error: $e");
      }
    });
  }

/* void updateResentWeb(){
    socket?.off('update_recent_list');
    socket?.on('update_recent_list', (messages) {
      debugPrint("update_recent_list ${jsonEncode(messages.toString())}");

      try {
        final updated = UserDataAPI.fromJson(messages);
        final chatController = Get.find<ChatHomeController>();
        final selectedUserId =
            chatController.selectedChat.value?.userId;
        if (APIs.me.userCompany?.companyId ==
            updated.userCompany?.companyId &&   updated.userId==selectedUserId ) {
          final chatUserId = updated.userId;
          final index = chatController.filteredList.indexWhere(
                (u) => u.userId == chatUserId,
          );

          if (index != -1) {
            // ✅ reset unread count
            chatController.filteredList[index].pendingCount = 0;

            // ✅ update last message preview
            chatController.filteredList[index].lastMessage =
                updated.lastMessage;
            chatController.filteredList.refresh();
          }

        }
        else  {
          // ALWAYS use the RxList directly
          final list = chatController.filteredList;
          // 1️⃣ Remove old entry
          list.removeWhere((e) =>
          e.userCompany?.userCompanyId ==
              updated.userCompany?.userCompanyId);
          // 2️⃣ Insert new one at TOP
          list.insert(0, updated);
          // 3️⃣ Force RxList rebuild
          chatController.filteredList.refresh();
        }
      } catch (e) {
        debugPrint("recent update error: $e");
      }
    });
  }*/

/*  void updateResentTaskWeb(){
    socket?.off('update_recent_task_list');
    socket?.on('update_recent_task_list', (messages) {
      debugPrint("update_recent_task_list ${jsonEncode(messages.toString())}");

      try {
        final updated = UserDataAPI.fromJson(messages);
        final taskController = Get.find<TaskHomeController>();
        final selectedUserId =
            taskController.selectedChat.value?.userId;
        if (APIs.me.userCompany?.companyId ==
            updated.userCompany?.companyId &&   updated.userId==selectedUserId ) {
          final chatUserId = updated.userId;
          final index = taskController.filteredList.indexWhere(
                (u) => u.userId == chatUserId,
          );

          if (index != -1) {
            // ✅ reset unread count
            taskController.filteredList[index].pendingCount = 0;

            // ✅ update last message preview
            taskController.filteredList[index].lastMessage =
                updated.lastMessage;
            taskController.filteredList.refresh();
          }

        }
        else  {
          // ALWAYS use the RxList directly
          final list = taskController.filteredList;
          // 1️⃣ Remove old entry
          list.removeWhere((e) =>
          e.userCompany?.userCompanyId ==
              updated.userCompany?.userCompanyId);
          // 2️⃣ Insert new one at TOP
          list.insert(0, updated);
          // 3️⃣ Force RxList rebuild
          taskController.filteredList.refresh();
        }
      } catch (e) {
        debugPrint("recent update error: $e");
      }
    });
  }*/
  void updateResentTaskWeb() {
    socket?.off('update_recent_task_list');

    socket?.on('update_recent_task_list', (messages) {
      try {
        final updated = UserDataAPI.fromJson(messages);

        // ✅ 1) Company mismatch => DO NOTHING
        final activeCompanyId = APIs.me.userCompany?.companyId;
        final msgCompanyId = updated.userCompany?.companyId;

        if (activeCompanyId == null || msgCompanyId == null) return;
        if (activeCompanyId != msgCompanyId) return; // ✅ ignore other company

        if (!Get.isRegistered<TaskHomeController>()) return;
        final taskController = Get.find<TaskHomeController>();

        final selectedUserId = taskController.selectedChat.value?.userId;

        final list = taskController.filteredList;

        // ✅ Use unique key if possible (recommended)
        final key = updated.userCompany?.userCompanyId;

        final index = (key != null)
            ? list.indexWhere((u) => u.userCompany?.userCompanyId == key)
            : list.indexWhere((u) => u.userId == updated.userId);

        final isCurrentlyOpen =
            (selectedUserId != null && updated.userId == selectedUserId);

        if (index != -1) {
          final existing = list[index];

          // update preview
          existing.lastMessage = updated.lastMessage;

          // pending count reset only when current chat is open
          if (isCurrentlyOpen) {
            existing.pendingCount = 0;
          } else {
            existing.pendingCount =
                updated.pendingCount ?? existing.pendingCount;
          }

          // move to top
          if (index != 0) {
            list.removeAt(index);
            list.insert(0, existing);
          }
        } else {
          if (isCurrentlyOpen) updated.pendingCount = 0;
          list.insert(0, updated);
        }

        list.refresh();
      } catch (e) {
        debugPrint("recent task update error: $e");
      }
    });
  }

  void registerUpdateRecentListListenerMobile() {
    socket?.off('update_recent_list');

    socket?.on('update_recent_list', (messages) {
      try {
        final updated = UserDataAPI.fromJson(messages);

        // ✅ 1) Company mismatch => DO NOTHING
        final activeCompanyId = APIs.me.userCompany?.companyId;
        final msgCompanyId = updated.userCompany?.companyId;

        if (activeCompanyId == null || msgCompanyId == null) return;
        if (activeCompanyId != msgCompanyId) return; // ✅ ignore other company

        if (!Get.isRegistered<ChatHomeController>()) return;
        final chatController = Get.find<ChatHomeController>();

        final list = chatController.filteredList;

        // ✅ 2) Use a UNIQUE key for recent row (recommended)
        // Prefer userCompanyId (mapping id) if available, else fallback to userId
        final key = updated.userCompany?.userCompanyId;

        final idx = (key != null)
            ? list.indexWhere((t) => t.userCompany?.userCompanyId == key)
            : list.indexWhere((t) => t.userId == updated.userId);

        if (idx != -1) {
          final existing = list[idx];

          // Keep pendingCount logic safe (optional)
          // existing.pendingCount = updated.pendingCount ?? existing.pendingCount;

          existing.lastMessage = updated.lastMessage;
          existing.pendingCount = updated.pendingCount ?? existing.pendingCount;

          // move to top
          list.removeAt(idx);
          list.insert(0, existing);
        } else {
          list.insert(0, updated);
        }

        list.refresh();
        final totalUnread = chatController.filteredList
            .fold<int>(0, (sum, e) => sum + (e.pendingCount ?? 0));

        // AppBadgeController.to.setCurrentCounts(chat: totalUnread);
      } catch (e) {
        debugPrint('update_recent error: $e');
      }
    });
  }

  /*void registerUpdateRecentListListenerMobile() {
    socket?.off('update_recent_list');
    socket?.on('update_recent_list', (messages) {
      debugPrint("update_recent_list ${jsonEncode(messages.toString())}");

      try {
        final updated = UserDataAPI.fromJson(messages);
        if (APIs.me.userCompany?.companyId ==
            updated.userCompany?.companyId) {
          final chatController = Get.find<ChatHomeController>();


          final list = chatController.filteredList;

          // FIND USER
          final idx = list.indexWhere(
                  (t) => t.userId == updated.userId
          );

          if (idx != -1) {
            // 🔥 REMOVE OLD
            list.removeAt(idx);
            // 🔥 INSERT UPDATED AT TOP
            list.insert(0, updated);
          } else {
            // 🔥 NEW CHAT
            list.insert(0, updated);
          }

          // 🔥 FORCE UI UPDATE
          list.refresh();
          // chatController.update();
        }
      } catch (e) {
        debugPrint('update_recent error: $e');
      }
    });
  }*/

/*  void registerUpdateRecentTaskUserListenerMobile() {
    socket?.off('update_recent_task_list');
    socket?.on('update_recent_task_list', (messages) {
      debugPrint("update_recent_task_list ${jsonEncode(messages.toString())}");

      try {
        final updated = UserDataAPI.fromJson(messages);
        if (APIs.me.userCompany?.companyId ==
            updated.userCompany?.companyId) {
          final taskhomeC = Get.find<TaskHomeController>();
          final updated = UserDataAPI.fromJson(messages);

          final list =  taskhomeC.filteredList;

          // FIND USER
          final idx = list.indexWhere(
                  (t) => t.userId == updated.userId
          );

          if (idx != -1) {
            // 🔥 REMOVE OLD
            list.removeAt(idx);
            // 🔥 INSERT UPDATED AT TOP
            list.insert(0, updated);
          } else {
            // 🔥 NEW CHAT
            list.insert(0, updated);
          }

          // 🔥 FORCE UI UPDATE
          list.refresh();
        }
        // chatController.update();
      } catch (e) {
        debugPrint('update_recent error: $e');
      }
    });
  }*/

  void registerUpdateRecentTaskUserListenerMobile() {
    socket?.off('update_recent_task_list');

    socket?.on('update_recent_task_list', (messages) {
      try {
        final updated = UserDataAPI.fromJson(messages);

        // ✅ 1) Company mismatch => DO NOTHING
        final activeCompanyId = APIs.me.userCompany?.companyId;
        final msgCompanyId = updated.userCompany?.companyId;

        if (activeCompanyId == null || msgCompanyId == null) return;
        if (activeCompanyId != msgCompanyId) return; // ✅ ignore other company

        if (!Get.isRegistered<TaskHomeController>()) return;
        final taskhomeC = Get.find<TaskHomeController>();

        final list = taskhomeC.filteredList;

        // ✅ 2) Use unique key if possible (recommended)
        final key = updated.userCompany?.userCompanyId;

        final idx = (key != null)
            ? list.indexWhere((t) => t.userCompany?.userCompanyId == key)
            : list.indexWhere((t) => t.userId == updated.userId);

        if (idx != -1) {
          final existing = list[idx];
          var dashCon;
          if(Get.isRegistered<DashboardController>()){
            dashCon = Get.find<DashboardController>();
          }
          // update last preview + pending if you want (optional but useful)
          existing.lastMessage = updated.lastMessage;
          existing.pendingCount = updated.pendingCount ?? existing.pendingCount;

          // move to top
          list.removeAt(idx);
          list.insert(0, existing);
          dashCon.newTask.value=true;
        } else {
          list.insert(0, updated);
        }

        list.refresh();
      } catch (e) {
        debugPrint('update_recent_task_list error: $e');
      }
    });
  }

  void connectUserEmitter(companyId) {
    try {
      if (companyId != null && APIs.me?.userId != null) {
        socket?.emit('select_company', {
          'company_id': companyId,
          'user_id': APIs.me!.userId,
        });
        debugPrint("user connected");
      }
    } catch (e) {
      debugPrint("connectUserEmitter error: $e");
    }
  }

  void _registerDeleteListener() {
    socket?.off('delete_message_listener');
    socket?.on('delete_message_listener', (data) {
      try {
        Map<String, dynamic> map;
        if (data is Map) {
          map = Map<String, dynamic>.from(data);
        } else if (data is String) {
          map = Map<String, dynamic>.from(jsonDecode(data));
        } else {
          return;
        }
        _handleMessageDeleted(map);
      } catch (_) {}
    });
  }

  void _handleMessageDeleted(Map<String, dynamic> payload) {
    final _tagid = ChatPresence.activeChatId.value;
    final _tag = "chat_${_tagid ?? 'mobile'}";
    ChatScreenController chatDetailController =
        Get.find<ChatScreenController>(tag: _tag);
    final dynamic idRaw = payload['chat_id'];
    final int? chatId = idRaw is int ? idRaw : int.tryParse('$idRaw');
    if (chatId == null) return;

    // 1) find the message in your current page
    final int idx = (chatDetailController.chatHisList ?? [])
        .indexWhere((m) => m.chatId == chatId);
    if (idx == -1) {
      // not in current page (maybe on a different page); nothing to update locally
      return;
    }

    // 2) mark it "deleted for everyone": clear text, clear media, set an activity flag (optional)
    final ChatHisList msg = chatDetailController.chatHisList![idx];
    msg.message = null; // text cleared means "deleted"
    msg.chatId = null; // text cleared means "deleted"
    msg.media = <MediaList>[]; // remove attachments

    // 3) put back & rebuild your date groups
    chatDetailController.chatHisList![idx] = msg;
    chatDetailController.chatHisList!.removeAt(idx);
    _rebuildCategories(_tag);
    chatDetailController.rebuildFlatRows();
    Get.back();

    // 4) notify GetBuilder UIs
    update();
    chatDetailController.update();
  }

  void _rebuildCategories(t) {
    final _tagid = ChatPresence.activeChatId.value;
    final _tag = "chat_${_tagid ?? 'mobile'}";
    ChatScreenController chatDetailController =
        Get.find<ChatScreenController>(tag: _tag);
    chatDetailController.chatCatygory =
        (chatDetailController.chatHisList ?? []).map((item) {
      DateTime? dt;
      if (item.sentOn != null) {
        dt = DateTime.tryParse(item.sentOn ?? '');
      }
      return GroupChatElement(dt ?? DateTime.now(), item);
    }).toList();
    chatDetailController.rebuildFlatRows();
  }

  void _registerDeleteListenerTask() {
    // avoid duplicate handlers
    socket?.off('delete_task_listener');

    socket?.on('delete_task_listener', (data) {
      try {
        Map<String, dynamic> map;
        if (data is Map) {
          map = Map<String, dynamic>.from(data);
        } else if (data is String) {
          map = Map<String, dynamic>.from(jsonDecode(data));
        } else {
          return;
        }
        _handleMessageDeletedTask(map);
      } catch (_) {}
    });
  }

  void _handleMessageDeletedTask(Map<String, dynamic> payload) {
    final _tagid = TaskPresence.activeTaskId.value;
    final _tag = "task_${_tagid ?? 'mobile'}";
    TaskController? taskController;
    if(!kIsWeb || Get.width<600){
      taskController =
          Get.find<TaskController>();
    }else{
      if (Get.isRegistered<TaskController>(tag: _tag)) {
        taskController =
            Get.find<TaskController>(tag: _tag);
      }
    }

    final dynamic idRaw = payload['task_id'];
    final int? chatId = idRaw is int ? idRaw : int.tryParse('$idRaw');
    if (chatId == null) return;

    // 1) find the message in your current page
    final int idx = (taskController?.taskHisList ?? [])
        .indexWhere((m) => m.taskId == chatId);
    if (idx == -1) {
      // not in current page (maybe on a different page); nothing to update locally
      return;
    }

    // 2) mark it "deleted for everyone": clear text, clear media, set an activity flag (optional)
    final TaskData? msg = taskController?.taskHisList![idx];
    msg?.title = null;
    msg?.taskId = null;
    msg?.details = null;
    msg?.deadline = null;
    msg?.currentStatus = null;
    msg?.statusHistory = null;
    msg?.media = <TaskMedia>[];

    // 3) put back & rebuild your date groups
    taskController?.taskHisList?[idx] = msg!;
    taskController?.taskHisList!.removeAt(idx);
    _rebuildCategoriesForTask();
    Get.back();
    update();
    taskController?.update();
  }

  void _rebuildCategoriesForTask() {
    TaskController chatDetailController = Get.find<TaskController>();
    chatDetailController.taskCategory =
        (chatDetailController.taskHisList ?? []).map((item) {
      DateTime? dt;
      if (item.createdOn != null) {
        dt = DateTime.tryParse(item.createdOn ?? '');
      }
      return GroupTaskElement(dt ?? DateTime.now(), item);
    }).toList();
  }

  void readMsgEmitter(
      {required int toucID, companyId, fromUcID, is_group_chat}) {
    socket?.emit('read_message', {
      "to_uc_id": toucID,
      "company_id": companyId,
      "from_uc_id": fromUcID,
      "is_group_chat": is_group_chat,
    });

    debugPrint(
        "to_uc_id: $toucID,company_id : $companyId,from_uc_id : $fromUcID ,is_group_chat : $is_group_chat");
  }

  /*
  void setupSocketListeners() {
    socket?.off('read_message_listener');
    socket?.on('read_message_listener', (data) {
      debugPrint("read_message_listener: ${jsonEncode(data)}");
      final chatController = Get.find<ChatHomeController>();
      final chatRoomController = Get.find<ChatScreenController>();
      final int toId = data['to_uc_id'];
      final int fromId = data['from_uc_id'];
      final int myUcId = APIs.me.userCompany?.userCompanyId ?? 0;

      // Only update when YOU are the receiver
      if (toId == myUcId) {
        // 1️⃣ Update unread count on Recents List
        for (var chat in chatController.filteredList) {
          if (chat.userCompany?.userCompanyId == fromId) {
            chat.pendingCount = 0;
            break;
          }
        }

        // 2️⃣ Update messages in Active Chat Screen
        for (var group in chatRoomController.chatCatygory) {
          final msg = group.chatMessageItems;
          // Only mark messages sent BY that user AND to you
          if (msg.fromUser?.userCompany?.userCompanyId == fromId &&
              msg.toUser?.userCompany?.userCompanyId == myUcId) {
            msg.readOn = DateTime.now().millisecondsSinceEpoch.toString();
          }
        }
        chatController.filteredList.refresh();
        chatRoomController.update();
      }
    });
  }*/

  void setupSocketListeners() {
    socket?.off('read_message_listener');
    socket?.on('read_message_listener', (data) {
      debugPrint("read_message_listener: ${jsonEncode(data)}");
      var dashCon;
      if(Get.isRegistered<DashboardController>()){
        dashCon = Get.find<DashboardController>();
      }
      final _tagid = ChatPresence.activeChatId.value;
      final _tag = "chat_${_tagid ?? 'mobile'}";
      final homeController = Get.find<ChatHomeController>();
      final ChatScreenController chatScreenController;
      if(!kIsWeb || Get.width<600){
        chatScreenController =
            Get.find<ChatScreenController>();
      }else{
        chatScreenController = Get.find<ChatScreenController>(tag: _tag);
      }
      final int fromUcId = data['from_uc_id'];
      final int toUcId = data['to_uc_id'];
      final int myUcId = APIs.me.userCompany?.userCompanyId ?? 0;

      final index = homeController.filteredList.indexWhere(
        (e) => e.userCompany?.userCompanyId == fromUcId,
      );

      if (index != -1) {
        homeController.filteredList[index].pendingCount = 0;
        dashCon.newChat.value=false;
        dashCon.newCompanyChat.value=false;
      }

      // 2️⃣ Update read_on in currently open chat
      for (var group in chatScreenController.chatCatygory) {
        final msg = group.chatMessageItems;

        // if (msg.fromUser?.userCompany?.userCompanyId == fromUcId &&
        //     msg.toUser?.userCompany?.userCompanyId == myUcId) {
        msg.readOn = DateTime.now().millisecondsSinceEpoch.toString();
        // }
      }

      homeController.filteredList.refresh();
      homeController.update();
      chatScreenController.update();
    });
  }

  void deleteMsgEmitter(
      {required String mode, required int chatId, int? groupId}) {
    socket?.emit('delete_message', {
      "mode": mode, // "direct" | "group" | "broadcast"
      "chat_id": chatId,
      "group_id": groupId,
    });
  }

  void deleteTaskEmitter({required int taskId, int? comid}) {
    socket?.emit('delete_task', {"task_id": taskId, "company_id": comid});
    debugPrint("Delete task for TaskId : $taskId || CompanyID: $comid");
  }

  void joinTaskEmitter({required int taskId}) {
    socket?.emit('join_task', {
      "task_id": taskId,
    });
  }

  Future<void> sendTaskComments({
    int? toId,
    String? message,
    var companyId,
    int? taskId,
    String pushToken = '',
  }) async {
    if (socket != null && socket!.connected) {
      debugPrint("Message sent:---------- $message");
      try {
        socket?.emit('add_task_comment', {
          "task_id": taskId,
          "company_id": companyId,
          "to_id": toId,
          "comment_text": message
        });
        debugPrint(
            "Message sent: $message ,receiverId: $toId ,fromid: ${APIs.me.userId}, comapnyid: ${APIs.me.userCompany?.userCompanyId}");

      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      debugPrint("Socket is not connected");
    }
  }

  Future<void>  sendMessage({
    int? receiverId,
    String? message,
    var companyId,
    int? chatId,
    int? forwardChatId,
    int? groupId,
    int? brID,
    int isGroup = 0,
    String? type,
    int? replyToId,
    String? replyToText,
    int isForward = 0,
    String pushToken = '',
    bool alreadySave = false,
  }) async {
    if (socket != null && socket!.connected) {
      debugPrint("Message sent:---------- $message");
      final Map<String,dynamic> map = {
        "type":type,
        "groupId":groupId,
        "brID":brID,
        "companyId":companyId,
        "receiverId":receiverId,
        "replyToId":replyToId,
        "replyToText":replyToText,
        "message":message,
        "isGroup":isGroup,
        "alreadySave":alreadySave,
        "chatId":chatId,
        "isForward":isForward,
        "forwardChatId":forwardChatId,
      };
      print("map========");
      debugPrint(map.toString(),wrapWidth: 2000);
      try {
        socket?.emit('send_message', {
          "mode": type,
          "group_id": groupId,
          "broadcast_id": brID,
          "company_id": companyId,
          "to_user_id": receiverId,
          "reply_to_id": replyToId,
          "reply_to_text": replyToText,
          "text": message,
          'is_group': isGroup,
          "already_saved": alreadySave,
          "chat_id": chatId,
          "is_forwarded": isForward,
          "forward_source_chat_id": forwardChatId,
        });


        debugPrint(
            "Message sent: $message ,receiverId: $receiverId,replyToId: $replyToId, Broadcast user id,: $brID , forwardChatId: $forwardChatId, fromid: ${APIs.me.userId}, comapnyid: ${APIs.me.userCompany?.userCompanyId}, group id: $groupId, alreadySaved: ${alreadySave}");
        var token = StorageService.getToken();
        debugPrint("authorization token is ********* $token");
        final svc = CompanyService.to;
        final myCompany = svc.selected;

        // if (pushToken != '' && pushToken != APIs.me.pushToken) {
        //   if (!isTaskMode) {
        //     // await LocalNotificationService.showChatNotification(
        //     //   title: '💬 New Message from ${APIs.me.name}',
        //     //   body: msg??'',
        //     // );
        //     await NotificationService.sendMessageNotification(
        //       targetToken: pushToken,
        //       senderName: APIs.me.userName ?? '',
        //       company: myCompany,
        //       message: message ?? '',
        //     );
        //   } else {
        //     // await NotificationService.sendTaskNotification(
        //     //   targetToken: token,
        //     //   assignerName: APIs.me.name,
        //     //   company: APIs.me.selectedCompany,
        //     //   taskSummary: taskDetails?.title??'',
        //     // );
        //     // await LocalNotificationService.showTaskNotification(
        //     //   title: '💬 New Task from ${APIs.me.name}',
        //     //   body: taskDetails?.title??'',
        //     // );
        //   }
        // }
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      debugPrint("Socket is not connected");
    }
  }

  Future<void> sendTaskMessage({
    int? receiverId,
    var companyId,
    taskTitle,
    taskDes,
    taskDeadline,
    attachmentsList,
    pushToken,
    bool alreadySave = false,
  }) async {
    if (socket != null && socket!.connected) {
      debugPrint("Task sent:---------- $taskTitle");
      try {
        socket?.emit('send_task', {
          "company_id": companyId,
          "to_id": receiverId,
          "title": taskTitle,
          "description": taskDes,
          "deadline": taskDeadline,
          "files": attachmentsList
        });
        debugPrint(
            "Task sent: $taskTitle ,receiverId: $receiverId ,companyId: $companyId  ");
        var token = StorageService.getToken();
        debugPrint("authorization token is ********* $token");
        final svc = CompanyService.to;
        final myCompany = svc.selected;

        // if(!kIsWeb) {
        //   if (pushToken != '' && pushToken != APIs.me.pushToken) {
        //     // await LocalNotificationService.showChatNotification(
        //     //   title: '💬 New Message from ${APIs.me.name}',
        //     //   body: msg??'',
        //     // );
        //     await NotificationService.sendTaskNotification(
        //       targetToken: pushToken,
        //       assignerName: APIs.me.userName ?? '',
        //       company: myCompany,
        //       taskSummary: taskTitle,
        //     );
        //   }
        // }
      } catch (e) {
        debugPrint("error is: ${e.toString()}");
      }
    } else {
      debugPrint("Socket is not connected");
    }
  }

  Future<void> updateTaskMessage({
    int? taskID,
    int? receiverId,
    var companyId,
    taskTitle,
    taskDes,
    taskDeadline,
    status,
    taskStatusId,
    List<AttachmentFiles>? attachmentsList,
    pushToken,
    bool isForward = false,
    UserDataAPI? forwardUser,
  }) async {
    if (socket != null && socket!.connected) {
      debugPrint("Update task sent:---------- $taskTitle");
      try {
        socket?.emit('update_task', {
          "task_id": taskID,
          "company_id": companyId,
          "to_id": receiverId,
          "title": taskTitle,
          "description": taskDes,
          "deadline": taskDeadline,
          "task_status_id": taskStatusId,
          "files": attachmentsList
        });
        debugPrint(
            "Update task sent: ======== task_id: $taskID,attachmentsList: ${attachmentsList}, title:  $taskTitle ,receiverId: $receiverId ,companyId : $companyId, taskStatusId:$taskStatusId");

        final svc = CompanyService.to;
        final myCompany = svc.selected;

        // if (pushToken != '' && pushToken != APIs.me.pushToken) {
        //   // await LocalNotificationService.showChatNotification(
        //   //   title: '💬 New Message from ${APIs.me.name}',
        //   //   body: msg??'',
        //   // );
        //   await NotificationService.sendTaskNotification(
        //     targetToken: pushToken,
        //     assignerName: APIs.me.userName ?? '',
        //     company: myCompany,
        //     taskSummary: taskTitle,
        //   );
        // }
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      debugPrint("Socket is not connected");
    }
  }

  Future<void> updateChatMessage({
    int? chatId,
    int? receiverId,
    var toUcId,
    message,
    pushToken,
  }) async {
    if (socket != null && socket!.connected) {
      debugPrint("Update chat sent:---------- $message");
      try {
        socket?.emit('update_message', {
          "chat_id": chatId,
          "to_uc_id": toUcId,
          "text": message,
        });
        debugPrint(
            "Update task sent: ======== task_id: $chatId,message: $message,toUcId: $toUcId");

        // final svc = CompanyService.to;
        // final myCompany = svc.selected;

        // if (pushToken != '' && pushToken != APIs.me.pushToken) {
        //   // await LocalNotificationService.showChatNotification(
        //   //   title: '💬 New Message from ${APIs.me.name}',
        //   //   body: msg??'',
        //   // );
        //   await NotificationService.sendTaskNotification(
        //     targetToken: pushToken,
        //     assignerName: APIs.me.userName ?? '',
        //     company: myCompany,
        //     taskSummary: taskTitle,
        //   );
        // }
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      debugPrint("Socket is not connected");
    }
  }

  Future<void> forwardTaskMessage({
    int? taskID,
    int? receiverId,
    var companyId,
    tasktitle,
    pushToken,
  }) async {
    if (socket != null && socket!.connected) {
      debugPrint("Message sent:---------- $receiverId");
      try {
        socket?.emit('forward_task', {
          "task_id": taskID,
          "company_id": companyId,
          "to_id": receiverId,
        });
        debugPrint("Message sent:TaskID $taskID ,receiverId: $receiverId ");
        final svc = CompanyService.to;
        final myCompany = svc.selected;

        // if (pushToken != '' && pushToken != APIs.me.pushToken) {
        //   // await LocalNotificationService.showChatNotification(
        //   //   title: '💬 New Message from ${APIs.me.name}',
        //   //   body: msg??'',
        //   // );
        //   await NotificationService.sendTaskNotification(
        //     targetToken: pushToken,
        //     assignerName: APIs.me.userName ?? '',
        //     company: myCompany,
        //     taskSummary: tasktitle,
        //   );
        // }
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      debugPrint("Socket is not connected");
    }
  }

  void onNewMessage(Function(dynamic) callback) {
    socket?.on('new_message', callback);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this); // ← ADD
    socket?.disconnect();
    super.onClose();
  }
}
