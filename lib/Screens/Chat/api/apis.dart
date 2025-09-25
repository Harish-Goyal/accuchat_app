import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:AccuChat/Screens/Chat/screens/auth/Presentation/Views/accept_invite_screen.dart';
import 'package:AccuChat/Screens/Chat/screens/auth/Presentation/Views/landing_screen.dart';
import 'package:AccuChat/Screens/Chat/screens/auth/Presentation/Views/login_screen.dart';
import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import '../../../Services/APIs/auth_service/auth_api_services_impl.dart';
import '../../../Services/APIs/local_keys.dart';
import '../../Home/Presentation/Controller/company_service.dart';
import '../../Home/Presentation/View/invite_member.dart';
import '../helper/notification_service.dart';
import '../models/chat_user.dart';
import '../models/company_model.dart';
import '../models/invite_model.dart';
import '../models/message.dart';

enum ChatType {
  oneToOne,
  group,
  broadcast,
}

class APIs {
  // for authentication
  // static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  // static FirebaseStorage storage = FirebaseStorage.instance;

  // to return current user
  // static User get user => auth.currentUser!;
  static UserDataAPI? get user => getUser();

  // static CompanyModel? selectedCompany;

  // for storing self information
  static UserDataAPI me = UserDataAPI(
      userId: user?.userId,
      userName: user?.userName,
      phone: user?.email,
      createdBy:user?.createdBy,
      isAdmin: user?.isAdmin,
      email: user?.email,
      about:user?.about,
      createdOn: user?.createdOn,
      isActive: user?.isActive,
      userImage: user?.userImage,
      userKey: user?.userKey,
      updatedOn: user?.updatedOn,
      allowedCompanies: user?.allowedCompanies,
      isDeleted: user?.isDeleted,
      userCompany: user?.userCompany,
      lastMessage: user?.lastMessage,
      memberCount: user?.memberCount,
      pendingCount: user?.pendingCount,
      invitedBy: user?.invitedBy,
      invitedOn: user?.invitedOn,
      joinedOn: user?.joinedOn,
      pushToken: user?.pushToken,
  );

  // streams in firebase cloud firestore
  // static Future<void> getSelfInfoProfile() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     final doc = await firestore.collection('users').doc(user.uid).get();
  //
  //     if (doc.exists) {
  //       APIs.me = ChatUser.fromJson(doc.data()!);
  //     }
  //   }
  // }

/*  static String getConversationIDTask(String id1, String id2) =>
      id1.hashCode <= id2.hashCode ? '${id1}_$id2' : '${id2}_$id1';*/

  // for accessing firebase messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission(alert: true,
      badge: true,
      sound: true,);

    await fMessaging.getToken().then((t) async {
      if (t != null) {
        me.pushToken = t;
      }
    });

    // for handling foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  static Future<String?> getTargetToken({String? email, String? phone}) async {
    // if ((email == null || email == 'null' || email.isEmpty) &&
    //     (phone == null || phone == 'null' || phone.isEmpty)) {
    //   print("❌ Error: Provide either email or phone");
    //   return null;
    // }

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('users');

    if (email != null && email != 'null' && email.isNotEmpty) {
      query = query.where('email', isEqualTo: email);
    } else if (phone != null && phone != 'null' && phone.isNotEmpty) {
      query = query.where('phone', isEqualTo: phone);
    }

    final snap = await query.limit(1).get();
    if (snap.docs.isNotEmpty) {
      final data = snap.docs.first.data();
      print("✅ Target user found with token: ${data['push_token']}");
      return data['push_token'];
    } else {
      print("❌ User not found for email/phone");
      return null;
    }
  }

  static Future<void> sendPushNotification(
      UserDataAPI chatUser,
      String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken ,
        "notification": {
          "title": me.userName??'', //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
        // "data": {
        //   "some_data": "User ID: ${me.id}",
        // },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
            'key=BJt_tuDwKCr6OR8Gibo9KMKsJfSjB3rje9fn7Q31qGPyxAi9SKF11kf8HYOd__Zo7Wubg_xgbhkZzykxRojmN9g'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }


  static Future<String?> getPushTokenByUserId(String userId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (snap.exists) {
        return snap.data()?['push_token'];
      }
    } catch (e) {
      print('❌ Error getting push token: $e');
    }
    return null;
  }

  static Future<void> getSelfInfo() async {
    final svc = Get.find<CompanyService>();
    final myCompany =svc.selected;
    Get.find<AuthApiServiceImpl>()
        .getUserApiCall(companyId: myCompany?.companyId??0)
        .then((value) async {
      me = value.data!;
      await getFirebaseMessagingToken();
    }).onError((error, stackTrace) {

    });
  }

  /* static Future<void> sendThreadMessage({
    required String conversationId,
    required String taskMessageId,
    ChatUser? chatUser,
    String? msg,
    Type? type,
  }) async {
    final ref = firestore.collection(
        'chats/${APIs.getConversationID(
            conversationId)}/messages/$taskMessageId/threads/');
    try {
      final time = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();
      final Message message = Message(
        toId: conversationId,
        fromId: APIs.me.id,
        msg: msg ?? '',
        companyId: me.selectedCompany?.id??'',
        read: '',
        typing: false,
        type: type ?? Type.text,
        sent: time,
        originalSenderId: APIs.me.id,
        originalSenderName: user.displayName,
        forwardTrail: [],
        isTask: false,
        createdAt: time,
      );

      await ref.doc(message.sent).set(message.toJson());
    } catch (e) {
      debugPrint('❌ Failed to send thread message: $e');
    }
  }




  static Stream<QuerySnapshot<Map<String, dynamic>>> getTaskThreads(
      String conversationId, String taskMessageId) {
    return firestore
        .collection(
        'chats/${APIs.getConversationID(
            conversationId)}/messages/$taskMessageId/threads/')
        .where('companyId', isEqualTo: me.selectedCompany?.id)
        .orderBy('sent', descending: true)
        .snapshots();
  }*/

  // for sending push notification


  // for checking if user exists or not?
/*  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<bool> isUserExits() async {
    final userEx = await firestore.collection('users').doc(user.uid).get();
    return userEx.exists;
  }

  // for adding an chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists

      log('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }*/

  // for getting current user info


  // for creating a new user
