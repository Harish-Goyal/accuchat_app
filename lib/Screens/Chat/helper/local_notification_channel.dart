import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../Home/Presentation/Controller/home_controller.dart';
import '../api/apis.dart';
import '../models/invite_model.dart';
import '../screens/auth/Presentation/Views/accept_invite_screen.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize({required Function(String? payload) onSelect}) async {
    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidInit);

    await _plugin.initialize(initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        onSelect(payload); // payload passed here
      },

    );


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

          Get.toNamed(AppRoutes.accept_invite,arguments: {
            'inviteId': inviteId,
            'company': invite.company!,
          });
        } else {
          print("⚠️ No pending invite found.");
        }
      } else if (type == 'task') {
        Get.find<DashboardController>().updateIndex(1);
      } else if (type == 'chat') {
        Get.find<DashboardController>().updateIndex(0);
      }
    });



  }

  static Future<void> createAllChannels() async {
    const channels = [
      AndroidNotificationChannel(
        'chat_channel',
        'Chat Messages',
        description: 'Notifications for new chat messages.',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        'task_channel',
        'Task Alerts',
        description: 'Notifications for assigned tasks.',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        'invite_channel',
        'Invitations',
        description: 'Notifications for company or group invites.',
        importance: Importance.high,

      ),
    ];

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    for (final channel in channels) {
      await androidPlugin?.createNotificationChannel(channel);
    }
  }

  static Future<void> showChatNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'chat_channel',
      'Chat Messages',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(android: androidDetails),
      payload: 'chat',

    );
  }

  static Future<void> showTaskNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Alerts',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(android: androidDetails),
      payload: 'task',
    );
  }

  static Future<void> showInviteNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'invite_channel',
      'Invitations',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(android: androidDetails),
      payload: 'invite',
    );
  }
}
