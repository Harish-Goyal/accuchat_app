import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/routes/app_pages.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/network_controller.dart';
import 'package:AccuChat/utils/shares_pref_web.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'Components/custom_loader.dart';
import 'Constants/app_theme.dart';
import 'Screens/Chat/helper/local_notification_channel.dart';
import 'Screens/Chat/helper/notification_service.dart';
import 'Screens/Chat/models/get_company_res_model.dart';
import 'Screens/Chat/models/invite_model.dart';
import 'Screens/Home/Presentation/Controller/company_service.dart';
import 'Screens/splash/binding/binding.dart';
import 'Services/APIs/local_keys.dart';
import 'Services/notification_web_mobile.dart';
import 'Services/storage_service.dart';
import 'Services/subscription/billing_controller.dart';
import 'Services/subscription/billing_service.dart';
import 'Services/web_notification_channel.dart';
import 'firebase_options.dart';

import 'Services/web_notication_stub.dart'
if (dart.library.html) 'Services/web_notofication_local.dart';

// 9882896000
CustomLoader customLoader = CustomLoader();
var log = Logger();
GetStorage storage = GetStorage();

late Size mq;
bool isConnected = true;
bool isTaskMode = false;
bool isFirstTimeChat = true;
class GlobalVariable {
  static final GlobalKey<ScaffoldMessengerState> navState =
  GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorState =
  GlobalKey<NavigatorState>();
}

DashboardController dashboardController = Get.put(DashboardController());
Future<void> main() async {

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white, // Background color
    statusBarIconBrightness: Brightness.dark, // Icon color (dark = black icons)
    statusBarBrightness: Brightness.light, // For iOS
  ));
  WidgetsFlutterBinding.ensureInitialized();
  _initializeFirebase();
  if (kIsWeb) {
    await _registerServiceWorker(); // step 2
    await _initWebPush();           // step 3
  }
  // NotificationService.init();
  await NotificationServicess.init(
    webVapidPublicKey: "BJt_tuDwKCr6OR8Gibo9KMKsJfSjB3rje9fn7Q31qGPyxAi9SKF11kf8HYOd__Zo7Wubg_xgbhkZzykxRojmN9g"
  );
  await LocalNotificationService.initialize(onSelect: handleNotificationTap);
  await LocalNotificationService.createAllChannels();

  final service = BillingService(
    baseUrl: 'https://api.accuchat.example',
    authTokenProvider: () async => '<JWT>',
  );
  final billingCtrl = Get.lazyPut(()=>BillingController(service));


  final Future<void> firebaseInit = _initializeFirebase();
  final Future<void> storageBoot = (() async {
    await Hive.initFlutter();
    // Register ALL needed adapters here (deps first)
    Hive.registerAdapter(UserCompanyRoleAdapter());
    Hive.registerAdapter(MembersAdapter());
    Hive.registerAdapter(CreatorAdapter());
    Hive.registerAdapter(UserCompaniesAdapter());
    Hive.registerAdapter(CompanyDataAdapter());

    // Init both storages you rely on at boot
    await AppStorage().init(boxName: 'accu_chat');
    await GetStorage.init('accuchat');  // <-- moved to critical path

    // If your selection lives in Hive, open that box here too:
    await Hive.openBox<CompanyData>('selected_company_box');
  })();

  await Future.wait<void>([firebaseInit, storageBoot]);

  await StorageService.init();
  Get.lazyPut(()=>NetworkController(),fenix: true);

  try {
    await Hive.openBox<CompanyData>(selected_company_box);
    await Hive.openBox('current');
  } catch (e) {
    debugPrint(e.toString());
  }

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  Get.put(CompanyService(), permanent: true);
  final cache = PaintingBinding.instance.imageCache;
  cache.maximumSize = 150;              // count
  cache.maximumSizeBytes = 80 << 20;
  //for setting orientation to portrait only
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    runApp(const MyApp());
  });
}