//   static Future<void> createUser() async {
//     final time = DateTime
//         .now()
//         .millisecondsSinceEpoch
//         .toString();
//
//     try {
//       final chatUser = ChatUser(
//           id: user.uid,
//           name: user.displayName.toString(),
//           email: user.email.toString() ?? '',
//           phone: user.phoneNumber.toString(),
//           about: "Hey, I'm using AccuChat!",
//           image: user.photoURL.toString(),
//           createdAt: time,
//           isOnline: false,
//           isTyping: false,
//           lastActive: time,
//           pushToken: '',
//           lastMessageTime: '',
//           xStikers: '', role: '',
//           company: null,
//         companyIds: []
//       );
//
//       return await firestore
//           .collection('users')
//           .doc(user.uid)
//           .set(chatUser.toJson());
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//   }
//
//   // for getting id's of known users from firestore database
//   static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
//     return firestore
//         .collection('users')
//         .doc(user.uid)
//         .collection('my_users')
//         .snapshots();
//   }
//
//   static Future<ChatUser?> getUserById(String userId) async {
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId)
//           .get();
//
//       if (doc.exists) {
//         return ChatUser.fromJson(doc.data()!);
//       } else {
//         return null; // No user found
//       }
//     } catch (e) {
//       return null;
//     }
//   }
//
//
//   static Future<void> forwardMessage({
//     required Message originalMessage,
//     required String toId,
//     required ChatType type, // user / group / broadcast
//   }) async {
//     final time = DateTime
//         .now()
//         .millisecondsSinceEpoch
//         .toString();
//
//     // Maintain trail
//     List<Map<String, String>> trail = [];
//
//     // If the message is already forwarded before, preserve its trail
//     if (originalMessage.forwardTrail != null) {
//       trail = List<Map<String, String>>.from(originalMessage.forwardTrail!);
//     }
//
//     // Add current user to trail
//     trail.add({'id': APIs.me.id, 'name': APIs.me.name});
//
//     final msg = Message(
//       fromId: APIs.me.id,
//       toId: toId,
//       msg: originalMessage.msg,
//       read: '',
//       typing: false,
//       type: originalMessage.type,
//       sent: time,
//       companyId: me.selectedCompany?.id??'',
//       createdAt: time,
//       originalSenderId:
//       originalMessage.originalSenderId ?? originalMessage.fromId,
//       originalSenderName: originalMessage.originalSenderName ?? APIs.me.name,
//       forwardTrail: trail,
//     );
//
//     // Store message depending on type
//     if (type == ChatType.oneToOne) {
//       await firestore
//           .collection('chats/${getConversationID(toId)}/messages')
//           .doc(time)
//           .set(msg.toJson());
//     } else if (type == ChatType.group) {
//       await firestore
//           .collection('groups/$toId/messages')
//           .doc(time)
//           .set(msg.toJson());
//     }
//   }
//
// /*  static Future<void> sendForwardedMessage(ChatUser receiver, Message msg) async {
//     final ref = firestore
//         .collection('chats/${getConversationID(receiver.id)}/messages');
//     await ref.doc(msg.sent).set(msg.toJson());
//     // Also ensure both users are added to each other's my_users
//     await firestore.collection('users/${receiver.id}/my_users').doc(user.uid).set({});
//     await firestore.collection('users/${user.uid}/my_users').doc(receiver.id).set({});
//   }*/
//   static Future<void> sendForwardedMessage(ChatUser chatUser,
//       Message message) async {
//     final time = DateTime
//         .now()
//         .millisecondsSinceEpoch
//         .toString();
//     final convID = getConversationID(chatUser.id);
//     final ref = firestore.collection('chats/$convID/messages/');
//     await ref.doc(time).set(message.toJson());
//     // add in both my_users
//     await firestore
//         .collection('users')
//         .doc(user.uid)
//         .update({'last_active': time}); // user = APIs.me
//
//     await firestore
//         .collection('users')
//         .doc(chatUser.id)
//         .update({'last_active': time});
//     await firestore
//         .collection('users/${user.uid}/my_users')
//         .doc(chatUser.id)
//         .set({});
//
//     // ✅ Also add CURRENT user to chatUser's my_users
//     await firestore
//         .collection('users/${chatUser.id}/my_users')
//         .doc(user.uid)
//         .set({});
//   }
//
// /*  static Future<List<ChatUser>> fetchAllUsers() async {
//     try {
//       final snapshot = await firestore
//           .collection('users')
//           .where('id', isNotEqualTo: APIs.me.id)
//           .get();
//
//       return snapshot.docs.map((doc) => ChatUser.fromJson(doc.data())).toList();
//     } catch (e, s) {
//       print("❌ Error in fetchAllUsers: $e");
//       print("📍 Stack trace: $s");
//       return [];
//     }
//   }*/
//
//   // for getting all users from firestore database
//  /* static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
//       List<String> userIds) {
//     log('\nUserIds: $userIds');
//
//     if (userIds.isEmpty) {
//       return const Stream.empty();
//     }
//
//     return firestore
//         .collection('users')
//         .where('id', whereIn: userIds)
//         .snapshots();
//
//     *//*return firestore
//         .collection('users')
//
//         .where('id', isNotEqualTo: user.uid)
//         .snapshots()*//*
//   }*/
//
//   static Future<List<String>> getAllUserIdsFromChats(String myId) async {
//     final snapshot = await firestore.collection('chats').get();
//
//     final userIds = <String>{};
//
//     for (var doc in snapshot.docs) {
//       final chatId = doc.id;
//
//       // split the ID and extract the other user
//       final parts = chatId.split('_');
//       if (parts.length == 2) {
//         final id1 = parts[0];
//         final id2 = parts[1];
//
//         if (id1 == myId) {
//           userIds.add(id2);
//         } else if (id2 == myId) {
//           userIds.add(id1);
//         }
//       }
//     }
//
//     return userIds.toList();
//   }
//
//   // for adding an user to my user when first message is send
// /*
//   static Future<void> sendFirstMessage(
//       ChatUser chatUser, String msg, Type type) async {
//     await firestore
//         .collection('users')
//         .doc(chatUser.id)
//         .collection('my_users')
//         .doc(user.uid)
//         .set({}).then((value) => sendMessage(chatUser, msg, type));
//   }
// */
//   static Future<void> sendFirstMessage(ChatUser chatUser,
//       String msg,
//       Type type, {
//         replyToMsg = '',
//         replyToSenderName = '',
//         replyToType,
//         isTask = false,
//         TaskDetails? taskDetails,
//         taskStartTime,
//       }) async {
//     final userDoc = firestore.collection('users').doc(chatUser.id);
//     print("chatUser.id====");
//     print(chatUser.id);
//
//     try {
//       // Check if chat user exists in DB
//       final docSnapshot = await userDoc.get();
//
//       if (!docSnapshot.exists) {
//         await userDoc.set({
//           'name': chatUser.name,
//           'email': chatUser.email,
//           'about': chatUser.about,
//           'image': chatUser.image,
//           'companyId': chatUser.selectedCompany?.id??'',
//           'createdAt': DateTime.now().toIso8601String(),
//           'isOnline': false,
//           'lastActive': DateTime
//               .now()
//               .millisecondsSinceEpoch
//               .toString(),
//           'pushToken': '',
//         });
//       }
//
//       // ✅ Add chatUser to CURRENT user's my_users
//       // await firestore
//       //     .collection('users/${user.uid}/my_users')
//       //     .doc(chatUser.id)
//       //     .set({});
//       //
//       // // ✅ Also add CURRENT user to chatUser's my_users
//       // await firestore
//       //     .collection('users/${chatUser.id}/my_users')
//       //     .doc(user.uid)
//       //     .set({});
//       await firestore
//           .collection('users')
//           .doc(chatUser.id)
//           .collection('my_users')
//           .doc(user.uid)
//           .set({});
//       await firestore
//           .collection('users')
//           .doc(user.uid)
//           .collection('my_users')
//           .doc(chatUser.id)
//           .set({});
//       // Send message
//       !isTask
//           ? await sendMessage(chatUser, msg,
//           type /*,replyToMsg: replyToMsg,
//           replyToSenderName: replyToSenderName,
//           replyToType: replyToType*/
//       )
//           : await sendMessage(chatUser, msg, type,
//           isTask: isTask, taskDetails: taskDetails);
//     } catch (e, stack) {
//       print('❌ Error in sendFirstMessage: $e');
//       print('📍 Stack trace: $stack');
//     }
//   }
//
//   // for updating user information
//   static Future<void> updateUserInfo(name,email,phone,about) async {
//     await firestore.collection('users').doc(user.uid).update({
//       'name': name,
//       'about':about,
//       'phone': phone,
//       'email':email,
//     });
//   }
//
//   // update profile picture of user
//   static Future<void> updateProfilePicture(File file) async {
//     //getting image file extension
//     final ext = file.path
//         .split('.')
//         .last;
//     log('Extension: $ext');
//
//     //storage file ref with path
//     final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
//
//     //uploading image
//     await ref
//         .putFile(file, SettableMetadata(contentType: 'image/$ext'))
//         .then((p0) {
//       log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
//     });
//
//     //updating image in firestore database
//     me.image = await ref.getDownloadURL();
//     await firestore
//         .collection('users')
//         .doc(user.uid)
//         .update({'image': me.image});
//   }
//
//   // for getting specific user info
//   static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
//       ChatUser chatUser) {
//     return firestore
//         .collection('users')
//         .where('id', isEqualTo: chatUser.id)
//         .snapshots();
//   }
//
//   // update online or last active status of user
//   static Future<void> updateActiveStatus(bool isOnline) async {
//     firestore.collection('users').doc(user.uid).set({
//       'is_online': isOnline,
//       'last_active': DateTime
//           .now()
//           .millisecondsSinceEpoch
//           .toString(),
//       'push_token': me.pushToken,
//     }, SetOptions(merge: true));
//   }
//
//   // update typing status of user
//   static Future<void> updateTypingStatus(bool isTyping) async {
//     firestore.collection('users').doc(user.uid).set({
//       'is_typing': isTyping,
//     }, SetOptions(merge: true));
//   }
//
//   ///************** Tasks_Chat Screen Related APIs **************
//
//   // chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)
//
//   // useful for getting conversation id
//   static String getConversationID(String id) =>
//       user.uid.hashCode <= id.hashCode
//           ? '${user.uid}_$id'
//           : '${id}_${user.uid}';
//
//   // for getting all messages of a specific conversation from firestore database
//   static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
//       ChatUser user) {
//     return firestore
//         .collection('chats/${getConversationID(user.id)}/messages/')
//         .orderBy('sent', descending: true)
//         .snapshots();
//   }
//
//   // for sending message
// /*  static Future<void> sendMessage(
//       ChatUser chatUser, String msg, Type type) async {
//     //message sending time (also used as id)
//     final time = DateTime.now().millisecondsSinceEpoch.toString();
//
//     //message to send
//     final Message message = Message(
//         toId: chatUser.id,
//         msg: msg,
//         read: '',
//         typing: false,
//         type: type,
//         fromId: user.uid,
//
//         sent: time);
//
//     final ref = firestore
//         .collection('chats/${getConversationID(chatUser.id)}/messages/');
//     await ref.doc(time).set(message.toJson()).then((value) =>
//         sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
//   }*/
//
//   static Future<void> sendMessage(ChatUser chatUser,
//       String msg,
//       Type type, {
//         String replyToMsg = '',
//         String replyToSenderName = '',
//         replyToType,
//         isTask = false,
//         TaskDetails? taskDetails,
//         taskStartTime,
//       }) async {
//     final time = DateTime
//         .now()
//         .millisecondsSinceEpoch
//         .toString();
//     final Message message = Message(
//         toId: chatUser.id,
//         msg: msg,
//         read: '',
//         typing: false,
//         type: type,
//         fromId: user.uid,
//         companyId: me.selectedCompany?.id??'',
//         sent: time,
//         replyToMsg: replyToMsg,
//         replyToSenderName: replyToSenderName,
//         replyToType: replyToType,
//         originalSenderId: user.uid,
//         originalSenderName: user.displayName,
//         forwardTrail: [],
//         isTask: isTask,
//         createdAt: time,
//         taskDetails: taskDetails,
//         taskStartTime: taskStartTime);
//
//     final ref = firestore
//         .collection('chats/${getConversationID(chatUser.id)}/messages/');
//
//     try {
//       await ref.doc(time).set(message.toJson());
//       await firestore
//           .collection('users')
//           .doc(user.uid)
//           .update({'last_active': time}); // user = APIs.me
//
//       await firestore
//           .collection('users')
//           .doc(chatUser.id)
//           .update({'last_active': time});
//
//       final token =chatUser.pushToken;
//       if (token != null && token != APIs.me.pushToken) {
//         if(!isTask) {
//           // await LocalNotificationService.showChatNotification(
//           //   title: '💬 New Message from ${APIs.me.name}',
//           //   body: msg??'',
//           // );
//           await NotificationService.sendMessageNotification(
//             targetToken: token,
//             senderName: APIs.me.name,
//             company: APIs.me.selectedCompany,
//             message: msg??'',
//           );
//         }else{
//
//           await NotificationService.sendTaskNotification(
//             targetToken: token,
//             assignerName: APIs.me.name,
//             company: APIs.me.selectedCompany,
//             taskSummary: taskDetails?.title??'',
//           );
//           // await LocalNotificationService.showTaskNotification(
//           //   title: '💬 New Task from ${APIs.me.name}',
//           //   body: taskDetails?.title??'',
//           // );
//         }
//       }
//     } catch (e, stack) {
//       print('❌ Error in sendMessage: $e');
//       print('📍 Stack trace: $stack');
//     }
//   }



  // static Future<void> sendTaskMessage({
  //   required ChatUser chatUser,
  //   required String title,
  //   required String description,
  //   required String? estimatedTime,
  // }) async {
  //   final String time = DateTime
  //       .now()
  //       .millisecondsSinceEpoch
  //       .toString();
  //   Map<String, dynamic> data = {
  //     'title': title,
  //     'description': description,
  //     'estimatedTime':
  //     estimatedTime ?? DateTime
  //         .now()
  //         .millisecondsSinceEpoch
  //         .toString(),
  //   };
  //   // Construct taskDetails map
  //   final taskDetails = TaskDetails.fromJson(data);
  //
  //   // Create full message object just like sendMessage()
  //   final Message message = Message(
  //     toId: chatUser.id,
  //     msg: "$title\n$description",
  //     read: '',
  //     typing: false,
  //     type: Type.text,
  //     fromId: user.uid,
  //     sent: time,
  //     replyToMsg: '',
  //     companyId: me.selectedCompany?.id??'',
  //     replyToSenderName: '',
  //     replyToType: null,
  //     originalSenderId: user.uid,
  //     originalSenderName: user.displayName ?? '',
  //     forwardTrail: [],
  //     isTask: true,
  //     createdAt: time,
  //     taskDetails: taskDetails,
  //     taskStartTime: DateTime.now().toIso8601String(),
  //   );
  //
  //   final ref = firestore
  //       .collection('chats/${getConversationID(chatUser.id)}/messages/');
  //
  //   try {
  //     await ref.doc(time).set(message.toJson());
  //
  //     await firestore
  //         .collection('users')
  //         .doc(user.uid)
  //         .update({'last_active': time});
  //
  //     await firestore
  //         .collection('users')
  //         .doc(chatUser.id)
  //         .update({'last_active': time});
  //     await sendPushNotification(chatUser, "$title\n$description");
  //     print('✅ Task message sent successfully');
  //   } catch (e, stack) {
  //     print('❌ Error in sendTaskMessage: $e');
  //     print('📍 Stack trace: $stack');
  //   }
  // }
  //
  // //update read status of message
  // static Future<void> updateMessageReadStatus(Message message) async {
  //   firestore
  //       .collection('chats/${getConversationID(message.fromId)}/messages/')
  //       .doc(message.sent)
  //       .set({
  //     'read': DateTime
  //         .now()
  //         .millisecondsSinceEpoch
  //         .toString(),
  //   }, SetOptions(merge: true));
  // }
  //
  //
  // static Future<void> deleteRecantUserAndChat(chatUserID)async{
  //   final batch = FirebaseFirestore.instance.batch();
  //   final firestore = FirebaseFirestore.instance;
  //   try {
  //     await firestore
  //         .collection('users')
  //         .doc(chatUserID)
  //         .collection('my_users')
  //         .doc(user.uid)
  //         .delete();
  //
  //     // 2. Optionally remove from your own my_users (if it's mutual)
  //     await firestore
  //         .collection('users')
  //         .doc(user.uid)
  //         .collection('my_users')
  //         .doc(chatUserID)
  //         .delete();
  //       print("user removed success");
  //
  //   }
  //   catch(e){
  //     debugPrint(e.toString());
  //   }
  //   try {
  //     final conversationId = APIs
  //         .getConversationID(
  //         chatUserID);
  //     // Step 2: Delete all messages in the subcollection
  //     final messagesRef = firestore
  //         .collection('chats')
  //         .doc(conversationId)
  //         .collection('messages');
  //
  //     final messagesSnap = await messagesRef.get();
  //     for (final doc in messagesSnap.docs) {
  //       await doc.reference.delete();
  //     }
  //
  //     // Step 3: Delete the parent chat document
  //     await firestore.collection('chats').doc(conversationId).delete();
  //     print("chatss removed success");
  //   }catch(e){
  //     debugPrint(e.toString());
  //   }
  //
  //
  //   await batch.commit();
  // }
  //
  //
  //
  // //update read status of message
  // static Future<void> updateTaskStatus(Message message, result, userid) async {
  //   try {
  //     firestore
  //         .collection('chats/${APIs.getConversationID(userid)}/messages/')
  //         .doc(message.sent)
  //         .update({
  //       'taskDetails.status': result,
  //     }); // ✅ Use update instead of set
  //     toast('Task marked as ${result
  //         .toString()
  //         .capitalizeFirst}');
  //   } catch (e) {
  //     errorDialog('Firebase Error ${e.toString()}');
  //   }
  // }
  //
  // //get only last message of a specific chat
  // static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
  //     ChatUser user) {
  //   return firestore
  //       .collection('chats/${getConversationID(user.id)}/messages/')
  //   // .where('isTask', isEqualTo: false)
  //       .orderBy('sent', descending: true)
  //       .limit(1)
  //       .snapshots();
  // }
  //
  // static Stream<QuerySnapshot<Map<String, dynamic>>> getTaskLastMessage(
  //     ChatUser user) {
  //   return firestore
  //       .collection('chats/${getConversationID(user.id)}/messages/')
  //       .where('companyId', isEqualTo: APIs.me.selectedCompany?.id)
  //       .where('isTask', isEqualTo: true)
  //       .orderBy('sent', descending: true)
  //       .limit(1)
  //       .snapshots();
  // }
  //
  // static Stream<QuerySnapshot<Map<String, dynamic>>> getChatLastMessage(
  //     ChatUser user) {
  //   return firestore
  //       .collection('chats/${getConversationID(user.id)}/messages/')
  //       .where('companyId', isEqualTo: APIs.me.selectedCompany?.id)
  //       .where('isTask', isEqualTo: false)
  //       .orderBy('sent', descending: true)
  //       .limit(1)
  //       .snapshots();
  // }
  //
  // static Stream<QuerySnapshot<Map<String, dynamic>>> getBroadcastLastMessage(
  //     BroadcastChat user) {
  //   return firestore
  //       .collection('broadcasts/${getConversationID(user.id)}/messages/')
  //       .where('companyId', isEqualTo: APIs.me.selectedCompany?.id)
  //       .where('isTask', isEqualTo: false)
  //       .orderBy('sent', descending: true)
  //       .limit(1)
  //       .snapshots();
  // }
  //
  // //get only last message of a specific chat
  // static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessageGroup(
  //     ChatGroup user) {
  //   return firestore
  //       .collection('groups')
  //       .doc(user.id)
  //       .collection('messages')
  //       .where('companyId', isEqualTo: APIs.me.selectedCompany?.id)
  //       .orderBy('sent', descending: true)
  //       .limit(1)
  //       .snapshots();
  // }
  //
  // //send chat image
  // static Future<void> sendChatImage(ChatUser chatUser, File file) async {
  //   //getting image file extension
  //   final ext = file.path
  //       .split('.')
  //       .last;
  //
  //   //storage file ref with path
  //   final ref = storage.ref().child(
  //       'images/${getConversationID(chatUser.id)}/${DateTime
  //           .now()
  //           .millisecondsSinceEpoch}.$ext');
  //
  //   //uploading image
  //   await ref
  //       .putFile(file, SettableMetadata(contentType: 'image/$ext'))
  //       .then((p0) {
  //     log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
  //   });
  //   await firestore
  //       .collection('users/${user.uid}/my_users')
  //       .doc(chatUser.id)
  //       .set({});
  //
  //   // ✅ Also add CURRENT user to chatUser's my_users
  //   await firestore
  //       .collection('users/${chatUser.id}/my_users')
  //       .doc(user.uid)
  //       .set({});
  //   //updating image in firestore database
  //   final imageUrl = await ref.getDownloadURL();
  //   await sendMessage(
  //     chatUser,
  //     imageUrl,
  //     Type.image,
  //   );
  // }
  //
  // static Future<void> sendChatImageGroup(ChatGroup chatUser, File file) async {
  //   //getting image file extension
  //   final ext = file.path
  //       .split('.')
  //       .last;
  //
  //   //storage file ref with path
  //   final ref = storage.ref().child(
  //       'images/${getConversationID(chatUser.id ?? '')}/${DateTime
  //           .now()
  //           .millisecondsSinceEpoch}.$ext');
  //
  //   //uploading image
  //   await ref
  //       .putFile(file, SettableMetadata(contentType: 'image/$ext'))
  //       .then((p0) {
  //     log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
  //   });
  //
  //   //updating image in firestore database
  //   final imageUrl = await ref.getDownloadURL();
  //   await sendGroupMessage(
  //     chatUser,
  //     imageUrl,
  //     Type.image,
  //   );
  // }
  //
  // static Future<void> sendChatImageBroadcast(BroadcastChat chatUser,
  //     File file) async {
  //   //getting image file extension
  //   final ext = file.path
  //       .split('.')
  //       .last;
  //
  //   //storage file ref with path
  //   final ref = storage.ref().child(
  //       'images/${getConversationID(chatUser.id ?? '')}/${DateTime
  //           .now()
  //           .millisecondsSinceEpoch}.$ext');
  //
  //   //uploading image
  //   await ref
  //       .putFile(file, SettableMetadata(contentType: 'image/$ext'))
  //       .then((p0) {
  //     log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
  //   });
  //   //updating image in firestore database
  //   final imageUrl = await ref.getDownloadURL();
  //   await sendBroadcastMessage(chatUser, imageUrl, Type.image);
  // }
  //
  // static Future<void> sendChatImageThread(ChatUser chatUser, File file,
  //     messageid) async {
  //   //getting image file extension
  //
  //   final ext = file.path
  //       .split('.')
  //       .last;
  //
  //   //storage file ref with path
  //   final ref = storage.ref().child(
  //       'images/${getConversationID(chatUser.id ?? '')}/${DateTime
  //           .now()
  //           .millisecondsSinceEpoch}.$ext');
  //
  //   //uploading image
  //   await ref
  //       .putFile(file, SettableMetadata(contentType: 'image/$ext'))
  //       .then((p0) {
  //     log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
  //   });
  //
  //   //updating image in firestore database
  //   final imageUrl = await ref.getDownloadURL();
  //   await sendThreadMessage(
  //       conversationId: chatUser.id,
  //       taskMessageId: messageid,
  //       msg: imageUrl,
  //       type: Type.image);
  //   await sendPushNotification(chatUser, 'image');
  // }
  //
  // //Send chat videos
  // static Future<void> sendChatVideo(ChatUser chatUser, File videoFile) async {
  //   final videoExt = videoFile.path
  //       .split('.')
  //       .last;
  //
  //   //storage file ref with path
  //   final ref = storage.ref().child(
  //       'images/${getConversationID(chatUser.id)}/${DateTime
  //           .now()
  //           .millisecondsSinceEpoch}.$videoExt');
  //
  //   //uploading image
  //   await ref
  //       .putFile(videoFile, SettableMetadata(contentType: 'video/$videoExt'))
  //       .then((p0) {
  //     log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
  //   });
  //   //updating video in firestore database
  //   final videoUrls = await ref.getDownloadURL();
  //   await sendMessage(chatUser, videoUrls, Type.video);
  // }
  //
  // //delete message
  // static Future<void> deleteMessage(Message message) async {
  //   await firestore
  //       .collection('chats/${getConversationID(message.toId)}/messages/')
  //       .doc(message.sent)
  //       .delete();
  //   if (message.type == Type.image) {
  //     await storage.refFromURL(message.msg).delete();
  //   }
  // }
  //
  // //delete message
  // static Future<void> deleteForMeMessage(String chatRoomID,
  //     Message message) async {
  //   await firestore
  //       .collection('chats/${getConversationID(message.fromId)}/messages/')
  //       .doc(message.sent)
  //       .delete();
  //
  //   if (message.type == Type.image) {
  //     await storage.refFromURL(message.msg).delete();
  //   }
  // }
  //
  // //update message
  // static Future<void> updateMessage(Message message, String updatedMsg) async {
  //   await firestore
  //       .collection('chats/${getConversationID(message.toId)}/messages/')
  //       .doc(message.sent)
  //       .set({'msg': updatedMsg}, SetOptions(merge: true));
  // }
  //
  // //update message
  // static Future<void> updateThreadMessage(Message message,
  //     String updatedMsg) async {
  //   await firestore
  //       .collection('chats/${getConversationID(message.toId)}/messages/')
  //       .doc(message.sent)
  //       .set({'msg': updatedMsg}, SetOptions(merge: true));
  // }
  //
  // static Future<void> updateTaskMessage({
  //   required Message message,
  //   required String updatedTitle,
  //   required String updatedDescription,
  //   String? updatedEstimatedTime, // optional
  // }) async {
  //   try {
  //     final taskDetailsMap = {
  //       'title': updatedTitle,
  //       'description': updatedDescription,
  //     };
  //
  //     if (updatedEstimatedTime != null) {
  //       taskDetailsMap['estimatedTime'] = updatedEstimatedTime;
  //     }
  //
  //     // Build fallback updated message text
  //     final fallbackMsg = "$updatedTitle\n$updatedDescription";
  //
  //     await firestore
  //         .collection('chats/${getConversationID(message.toId)}/messages/')
  //         .doc(message.sent)
  //         .set({
  //       'createdAt': DateTime
  //           .now()
  //           .millisecondsSinceEpoch
  //           .toString(),
  //       'taskDetails': taskDetailsMap,
  //     }, SetOptions(merge: true));
  //
  //     print('✅ Task message updated');
  //   } catch (e) {
  //     print('❌ Error updating task: $e');
  //   }
  // }
  //
  // static Future<int> getPendingTaskCount(String id) async {
  //   final querySnapshot = await firestore
  //       .collection('chats/${getConversationID(id)}/messages/')
  //       .where('isTask', isEqualTo: true)
  //       .where('taskDetails.status', isEqualTo: 'Pending')
  //       .get();
  //
  //   return querySnapshot.docs.length;
  // }
  //
  // static Future<int> getThreadConversationTaskCount(String id,
  //     taskMessageId) async {
  //   final querySnapshot = await firestore
  //       .collection(
  //       'chats/${getConversationID(id)}/messages/$taskMessageId/threads/')
  //       .get();
  //
  //   return querySnapshot.docs.length;
  // }
  //
  // // send stickers
  // static Future<void> uploadSticker(ChatUser chatUser, File stickerFile) async {
  //   final ext = stickerFile.path
  //       .split('.')
  //       .last;
  //   log('Extension: $ext');
  //   final Reference storageReference = storage.ref().child(
  //       'stickers/${getConversationID(chatUser.id)}/${DateTime
  //           .now()
  //           .millisecondsSinceEpoch}.$ext');
  //   //uploading stickers to storage cloud
  //   await storageReference
  //       .putFile(stickerFile, SettableMetadata(contentType: 'stickers/$ext'))
  //       .then((p0) {
  //     log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
  //   });
  //
  //   //updating stickers in firestore database
  //   me.xStikers = await storageReference.getDownloadURL();
  //   await firestore
  //       .collection('users')
  //       .doc(user.uid)
  //       .update({'xStikers': me.xStikers});
  // }
  //
  // static Future<void> createGroup({
  //   required String name,
  //   required String createdById,
  //   required String companyId,
  // }) async {
  //   final groupId = firestore
  //       .collection('groups')
  //       .doc()
  //       .id;
  //   final timestamp = DateTime
  //       .now()
  //       .millisecondsSinceEpoch
  //       .toString();
  //
  //   final group = ChatGroup(
  //     id: groupId,
  //     name: name,
  //     image: '',
  //     companyId: companyId,
  //     createdBy: createdById,
  //     createdAt: timestamp,
  //     admins: [createdById],
  //     lastMessage: '',
  //     lastMessageTime: timestamp,
  //     lastActive: timestamp,
  //     members: [createdById],
  //   );
  //
  //   try {
  //     await firestore.collection('groups').doc(groupId).set(group.toJson());
  //
  //     Get.back();
  //   } catch (e) {
  //     print('📍 Stack trace: $e');
  //   }
  // }
  //
  // static Stream<QuerySnapshot<Map<String, dynamic>>> getGroups() {
  //   return firestore
  //       .collection('groups')
  //       .where('companyId', isEqualTo: me.selectedCompany?.id)
  //       .orderBy('createdAt', descending: true)
  //       .snapshots();
  // }
  //
  // static Stream<QuerySnapshot<Map<String, dynamic>>> getBroadcast() {
  //   return firestore
  //       .collection('broadcasts')
  //       .where('companyId', isEqualTo: me.selectedCompany?.id)
  //       .orderBy('createdAt', descending: true)
  //       .snapshots();
  // }
  //
  // static Stream<QuerySnapshot<Map<String, dynamic>>> getOnlyChatMessages(
  //     String userid) {
  //   return firestore
  //       .collection('chats/${getConversationID(userid)}/messages/')
  //       .where('isTask', isEqualTo: false)
  //       .where('companyId', isEqualTo: me.selectedCompany?.id)
  //       .orderBy('sent', descending: true)
  //       .snapshots();
  // }
  //
  // static Stream<QuerySnapshot<Map<String, dynamic>>> getOnlyTaskMessages(
  //     String userid) {
  //   return firestore
  //       .collection('chats/${getConversationID(userid)}/messages/')
  //       .where('isTask', isEqualTo: true)
  //       .where('companyId', isEqualTo: me.selectedCompany?.id)
  //       .orderBy('sent', descending: true)
  //       .snapshots();
  // }
  //
  // static Stream<QuerySnapshot<Map<String, dynamic>>> getGroupMembers(
  //     String groupId) async* {
  //   try {
  //     final docSnapshot =
  //     await firestore.collection('groups').doc(groupId).get();
  //     final data = docSnapshot.data();
  //
  //     if (data == null || data['members'] == null) {
  //       yield* const Stream.empty();
  //       return;
  //     }
  //
  //     final List<String> memberIds = List<String>.from(data['members']);
  //
  //     yield* firestore
  //         .collection('users')
  //         .where('id', whereIn: memberIds.isEmpty ? ['null'] : memberIds)
  //         .snapshots();
  //   } catch (e, s) {
  //     print('🔥 Error in getGroupMembers: $e');
  //     print('📍 Stack trace: $s');
  //     yield* const Stream.empty();
  //   }
  // }
  //
  // static Stream<QuerySnapshot<Map<String, dynamic>>> getBroadcastsMembers(
  //     String id) async* {
  //   try {
  //     final docSnapshot =
  //     await firestore.collection('broadcasts').doc(id).get();
  //     final data = docSnapshot.data();
  //
  //     if (data == null || data['members'] == null) {
  //       yield* const Stream.empty();
  //       return;
  //     }
  //
  //     final List<String> memberIds = List<String>.from(data['members']);
  //
  //     yield* firestore
  //         .collection('users')
  //         .where('id', whereIn: memberIds.isEmpty ? ['null'] : memberIds)
  //         .snapshots();
  //   } catch (e, s) {
  //     print('🔥 Error in getGroupMembers: $e');
  //     print('📍 Stack trace: $s');
  //     yield* const Stream.empty();
  //   }
  // }
  //
  // static Future<void> sendGroupMessage(ChatGroup group, String msg, Type type,
  //     {replyToMsg = '', replyToSenderName = '', replyToType}) async {
  //   try {
  //     final time = DateTime
  //         .now()
  //         .millisecondsSinceEpoch
  //         .toString();
  //     final currentUser = FirebaseAuth.instance.currentUser!;
  //
  //     final message = Message(
  //         toId: group.id ?? '',
  //         msg: msg,
  //         read: '',
  //         typing: false,
  //         type: type,
  //         fromId: currentUser.uid,
  //         sent: time,
  //         companyId: me.selectedCompany?.id??'',
  //         replyToMsg: replyToMsg,
  //         replyToSenderName: replyToSenderName,
  //         replyToType: replyToType,
  //         originalSenderId: user.uid,
  //         originalSenderName: user.displayName,
  //         createdAt: time,
  //         forwardTrail: []);
  //
  //     await firestore
  //         .collection('groups/${group.id}/messages')
  //         .doc(time)
  //         .set(message.toJson());
  //
  //     await firestore.collection('groups').doc(group.id).update({
  //       'lastMessage': msg,
  //       'lastMessageTime': time,
  //     });
  //   } catch (e, s) {
  //     print('🔥 Error sending group message: $e');
  //     print('📍 Stack trace: $s');
  //   }
  // }
  //
  // static Future<void> sendBroadcastMessage(BroadcastChat chat, String msg,
  //     Type type,
  //     {replyToMsg = '', replyToSenderName = '', replyToType}) async {
  //   final time = DateTime
  //       .now()
  //       .millisecondsSinceEpoch
  //       .toString();
  //
  //   final message = Message(
  //       fromId: APIs.me.id,
  //       toId: '',
  //       msg: msg,
  //       companyId: me.selectedCompany?.id??'',
  //       read: '',
  //       typing: false,
  //       type: type,
  //       sent: time,
  //       replyToMsg: replyToMsg,
  //       replyToSenderName: replyToSenderName,
  //       replyToType: replyToType,
  //       originalSenderId: user.uid,
  //       originalSenderName: user.displayName,
  //       forwardTrail: [],
  //       createdAt: time);
  //
  //   try {
  //     // 1. Save to broadcasts/{id}/messages/
  //     await firestore
  //         .collection('broadcasts/${chat.id}/messages')
  //         .doc(time)
  //         .set(message.toJson());
  //
  //     // 2. Fan-out to members (only write messages, don't modify my_users!)
  //     for (String uid in chat.members) {
  //       final convID = getConversationID(uid);
  //       final ref = firestore.collection('chats/$convID/messages');
  //
  //       await ref.doc(time).set(message.toJson());
  //       await firestore
  //           .collection('users')
  //           .doc(uid)
  //           .update({'last_active': time});
  //     }
  //
  //     // 3. Update broadcast metadata
  //     await firestore.collection('broadcasts').doc(chat.id).update({
  //       'lastMessage': msg,
  //       'lastMessageTime': time,
  //     });
  //
  //     print("✅ Broadcast message sent to ${chat.members.length} users");
  //   } catch (e, s) {
  //     print("❌ sendBroadcastMessage error: $e");
  //     print("📍 Stack trace: $s");
  //   }
  // }
  //
  // static Stream<QuerySnapshot<Map<String, dynamic>>> getGroupMessages(
  //     String groupId) async* {
  //   try {
  //     yield* firestore
  //         .collection('groups')
  //         .doc(groupId)
  //         .collection('messages')
  //         .where('companyId', isEqualTo: me.selectedCompany?.id)
  //         .orderBy('sent', descending: true)
  //         .snapshots();
  //   } catch (e, s) {
  //     print('🔥 Error in getGroupMessages: $e');
  //     print('📍 Stack trace: $s');
  //     yield* const Stream.empty();
  //   }
  // }
  //
  // static Stream<QuerySnapshot<Map<String, dynamic>>> getBroadcastMessages(
  //     String broadcastId) {
  //   return firestore
  //       .collection('broadcasts/$broadcastId/messages')
  //       .where('companyId', isEqualTo: me.selectedCompany?.id)
  //       .orderBy('sent', descending: true)
  //       .snapshots();
  // }
  //
  // static Future<void> addMemberToBroadcast(String broadcastId, uidToAdd) async {
  //   /*final doc = firestore.collection('broadcasts').doc(broadcastId);
  //   await doc.update({
  //     'members': FieldValue.arrayUnion([uidToAdd])
  //   });*/
  //
  //   try {
  //     final broadRef = firestore.collection('broadcasts').doc(broadcastId);
  //     final doc = await broadRef.get();
  //     final data = doc.data();
  //     if (data != null) {
  //       List<String> existing = List<String>.from(data['members'] ?? []);
  //       List<String> updated =
  //       existing.toSet().union(uidToAdd.toSet()).toList();
  //       await broadRef.update({'members': updated});
  //       Get.back();
  //     }
  //   } catch (e, s) {
  //     print('Error adding members: $e');
  //     print('Stack trace: $s');
  //   }
  // }
  //
  // static Future<void> removeMemberFromBroadcast(String broadcastId,
  //     String uidToRemove) async {
  //   final doc = firestore.collection('broadcasts').doc(broadcastId);
  //   await doc.update({
  //     'members': FieldValue.arrayRemove([uidToRemove])
  //   });
  // }
  //
  // static Future<void> addMembersToGroup(groupid, selecteduderid) async {
  //   try {
  //     final groupRef = firestore.collection('groups').doc(groupid);
  //     final doc = await groupRef.get();
  //     final data = doc.data();
  //     if (data != null) {
  //       List<String> existing = List<String>.from(data['members'] ?? []);
  //       List<String> updated =
  //       existing.toSet().union(selecteduderid.toSet()).toList();
  //       await groupRef.update({'members': updated});
  //       Get.back();
  //     }
  //   } catch (e, s) {
  //     print('Error adding members: $e');
  //     print('Stack trace: $s');
  //   }
  // }
  //
  // static Future<ChatUser?> getUserDetailsById(String uid) async {
  //   try {
  //     final doc = await firestore.collection('users').doc(uid).get();
  //     if (doc.exists) return ChatUser.fromJson(doc.data()!);
  //   } catch (e) {
  //     print('❌ Error fetching sender: $e');
  //   }
  //   return null;
  // }
  //
  //
  // static Future<String?> uploadCompanyLogo(File file, String companyId) async {
  //   final ext = file.path
  //       .split('.')
  //       .last;
  //   final ref = FirebaseStorage.instance
  //       .ref()
  //       .child('company_logos/$companyId.$ext');
  //
  //   await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
  //
  //   return await ref.getDownloadURL();
  // }
  //
  //
  // static Future<String?> createCompany({
  //   required String name,
  //   String? email,
  //   String? phone,
  //   String? address,
  //   File? logoUrl,
  //   bool isHome = false,
  // }) async {
  //   try {
  //     print(logoUrl?.path);
  //     final time = DateTime
  //         .now()
  //         .millisecondsSinceEpoch
  //         .toString();
  //     final user = FirebaseAuth.instance.currentUser;
  //     if (user == null) throw Exception('User not logged in');
  //
  //
  //     final uid = APIs.user.uid;
  //
  //     // Check if the current user already has a company with the same name
  //     final userDocRef = firestore.collection('users').doc(uid);
  //     final userDoc = await userDocRef.get();
  //     final userData = userDoc.data();
  //
  //     final docRef = firestore.collection('companies').doc();
  //     final companyId = docRef.id;
  //
  //     if (userData != null) {
  //       // Get all companies associated with the current user
  //       final userCompanies = userData['company'] as List<dynamic>? ?? [];
  //
  //       // Check if the current user already has a company with the same name
  //       bool hasDuplicateCompany = userCompanies.any((company) {
  //         final companyData = company as Map<String, dynamic>;
  //         return companyData['name'].toString().toLowerCase() == name.toLowerCase();
  //       });
  //
  //       if (hasDuplicateCompany) {
  //         // Prevent the creation of a company with the same name for this user
  //         Get.snackbar("Error","❌ You already have a company with the name '$name'.",colorText: Colors.white,backgroundColor: Colors.red);
  //         return null;
  //       }
  //     }
  //
  //
  //     final currentAllowed = (userDoc.data()?['selectedCompany.allowedCompany']??10) as int;
  //
  //     if (currentAllowed <= 0) {
  //       Get.snackbar("Error","❌ You have reached the maximum company creation limit.",colorText: Colors.white,backgroundColor: Colors.red);
  //       return null;
  //     }
  //
  //
  //     String? logo ='';
  //     if ((logoUrl?.path.isNotEmpty??true) ||logoUrl?.path!='') {
  //       logo = await uploadCompanyLogo(logoUrl!, companyId);
  //     }
  //     final company = CompanyModel(
  //       id: companyId,
  //       name: name,
  //       address: address,
  //       logoUrl:(logo=='')?'': logo ?? '',
  //       email: email ?? '',
  //       phone: phone ?? '',
  //       createdAt: time,
  //       createdBy: uid,
  //       allowedCompany: currentAllowed-1,
  //       adminUserId: uid,
  //       members: [uid],
  //     );
  //
  //     await docRef.set(company.toJson());
  //
  //     // // Optional: Save companyId to user profile
  //     // await userDocRef.update({
  //     //   'company': FieldValue.arrayUnion([company.toJson()]),
  //     //   'selectedCompany': company.toJson(),
  //     // });
  //     await userDocRef.update({
  //       'company': FieldValue.arrayUnion([company.toJson()]),
  //       'selectedCompany': company.toJson(),
  //       'selectedCompany.allowedCompany':  (currentAllowed - 1),
  //       'allowedCompany': (currentAllowed - 1),
  //       'companyIds': FieldValue.arrayUnion([company.id]),
  //       'role': 'admin',
  //     });
  //
  //     await docRef.collection('members').doc(company.adminUserId).set({
  //       'role': 'admin',
  //       'joinedAt': time,
  //     });
  //     // await getSelfInfoProfile();
  //     me.selectedCompany = company;
  //     if(isHome){
  //       Get.toNamed(AppRoutes.home);
  //     }else{
  //       Get.offAllNamed(AppRoutes.inviteMemberRoute,
  //           arguments: {
  //             'company': company,
  //             'invitedBy': uid,
  //           }
  //       );
  //     }
  //
  //     return docRef.id;
  //   } catch (e) {
  //     print('❌ Error creating company: $e');
  //     return null;
  //   }
  // }
  //
  //
  // static Future<CompanyModel?> getUserCompany() async {
  //   if (APIs.me.selectedCompany?.id == null || (APIs.me.selectedCompany?.id??'').isEmpty) return null;
  //   final companyDoc = await FirebaseFirestore.instance
  //       .collection('companies')
  //       .doc(APIs.me.selectedCompany?.id )
  //       .get();
  //   if (!companyDoc.exists) return null;
  //
  //   return CompanyModel.fromJson(companyDoc.data()!);
  // }

 /* static Future<bool> joinCompany(
      {required String userId, required CompanyModel company}) async {
    try {
      final companyDoc = firestore.collection('companies').doc(company.id);
      final userDoc = firestore.collection('users').doc(userId);

      final snapshot = await companyDoc.get();
      if (!snapshot.exists) return false;

      final data = snapshot.data()!;
      final members = List<String>.from(data['members'] ?? []);

      if (!members.contains(userId)) {
        members.add(userId);
        await companyDoc.update({'members': members});
      }

      await userDoc.update({'company': company.toJson(),'role': "member"});
      // await userDoc.update({'role': "member"});
    } catch (e) {
      print('❌ Error fetching sender: $e');
    }
    return true;
  }


  static Future<void> handleJoinCompany({required BuildContext context, required String userId, required CompanyModel company,}) async {
    final joined = await joinCompany(userId: userId, company: company);

    if (!joined) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Invalid Company ID")),
      );
      return;
    }

    try {
      // 🔍 Step 1: Check invitation for this user (by email or phone)
      final invites = await FirebaseFirestore.instance
          .collection('invitations')
          .where('companyId', isEqualTo: company.id)
          .where('target', isEqualTo: APIs.me.email ?? APIs.me.phone)
          .where('isAccepted', isEqualTo: false)
          .get();

      if (invites.docs.isNotEmpty) {
        // ✅ Show accept invitation screen
        final inviteId = invites.docs.first.id;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AcceptInvitationScreen(),
          ),
        );
      } else {
        // ❌ Show error if no invite
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text("Not Invited"),
            content: const Text("You are not invited to this company."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print("❌ Error checking invitation: $e");
      toast("Error while checking invitation.");
    }
  }
*/

