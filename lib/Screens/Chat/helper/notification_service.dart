import 'dart:convert';
import 'package:AccuChat/Screens/Chat/screens/auth/accept_invite_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import '../../Home/Presentation/Controller/home_controller.dart';
import '../api/apis.dart';
import '../models/invite_model.dart';
import 'local_notification_channel.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static ServiceAccountCredentials? _credentials;
  static AutoRefreshingAuthClient? _client;
  static String? _projectId;

  /// Initialize service account and auth client
  static Future<void> init() async {
    final serviceAccountJson = await rootBundle.loadString('assets/service-account.json');
    final jsonMap = json.decode(serviceAccountJson);
    _projectId = jsonMap['project_id'];
    _credentials = ServiceAccountCredentials.fromJson(serviceAccountJson);

    _client = await clientViaServiceAccount(
      _credentials!,
      ['https://www.googleapis.com/auth/firebase.messaging'],
    );
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = await clientViaServiceAccount(_credentials!, scopes);
    final token = await client.credentials.accessToken;

    print('✅ Access Token: ${token.data}',);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📬 Foreground message: ${message.notification?.title}');

      final title = message.notification?.title ?? '';
      final body = message.notification?.body ?? '';

      LocalNotificationService.showInviteNotification(
        title: title,
        body: body,
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      final type = message.data['type'];
      print('🔔 Notification tapped. Type: $type');

      if (type == 'invite') {
        final inviteSnap = await FirebaseFirestore.instance
            .collection('invitations')
            .where('email', isEqualTo: APIs.me.phone == 'null' || APIs.me.phone == null || APIs.me.phone == ''
            ? APIs.me.email
            : APIs.me.phone)
            .where('isAccepted', isEqualTo: false)
            .limit(1)
            .get();

        if (inviteSnap.docs.isNotEmpty) {
          final invite = InvitationModel.fromMap(inviteSnap.docs.first.data());
          final inviteId = inviteSnap.docs.first.id;

          Get.to(() => AcceptInvitationScreen(
            inviteId: inviteId,
            company: invite.company!,
          ));
        } else {
          print("⚠️ No pending invite found.");
        }
      } else if (type == 'task') {
        Get.find<DashboardController>().updateIndex(2);
      } else if (type == 'chat') {
        Get.find<DashboardController>().updateIndex(1);
      }
    });



  }



  static void handleNotificationTap(String? payload)async {
    if (payload == 'invite') {
      // Navigate to pending invite screen
      final inviteSnap = await FirebaseFirestore.instance
          .collection('invitations')
          .where('email', isEqualTo: APIs.me.phone=='null' || APIs.me.phone==null||
          APIs.me.phone==''? APIs.me.email:APIs.me.phone)
          .where('isAccepted', isEqualTo: false)
          .limit(1)
          .get();
      final invite = InvitationModel.fromMap(inviteSnap.docs.first.data());
      final inviteId = inviteSnap.docs.first.id;


      // ✅ Proceed to Accept Invitation Screen
      Get.to(()=>AcceptInvitationScreen(
        inviteId: inviteId,
        company: invite.company!,
      )); // or use Navigator.push if not using GetX
    } else if (payload == 'task') {
      Get.find<DashboardController>().updateIndex(2);

    } else if (payload == 'chat') {
      Get.find<DashboardController>().updateIndex(1);
    }
  }

  /// Send a general push notification
  static Future<void> _sendNotification({
    required String targetToken,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    if (_client == null || _projectId == null) {
      await init();
    }

    final url = Uri.parse('https://fcm.googleapis.com/v1/projects/$_projectId/messages:send');

    final message = {
      "message": {
        "token": targetToken,
        "notification": {
          "title": title,
          "body": body,
        },
        "data": data ?? {
          "click_action": "FLUTTER_NOTIFICATION_CLICK"
        }
      }
    };

    final response = await _client!.post(url, body: jsonEncode(message));

    if (response.statusCode == 200) {
      print('✅ Notification sent!');
    } else {
      print('❌ Failed to send notification: ${response.body}');
    }
  }

  /// Invitation Notification
  static Future<void> sendInvitationNotification({
    required String targetToken,
    required String inviterName,
    required String companyName,
  }) async {
    await _sendNotification(
      targetToken: targetToken,
      title: "📬 Invitation Received",
      body: "$inviterName invited you to join $companyName.",
      data: {
        "type": "invite",
        "company": companyName,
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      final payload = message.data['type'];

      if (payload == 'invite') {
        // Navigate to pending invite screen
        final inviteSnap = await FirebaseFirestore.instance
            .collection('invitations')
            .where('email', isEqualTo: APIs.me.phone=='null' || APIs.me.phone==null||
            APIs.me.phone==''? APIs.me.email:APIs.me.phone)
            .where('isAccepted', isEqualTo: false)
            .limit(1)
            .get();
        final invite = InvitationModel.fromMap(inviteSnap.docs.first.data());
        final inviteId = inviteSnap.docs.first.id;


        // ✅ Proceed to Accept Invitation Screen
        Get.to(()=>AcceptInvitationScreen(
          inviteId: inviteId,
          company: invite.company!,
        )); // or use Navigator.push if not using GetX
      } else if (payload == 'task') {
        Get.find<DashboardController>().updateIndex(2);

      } else if (payload == 'chat') {
        Get.find<DashboardController>().updateIndex(1);
      }
    });
  }

  /// Chat Message Notification
  static Future<void> sendMessageNotification({
    required String targetToken,
    required String senderName,
    required String message,
  }) async {
    await _sendNotification(
      targetToken: targetToken,
      title: "💬 New Message from $senderName",
      body: message,
      data: {
        "type": "chat",
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      final payload = message.data['type'];

      if (payload == 'invite') {
        // Navigate to pending invite screen
        final inviteSnap = await FirebaseFirestore.instance
            .collection('invitations')
            .where('email', isEqualTo: APIs.me.phone=='null' || APIs.me.phone==null||
            APIs.me.phone==''? APIs.me.email:APIs.me.phone)
            .where('isAccepted', isEqualTo: false)
            .limit(1)
            .get();
        final invite = InvitationModel.fromMap(inviteSnap.docs.first.data());
        final inviteId = inviteSnap.docs.first.id;


        // ✅ Proceed to Accept Invitation Screen
        Get.to(()=>AcceptInvitationScreen(
          inviteId: inviteId,
          company: invite.company!,
        )); // or use Navigator.push if not using GetX
      } else if (payload == 'task') {
        Get.find<DashboardController>().updateIndex(2);

      } else if (payload == 'chat') {
        Get.find<DashboardController>().updateIndex(1);
      }
    });
  }

  /// Task Message Notification
  static Future<void> sendTaskNotification({
    required String targetToken,
    required String assignerName,
    required String taskSummary,
  }) async {
    await _sendNotification(
      targetToken: targetToken,
      title: "📝 Task Assigned by $assignerName",
      body: taskSummary,
      data: {
        "type": "task",
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      final payload = message.data['type'];

      if (payload == 'invite') {
        // Navigate to pending invite screen
        final inviteSnap = await FirebaseFirestore.instance
            .collection('invitations')
            .where('email', isEqualTo: APIs.me.phone=='null' || APIs.me.phone==null||
            APIs.me.phone==''? APIs.me.email:APIs.me.phone)
            .where('isAccepted', isEqualTo: false)
            .limit(1)
            .get();
        final invite = InvitationModel.fromMap(inviteSnap.docs.first.data());
        final inviteId = inviteSnap.docs.first.id;


        // ✅ Proceed to Accept Invitation Screen
        Get.to(()=>AcceptInvitationScreen(
          inviteId: inviteId,
          company: invite.company!,
        )); // or use Navigator.push if not using GetX
      } else if (payload == 'task') {
        Get.find<DashboardController>().updateIndex(2);

      } else if (payload == 'chat') {
        Get.find<DashboardController>().updateIndex(1);
      }
    });
  }
}
