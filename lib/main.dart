import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/routes/app_pages.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/no_network.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'Components/custom_loader.dart';
import 'Constants/app_theme.dart';
import 'Screens/Chat/helper/local_notification_channel.dart';
import 'Screens/Chat/models/get_company_res_model.dart';
import 'Screens/Home/Presentation/Controller/company_service.dart';
import 'Screens/Home/Presentation/Controller/socket_controller.dart';
import 'Services/APIs/auth_service/auth_api_services_impl.dart';
import 'Services/APIs/post/post_api_service_impl.dart';
import 'Services/hive_boot.dart';
import 'Screens/splash/binding/binding.dart';
import 'Services/notification_web_mobile.dart';
import 'Services/storage_service.dart';
import 'Services/subscription/billing_controller.dart';
import 'Services/subscription/billing_service.dart';
import 'firebase_options.dart';

CustomLoader customLoader = CustomLoader();
var log = Logger();

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

Future<void>? _bootOnce;

Future<void> main() async {
  Get.put(NoNetworkController(), permanent: true);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );
  final Future<void> firebaseInit = _initializeFirebase();
  final Future<void> notifInit = NotificationServicess.init(
    webVapidPublicKey:
    "BJt_tuDwKCr6OR8Gibo9KMKsJfSjB3rje9fn7Q31qGPyxAi9SKF11kf8HYOd__Zo7Wubg_xgbhkZzykxRojmN9g",
  );

  final Future<void> localNotifInit = (() async {
    await LocalNotificationService.initialize(
      onSelect: handleNotificationTap,
    );
    await LocalNotificationService.createAllChannels();
  })();
  await Future.wait<void>([
    firebaseInit.timeout(const Duration(seconds: 5), onTimeout: () => null),
    notifInit.timeout(const Duration(seconds: 4), onTimeout: () => null),
    localNotifInit.timeout(const Duration(seconds: 4), onTimeout: () => null),
  ]);
  await StorageService.init();
  await HiveBoot.init();
  await HiveBoot.openBoxOnce<CompanyData>(selectedCompanyBox);
  await Get.putAsync<CompanyService>(
        () async => await CompanyService().init(),
    permanent: true,
  );



  if (kIsWeb) {
    if (!Get.isRegistered<PostApiServiceImpl>()) {
      Get.put(PostApiServiceImpl(), permanent: true);
    }
    if (!Get.isRegistered<AuthApiServiceImpl>()) {
      Get.put(AuthApiServiceImpl(), permanent: true);
    }
  }
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    runApp(const MyApp());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootOnce ??=
          _deferredBoot();
    });
  });
}

const selectedCompanyBox = 'selected_company_box';
Future<void> _deferredBoot() async {
  final service = BillingService(
    baseUrl: 'https://api.accuchat.example',
    authTokenProvider: () async => '<JWT>',
  );
  final billingCtrl = Get.lazyPut(() => BillingController(service));

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final cache = PaintingBinding.instance.imageCache;
  cache.maximumSize = 150;
  cache.maximumSizeBytes = 80 << 20;
}

Future<void> clearHiveCompletely() async {
  await Hive.close();
  await Hive.deleteFromDisk();
}

void handleNotificationTap(String? payload) async {
  if (payload == 'invite') {
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
  } on FirebaseException catch (e) {
    debugPrint('Firebase error: ${e.message}');
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('📩 Background message received: ${message.data}');

}

class MyApp extends StatelessWidget {
  const MyApp();

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
      logWriterCallback:kIsWeb?null: LoggerX.write,
      builder: EasyLoading.init(),
      defaultTransition: Transition.cupertino,
      onReady: () {
        if (kIsWeb) {
          Future.delayed(const Duration(milliseconds: 50), () {
            Get.offAllNamed(AppRoutes.home);
          });
        }
      },
    );
  }
}

class LoggerX {
  static void write(String text, {bool isError = false}) {
    Future.microtask(() => isError ? log.v("$text") : log.i("$text"));
  }
}
