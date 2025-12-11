import 'dart:convert';
import 'package:AccuChat/Screens/Chat/models/task_attachment_res_model.dart';
import 'package:AccuChat/Screens/Chat/models/task_commets_res_model.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_home_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_home_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_thread_controller.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../Services/APIs/api_ends.dart';
import '../../../../Services/APIs/local_keys.dart';
import '../../../../Services/storage_service.dart';
import '../../../../main.dart';
import '../../../Chat/api/apis.dart';
import '../../../Chat/helper/notification_service.dart';
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

class SocketController extends GetxController with WidgetsBindingObserver  {
  late IO.Socket? socket;
  bool initialized = false;
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _getMe();
    if (!initialized) {
      initialized = true;
      initSocket();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    if (state == AppLifecycleState.resumed) {
      final svc = CompanyService.to;
      final myCompany =svc.selected;
      // Ensure an active transport
      if (!(socket?.connected ?? false)) {
        try { socket?.connect(); } catch (_) {}
      }
      // Idempotently re-wire listeners and re-select company on resume
      // allListerer();           // ensures .off() then .on() again
      connectUserEmitter(myCompany?.companyId);    // re-emit company context
    }
  }

  Future<void> initSocket() async {
    initial();
    final svc = CompanyService.to;
    final myCompany =svc.selected;
    connectUserEmitter(myCompany?.companyId);   // already in your code
    // allListerer();
  }

  initial() {
    try {
      // If an old socket instance exists, dispose it safely (keeps us single-instance)
      try { socket?.dispose(); } catch (_) {}                  // ← ADD
      if (socket?.connected ?? false) {
        socket?.disconnect();                                  // ← ADD (your line socket?.disconnected was a no-op)
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
          .setPath('/socket.io/')      // must match server/proxy location
          .setTimeout(20000)
          .setReconnectionDelay(2000)
          .setReconnectionAttempts(20)
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    socket?.connect();

    socket?.onConnect((_) {
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
      debugPrint("Socket disconnected $v");
    });
    socket?.onConnectError((e) => debugPrint('Connect error: $e'));
    socket?.onError((error) {
      debugPrint("Socket disconnected $error");
    });
  }


  UserDataAPI? me = UserDataAPI();
  _getMe() {
    me = getUser();
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
          ChatScreenController chatDetailController =
          Get.find<ChatScreenController>();
          ChatHisList receivedMessageDataModal = ChatHisList.fromJson(messages);
          final selectedUserId = chatDetailController.user?.userId?.toString();
          final meId           = me?.userId?.toString();

          final msgFrom = receivedMessageDataModal.fromUser?.userId?.toString();
          final msgTo   = receivedMessageDataModal.toUser?.userId?.toString();

// allow only when the message belongs to CURRENT OPEN CHAT
          final isMessageForThisChat =
              (msgFrom == selectedUserId && msgTo == meId) ||    // selectedUser → me
                  (msgFrom == meId && msgTo == selectedUserId);
          if (isMessageForThisChat) {
            // safe to insert the message
          ChatHisList chatMessageItems = ChatHisList(
            chatId: receivedMessageDataModal.chatId,
            fromUser: receivedMessageDataModal.fromUser,
            toUser: receivedMessageDataModal.toUser,
            message: receivedMessageDataModal.message,
            sentOn: receivedMessageDataModal.sentOn,
            media: receivedMessageDataModal.media,
            replyToText: receivedMessageDataModal.replyToText,
            replyToId: receivedMessageDataModal.replyToId,
            replyToTime: receivedMessageDataModal.replyToTime,
            replyToName: receivedMessageDataModal.replyToName,
            isGroupChat: receivedMessageDataModal.isGroupChat,
            isActivity: receivedMessageDataModal.isActivity,
          );
          chatDetailController.chatHisList?.insert(0, chatMessageItems);
          chatDetailController.chatCatygory
              .insert(0, GroupChatElement(DateTime.now(), chatMessageItems));
          chatDetailController.rebuildFlatRows();
          chatDetailController.update();
          }

          if(meId != msgFrom ){
            chatDetailController.markAllVisibleAsReadOnOpen(receivedMessageDataModal.fromUser?.userCompany?.userCompanyId,receivedMessageDataModal.toUser?.userCompany?.userCompanyId,receivedMessageDataModal.toUser?.userCompany?.isGroup==1?1:0);
          }

          // Get.find<ChatHomeController>().hitAPIToGetRecentChats();
        } catch (e) {
          debugPrint(e.toString());
        }
      });