/*
  static Future<void> handleJoinCompany({
    required BuildContext context,
    required String emailOrPhone,
  }) async {
    try {
      // 🔍 Step 1: Check invitation for this user (by email or phone)
      final inviteSnap = await FirebaseFirestore.instance
          .collection('invitations')
          .where('email', isEqualTo: emailOrPhone)
          .where('isAccepted', isEqualTo: false)
          .limit(1)
          .get();

      if (inviteSnap.docs.isEmpty) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Not Invited"),
            backgroundColor: Colors.white,
            content: const Text("You are not invited to any company."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return;
      }

      final invite = InvitationModel.fromMap(inviteSnap.docs.first.data());
      final inviteId = inviteSnap.docs.first.id;


      // ✅ Proceed to Accept Invitation Screen
      Get.toNamed(AppRoutes.acceptInviteRoute,arguments: {
        'inviteId': inviteId,
        'company': invite.company!,
      });
    } catch (e) {
      print("❌ Error checking invitation: $e");
      toast("Something went wrong. Try again.");
    }
  }


 static Future<void> joinNewCompany(CompanyModel company) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(APIs.me.id);

    final docSnap = await userDoc.get();
    List<Map<String, dynamic>> companies = [];

    if (docSnap.exists && docSnap.data()?['company'] != null) {
      companies = List<Map<String, dynamic>>.from(docSnap.data()!['company']);
    }

    // Avoid duplicate companies
    if (!companies.any((c) => c['id'] == company.id)) {
      companies.add(company.toJson());
    }

    await userDoc.update({
      'company': companies,
      'selectedCompany': company.toJson(),
    });

    print("✅ Company added to user's company list");
  }

  static Future<List<String>> getInvitedContacts(String companyId) async {
    final invitesSnapshot = await FirebaseFirestore.instance
        .collection('invitations')
        .where('companyId', isEqualTo: companyId)
        .where('isAccepted', isEqualTo: false) // Get only pending invitations
        .get();

    List<String> invitedContacts = [];

    invitesSnapshot.docs.forEach((doc) {
      if (doc['email'] != null) {
        invitedContacts.add(doc['email']);
      }
      if (doc['phone'] != null) {
        invitedContacts.add(doc['phone']);
      }
    });

    return invitedContacts;
  }

  static Future<void> sendInvitation({
    required int companyId,
    required String email,
    required String name,
    required String invitedBy,
    required CompanyModel company,
  }) async {
    try {


      final existingInvites = await FirebaseFirestore.instance
          .collection('invitations')
          .where('companyId', isEqualTo: companyId)
          .where('email', isEqualTo: email)
          .where('isAccepted', isEqualTo: false)
          .get();

      if (existingInvites.docs.isNotEmpty) {
        // errorDialog("❗ This member is already invited.");
        return;
      }



      final time = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();
      final id = FirebaseFirestore.instance
          .collection('invitations')
          .doc()
          .id;

      final invite = InvitationModel(
        id: id,
        companyId: companyId,
        email: email,
        invitedBy: invitedBy,
        name: name.capitalizeFirst,
        sentAt: time,
        company: company,
      );

      await firestore.collection('invitations').doc(id).set(invite.toMap());
      final token = await getTargetToken(email:email.endsWith(".com") ? email : "",phone: email.startsWith("+91") ? email:'');
      print("token");
      print(token);

      if (token != null && token != APIs.me.pushToken) {
        await NotificationService.sendInvitationNotification(
          targetToken: token,
          inviterName: APIs.me.name,
          companyName: company.name??"",
        );
        // await LocalNotificationService.showInviteNotification(
        //   title: '📬 You got an invite',
        //   body: 'Join ${company.name??""} now!',
        // );

        print("🔔 Sending notification to token: $token");
        print("🤖 My device token: ${me.pushToken}");
      }
    } catch (e) {
      print('❌ Error fetching sender: $e');
    }
  }




  static Stream<QuerySnapshot<Map<String, dynamic>>> getCompanyUsers(userIds) {
    if (userIds.isEmpty) {
      // Firebase does not allow empty whereIn lists
      return const Stream.empty();
    }
    return firestore
        .collection('users').where('id', whereIn: userIds)
        .where('selectedCompany.id', isEqualTo: APIs.me.selectedCompany?.id)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllCompanyUsers() {

    final companyIds = APIs.me.company?.map((c) => c.id).toSet().toList() ?? [];
    print(companyIds.isEmpty);

    if (companyIds.isEmpty) {
      return Stream.empty();
      // return Stream.value(); // Or handle appropriately
    } else {
      return firestore
          .collection('users')
          .where('companyIds', arrayContainsAny: companyIds)
          .snapshots();
    }

  }*/

