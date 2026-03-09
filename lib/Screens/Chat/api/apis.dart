import 'dart:io';
import 'package:AccuChat/Screens/Chat/api/session_alive.dart';
import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../Extension/user_Ext.dart';
import '../../../Services/APIs/post/post_api_service_impl.dart';


enum ChatType {
  oneToOne,
  group,
  broadcast,
}

class APIs {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Session get _session => Get.find<Session>();

  static UserDataAPI? get user => _session.user;

  static UserDataAPI get me => _session.user ?? UserDataAPIEmpty.empty();

  static Rxn<UserDataAPI> get meRx => _session.rxUser;

  /// Easy way to force refresh from server anywhere:
  static Future<UserDataAPI?> refreshMe({required int companyId}) =>
      _session.refreshUser(companyId: companyId);

  /// If some screen edits the profile and you want instant local reflect:
  static void patchMe(UserDataAPI updated) => _session.patchUserLocally(updated);


  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  static Future<String?>? _pendingToken;


/*  static Future<void> getFirebaseMessagingToken() async {
    if (_pendingToken != null) {
      print("tokenis =======0000");
      print(_pendingToken);
      final existing = await _pendingToken!;
      if (existing != null && existing.isNotEmpty) {
        me.pushToken = existing;
        hitAPIToPushRegister(existing);
      }
      return;
    }

    // ---- Permission handling (web + mobile) ----
    if (kIsWeb) {
      // On web, use requestPermission (works) and DO NOT return early
      final settings = await fMessaging.requestPermission(alert: true, badge: true, sound: true);
      if (settings.authorizationStatus != AuthorizationStatus.authorized) return;
    } else if (Platform.isIOS || Platform.isMacOS) {
      final s = await fMessaging.requestPermission(alert: true, badge: true, sound: true);
      if (s.authorizationStatus != AuthorizationStatus.authorized &&
          s.authorizationStatus != AuthorizationStatus.provisional) {
        return;
      }
      await fMessaging.setAutoInitEnabled(true);
    } else if (Platform.isAndroid) {
      if (await _isAndroid13OrAbove()) {
        final st = await Permission.notification.status;
        if (!st.isGranted) {
          final r = await Permission.notification.request();
          if (!r.isGranted) return;
        }
      }
      await fMessaging.setAutoInitEnabled(true);
    }

    // ---- Token fetch for ALL platforms (including web) ----
    _pendingToken = _getTokenWithBackoff();
    try {
      final token = await _pendingToken!;
      print("tokenis =======12313");
      print(token);
      if (token != null && token.isNotEmpty) {
        me.pushToken = token;
        hitAPIToPushRegister(token);
      }
    } finally {
      _pendingToken = null;
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((t) {
      if (t.isNotEmpty) {
        me.pushToken = t;
        hitAPIToPushRegister(t);
      }
    });
  }*/
  static Future<void> getFirebaseMessagingToken() async {
    if (_pendingToken != null) {
      final existing = await _pendingToken!;
      if (existing != null && existing.isNotEmpty) {
        me.pushToken = existing;
        hitAPIToPushRegister(existing);
      }
      return;
    }

    if (kIsWeb) {
      final current = await fMessaging.getNotificationSettings();
      if (current.authorizationStatus != AuthorizationStatus.authorized) {
        final s = await fMessaging.requestPermission(alert: true, badge: true, sound: true);
        if (s.authorizationStatus != AuthorizationStatus.authorized) return;
      }

    } else if (Platform.isIOS || Platform.isMacOS) {
      final s = await fMessaging.requestPermission(alert: true, badge: true, sound: true);
      if (s.authorizationStatus != AuthorizationStatus.authorized &&
          s.authorizationStatus != AuthorizationStatus.provisional) {
        return;
      }
      await fMessaging.setAutoInitEnabled(true);
    } else if (Platform.isAndroid) {
      // Android 13+ runtime notification permission
      if (await _isAndroid13OrAbove()) {
        final st = await Permission.notification.status;
        if (!st.isGranted) {
          final r = await Permission.notification.request();
          if (!r.isGranted) return;
        }
      }
      await fMessaging.setAutoInitEnabled(true);
    }

    _pendingToken = _getTokenWithBackoff();
    try {
      final token = await _pendingToken!;
      if (token != null && token.isNotEmpty) {
        me.pushToken = token;
        hitAPIToPushRegister(token);
      }
    } finally {
      _pendingToken = null;
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((t) {
      if (t.isNotEmpty) {
        me.pushToken = t;
        hitAPIToPushRegister(t);
      }
    });
  }

  // Retries only on transient/IOException conditions; caps attempts.
  static Future<String?> _getTokenWithBackoff() async {
    const int maxAttempts = 3;
    var delayMs = 500;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final token = await fMessaging.getToken(
          vapidKey: kIsWeb ? 'BJt_tuDwKCr6OR8Gibo9KMKsJfSjB3rje9fn7Q31qGPyxAi9SKF11kf8HYOd__Zo7Wubg_xgbhkZzykxRojmN9g' : null,
        );

        if (token != null && token.isNotEmpty) return token;

        // token null: not transient usually, but we can retry once or twice
      } catch (e, st) {
      }

      if (attempt < maxAttempts) {
        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2;
      }
    }
    return null;
  }
