import 'dart:convert';
import 'package:AccuChat/Screens/Chat/models/task_commets_res_model.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_controller.dart';
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



  @override
  void onInit() {
    WidgetsBinding.instance.addObserver(this);
    _getMe();
    initSocket();
    super.onInit();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Ensure an active transport
      if (!(socket?.connected ?? false)) {
        try { socket?.connect(); } catch (_) {}
      }
      // Idempotently re-wire listeners and re-select company on resume
      allListerer();           // ensures .off() then .on() again
      connectUserEmitter();    // re-emit company context
    }
  }

  Future<void> initSocket() async {
    initial();
    allListerer();
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
          .setTransports(['websocket'])
          .enableForceNew()
          .enableReconnection()
          .enableAutoConnect()
          .setReconnectionDelay(2000)
          .setReconnectionAttempts(20)
          .setTimeout(20000)
          .setAuth({'token': token})
          .setPath('/socket.io/')
          .build(),
    );

    socket?.connect();

    socket?.onConnect((_) {
      connectUserEmitter();   // already in your code
      allListerer();          // ← ADD: make sure listeners are wired on first connect
    });

    socket?.onReconnectAttempt((_) {
      print("🔄 Trying to reconnect...");
    });

    socket?.onReconnect((_) {
      print("🔄 Reconnected!");
      // Re-attach handlers & re-emit company selection after reconnection
      allListerer();          // ← ADD
      connectUserEmitter();   // ← ADD
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

  allListerer() {

    socket?.off('send_message_listener');
    socket?.on('send_message_listener', (messages) {
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
    });

    // task listener

    socket?.off('send_task_listener');
    socket?.on('send_task_listener', (messages) {
      debugPrint("Listing task......4");
      debugPrint("send_task_listener ${jsonEncode(messages.toString())}");
      try {
        TaskController taskController =
            Get.find<TaskController>();
        TaskData receivedMessageDataModal = TaskData.fromJson(messages);

        if ((receivedMessageDataModal.fromUser?.userId.toString() ==
                (me?.userId).toString()) ||
            (receivedMessageDataModal.toUser?.userId.toString() ==
                (taskController.user?.userId.toString()))) {
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
      } catch (e) {
        debugPrint(e.toString());
      }
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

    socket?.off('update_task_listener');
    socket?.on('update_task_listener', (payload) {
      debugPrint("Listing update task......8");
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
      print("Joined task listen");
    }
        catch(e){
          print("Something went wrong Joined task");
        }
    });
  }

/*  addChatList(messages){
    if( Get.isRegistered<UserChatListController>()){
      ChatDetailResModel chatMessageItems=    ChatDetailResModel.fromJson(messages);
      if((chatMessageItems.senderId?.userId.toString())!=storage.read(userId))
      {
        List<UserChatListData>? chatList = Get.find<UserChatListController>().chatList;
        final index1 =   chatList?.indexWhere((item){
          return (item.userId?.toString()) ==
              chatMessageItems.senderId?.userId;
        });
        if(index1!=-1){
          int? unReadCount=Get
              .find<UserChatListController>()
              .chatList?[index1!].unreadMessageCount;

          Get
              .find<UserChatListController>()
              .chatList?.removeAt(index1!);
          chatList?.insert(0, UserChatListData(
            userId:int.parse(storage.read(userId)),
            regdDate: chatList[index1!].regdDate,
            userName: chatList[index1].userName,
            password:"",
            status: (unReadCount??0)+1,
            userRoleId: 0,
            empId: chatList[index1].empId,
            canViewAll: chatList[index1].canViewAll,
            canEditAll: chatList[index1].canEditAll,
            canAddAll: chatList[index1].canAddAll,
            userAbbr: chatList[index1].userAbbr,
            accessEmailCheckBox: chatList[index1].accessEmailCheckBox,
            canViewClientContact: chatList[index1].canViewClientContact,
            isGroup: chatList[index1].isGroup,
            isCollection: chatList[index1].isCollection,
            createdOn: chatList[index1].createdOn,
            socketId: chatList[index1].socketId,
            employee: chatList[index1].employee,
            unreadMessageCount: chatList[index1].unreadMessageCount,
            lastMessage: chatList[index1].lastMessage,



          ));
        }
        else{
          chatList?.insert(0, UserChatListData(
            userId:int.parse(storage.read(userId)),
            regdDate: chatList[index1!].regdDate,
            userName: chatList[index1].userName,
            password:"",
            // status: (unReadCount??0)+1,
            userRoleId: 0,
            empId: chatList[index1].empId,
            canViewAll: chatList[index1].canViewAll,
            canEditAll: chatList[index1].canEditAll,
            canAddAll: chatList[index1].canAddAll,
            userAbbr: chatList[index1].userAbbr,
            accessEmailCheckBox: chatList[index1].accessEmailCheckBox,
            canViewClientContact: chatList[index1].canViewClientContact,
            isGroup: chatList[index1].isGroup,
            isCollection: chatList[index1].isCollection,
            createdOn: chatList[index1].createdOn,
            socketId: chatList[index1].socketId,
            employee: chatList[index1].employee,
            unreadMessageCount: chatList[index1].unreadMessageCount,
            lastMessage: chatList[index1].lastMessage,
          ));
        }

        if (((chatList ?? []).any((item) =>
        (item.userId.toString() ?? "-1") ==
            chatMessageItems.senderId?.userId))) {


          chatList?.add(  UserChatListData(
            userId:int.parse(storage.read(userId)),
            regdDate: chatList[index1!].regdDate,
            userName: chatList[index1].userName,
            password:"",
            // status: (unReadCount??0)+1,
            userRoleId: 0,
            empId: chatList[index1].empId,
            canViewAll: chatList[index1].canViewAll,
            canEditAll: chatList[index1].canEditAll,
            canAddAll: chatList[index1].canAddAll,
            userAbbr: chatList[index1].userAbbr,
            accessEmailCheckBox: chatList[index1].accessEmailCheckBox,
            canViewClientContact: chatList[index1].canViewClientContact,
            isGroup: chatList[index1].isGroup,
            isCollection: chatList[index1].isCollection,
            createdOn: chatList[index1].createdOn,
            socketId: chatList[index1].socketId,
            employee: chatList[index1].employee,
            unreadMessageCount: chatList[index1].unreadMessageCount,
            lastMessage: chatList[index1].lastMessage,



          ));
        }
        else {
          chatList?.add(   UserChatListData(
            userId:int.parse(storage.read(userId)),
            regdDate: chatList[index1!].regdDate,
            userName: chatList[index1].userName,
            password:"",
            // status: (unReadCount??0)+1,
            userRoleId: 0,
            empId: chatList[index1].empId,
            canViewAll: chatList[index1].canViewAll,
            canEditAll: chatList[index1].canEditAll,
            canAddAll: chatList[index1].canAddAll,
            userAbbr: chatList[index1].userAbbr,
            accessEmailCheckBox: chatList[index1].accessEmailCheckBox,
            canViewClientContact: chatList[index1].canViewClientContact,
            isGroup: chatList[index1].isGroup,
            isCollection: chatList[index1].isCollection,
            createdOn: chatList[index1].createdOn,
            socketId: chatList[index1].socketId,
            employee: chatList[index1].employee,
            unreadMessageCount: chatList[index1].unreadMessageCount,
            lastMessage: chatList[index1].lastMessage,

          ));
        }
      }
      Get
          .find<UserChatListController>().update();
    }

  }*/

/*  void connectUserEmitter() {
    final svc = CompanyService.to;
    final myCompany = svc.selected;
    socket?.emit('select_company', {'company_id': myCompany?.companyId,'user_id': me?.userId});
    debugPrint("user connected");
  }*/

  void connectUserEmitter() {
    try {
      final svc = CompanyService.to;
      final myCompany = svc.selected;
      if (myCompany?.companyId != null && me?.userId != null) {
        socket?.emit('select_company', {
          'company_id': myCompany!.companyId,
          'user_id': me!.userId,
        });
        debugPrint("user connected");
      }
    } catch (e) {
      debugPrint("connectUserEmitter error: $e");
    }
  }


  void _registerDeleteListener() {
    // avoid duplicate handlers
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
      {required int chatId}) {
    print("read message for chat id$chatId");
    socket?.emit('read_message', {
      "chat_id": chatId,
    });
  }

  void setupSocketListeners() {
    socket?.off('read_message_listener');

    if(Get.isRegistered<ChatScreenController>()){

      ChatScreenController chatDetailController =
      Get.find<ChatScreenController>();
    socket?.on('read_message_listener', (data) {
      print("Reading...............");
      final int chatId = data['chat_id'];
      final String? readOnStr = data['read_on']; // assuming backend sends this
      final String? readOn = readOnStr != null ?readOnStr: null;

      final idx = (chatDetailController.chatHisList ?? []).indexWhere((m) => m.chatId == chatId);
      if (idx != -1) {

        (chatDetailController.chatHisList ?? [])[idx].readOn = readOn; // update with backend time
        update(); // if you're using GetX
        // _rebuildCategories();
      }
    });

  }

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

    print("Delete task for TaskId : $taskId || CompanyID: $comid");
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
            "Message sent: $message ,receiverId: $receiverId Broadcast user id,: $brID , forwardChatId: $forwardChatId, fromid: ${APIs.me.userId}, comapnyid: ${APIs.me.userCompany?.userCompanyId}, group id: $groupId, alreadySaved: ${alreadySave}");
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
    attachmentsList,
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
        debugPrint("Update task sent: ======== task_id: $taskID, title:  $taskTitle ,receiverId: $receiverId ,companyId : $companyId, taskStatusId:$taskStatusId");

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