/*  static Future<void> acceptInvitation(String inviteId, String userId) async {
    final inviteDoc = firestore.collection('invitations').doc(inviteId);
    final inviteSnap = await inviteDoc.get();
    final time = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();

    if (inviteSnap.exists) {
      final invite = InvitationModel.fromMap(inviteSnap.data()!);

      // 1. Add user to the company member list
      await firestore
          .collection('companies')
          .doc(invite.companyId)
          .collection('members')
          .doc(userId)
          .set({
        'role': 'member',
        'joinedAt': time,
      });

      // 2. Update user document with companyId
      await firestore.collection('users').doc(userId).update({
        'company': invite.company!.toJson(),
      });
      final companyRef = firestore.collection('companies').doc(invite.companyId);
      await companyRef.update({
        'members': FieldValue.arrayUnion([userId]),
      });
      // 3. Mark invitation as accepted
      await inviteDoc.update({'isAccepted': true});
    }
  }*/

 /* static Stream<List<ChatUser>>? getCompanyMembers(String companyId) {
    try {
      return FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .snapshots()
          .asyncMap((snapshot) async {
        // Check if the company document exists and get the members list from it
        if (!snapshot.exists || !snapshot.data()!.containsKey('members')) {
          return []; // Return an empty list if no members are found
        }

        final userIds = List<String>.from(snapshot.data()!['members']);
        print("userIds================");
        print(userIds);
        if (userIds.isEmpty) return []; // No members found

        // Fetch the user details from 'users' collection based on the member IDs
        final userDocs = await FirebaseFirestore.instance
            .collection('users')
            .where('id', whereIn: userIds)
            .get();

        // Map the user documents to ChatUser objects
        return userDocs.docs.map((e) => ChatUser.fromJson(e.data())).toList();
      });
    } catch (e) {
      print("❌ Error getting members: $e");
      return null; // Return null in case of error
    }
  }*/