      socket?.off('send_message_error');
      socket?.on('send_message_error', (messages) {
        debugPrint("send_message_error ${jsonEncode(messages.toString())}");
      });
    socket?.off('update_recent_list');
    socket?.on('update_recent_list', (messages) {
      debugPrint("update_recent_list ${jsonEncode(messages.toString())}");

      try {
        final chatController = Get.find<ChatHomeController>();
        final updated = UserDataAPI.fromJson(messages);

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

      } catch (e) {
        debugPrint("recent update error: $e");
      }
    });

    socket?.off('update_recent_task_list');
    socket?.on('update_recent_task_list', (messages) {
      debugPrint("update_recent_task_list ${jsonEncode(messages.toString())}");
      try {
        final taskhomeC = Get.find<TaskHomeController>();
        final updated = UserDataAPI.fromJson(messages);

        // ALWAYS use the RxList directly
        final list = taskhomeC.filteredList;

        // 1️⃣ Remove old entry
        list.removeWhere((e) =>
        e.userCompany?.userCompanyId ==
            updated.userCompany?.userCompanyId);

        // 2️⃣ Insert new one at TOP
        list.insert(0, updated);

        // 3️⃣ Force RxList rebuild
        taskhomeC.filteredList.refresh();

      } catch (e) {
        debugPrint("recent update task error: $e");
      }
    });


    /*socket?.off('update_recent_list');
    socket?.on('update_recent_list', (messages) {
      debugPrint("update_recent_list ${jsonEncode(messages.toString())}");

      try {
        final chatController = Get.find<ChatHomeController>();
        final updated = UserDataAPI.fromJson(messages);

        final list = chatController.filteredList;

        // FIND USER
        final idx = list.indexWhere(
                (t) => t.userId == updated.userId
        );

        // IF EXISTS → REPLACE OBJECT
        if (idx != -1) {
          chatController.filteredList[idx] = updated;   // ⭐ IMPORTANT ⭐
        }
        // IF NOT EXISTS → ADD AT TOP
        else {
          chatController.filteredList.insert(0, updated);
        }

      } catch (e) {
        debugPrint('update_recent error: $e');
      }
    });
*/

    /* socket?.on('send_message_listener', (messages) {
      debugPrint("Listing......3");
      debugPrint("send_message_listener ${jsonEncode(messages.toString())}");
      try {
        ChatScreenController chatDetailController =
            Get.find<ChatScreenController>();
        ChatHisList receivedMessageDataModal = ChatHisList.fromJson(messages);

        // if ((receivedMessageDataModal.fromUser?.userId.toString() ==
        //         (APIs.me?.userId).toString()) ||
        //     (receivedMessageDataModal.toUser?.userId.toString() ==
        //         (chatDetailController.user?.userId.toString()))) {
          ChatHisList chatMessageItems = ChatHisList(
            chatId: receivedMessageDataModal.chatId,
            fromUser: receivedMessageDataModal.fromUser,
            toUser: receivedMessageDataModal.toUser,
            message: receivedMessageDataModal.message,
            sentOn: receivedMessageDataModal.sentOn,
            media: receivedMessageDataModal.media,
            replyToText: receivedMessageDataModal.replyToText,
            replyToId: receivedMessageDataModal.replyToId,
            replyToTime: receivedMessageDataModal.replyToTime,
            replyToName: receivedMessageDataModal.replyToName,
            isGroupChat: receivedMessageDataModal.isGroupChat,
            isActivity: receivedMessageDataModal.isActivity,
          );
          chatDetailController.chatHisList?.insert(0, chatMessageItems);
          chatDetailController.chatCatygory
              .insert(0, GroupChatElement(DateTime.now(), chatMessageItems));
        chatDetailController.rebuildFlatRows();
        // }

        chatDetailController.update();
      } catch (e) {
        debugPrint(e.toString());
      }
    });*/

    // task listener

