import 'dart:convert';
import 'package:AccuChat/Screens/Chat/screens/auth/Presentation/Views/accept_invite_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import '../../../Services/APIs/local_keys.dart';
import '../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../main.dart';
import '../../../routes/app_routes.dart';
import '../../Home/Presentation/Controller/home_controller.dart';
import '../api/apis.dart';
import '../models/company_model.dart';
import '../models/get_company_res_model.dart';
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

          Get.toNamed(AppRoutes.home);

      } else if (type == 'task') {
        Get.find<DashboardController>().updateIndex(1);
      } else if (type == 'chat') {
        Get.find<DashboardController>().updateIndex(0);
      }
    });



  }



  static void handleNotificationTap(String? payload)async {
    if (payload == 'invite') {
      // Navigate to pending invite screen
      Get.toNamed(AppRoutes.home);
    } else if (payload == 'task') {
      Get.find<DashboardController>().updateIndex(1);

    } else if (payload == 'chat') {
      Get.find<DashboardController>().updateIndex(0);
    }
  }

  /// Send a general push notification
  static Future<void> _sendNotification({
    required String targetToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
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
      title: "Invitation!",
      body: "$companyName invited you.",
      data: {
        "type": "invite",
        "company": companyName,
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      final payload = message.data['type'];

      if (payload == 'invite') {
        // Navigate to pending invite screen
        Get.toNamed(AppRoutes.home);
      } else if (payload == 'task') {
        Get.find<DashboardController>().updateIndex(1);
      } else if (payload == 'chat') {
        Get.find<DashboardController>().updateIndex(0);
      }
    });
  }

  ///Accept Invitation Notification
  static Future<void> sendAcceptInvitationNotification({
    required String targetToken,
    required String inviterName,
    required String number,
    required String companyName,
  }) async {
    await _sendNotification(
      targetToken: targetToken,
      title: "Invitation Accepted",
      body: "${inviterName==''?number:inviterName} accepted your Invitation for $companyName.",
      data: {
        "type": "acceptinvite",
        "company": companyName,
      },
    );

  }

  /// Chat Message Notification
  static Future<void> sendMessageNotification({
    required String targetToken,
    required String senderName,
    CompanyData? company,
    required String message,
  }) async {
    await _sendNotification(
      targetToken: targetToken,
      title: "💬 New Message from $senderName",
      body: message,
      data: {
        "type": "chat",
        "companyId": company?.companyId,
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      final payload = message.data['type'];
      final payloadC = message.data['companyId'];

      if (payload == 'invite') {

          Get.offAllNamed(AppRoutes.home);


      } else if (payload == 'task') {
        Get.find<DashboardController>().updateIndex(1);
        if(payloadC != APIs.me.userCompany?.userCompanyId){

          await APIs.getSelfInfo();
        }


      } else if (payload == 'chat') {
        Get.find<DashboardController>().updateIndex(0);
        if(payloadC != APIs.me.userCompany?.userCompanyId){

          await APIs.getSelfInfo();
        }
      }
    });
  }

  /// Task Message Notification
  static Future<void> sendTaskNotification({
    required String targetToken,
    required String assignerName,
    required String taskSummary,
     CompanyData? company,
  }) async {
    await _sendNotification(
      targetToken: targetToken,
      title: "📝 Task Assigned by $assignerName",
      body: taskSummary,
      data: {
        "type": "task",
        "companyId": company?.companyId??0,
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      final payload = message.data['type'];
      final payloadC = message.data['companyId'];
      if (payload == 'invite') {
        Get.toNamed(AppRoutes.home);
      } else if (payload == 'task') {
        Get.find<DashboardController>().updateIndex(1);
        if(payloadC != APIs.me.userCompany?.userCompanyId){

          await APIs.getSelfInfo();
        }

      } else if (payload == 'chat') {
        Get.find<DashboardController>().updateIndex(0);
        if(payloadC != APIs.me.userCompany?.userCompanyId){

          await APIs.getSelfInfo();
        }
      }
    });
  }
}