/*  static Future<List<ChatUser>> getCompanyMembers2(String companyId) async {

    // 1. Get the company document
    final companyDoc = await firestore.collection('companies').doc(companyId).get();

    if (!companyDoc.exists) return [];

    final data = companyDoc.data();
    final List<dynamic> memberIds = data?['members'] ?? [];

    if (memberIds.isEmpty) return [];

    // 2. Fetch all users whose ID is in the memberIds array
    final userQuery = await firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: memberIds.length > 10
        ? memberIds.sublist(0, 10) // Firestore 'in' supports max 10 items
        : memberIds)
        .get();

    List<ChatUser> members = userQuery.docs.map((doc) {
      return ChatUser.fromJson(doc.data());
    }).toList();

    return members;
  }


  static Stream<List<ChatUser>>? getCompanyMembers(String companyId) {
    try {
      return FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .snapshots()
          .asyncMap((snapshot) async {
        // Check if the company document exists and get the members list from it
        if (!snapshot.exists || !snapshot.data()!.containsKey('members')) {
          return []; // Return an empty list if no members are found
        }

        final userIds = List<String>.from(snapshot.data()?['members']);
        if (userIds.isEmpty) return []; // No members found

        // Fetch the user details from 'users' collection based on the member IDs
        final userDocs = await FirebaseFirestore.instance
            .collection('users')
            .where('id', whereIn: userIds)
            .get();

        // Map the user documents to ChatUser objects
        return userDocs.docs.map((e) => ChatUser.fromJson(e.data())).toList();
      });
    } catch (e) {
      print("❌ Error getting members: $e");
      return null; // Return null in case of error
    }
  }*/


