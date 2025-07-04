import 'dart:convert';
import 'package:AccuChat/Screens/chat_module/models/chat_history_model.dart';
import 'package:AccuChat/Screens/chat_module/models/getGroupResModel.dart';
import 'package:AccuChat/Screens/chat_module/presentation/controllers/chat_detail_controller.dart';
import 'package:AccuChat/Screens/chat_module/presentation/views/chatting_deatail_screen.dart';
import 'package:AccuChat/Screens/chat_module/time_ago_local.dart';
import 'package:AccuChat/Services/APIs/Chat_service/chat_api_servcie_impl.dart';
import 'package:hive/hive.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:AccuChat/main.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as multi;
import '../../../../Services/APIs/local_keys.dart';
import '../../models/chat_detail_model.dart';
import '../../models/user_chat_list_model.dart';

class UserChatListController extends GetxController {
  bool isGoChatScreen = false;
  bool showPostShimmer = false;
  late ScrollController scrollController;
  late TextEditingController searchUserConroller;
  bool isLoading = false;
  int currentPage = 1;
  int perPage = 30;

  var selectedGroupType = "Group";
  var searchText = "";

  UserChatListResModel userChatListResModel = UserChatListResModel();
  // List<UserChatListData>? chatList = [];

  late TextEditingController groupController;


@override
  void onReady() {
  timeago.setLocaleMessages('short', ShortMessages());
    super.onReady();
  }


  @override
  void onInit(){
    timeago.setLocaleMessages('short', ShortMessages());
    groupController= TextEditingController();
    searchUserConroller= TextEditingController();
    if(!isConnected){
      // getOfflineHistory();
    }

    scrollController = ScrollController();
    if(isConnected) {
      initDummyData();
      // hitApiToGetChatList();
      // getOfflineHistory();
    }

    super.onInit();
  }