    socket?.off('send_task_listener');
    socket?.on('send_task_listener', (messages) {
      debugPrint("Listing task......4");
      debugPrint("send_task_listener ${jsonEncode(messages.toString())}");
      try {
        TaskController taskController =
            Get.find<TaskController>();
        TaskData receivedMessageDataModal = TaskData.fromJson(messages);
        final selectedUserId = taskController.user?.userId?.toString();
        final meId       = me?.userId?.toString();

        final msgFrom = receivedMessageDataModal.fromUser?.userId?.toString();
        final msgTo   = receivedMessageDataModal.toUser?.userId?.toString();

// allow only when the message belongs to CURRENT OPEN CHAT
        final isMessageForThisChat =
            (msgFrom == selectedUserId && msgTo == meId) ||    // selectedUser → me
                (msgFrom == meId && msgTo == selectedUserId);
        if (isMessageForThisChat) {
          TaskData chatMessageItems = TaskData(
            taskId: receivedMessageDataModal.taskId,
            fromUser: receivedMessageDataModal.fromUser,
            toUser: receivedMessageDataModal.toUser,
            title: receivedMessageDataModal.title,
            details: receivedMessageDataModal.details,
            deadline: receivedMessageDataModal.deadline,
            createdOn: receivedMessageDataModal.createdOn,
            media: receivedMessageDataModal.media,
            startDate: receivedMessageDataModal.startDate,
            endDate: receivedMessageDataModal.endDate,
            currentStatus: receivedMessageDataModal.currentStatus,
            statusHistory: receivedMessageDataModal.statusHistory,
          );
          taskController.taskHisList?.insert(0, chatMessageItems);
          taskController.taskCategory
              .insert(0, GroupTaskElement(DateTime.now(), chatMessageItems));
          // }
          taskController.update();
        }
        Get.find<TaskHomeController>().hitAPIToGetRecentTasksUser();
      } catch (e) {
        debugPrint(e.toString());
      }
    });

    socket?.off('company_joined');
    socket?.on('company_joined', (messages) {
      debugPrint("Listing task......67");
      debugPrint("company_joined ${messages}");
    });


  socket?.off('add_task_comment_listener');
    socket?.on('add_task_comment_listener', (messages) {
      debugPrint("Comments Listing task......4");
      debugPrint("add_task_comment_listener ${jsonEncode(messages.toString())}");
      try {
        TaskThreadController threadController =
            Get.find<TaskThreadController>();
        TaskComments receivedMessageDataModal = TaskComments.fromJson(messages);

        // if ((receivedMessageDataModal.fromUser?.userId.toString() ==
        //         (me?.userId).toString()) ||
        //     (receivedMessageDataModal.toUser?.userId.toString() ==
        //         (threadController.taskMessage?.fromUser?.userId.toString()))) {
          TaskComments taskComments = TaskComments(
              taskCommentId:receivedMessageDataModal.taskCommentId,
              fromUser:receivedMessageDataModal.fromUser,
              toUser:receivedMessageDataModal.toUser,
              commentText:receivedMessageDataModal.commentText,
              sentOn:receivedMessageDataModal.sentOn,
              isDeleted:receivedMessageDataModal.isDeleted,
              media:receivedMessageDataModal.media,
          );
          threadController.commentsList?.insert(0, taskComments);
          threadController.commentsCategory
              .insert(0, GroupCommentsElement(DateTime.now(), taskComments));
        // }
        threadController.update();
      } catch (e) {
        debugPrint(e.toString());
      }
    });

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
        final chatController = Get.find<ChatScreenController>();
        final updated = ChatHisList.fromJson(payload);

        final meId = APIs.me.userId?.toString();
        final fromId = updated.fromUser?.userId?.toString();
        final toId   = updated.toUser?.userId?.toString();