/*
  static Future<void> removeCompanyMember(String userId, String companyId, String currentUserId, String role) async {
    try {
      final companyDoc = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .get();

      if (!companyDoc.exists) {
        print("❌ Company not found");
        return;
      }

      final companyData = companyDoc.data()!;
      final creatorId = companyData['createdBy'];
      final members = List<String>.from(companyData['members'] ?? []);

      // 1. Check if the logged-in user is the creator or admin of the company
      if (currentUserId == creatorId) {
        // The creator can remove other members but not themselves
        if (userId == currentUserId) {
          print("❌ You cannot remove yourself from the company");
          return;
        }

        if (members.contains(userId)) {
          members.remove(userId);
          await FirebaseFirestore.instance
              .collection('companies')
              .doc(companyId)
              .update({
            'members': members,
          });

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
            'company': FieldValue.delete(),
            'role': FieldValue.delete(),
          });

          print("✅ Member removed by creator successfully.");
        } else {
          print("❌ The user is not a member of this company.");
        }
      } else if (role == 'admin') {
        // Admin can remove other members but not themselves
        if (userId == currentUserId) {
          print("❌ You cannot remove yourself from the company");
          return;
        }

        if (members.contains(userId)) {
          members.remove(userId);
          await FirebaseFirestore.instance
              .collection('companies')
              .doc(companyId)
              .update({
            'members': members,
          });

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
            'company': FieldValue.delete(),
            'role': FieldValue.delete(),
          });

          print("✅ Member removed by admin successfully.");
        } else {
          print("❌ The user is not a member of this company.");
        }
      } else {
        print("❌ You do not have permission to remove members.");
      }
    } catch (e) {
      print("❌ Error removing member: $e");
    }
  }

*/