  getOfflineHistory()async{
    try {
      if (!Hive.isBoxOpen("userChatList")) {
        await Hive.openBox<UserChatListData>('chatUserList');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    chatList= await getChatUserList();
    update();
  }

  String timeAgo = '';

  String getTimeAgo(String lastMessageTime) {
    try {
      // Parse the provided timestamp string into a DateTime object
      DateTime lastMessageDateTime = DateTime.parse(lastMessageTime).toUtc();
      DateTime dateTimeLocal = lastMessageDateTime.toLocal();
      // Calculate the "time ago" using the timeago package
      return timeago.format(dateTimeLocal, locale: 'short');
    } catch (e) {
      // Handle parsing errors
      return "";
    }
  }

  @override
  void onClose() {
    // if (isGoChatScreen == false) {
    //   if (Get.isRegistered<SocketController>()) {
    //     // Get.find<SocketController>().leaveChatEmitter();
    //   }
    // }
    isGoChatScreen = false;
    super.onClose();
  }

  //dummy
  List<Map<String, dynamic>> jsonData = [
    {
      "user_id": 101,
      "regd_date": "2024-11-01T10:00:00",
      "user_name": "Amit Sharma",
      "password": "password123",
      "status": 1,
      "user_role_id": 3,
      "emp_id": 201,
      "can_view_all": 1,
      "can_edit_all": 1,
      "can_add_all": 1,
      "user_abbr": "AS",
      "access_email_check_box": true,
      "can_view_client_contact": 1,
      "is_group": 0,
      "is_collection": false,
      "created_on": "2024-11-01T09:00:00",
      "created_by": "admin",
      "socket_id": "socket123amit",
      "employee": {
        "id": 201,
        "name": "Amit Sharma",
        "designation": "Support Executive"
      },
      "unread_message_count": 2,
      "last_message": {
        "message_id": 501,
        "text": "Sir, I have shared the form details.",
        "timestamp": "2024-11-01T10:15:00",
        "sender_id": 101
      }
    },
    {
      "user_id": 102,
      "regd_date": "2024-12-10T14:00:00",
      "user_name": "Priya Mehta",
      "password": "secure@456",
      "status": 1,
      "user_role_id": 2,
      "emp_id": 202,
      "can_view_all": 0,
      "can_edit_all": 0,
      "can_add_all": 1,
      "user_abbr": "PM",
      "access_email_check_box": false,
      "can_view_client_contact": 0,
      "is_group": 0,
      "is_collection": false,
      "created_on": "2024-12-10T13:30:00",
      "created_by": "admin",
      "socket_id": "socket102priya",
      "employee": {
        "id": 202,
        "name": "Priya Mehta",
        "designation": "Data Entry"
      },
      "unread_message_count": 0,
      "last_message": {
        "message_id": 502,
        "text": "Please check the updated ticket status.",
        "timestamp": "2024-12-10T14:20:00",
        "sender_id": 102
      }
    },
    {
      "user_id": 103,
      "regd_date": "2025-01-15T16:45:00",
      "user_name": "Ravi Kumar",
      "password": "ravi@321",
      "status": 0,
      "user_role_id": 1,
      "emp_id": 203,
      "can_view_all": 1,
      "can_edit_all": 1,
      "can_add_all": 1,
      "user_abbr": "RK",
      "access_email_check_box": true,
      "can_view_client_contact": 1,
      "is_group": 1,
      "is_collection": true,
      "created_on": "2025-01-15T16:00:00",
      "created_by": "admin",
      "socket_id": "socket103ravi",
      "employee": {
        "id": 203,
        "name": "Ravi Kumar",
        "designation": "Manager"
      },
      "unread_message_count": 5,
      "last_message": {
        "message_id": 503,
        "text": "Team meeting scheduled for tomorrow.",
        "timestamp": "2025-01-15T16:40:00",
        "sender_id": 103
      }
    }
  ];

  List<UserChatListData>? chatList;

  initDummyData(){
    chatList  = jsonData.map((json) => UserChatListData.fromJson(json)).toList();
  }


  hitApiToGetChatList({searchtext}) {
    showPostShimmer = true;
    var reqData = multi.FormData.fromMap({
      // "auth_key": ApiEnd.authKEy,
      "user_id": storage.read(userId),
      "user_name":searchtext,
    });

    Get.find<ChatApiServiceImpl>()
        .getUserChatListApi(dataBody: reqData)
        .then((value) {
      customLoader.hide();
      showPostShimmer = false;
      userChatListResModel = value;
      chatList = userChatListResModel.body;
      saveChatUserList(chatList??[]);
      update();
    }).onError((error, stackTrace) {
      showPostShimmer = false;
      update();
      getOfflineHistory();
      errorDialog(error.toString());
    }).whenComplete((){
      // getOfflineHistory();
    });
  }

  createGroupApi(isGroup) {
    customLoader.show();
    var reqData = multi.FormData.fromMap({
      // "auth_key": ApiEnd.authKEy,
      "user_id": storage.read(userId),
      "group_id":"",
      "is_group":isGroup,
      "user_name": groupController.text.capitalizeFirst,
    });

    Get.find<ChatApiServiceImpl>()
        .editGroupMembersApi(dataBody: reqData)
        .then((value)  {
      Get.back();

      groupController.clear();
      customLoader.hide();

      update();
    }).onError((error, stackTrace) {
      update();
      Get.back();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete((){
      // hitApiToGetChatList();
    });
  }

  Future<List<UserChatListData>> getChatUserList() async{
    try {
      if (!Hive.isBoxOpen("userChatList")) {
        await Hive.openBox<UserChatListData>('userChatList');
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    var chatUserListBox = Hive.box<UserChatListData>('userChatList');
    return chatUserListBox.values.toList();
  }

  Future<void> saveChatUserList(List<UserChatListData> userList) async {
    try {
      if (!Hive.isBoxOpen("userChatList")) {
        await Hive.openBox<UserChatListData>('userChatList');
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    final chatUserListBox = Hive.box<UserChatListData>('userChatList');
    await chatUserListBox.clear();
    for (var user in userList) {
      await chatUserListBox.put(user.userId, user); // Use userId as the unique key
    }
  }

  /*********************************************************** pagination *************************************************/
/*  void paginationStockItemList() {
    scrollController.addListener(() {
      var nextPageTrigger = 0.9 * scrollController.position.maxScrollExtent;
      if (scrollController.position.pixels > nextPageTrigger)
          {
            if (isLoading == false &&
            currentPage < (chatUserListResponse?.pageCount ?? 1)) {

          currentPage++;

          if (currentPage <=
              (chatUserListResponse?.pageCount ?? 1).toInt()) {
            isLoading = true;
            update();
            Timer.periodic(Duration(seconds: 2), (timer) async {
              timer.cancel();

              // Get.find<SocketController>().chatListEmmitter(currentPage: currentPage,perPage: perPage);
              // isLoading=false;
              await Get.find<PostApiServiceImpl>()
                  .chatUserListApiCall(
                  userID: Get.find<GetLoginModalService>().getUserDataModal()?.sId,
                  perPage: perPage, page: currentPage)
                  .then((value) {
                chatUserListResponse = value.data;

                getChatList?.addAll(chatUserListResponse?.listItems ?? []);
                isLoading = false;

                update();
              }).onError((error, stackTrace) {
                toast(error.toString());
              });
            });
          } else {
            isLoading = false;
            update();
          }
        }
      }
    });
  }*/
}

class SocketController extends GetxController {
  late IO.Socket? socket;

  // @override
  // void onClose() {
  //   socket?.disconnect();
  //   super.onClose();
  // }
  @override
  void onInit() {
    // initSocket();
    super.onInit();
  }


  Future<void> initSocket() async {
    initial();
    allListerer();
  }

  initial() {
    try {
      if (socket?.connected ?? false) {
        socket?.disconnected;
      }
    } catch (e) {}

    socket = IO.io('http://192.168.1.112:3000', OptionBuilder().setTransports(['websocket']).build());
    socket?.connect();
    socket?.onConnect((_) {
      connectUserEmitter();
    });

    socket?.onDisconnect((_) {
      // errorDialog("Socket disconnected");
    });

    socket?.onError((error) {
      // errorDialog(error.toString());
    });
  }

  allListerer() {
    // socket.on('getChatList', (message) {
    //   print("getChatList " + jsonEncode(message));
    //   chatUserListResponse= PaginatinDataModal.fromJson(
    //       message, (data2) => GetChatList.fromJson(data2));
    //
    //   getChatList?.addAll(chatUserListResponse?.listItems??[]);
    //
    //   try {
    //     Get.find<UserChatListController>().update();
    //   } catch (e) {
    //     debugPrint("error ${e.toString()}");
    //   }
    // });
    socket?.off('connect_user_listner');
    socket?.on('connect_user_listner', (message) {
      debugPrint("Listing......2");
      debugPrint("joinChatSuccess " + jsonEncode(message));
      // EmitterMessageDataModal joinChatMessage =
      // EmitterMessageDataModal.fromJson(message);
      //
      // if (joinChatMessage.isConnected ?? false) {
      //   chatListEmmitter(
      //     perPage: 30,
      //     currentPage: 1,
      //
      //   );
      // }
    });
    socket?.off('send_message_listner');
    socket?.on('send_message_listner', (messages) {
      debugPrint("Listing......3");
      debugPrint("send_message_listner ${jsonEncode(messages.toString())}");
      try {
        ChatDetailController chatDetailController =
        Get.find<ChatDetailController>();
        ChatHistoryData receivedMessageDataModal =
        ChatHistoryData.fromJson(messages);

      // if ((receivedMessageDataModal.senderId?.userId.toString() ==
      //       (storage.read(userId))) ||
      //       (receivedMessageDataModal.receiverId?.userId.toString() ==
      //           (chatDetailController.receiverIdis.toString()))) {
          ChatHistoryData chatMessageItems = ChatHistoryData(
               userSendBy:receivedMessageDataModal.userSendBy,
               userReceiveBy:receivedMessageDataModal.userReceiveBy,
               msg:receivedMessageDataModal.msg,
           createdAt:receivedMessageDataModal.createdAt,
               referenceId:receivedMessageDataModal.referenceId,
               readOn: receivedMessageDataModal.readOn,
               // message:receivedMessageDataModal.,
              // msg: receivedMessageDataModal.message,
              // userSendBy: receivedMessageDataModal.senderId?.userId ,
              // userReceiveBy:receivedMessageDataModal.receiverId?.userId,
            message:LastMessage(
                userSendBy:receivedMessageDataModal.userSendBy,
                userReceiveBy:receivedMessageDataModal.userReceiveBy,
                msg:receivedMessageDataModal.message?.msg??'',
                isRead:receivedMessageDataModal.message?.isRead??'',
                referenceId:receivedMessageDataModal.message?.referenceId,
            )
          );
          chatDetailController.chatHistory?.insert(0, chatMessageItems);
          chatDetailController.chatCatygory
              .insert(0, GroupChatElement(DateTime.now(), chatMessageItems));
        // }

        chatDetailController.update();
        } catch (e) {
        debugPrint(e.toString());
      }
    });

/*    socket?.on('send_message_listner_to', (messages) {
      print("Listing......3");
      print("send_message_listner_to ${jsonEncode(messages.toString())}");
      // addChatList(messages);
      try {
        ChatDetailController chatDetailController =
        Get.find<ChatDetailController>();
        ChatDetailResModel receivedMessageDataModal =
        ChatDetailResModel.fromJson(messages);

      if ((receivedMessageDataModal.senderId?.userId.toString() ==
            (storage.read(userId))) ||
            (receivedMessageDataModal.receiverId?.userId.toString() ==
                (chatDetailController.receiverIdis.toString()))) {
          // sendMessage(messageID: receivedMessageDataModal.messageID);
          ChatHistoryData chatMessageItems = ChatHistoryData(
              msg: receivedMessageDataModal.message,
              // storyId: receivedMessageDataModal.storyId,
              // storyLink: receivedMessageDataModal.storyLink,
              // messageThumbnail: receivedMessageDataModal.messageThumbnail,
              // messageType: receivedMessageDataModal.messageType,
              userSendBy: receivedMessageDataModal.senderId?.userId ,
              userReceiveBy:receivedMessageDataModal.receiverId?.userId,
              createdAt: "${DateTime.now()}");
          chatDetailController.chatHistory.insert(0, chatMessageItems);
          chatDetailController.chatCatygory
              .insert(0, GroupChatElement(DateTime.now(), chatMessageItems));
        }

        chatDetailController.update();
      } catch (e) {}
    });*/
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

  void connectUserEmitter() {
    debugPrint("user connected");
    socket?.emit('connect_user', {'user_id': storage.read(userId)});
  }

  void sendMessage(
      {required String senderId,
      required String receiverId,
      required String message,
      var refId,
      var isGroup,
      }) {
    if (socket != null && socket!.connected) {
      debugPrint("Message sent:---------- $message");
      socket?.emit('send_message', {
        'sender_id': senderId,
        'receiver_id': receiverId,
        'message': message,
        'reference_id':refId,
        'is_group':isGroup,
      });
      debugPrint("Message sent: $message ,receiverId: $receiverId,senderId : $senderId,refIf :$refId");
    } else {
      debugPrint("Socket is not connected");
    }
  }

  void onNewMessage(Function(dynamic) callback) {
    socket?.on('new_message', callback);
  }
}