Future<void> clearHiveCompletely() async {
  // Make sure no boxes are in use
  await Hive.close();

  // Deletes all box files / IndexedDB entries
  await Hive.deleteFromDisk();
}

void handleNotificationTap(String? payload)async {
  if (payload == 'invite') {
    // Navigate to pending invite screen
    // final inviteSnap = await FirebaseFirestore.instance
    //     .collection('invitations')
    //     .where('email', isEqualTo: APIs.me.phone=='null' || APIs.me.phone==null||
    //     APIs.me.phone==''? APIs.me.email:APIs.me.phone)
    //     .where('isAccepted', isEqualTo: false)
    //     .limit(1)
    //     .get();
    // final invite = InvitationModel.fromMap(inviteSnap.docs.first.data());
    // final inviteId = inviteSnap.docs.first.id;
    // Get.toNamed(AppRoutes.acceptInviteRoute,arguments: {
    //   'inviteId': inviteId,
    //   'company': invite.company!,
    // });
    Get.toNamed(AppRoutes.home);
  } else if (payload == 'task') {
    Get.find<DashboardController>().updateIndex(1);

  } else if (payload == 'chat') {
    Get.find<DashboardController>().updateIndex(0);
  }
}


  _initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }on FirebaseException catch (e) {
      print('Firebase error: ${e.message}');
    }

}

Future<void> _initWebPush() async {
  if (!kIsWeb) return;

  // Permission (browser-level)
  try {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true, badge: true, sound: true,
    );
    debugPrint('🔐 Web permission: ${settings.authorizationStatus}');
  } on FirebaseException catch (e, st) {
    debugPrint('🚫 requestPermission FirebaseException: ${e.code} ${e.message}');
    return; // abort early; token will also fail
  } catch (e, st) {
    debugPrint('🚫 requestPermission error: $e');
    return;
  }

  // Token with your VAPID key (Public key from Firebase console)
  const vapidKey = 'BJt_tuDwKCr6OR8Gibo9KMKsJfSjB3rje9fn7Q31qGPyxAi9SKF11kf8HYOd__Zo7Wubg_xgbhkZzykxRojmN9g';
  try {
    final token = await FirebaseMessaging.instance.getToken(vapidKey: vapidKey);
    debugPrint('✅ FCM Web Token: $token');
  } on FirebaseException catch (e, st) {
    debugPrint('🚫 getToken FirebaseException: ${e.code} ${e.message}');
    return;
  } catch (e, st) {
    debugPrint('🚫 getToken error: $e');
    return;
  }

  // Foreground messages
  FirebaseMessaging.onMessage.listen((m) {
    final title = m.notification?.title ?? 'New message';
    final body  = m.notification?.body  ?? '';
    final type  = m.data['type'] ?? 'default';
    final click = m.data['click_action'];

    showBrowserNotification(title, body, clickUrl: click);
    // sanity log
    print('Will show web notif -> $title | $body | $type');
    // showWebNotification(title: title, body: body, tag: type, data: m.data);
  });
}


Future<void> _registerServiceWorker() async {
  // if (html.window.navigator.serviceWorker != null) {
  //   try {
  //     final reg = await html.window.navigator.serviceWorker!
  //         .register('/firebase-messaging-sw.js');
  //     print('✅ Service worker registered: ${reg.scope}');
  //   } catch (e) {
  //     print('❌ Service worker registration failed: $e');
  //   }
  // } else {
  //   print('⚠️ Service workers are not supported in this browser.');
  // }
}

class MyApp extends StatelessWidget {
  const MyApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return GetMaterialApp(
      title: 'AccuChat',
      theme: themeData,
      initialBinding: InitBinding(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      scaffoldMessengerKey: GlobalVariable.navState,
      debugShowCheckedModeBanner: false,
      enableLog: true,
      logWriterCallback: LoggerX.write,
      builder: EasyLoading.init(),
      defaultTransition: Transition.cupertino,
    );
  }
}

class LoggerX {
  static void write(String text, {bool isError = false}) {
    Future.microtask(() => isError ? log.v("$text") : log.i("$text"));
  }
}