/*  static Future<String?> _getTokenWithBackoff() async {
    const int maxAttempts = 3;
    var delayMs = 500; // 0.5s → 1s → 2s
    var token;
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        if (kIsWeb) {
          token = await fMessaging.getToken();
          print("token _getTokenWithBackoff");
          print(token);

        } else {
          token = await fMessaging.getToken();
        }
      } catch (e) {
        final msg = e.toString();
        final isTransient = msg.contains('SERVICE_NOT_AVAILABLE') ||
            msg.contains('IOException') ||
            msg.contains('SERVICE_NOT_READY');

        if (!isTransient || attempt == maxAttempts) {
          break;
        }
        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2;
      }
    }
    return token;
  }*/

  static Future<bool> _isAndroid13OrAbove() async {
    final info = await DeviceInfoPlugin().androidInfo;
    return info.version.sdkInt >= 33;
  }
  static var deviceName, deviceType, deviceID;

  static getDeviceData() async {
    DeviceInfoPlugin info = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await info.androidInfo;
      deviceName = androidDeviceInfo.model;
      deviceID = androidDeviceInfo.device;
      deviceType = "1";
    } else if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await info.iosInfo;
      deviceName = iosDeviceInfo.model;
      deviceID = iosDeviceInfo.identifierForVendor;
      deviceType = "2";
    }
  }


  static Future<void> hitAPIToPushRegister(pushToken) async {

    if(!kIsWeb){
      DeviceInfoPlugin info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidDeviceInfo = await info.androidInfo;
        deviceName = androidDeviceInfo.model;
        deviceID = androidDeviceInfo.device;
        deviceType = "1";
      } else if (Platform.isIOS) {
        IosDeviceInfo iosDeviceInfo = await info.iosInfo;
        deviceName = iosDeviceInfo.model;
        deviceID = iosDeviceInfo.identifierForVendor;
        deviceType = "2";
      }
    }
    Map<String, dynamic> dataBody = {
      "token": pushToken,
      "platform": kIsWeb
          ? "web"
          : Platform.isAndroid
          ? "android"
          : 'ios',
      "device_id": deviceID,
    };
   await  Get.find<PostApiServiceImpl>()
        .registerPushTokenApiCall(dataBody: dataBody)
        .then((value) async {})
        .onError((error, stackTrace) {

       if(!kIsWeb) {
         FirebaseCrashlytics.instance.recordError(
             error, stackTrace, reason: 'apiCall failed');
       }
    });
  }

}