/*
  static Future<void> removeCompanyMember(String userId, String companyId, String currentUserId, String role) async {
    try {
      final companyDoc = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .get();

      if (!companyDoc.exists) {
        print("❌ Company not found");
        return;
      }

      final companyData = companyDoc.data()!;
      final creatorId = companyData['createdBy'];
      final members = List<String>.from(companyData['members'] ?? []);

      // 1. Check if the logged-in user is the creator or admin of the company
      if (currentUserId == creatorId) {
        // The creator can remove other members but not themselves
        if (userId == currentUserId) {
          print("❌ You cannot remove yourself from the company");
          return;
        }

        if (members.contains(userId)) {
          members.remove(userId);
          await FirebaseFirestore.instance
              .collection('companies')
              .doc(companyId)
              .update({
            'members': members,
          });

          // Remove from user document
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
            'company': FieldValue.delete(),
            'role': FieldValue.delete(),
          });

          print("✅ Member removed by creator successfully.");
        } else {
          print("❌ The user is not a member of this company.");
        }
      } else if (role == 'admin') {
        // Admin can remove other members but not themselves
        if (userId == currentUserId) {
          print("❌ You cannot remove yourself from the company");
          return;
        }

        if (members.contains(userId)) {
          members.remove(userId);
          await FirebaseFirestore.instance
              .collection('companies')
              .doc(companyId)
              .update({
            'members': members,
          });

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
            'company': FieldValue.delete(),
            'role': FieldValue.delete(),
          });

          print("✅ Member removed by admin successfully.");
        } else {
          print("❌ The user is not a member of this company.");
        }
      } else {
        print("❌ You do not have permission to remove members.");
      }
    } catch (e) {
      print("❌ Error removing member: $e");
    }
  }
*/

 /* static Future<void> removeCompanyMember(
    String userId,
    String companyId,
    String currentUserId,
    String role,
  ) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      // 1. Get company document to verify if the user is the creator or admin
      final companyDoc = await firestore.collection('companies').doc(companyId).get();

      if (!companyDoc.exists) {
        print("❌ Company not found");
        return;
      }

      final companyData = companyDoc.data()!;
      final creatorId = companyData['createdBy'];
      final members = List<String>.from(companyData['members'] ?? []);

      // 2. Check if logged-in user is the creator or admin
      if (currentUserId == creatorId) {
        // The creator can remove other members but not themselves
        if (userId == currentUserId) {
          print("❌ You cannot remove yourself from the company");
          return;
        }

        if (members.contains(userId)) {
          // Remove from company's member list
          members.remove(userId);
          batch.update(
            firestore.collection('companies').doc(companyId),
            {'members': members},
          );

          // 3. Remove from user's company array in users collection
          batch.update(
            firestore.collection('users').doc(userId),
            {
              'company': FieldValue.arrayRemove([companyId]),
              'role': FieldValue.delete(),
            },
          );

          // 4. Remove from selectedCompany if it's the company being deleted
          batch.update(
            firestore.collection('users').doc(userId),
            {
              'selectedCompany': FieldValue.delete(),
            },
          );

          // 5. Remove the member from the `my_users` collection of other users
          final myUsersSnap = await firestore
              .collection('users')
              .where('company', arrayContains: companyId)
              .get();

          for (var userDoc in myUsersSnap.docs) {
            final userData = userDoc.data();
            final myUsers = List<String>.from(userData['my_users'] ?? []);
            myUsers.remove(userId);

            batch.update(
              firestore.collection('users').doc(userDoc.id),
              {'my_users': myUsers},
            );
          }

          // Commit the batch update
          await batch.commit();

          print("✅ Member removed by creator successfully.");
        } else {
          print("❌ The user is not a member of this company.");
        }
      } else if (role == 'admin') {
        // Admin can remove other members but not themselves
        if (userId == currentUserId) {
          print("❌ You cannot remove yourself from the company");
          return;
        }

        if (members.contains(userId)) {
          // Remove from company's member list
          members.remove(userId);
          batch.update(
            firestore.collection('companies').doc(companyId),
            {'members': members},
          );

          // 6. Remove from user's company array in users collection
          batch.update(
            firestore.collection('users').doc(userId),
            {
              'company': FieldValue.arrayRemove([companyId]),
              'role': FieldValue.delete(),
            },
          );

          // 7. Remove from selectedCompany if it's the company being deleted
          batch.update(
            firestore.collection('users').doc(userId),
            {
              'selectedCompany': FieldValue.delete(),
            },
          );

          // 8. Remove the member from the `my_users` collection of other users
          final myUsersSnap = await firestore
              .collection('users')
              .where('company', arrayContains: companyId)
              .get();

          for (var userDoc in myUsersSnap.docs) {
            final userData = userDoc.data();
            final myUsers = List<String>.from(userData['my_users'] ?? []);
            myUsers.remove(userId);

            batch.update(
              firestore.collection('users').doc(userDoc.id),
              {'my_users': myUsers},
            );
          }

          // Commit the batch update
          await batch.commit();

          print("✅ Member removed by admin successfully.");
        } else {
          print("❌ The user is not a member of this company.");
        }
      } else {
        print("❌ You do not have permission to remove members.");
      }
    } catch (e) {
      print("❌ Error removing member: $e");
    }
  }*/

/*  static Future<void> removeCompanyMember(String userId, String companyId) async {
    try {
      // 1. Remove from company members subcollection
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .collection('members')
          .doc(userId)
          .delete();

      // 2. Remove company field from user
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'company': FieldValue.delete(),
        'role': FieldValue.delete(),
      });

      // 3. Optional: Remove from 'my_users' of other users if you track 1:1
      // 4. Optional: Delete company chats/tasks if needed (handle manually)

      print("✅ User removed successfully.");
    } catch (e) {
      print("❌ Error removing member: $e");
    }
  }*/

/*

  static Future<void> removeCompanyMember({
    required String userId,
    required String companyId,
    required String currentUserId,
    required String role,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      // 1. Get the company document to verify if the user is the creator or admin
      final companyDoc = await firestore.collection('companies').doc(companyId).get();

      if (!companyDoc.exists) {
        print("❌ Company not found");
        return;
      }

      final companyData = companyDoc.data()!;
      final creatorId = companyData['createdBy'];
      final members = List<String>.from(companyData['members'] ?? []);

      // 2. Check if logged-in user is the creator or admin
      if (currentUserId == creatorId) {
        // The creator can remove other members but not themselves
        if (userId == currentUserId) {
          print("❌ You cannot remove yourself from the company");
          return;
        }

        if (members.contains(userId)) {
          // Remove from company's member list
          members.remove(userId);
          batch.update(
            firestore.collection('companies').doc(companyId),
            {'members': members},
          );

          // 3. Remove company from user's company array in the users collection
          final userDoc = await firestore.collection('users').doc(userId).get();
          final userData = userDoc.data()!;

          // 3a. Remove the company from the user's list of companies
          final List<dynamic> userCompanies = List.from(userData['company'] ?? []);
          userCompanies.removeWhere((company) => company['id'] == companyId);

          // 3b. If the removed company is the selected company, delete it from the selectedCompany
          final selectedCompany = userData['selectedCompany'];
          if (selectedCompany != null && selectedCompany['id'] == companyId) {
            batch.update(firestore.collection('users').doc(userId), {
              'selectedCompany': FieldValue.delete(),
            });
          }

          // Update the user document to remove the company and role
          batch.update(
            firestore.collection('users').doc(userId),
            {
              'company': userCompanies,
              'role': FieldValue.delete(),
            },
          );

          // 4. Remove the member from the 'my_users' collection of other users
          */
/*final myUsersSnap = await firestore
              .collection('users')
              .where('company', arrayContains: companyId)
              .get();

          for (var userDoc in myUsersSnap.docs) {
            final userData = userDoc.data();
            final myUsers = List<String>.from(userData['my_users'] ?? []);
            myUsers.remove(userId);

            batch.update(
              firestore.collection('users').doc(userDoc.id),
              {'my_users': myUsers},
            );
          }
*//*

          // 5. Commit the batch update for the removal process
          await batch.commit();

          // Check if selectedCompany is null after removal
          if (userData['selectedCompany'] == null || userData['selectedCompany']=={}) {
            // If the user has no selected company, navigate to the landing page
            Get.offAllNamed(AppRoutes.landingRoute);
          }

          print("✅ Member removed by creator successfully.");
        } else {
          print("❌ The user is not a member of this company.");
        }
      } else if (role == 'admin') {
        // Admin can remove other members but not themselves
        if (userId == currentUserId) {
          print("❌ You cannot remove yourself from the company");
          return;
        }

        if (members.contains(userId)) {
          // Remove from company's member list
          members.remove(userId);
          batch.update(
            firestore.collection('companies').doc(companyId),
            {'members': members},
          );

          // 6. Remove from user's company array in users collection
          final userDoc = await firestore.collection('users').doc(userId).get();
          final userData = userDoc.data()!;

          // 6a. Remove the company from the user's list of companies
          final List<dynamic> userCompanies = List.from(userData['company'] ?? []);
          userCompanies.removeWhere((company) => company['id'] == companyId);

          // 6b. If the removed company is the selected company, delete it from the selectedCompany
          final selectedCompany = userData['selectedCompany'];
          if (selectedCompany != null && selectedCompany['id'] == companyId) {
            batch.update(firestore.collection('users').doc(userId), {
              'selectedCompany': FieldValue.delete(),
            });
          }

          // Update the user document to remove the company and role
          batch.update(
            firestore.collection('users').doc(userId),
            {
              'company': userCompanies,
              'role': FieldValue.delete(),
            },
          );

          // 7. Remove the member from the 'my_users' collection of other users
         */