        if (fromId == meId || toId == meId) {
          final list = chatController.chatHisList ?? [];
          final idx  = list.indexWhere((t) => t.chatId == updated.chatId);

          if (idx != -1) {
            final old = list[idx];
            old.chatId= updated.chatId??old.chatId;
            old.fromUser= updated.fromUser??old.fromUser;
            old.toUser= updated.toUser??old.toUser;
            old.message= updated.message??old.message;
            old.isActivity= updated.isActivity??old.isActivity;
            old.isForwarded= updated.isForwarded??old.isForwarded;
            old.sentOn= updated.sentOn??old.sentOn;
            old.readOn= updated.readOn??old.readOn;
            old.pendingCount= updated.pendingCount??old.pendingCount;
            old.isGroupChat= updated.isGroupChat??old.isGroupChat;
            old.broadcastUserId= updated.broadcastUserId??old.broadcastUserId;
            old.replyToId= updated.replyToId??old.replyToId;
            old.replyToText= updated.replyToText??old.replyToText;
            old.replyToTime= updated.replyToTime??old.replyToTime;
            old.replyToName= updated.replyToName??old.replyToName;
            old.media=(updated.media?.isNotEmpty ?? false)? updated.media:old.media;
            chatController.update();
            final gIdx = chatController.chatCatygory
                .indexWhere((g) => g.chatMessageItems.chatId == updated.chatId);
            if (gIdx != -1) {
              chatController.chatCatygory[gIdx].chatMessageItems.chatId= old.chatId;
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

        final taskController = Get.find<TaskController>();
        final updated = TaskData.fromJson(payload);

        final meId = APIs.me.userId?.toString();
        final fromId = updated.fromUser?.userId?.toString();
        final toId   = updated.toUser?.userId?.toString();

        if (fromId == meId || toId == meId) {
          final list = taskController.taskHisList ?? [];
          final idx  = list.indexWhere((t) => t.taskId == updated.taskId);

          if (idx != -1) {
            // ✅ UPDATE IN PLACE — NO INSERT
            final old = list[idx];

            // Agar aapke model me copyWith nahi hai, to fields assign kar do:
            old.taskId         = updated.taskId         ?? old.taskId;
            old.title         = updated.title         ?? old.title;
            old.details       = updated.details       ?? old.details;
            old.deadline      = updated.deadline      ?? old.deadline;
            old.startDate     = updated.startDate     ?? old.startDate;
            old.endDate       = updated.endDate       ?? old.endDate;
            old.currentStatus = updated.currentStatus ?? old.currentStatus;
            old.statusHistory = (updated.statusHistory?.isNotEmpty ?? false)
                ? updated.statusHistory
                : old.statusHistory;
            old.media         = (updated.media?.isNotEmpty ?? false)
                ? updated.media
                : old.media;
            old.fromUser      = updated.fromUser ?? old.fromUser;
            old.toUser        = updated.toUser   ?? old.toUser;

            // RxList ho to:
            // taskController.taskHisList![idx] = old;
            // taskController.taskHisList!.refresh();

            // Sirf usi card ko rebuild karo:
            taskController.update();

            // (optional) Agar grouped list bhi maintain karte ho:
            final gIdx = taskController.taskCategory
                .indexWhere((g) => g.taskMsg.taskId == updated.taskId);
            if (gIdx != -1) {
              taskController.taskCategory[gIdx].taskMsg.taskId = old.taskId;
              // targeted update same id se ho jayega
            }
          } else {
            // ❓ Not found = naya task aaya? Tab hi insert karo.
            list.insert(0, updated);
            taskController.update(); // list-container ke liye alag id
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
    }
        catch(e){
          debugPrint("Something went wrong Joined task");
        }
    });
  }


  void connectUserEmitter(companyId) {
    try {
      if (companyId != null && me?.userId != null) {
        socket?.emit('select_company', {
          'company_id': companyId,
          'user_id': me!.userId,
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
    ChatScreenController chatDetailController =
        Get.find<ChatScreenController>();
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
    _rebuildCategories();
    chatDetailController.rebuildFlatRows();
    Get.back();

    // 4) notify GetBuilder UIs
    update();
    chatDetailController.update();
  }

  void _rebuildCategories() {
    ChatScreenController chatDetailController =
        Get.find<ChatScreenController>();
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
    TaskController chatDetailController =
        Get.find<TaskController>();
    final dynamic idRaw = payload['task_id'];
    final int? chatId = idRaw is int ? idRaw : int.tryParse('$idRaw');
    if (chatId == null) return;

    // 1) find the message in your current page
    final int idx = (chatDetailController.taskHisList ?? [])
        .indexWhere((m) => m.taskId == chatId);
    if (idx == -1) {
      // not in current page (maybe on a different page); nothing to update locally
      return;
    }

    // 2) mark it "deleted for everyone": clear text, clear media, set an activity flag (optional)
    final TaskData msg = chatDetailController.taskHisList![idx];
    msg.title = null; // text cleared means "deleted"
    msg.taskId = null; // text cleared means "deleted"
    msg.details = null; // text cleared means "deleted"
    msg.deadline = null; // text cleared means "deleted"
    msg.currentStatus = null; // text cleared means "deleted"
    msg.statusHistory = null; // text cleared means "deleted"
    msg.media = <TaskMedia>[]; // remove attachments

    // 3) put back & rebuild your date groups
    chatDetailController.taskHisList![idx] = msg;
    chatDetailController.taskHisList!.removeAt(idx);
    _rebuildCategoriesForTask();
    Get.back();
    // 4) notify GetBuilder UIs
    update();
    chatDetailController.update();
  }

  void _rebuildCategoriesForTask() {
    TaskController chatDetailController =
        Get.find<TaskController>();
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
      {required int ucID,companyId,fromUcID,is_group_chat}) {
    socket?.emit('read_message', {
      "to_uc_id": ucID,
      "company_id": companyId,
      "from_uc_id": fromUcID,
      "is_group_chat": is_group_chat,
    });
    debugPrint("to_uc_id: $ucID,company_id : $companyId,from_uc_id : $fromUcID ,is_group_chat : $is_group_chat");
  }

  void setupSocketListeners() {



    /*socket?.off('read_message_listener');
    socket?.on('read_message_listener', (data) {
      debugPrint("read_message_listener: ${jsonEncode(data)}");

      final chatController = Get.find<ChatHomeController>();
      final chatRoomController = Get.find<ChatScreenController>();
      final int toId = data['to_uc_id'];
      final int fromId = data['from_uc_id'];
      for (var item in chatController.filteredList) {
        if (item.userCompany?.userCompanyId == fromId) {
          item.pendingCount = 0;
          for(var i in chatRoomController.chatCatygory){
            if (fromId == i.chatMessageItems.fromUser?.userCompany?.userCompanyId) {
              i.chatMessageItems.readOn = DateTime.now().millisecondsSinceEpoch.toString();
            }
          }
          break;
        }
      }

      chatController.filteredList.refresh();
      chatRoomController.update();
    });*/

    socket?.off('read_message_listener');
    socket?.on('read_message_listener', (data) {
      debugPrint("read_message_listener: ${jsonEncode(data)}");

      final chatController = Get.find<ChatHomeController>();
      final chatRoomController = Get.find<ChatScreenController>();

      final int toId = data['to_uc_id'];     // user who RECEIVED the message
      final int fromId = data['from_uc_id']; // user who SENT the message
      final int myUcId = APIs.me.userCompany?.userCompanyId??0; // your own UC ID

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

}
  void deleteMsgEmitter(
      {required String mode, required int chatId, int? groupId}) {
    socket?.emit('delete_message', {
      "mode": mode, // "direct" | "group" | "broadcast"
      "chat_id": chatId,
      "group_id": groupId,
    });
  }



  void deleteTaskEmitter(
      {required int taskId, int? comid}) {
    socket?.emit('delete_task',{
      "task_id": taskId,
      "company_id":comid
    });

    debugPrint("Delete task for TaskId : $taskId || CompanyID: $comid");
  }

  void joinTaskEmitter(
      {required int taskId}) {
    socket?.emit('join_task',{
      "task_id": 8,
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
          "to_id":toId,
          "comment_text": message
        });
        debugPrint(
            "Message sent: $message ,receiverId: $toId ,fromid: ${APIs.me.userId}, comapnyid: ${APIs.me.userCompany?.userCompanyId}");

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


  Future<void> sendMessage({
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
          "forward_source_chat_id": forwardChatId
        });
        debugPrint(
            "Message sent: $message ,receiverId: $receiverId,replyToId: $replyToId, Broadcast user id,: $brID , forwardChatId: $forwardChatId, fromid: ${APIs.me.userId}, comapnyid: ${APIs.me.userCompany?.userCompanyId}, group id: $groupId, alreadySaved: ${alreadySave}");
        var token =  StorageService.getToken();
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
      debugPrint("Message sent:---------- $taskTitle");
      try {
        socket?.emit('send_task', {
          "company_id": companyId,
          "to_id": receiverId,
          "title": taskTitle,
          "description": taskDes,
          "deadline": taskDeadline,
          "files": attachmentsList
        });
        debugPrint("Message sent: $taskTitle ,receiverId: $receiverId ,companyId: $companyId  ");
        var token =  StorageService.getToken();
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
        debugPrint("Update task sent: ======== task_id: $taskID,attachmentsList: ${attachmentsList}, title:  $taskTitle ,receiverId: $receiverId ,companyId : $companyId, taskStatusId:$taskStatusId");

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
        debugPrint("Update task sent: ======== task_id: $chatId,message: $message,toUcId: $toUcId");

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
        socket?.emit(
          'forward_task', {
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
    WidgetsBinding.instance.removeObserver(this);        // ← ADD
    socket?.disconnect();
    super.onClose();
  }
}
