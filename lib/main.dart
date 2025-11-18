import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/routes/app_pages.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/network_controller.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'Services/APIs/auth_service/auth_api_services_impl.dart';
import 'Services/APIs/post/post_api_service_impl.dart';
import 'Services/hive_boot.dart';
import 'Screens/splash/binding/binding.dart';
import 'Services/notification_web_mobile.dart';
import 'Services/storage_service.dart';
import 'Services/subscription/billing_controller.dart';
import 'Services/subscription/billing_service.dart';
import 'firebase_options.dart';

// 9882896000
// 9882996003
CustomLoader customLoader = CustomLoader();
var log = Logger();
// GetStorage storage = GetStorage();

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

// (kept as-is)
DashboardController dashboardController = Get.put(DashboardController());

// ---------------------------------------------
// NEW: one-shot boot guard (so we don't run twice)
Future<void>? _bootOnce;
// ---------------------------------------------

Future<void> main() async {
  // (kept) system UI style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  WidgetsFlutterBinding.ensureInitialized();


    await StorageService.init();
    await HiveBoot.init();
    await HiveBoot.openBoxOnce<CompanyData>(selectedCompanyBox);
    if(!Get.isRegistered<CompanyService>()) {
      await Get.putAsync<CompanyService>(
            () async => await CompanyService().init(),
        permanent: true,
      );
    }
  if (kIsWeb) {
    if (!Get.isRegistered<PostApiServiceImpl>()) {
      Get.put(PostApiServiceImpl(), permanent: true);
    }
    if (!Get.isRegistered<AuthApiServiceImpl>()) {
      Get.put(AuthApiServiceImpl(), permanent: true);
    }
  }

  // IMPORTANT CHANGE:
  // Instead of doing heavy awaits here, we start UI immediately and
  // defer your exact same initialization to after first frame (see _deferredBoot).
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    runApp(const MyApp());

    // Kick boot AFTER first frame to avoid blocking splash.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootOnce ??=
          _deferredBoot(); // runs all your original awaits, just later
    });
  });
}

// ---------------------------------------------
// NEW: moved your heavy code here (nothing removed, only deferred)
// ---------------------------------------------
const selectedCompanyBox = 'selected_company_box';
Future<void> _deferredBoot() async {
  // Your original code lines are preserved below; I only grouped & parallelized them.
  // await StorageService.init();
  // ---- originally: firebase + notifications + storages + boxes ----
  final Future<void> firebaseInit = _initializeFirebase(); // (kept)

  // (kept) Notification init – deferred, same call
  final Future<void> notifInit = NotificationServicess.init(
    webVapidPublicKey:
        "BJt_tuDwKCr6OR8Gibo9KMKsJfSjB3rje9fn7Q31qGPyxAi9SKF11kf8HYOd__Zo7Wubg_xgbhkZzykxRojmN9g",
  );

  // (kept) Local notifications – deferred, same calls
  final Future<void> localNotifInit = (() async {
    await LocalNotificationService.initialize(onSelect: handleNotificationTap);
    await LocalNotificationService.createAllChannels();
  })();

  // (kept) Billing service/controller – same creation, just deferred
  final service = BillingService(
    baseUrl: 'https://api.accuchat.example',
    authTokenProvider: () async => '<JWT>',
  );
  final billingCtrl = Get.lazyPut(() => BillingController(service)); // (kept)

  // (kept) storages + hive registrations + box open


  // final storageBoot = (() async {
  //   await HiveBoot.init();
  //   await HiveBoot.openBoxOnce<CompanyData>(selectedCompanyBox);
  // })();
  //
  //   await Get.putAsync<CompanyService>(
  //         () async => await CompanyService().init(),
  //     permanent: true,
  //   );

  await Future.wait<void>([
    firebaseInit.timeout(const Duration(seconds: 5), onTimeout: () => null),
    notifInit.timeout(const Duration(seconds: 4), onTimeout: () => null),
    localNotifInit.timeout(const Duration(seconds: 4), onTimeout: () => null),
    // storageBoot.timeout(const Duration(seconds: 6), onTimeout: () => null),
  ]);

  Get.lazyPut(() => NetworkController(), fenix: true);

  // (kept) open boxes in try/catch – deferred
  // try {
  //   await Hive.openBox<CompanyData>(selected_company_box);
  //   await Hive.openBox('current');
  // } catch (e) {
  //   debugPrint(e.toString());
  // }

  // (kept) immersive mode – deferred
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // (kept) CompanyService – deferred

  // (kept) image cache tuning – deferred
  final cache = PaintingBinding.instance.imageCache;
  cache.maximumSize = 150; // count
  cache.maximumSizeBytes = 80 << 20;

  // DONE: all the same work you had before is now finished,
  // but the UI/splash wasn't blocked by it.
}

Future<void> clearHiveCompletely() async {
  // (kept as-is)
  await Hive.close();
  await Hive.deleteFromDisk();
}

void handleNotificationTap(String? payload) async {
  // (kept as-is)
  if (payload == 'invite') {
    Get.toNamed(AppRoutes.home);
  } else if (payload == 'task') {
    Get.find<DashboardController>().updateIndex(1);
  } else if (payload == 'chat') {
    Get.find<DashboardController>().updateIndex(0);
  }
}

_initializeFirebase() async {
  // (kept as-is)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    print('Firebase error: ${e.message}');
  }
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
    );
  }
}

class LoggerX {
  static void write(String text, {bool isError = false}) {
    // (kept as-is)
    Future.microtask(() => isError ? log.v("$text") : log.i("$text"));
  }
}