/* final myUsersSnap = await firestore
              .collection('users')
              .where('company', arrayContains: companyId)
              .get();

          for (var userDoc in myUsersSnap.docs) {
            final userData = userDoc.data();
            final myUsers = List<String>.from(userData['my_users'] ?? []);
            myUsers.remove(userId);

            batch.update(
              firestore.collection('users').doc(userDoc.id),
              {'my_users': myUsers},
            );
          }*//*


          // 8. Commit the batch update for the removal process
          await batch.commit();

          print("✅ Member removed by admin successfully.");
        } else {
          print("❌ The user is not a member of this company.");
        }
      } else {
        print("❌ You do not have permission to remove members.");
      }
    } catch (e) {
      print("❌ Error removing member: $e");
    }
  }





  static Future<List<InvitationModel>> getInvitations(String selectedCompanyId) async {
    try {
      final invitesSnapshot = await FirebaseFirestore.instance
          .collection('invitations')
          .where('companyId', isEqualTo: selectedCompanyId) // Filter by selected company
          .get();

      List<InvitationModel> invites = invitesSnapshot.docs.map((doc) {
        return InvitationModel.fromMap(doc.data());
      }).toList();

      return invites;
    } catch (e) {
      print('❌ Error fetching invitations: $e');
      return [];
    }
  }

  static Future<int> getPendingInvitationCount(String? companyId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('invitations')
          .where('companyId', isEqualTo: companyId)
          .get();

      return snapshot.size; // returns the count of matching documents
    } catch (e) {
      print('❌ Error fetching invitation count: $e');
      return 0;
    }
  }



  static Future<bool> deleteInvitation(String invitationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('invitations')
          .doc(invitationId)
          .delete();

      print('✅ Invitation deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting invitation: $e');
      return false;
    }
  }


  static Future<List<CompanyModel>> fetchJoinedCompanies() async {
    final userEmail = APIs.me.email ?? '';
    final userPhone = APIs.me.phone ?? '';
    final userId = APIs.me.id;

    List<CompanyModel> companies = [];
    // 🔹 1. Fetch companies where user is directly a member (creator or invited and accepted)
    final directCompaniesSnap = await FirebaseFirestore.instance
        .collection('companies')
        .where('members', arrayContains: userId)
        .get();

    for (var doc in directCompaniesSnap.docs) {
      companies.add(CompanyModel.fromJson(doc.data()));
    }

    // 🔹 2. Fetch companies where the user accepted invitation (optional: if needed separately)
    final invitesSnap = await FirebaseFirestore.instance
        .collection('invitations')
        .where('isAccepted', isEqualTo: true)
        .where(Filter.or(
      Filter('email', isEqualTo: userEmail),
      Filter('phone', isEqualTo: userPhone),
    ))
        .get();

    for (var doc in invitesSnap.docs) {
      final companyId = doc['companyId'];
      final companyDoc = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .get();

      if (companyDoc.exists &&
          !companies.any((c) => c.id == companyId)) {
        companies.add(CompanyModel.fromJson(companyDoc.data()!));
      }
    }

    return companies;
  }
*/


 /* static Future<List<CompanyModel>> fetchJoinedCompanies() async {
    final userEmail = APIs.me.email ?? '';
    final userPhone = APIs.me.phone ?? '';

    final invitesSnap = await FirebaseFirestore.instance
        .collection('invitations')
        .where('isAccepted', isEqualTo: true)
        .where(Filter.or(
      Filter('email', isEqualTo: userEmail),
      Filter('phone', isEqualTo: userPhone),
    ))
        .get();

    List<CompanyModel> companies = [];
    for (var doc in invitesSnap.docs) {
      final companyId = doc['companyId'];
      final companyDoc = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .get();
      if (companyDoc.exists) {
        companies.add(CompanyModel.fromJson(companyDoc.data()!));
      }
    }
    return companies;
  }*/

/*  static Future<void>  updateCompany(CompanyModel company) async {
    try {
      final companyRef = FirebaseFirestore.instance.collection('companies').doc(company.id);
      final userDoc = FirebaseFirestore.instance.collection('users').doc(APIs.me.id);
      await companyRef.update(company.toJson()).onError((e,v)=>print("eeeeeeeeeeeeeeeeeeeeeee ==========${e.toString()}"));

      await userDoc.update({
        'selectedCompany':company.toJson(),
      }).onError((e,v)=>print("eeeeeeeeeeeeeeeeeeeeeee -----------${e.toString()}"));
      me.selectedCompany = company;
      Get.back();
      Get.snackbar(
          'Company Updated',
          'Company Updated Successfully!',
          backgroundColor: Colors.white.withOpacity(.9),colorText: Colors.black);

      } catch (e) {
      print("❌ Error updating company: $e");
    }
  }

  static Future<void> updateCompanyLogo(File logoFile) async {
    try {

      final ext = logoFile.path
          .split('.')
          .last;
      log('Extension: $ext');

      //storage file ref with path
      final ref = storage.ref().child('company_logo/${user.uid}.$ext');

      //uploading image
      await ref
          .putFile(logoFile, SettableMetadata(contentType: 'image/$ext'))
          .then((p0) {
        log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
      });

      //updating image in firestore database
      me.selectedCompany?.logoUrl = await ref.getDownloadURL();
      await firestore
          .collection('companies')
          .doc(me.selectedCompany?.id)
          .update({'logoUrl': me.selectedCompany?.logoUrl});


      await firestore.collection('users').doc(me.id).update({
        'selectedCompany.logoUrl': me.selectedCompany?.logoUrl,
      });

      // final ext = logoFile.path.split('.').last;
      // final companyId = me.selectedCompany?.id;
      //
      // if (companyId == null) {
      //   print("❌ No selected company found");
      //   return;
      // }
      //
      // final ref = storage.ref().child('company_logo/$companyId.$ext');
      //
      // // Upload image
      // await ref.putFile(
      //   logoFile,
      //   SettableMetadata(contentType: 'image/$ext'),
      // );
      //
      // final logoUrl = await ref.getDownloadURL();
      //
      // // 🔹 1. Update logo in company doc
      // await firestore.collection('companies').doc(companyId).update({
      //   'logoUrl': logoUrl,
      // });
      //
      // // 🔹 2. Update user's selectedCompany map (replace full object)
      // final updatedCompany = me.selectedCompany!.copyWith(logoUrl: logoUrl);
      //
      // await firestore.collection('users').doc(me.id).update({
      //   'selectedCompany': updatedCompany.toJson(),
      // });

      print("✅ Company logo updated successfully");
    } catch (e) {
      print("❌ Error updating company logo: $e");
    }
  }


  static Future<void> deleteUserAccountChunked(String userId) async {
    final userDoc = firestore.collection('users').doc(userId);

    try {
      final userSnapshot = await userDoc.get();
      if (!userSnapshot.exists) {
        print('User not found.');
        return;
      }

      final userData = userSnapshot.data();
      final role = userData?['role'] ?? '';

      if (role == 'admin') {
        toast('Admin user — use deleteCompany() instead.');
        return;
      }

      final companyRef = firestore.collection('companies').doc(userData?['selectedCompany']?['id']);

      if (companyRef != null) {
        await companyRef.update({
          'members': FieldValue.arrayRemove([userId])
        });
      }


      // 1. Remove user from groups
      final groupQuery = await firestore.collection('groups')
          .where('members', arrayContains: userId)
          .get();

      for (var groupDoc in groupQuery.docs) {
        await groupDoc.reference.update({
          'members': FieldValue.arrayRemove([userId])
        });
      }

      // 2. Remove user from broadcasts
      final broadcastQuery = await firestore.collection('broadcasts')
          .where('members', arrayContains: userId)
          .get();

      for (var bDoc in broadcastQuery.docs) {
        await bDoc.reference.update({
          'members': FieldValue.arrayRemove([userId])
        });
      }

      // 3. Chunked delete of messages where user is originalSender
      final chatQuery = await firestore.collection('chats').get();

      for (var chatDoc in chatQuery.docs) {
        final messagesRef = chatDoc.reference.collection('messages');
        QuerySnapshot<Map<String, dynamic>> msgSnapshot;
        do {
          msgSnapshot = await messagesRef
              .where('originalSenderId', isEqualTo: userId)
              .limit(400)
              .get();

          if (msgSnapshot.docs.isNotEmpty) {
            WriteBatch batch = firestore.batch();
            for (var msg in msgSnapshot.docs) {
              batch.delete(msg.reference);
            }
            await batch.commit();
          }
        } while (msgSnapshot.docs.isNotEmpty);
      }

      // 4. Delete user document
      await firestore.collection('users').doc(userId).delete();

      final selectedCompanyId = userData?['selectedCompany']?['id'];
      if (selectedCompanyId != null) {
        final companyRef = firestore.collection('companies').doc(selectedCompanyId);
        await companyRef.update({
          'members': FieldValue.arrayRemove([userId])
        });
      }

      Get.offAllNamed(AppRoutes.loginGRoute);
      toast('✅ User and related data deleted in chunks.');

    } catch (e) {
      print('❌ Error during user deletion: $e');
    }
  }*/




/*
  static Future<void> updateCompanyLogo(File logoUrl) async {
    try {


      final ext = logoUrl.path
          .split('.')
          .last;
      log('Extension: $ext');

      //storage file ref with path
      final ref = storage.ref().child('company_logo/${me.selectedCompany?.id}.$ext');

      //uploading image
      await ref
          .putFile(logoUrl, SettableMetadata(contentType: 'image/$ext'))
          .then((p0) {
        log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
      });

      //updating image in firestore database
      var lo = await ref.getDownloadURL();
      await firestore
          .collection('companies')
          .doc(me.selectedCompany?.id??'')
          .update({'logoUrl': lo});

      await FirebaseFirestore.instance
          .collection('users')
          .doc(me.id)
          .update({
        'selectedCompany.logoUrl':lo,
      });

      // final companyRef = FirebaseFirestore.instance.collection('companies').doc(companyId);
      //
      // await companyRef.update({'logoUrl': logoUrl});
      print("✅ Company logo updated successfully");
    } catch (e) {
      print("❌ Error updating company logo: $e");
    }

*/

}




// firebase rule just copy and paste into your firestore database rules for open chat
/*
rules_version = '2';

service cloud.firestore {
match /databases/{database}/documents {
match /users/{userId} {
allow read, write: if request.auth != null;

match /my_users/{docId} {
allow read, write: if request.auth != null;
}
}
match /chats/{conversationId}/messages/{messageId} {
allow read, write: if request.auth != null;
match /thread/{threadId} {
allow read, write: if request.auth != null;
}
}
match /chats/{conversationId} {
match /messages/{messageId} {
allow read, write: if request.auth != null;

match /threads/{threadId} {
allow read, write: if request.auth != null;
}
}
}
match /chats/{conversationId}/messages/{messageId}/threads/{threadId} {
allow read, write: if request.auth != null;
}
match /chats/{chatId}/messages/{msgId} {
allow read, write: if request.auth != null;
match /thread/{threadId} {
allow read, write: if request.auth != null;
}
}

match /groups/{groupId} {
allow read, write: if request.auth != null;

match /messages/{messageId} {
allow read, write: if request.auth != null;
}
}
match /broadcasts/{broadcastId} {
allow read, write: if request.auth != null;
}

match /broadcasts/{broadcastId}/messages/{messageId} {
allow read, write: if request.auth != null;
}
match /chats/{chatId}/messages/{messageId} {
allow read, write: if request.auth != null;
match /thread/{threadId} {
allow read, write: if request.auth != null;
}
}
match /tasks/{taskId} {
allow read: if request.auth.uid in resource.data.assignedTo;
allow update: if request.auth.uid == resource.data.createdBy || request.auth.uid in resource.data.assignedTo;
}

match /tasks/{taskId}/comments/{commentId} {
allow read, write: if request.auth.uid in get(/databases/(default)/documents/tasks/$(taskId)).data.assignedTo;
}

}
}*/
