import 'package:AccuChat/Services/storage_service.dart';
import 'package:AccuChat/Services/subscription/billing_controller.dart';
import 'package:AccuChat/Services/subscription/billing_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import '../Screens/Chat/helper/local_notification_channel.dart';
import '../Screens/Chat/models/get_company_res_model.dart';
import '../Screens/Home/Presentation/Controller/company_service.dart';
import '../firebase_options.dart';
import '../main.dart';
import 'APIs/auth_service/auth_api_services_impl.dart';
import 'APIs/post/post_api_service_impl.dart';
import 'hive_boot.dart';
import 'notification_web_mobile.dart';

class AppBootstrapper extends StatefulWidget {
  final Widget child;
  const AppBootstrapper({super.key, required this.child});

  @override
  State<AppBootstrapper> createState() => _AppBootstrapperState();
}

class _AppBootstrapperState extends State<AppBootstrapper> {
  late final Future<void> _bootFuture;

  @override
  void initState() {
    super.initState();

    // Start boot AFTER first frame → first paint happens sooner
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootFuture = _boot();
      setState(() {}); // so FutureBuilder can react
    });

    // Fallback in case build happens before callback
    _bootFuture = Future.value();
  }

  Future<void> _boot() async {
    // ✅ System UI mode + image cache tuning can happen here
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    final cache = PaintingBinding.instance.imageCache;
    cache.maximumSize = 150;
    cache.maximumSizeBytes = 80 << 20;

    // ✅ Web-only service registration
    if (kIsWeb) {
      Get.put(PostApiServiceImpl(), permanent: true);
      Get.put(AuthApiServiceImpl(), permanent: true);
    }

    // ✅ Run independent init in parallel (don’t block each other)
    await Future.wait<void>([
      _initializeFirebase().timeout(const Duration(seconds: 5), onTimeout: () {}),
      NotificationServicess.init(
        webVapidPublicKey:
        "BJt_tuDwKCr6OR8Gibo9KMKsJfSjB3rje9fn7Q31qGPyxAi9SKF11kf8HYOd__Zo7Wubg_xgbhkZzykxRojmN9g",
      ).timeout(const Duration(seconds: 4), onTimeout: () {}),
      _initLocalNotifications().timeout(const Duration(seconds: 4), onTimeout: () {}),
    ]);

    // ✅ These usually hit disk → keep them out of main()
    await StorageService.init();
    await HiveBoot.init();
    await HiveBoot.openBoxOnce<CompanyData>(selectedCompanyBox);

    // ✅ GetX async service init
    await Get.putAsync<CompanyService>(
          () async => CompanyService().init(),
      permanent: true,
    );

    // ✅ Lazy register heavy/rare features
    Get.lazyPut<BillingController>(() {
      final service = BillingService(
        baseUrl: 'https://api.accuchat.example',
        authTokenProvider: () async => '<JWT>',
      );
      return BillingController(service);
    }, fenix: true);
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

  Future<void> _initLocalNotifications() async {
    await LocalNotificationService.initialize(onSelect: handleNotificationTap);
    await LocalNotificationService.createAllChannels();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _bootFuture,
      builder: (context, snap) {
        // Option A: show your splash while booting
        if (snap.connectionState != ConnectionState.done) {
          return const _SplashScreen(); // make your own
        }
        // Option B: always show app and just let it boot in background
        return widget.child;
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Material(
      child: Center(child: CircularProgressIndicator()),
    );
  }
}