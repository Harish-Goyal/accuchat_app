import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/routes/app_pages.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/network_controller.dart';
import 'package:AccuChat/utils/shares_pref_web.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'Services/storage_service.dart';


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
  NotificationService.init();
  await LocalNotificationService.initialize(onSelect: handleNotificationTap);
  await LocalNotificationService.createAllChannels();
  await Hive.initFlutter();
  // Register adapters
  Hive.registerAdapter(CompanyDataAdapter());
  Hive.registerAdapter(UserCompaniesAdapter());
  Hive.registerAdapter(UserCompanyRoleAdapter());
  Hive.registerAdapter(CreatorAdapter());
  Hive.registerAdapter(MembersAdapter());
  // Hive.registerAdapter(UserChatListDataAdapter());
  // Hive.registerAdapter(EmployeeAdapter());
  // Hive.registerAdapter(LastMessageAdapter());
  // Hive.registerAdapter(ChatHistoryDataAdapter());
  // Hive.registerAdapter(SenderDataAdapter());
  // Hive.registerAdapter(UserDataAdapter());
  // Hive.registerAdapter(GroupMemberDataAdapter());
  Get.put(NetworkController(), permanent: true);
  await AppStorage().init(boxName: 'accu_chat');
  await StorageService.init();
  try {
    await Hive.openBox<CompanyData>(selected_company_box);
    await Hive.openBox('current');
    // await Hive.openBox<UserChatListData>('chatUserList');
    // await Hive.openBox<ChatHistoryData>('chatHistory');
  } catch (e) {
    debugPrint(e.toString());
  }


  await GetStorage.init('accuchat');
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  Get.put(CompanyService(), permanent: true);

  // await svc.init();
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
     const FirebaseOptions firebaseOptions = FirebaseOptions(
       apiKey: 'AIzaSyDSAwm0Ro420zfkcBnViLU7xdy8SfU6ImA',
       appId: '1:975726861063:android:b0f2917d0dbe74221083a2',
       messagingSenderId: '975726861063',
       projectId: 'accuchat-d5e99',
       storageBucket: 'accuchat-d5e99.firebasestorage.app',
     );
     await Firebase.initializeApp(options: firebaseOptions);


  // var result = await FlutterNotificationChannel().registerNotificationChannel(
  //     description: 'For Showing Message Notification',
  //     id: 'chats',
  //     importance: NotificationImportance.IMPORTANCE_HIGH,
  //     name: 'Chats');
  // debugPrint('\nNotification Channel Result: $result');
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

