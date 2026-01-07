
import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Screens/Chat/models/get_company_res_model.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_home_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_home_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/compnaies_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/socket_controller.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../Services/APIs/auth_service/auth_api_services_impl.dart';
import '../../../../Services/APIs/local_keys.dart';
import '../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../main.dart';
import '../../../../utils/custom_flashbar.dart';
import '../../../../utils/shares_pref_web.dart';
import '../../../Chat/api/apis.dart';
import '../../../Chat/api/session_alive.dart';
import '../../../Chat/screens/auth/models/get_uesr_Res_model.dart';
import '../../../Chat/screens/chat_tasks/Presentation/Views/chat_home_screen.dart';
import '../../../Chat/screens/chat_tasks/Presentation/Views/chat_task_shimmmer.dart';
import '../../../Chat/screens/chat_tasks/Presentation/Views/task_home_screen.dart';
import '../../../Settings/Model/get_company_roles_res_moel.dart';
import '../../../Settings/Model/get_nav_permission_res_model.dart';
import '../View/companies_screen.dart';
import '../View/gallery_view.dart';
import 'company_service.dart';

class DashboardController extends GetxController with WidgetsBindingObserver {
  var currentIndex = 0;
  UserDataAPI? user;

  void updateIndex(int index) {
    currentIndex = index;
    update();
  }

  bool _inited = false;

  // --- add: simple skeleton widgets to avoid white frame before nav loads
  List<Widget> get _fallbackScreens => [
   const ChatHomeShimmer(itemCount: 12),
   const ChatHomeShimmer(itemCount: 12),
  //
  ];


  List<BottomNavigationBarItem> get _fallbackBarItems =>  [
    BottomNavigationBarItem(
      icon: Image.asset(chatHome,height: 22),
      label: 'Chat',
    ),BottomNavigationBarItem(
      icon: Image.asset(tasksHome,height: 22),
      label: 'Task',
    ),BottomNavigationBarItem(
      icon: Image.asset(connectedAppIcon,height: 22),
      label: 'Companies',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(galleryIcon,height: 22),
      label: 'Gallery',
    ),
  ];

  // --- add: ensure we always have something to render
  void _ensureFallbackNavIfEmpty() {
    if (screens.isEmpty) {
      screens = _fallbackScreens;
    }
    if (barItems.isEmpty) {
      barItems = _fallbackBarItems;
    }
  }

  List<Widget> screens = [];

  List<BottomNavigationBarItem> barItems = [];
  initscres() async {
    if (_inited) {
      _ensureFallbackNavIfEmpty();
      update();
      return;
    }
    _inited = true;

    // (kept) registrations – wrapped in try to avoid crash if already registered
    try {
       Get.put<SocketController>( SocketController(), permanent: true);
    } catch (_) {}
    try { Get.lazyPut(() => DashboardController(), fenix: true); } catch (_) {}
    try { Get.lazyPut(() =>ChatHomeController(), fenix: true); } catch (_) {}
    try { Get.lazyPut(() => TaskHomeController(), fenix: true); } catch (_) {}
    try { Get.lazyPut(() => CompaniesController(), fenix: true); } catch (_) {}

    callNetworkCheck();

    // (kept) your mapping – but ensure non-empty fallbacks
    screens = bottomNavItems.map((nav) => screenFor(nav)).toList();
    barItems = bottomNavItems.map((NavigationItem nav) {
      return BottomNavigationBarItem(
        icon: Image.asset(
          iconFor(nav),
          height: 22,
        ),
        label: nav.navigationItem?.split(" ").first,
        tooltip:  nav.navigationItem
      );
    }).toList();

    // --- add: if user’s nav hasn’t arrived yet, show a minimal UI (no white)
    _ensureFallbackNavIfEmpty();

    // WidgetsBinding.instance.addObserver(this); // (kept commented)
    update();
  }

  Widget screenFor(NavigationItem nav) {
    switch (nav.navigationItem) {
      case 'Chat Button':
        return ChatsHomeScreen();
      case 'Task Button':
        return TaskHomeScreen();
      case 'Companies Button':
        return CompaniesScreen();

        
      case 'Gallery Button':
        return GalleryTab();
      default:
      // --- change: visible tiny loader instead of invisible container
        return const Center(child: IndicatorLoading());

    }
  }

  String iconFor(NavigationItem nav) {
    switch (nav.navigationItem) {
      case 'Chat Button':
        return chatHome;
      case 'Task Button':
        return tasksHome;
      case 'Companies Button':
        return connectedAppIcon;
      case 'Gallery Button':
        return galleryIcon;
      default:
        return appIcon;
    }
  }

  callNetworkCheck() async {
    try {
      // old line (kept) but wrapped safely
      await checkNetworkConnection(Get.context!);
    } catch (_) {
      // --- add: context may be null during early boot; retry shortly
      Future.delayed(const Duration(seconds: 1), () {
        final ctx = Get.context;
        if (ctx != null) {
          checkNetworkConnection(ctx);
        }
      });
    }
  }

  Future<void> checkNetworkConnection(BuildContext context) async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
    } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
    } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
    } else if (connectivityResult.contains(ConnectivityResult.other)) {
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      _showNoNetworkDialog(context);
    }
  }

  void _showNoNetworkDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('No Network Connection'),
          content: const Text(
              'Your mobile data is off or you are not connected to Wi-Fi. Please turn it on to continue using the app.'),
          actions: [
            TextButton(
              onPressed: () {
                // Exit the app if the user presses 'Exit'
                SystemNavigator.pop();
              },
              child: const Text('Exit'),
            ),
            TextButton(
              onPressed: () {
                // Just close the dialog if the user presses 'Cancel'
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> onCompanyChanged(int? companyId) async => refreshChats();

  @override
  void onInit() async {
    getCompany();
    _ensureFallbackNavIfEmpty();


    // getTopSixRecentChats();
    // futureChats = getTopSixRecentChats();
    super.onInit();
  }

  List<NavigationItem>? userNav = [];
  CompanyData? myCompany;
  getCompany() async {
    final svc = CompanyService.to;
    myCompany = svc.selected;
    update();
    // final svc = Get.put<CompanyService>(CompanyService());
    // await svc.init();
    //   myCompany = svc.selected;
      Future.delayed(const Duration(milliseconds: 500), () {
        hitAPIToGetUser(myCompany?.companyId);
      });


  }

  List<RolesData> rolesList = [];
  Future<void> hitAPIToGetAllRolesAPI() async {
    Get.find<PostApiServiceImpl>()
        .getCompanyRolesApiCall(myCompany?.companyId)
        .then((value) async {
      rolesList = value.data ?? [];
      update();
    }).onError((error, stackTrace) {
      update();
    });
  }

  List<NavigationItem> bottomNavItems = [];

  getUserNavigation() {
    if (bottomNavItems.isEmpty) {
      bottomNavItems = [
        NavigationItem(navigationItem: 'Chat Button', isActive: 1, sortingOrder: 1, navigationPlace: bottom_nav_key),
        NavigationItem(navigationItem: 'Task Button', isActive: 1, sortingOrder: 2, navigationPlace: bottom_nav_key),
        NavigationItem(navigationItem: 'Companies Button', isActive: 1, sortingOrder: 3, navigationPlace: bottom_nav_key),
        NavigationItem(navigationItem: 'Gallery Button', isActive: 1, sortingOrder: 4, navigationPlace: bottom_nav_key),
      ];
    }

    userNav = getNavigation();
    update();

    userNav = (userNav ?? [])
        .where((nav) => nav.navigationPlace == bottom_nav_key)
        .toList();

    // print(userNav?.map((v) => v.toJson()));
    // bottomNavItems = (userNav ?? [])
    //     .where(
    //         (nav) => nav.navigationPlace == bottom_nav_key && nav.isActive == 1)
    //     .toList()
    //   // sort by your configured order
    //   ..sort((a, b) => (a.sortingOrder ?? 0).compareTo(b.sortingOrder ?? 0));

    // print(bottomNavItems.map((v) => v.toJson()));
  }

  bool isLoadingPer = true;

  hitAPIToGetNavPermissions() async {
    Get.find<PostApiServiceImpl>()
        .getNavPerUSerApiCall(
            comId: myCompany?.companyId ?? 0,
            userComId: userData.userCompany?.userCompanyRoleId ?? 0)
        .then((value) async {
      isLoadingPer = false;
      userNav = value.data ?? [];
      saveNavigation(userNav ?? []);
      update();
    }).onError((error, stackTrace) {
      isLoadingPer = false;
      update();
    });
  }



  int length = 0;

  late Future<List<Map<String, dynamic>>> futureChats;

  var initData;

  UserDataAPI userData = UserDataAPI();

  Future<void> hitAPIToGetUser(comid) async {
    FocusManager.instance.primaryFocus!.unfocus();
    Get.find<AuthApiServiceImpl>()
        .getUserApiCall(companyId: comid)
        .then((value) async {
      userData = value.data!;
      await APIs.getFirebaseMessagingToken();
      saveUser(userData);
      _navigationLogic();
    }).onError((error, stackTrace) {
      customLoader.hide();
      errorDialog(error.toString());
      update();
    });
  }

  _navigationLogic() async {
    if (screens.isEmpty || barItems.isEmpty) {
      _ensureFallbackNavIfEmpty();
      update();
    }
    await hitAPIToGetAllRolesAPI();

    Future.delayed(Duration(milliseconds: 800), () {
      if (myCompany?.userCompanies?.userCompanyRoleId != null ||
          myCompany?.userCompanies?.userCompanyRole != null) {
        final selectedRoleId = myCompany?.userCompanies?.userCompanyRoleId;
        final selectedCompanyId = myCompany?.companyId;

// 3. Find the matching RoleData
        final matchingRole = rolesList.firstWhere(
          (r) =>
              r.userCompanyRoleId == selectedRoleId &&
              r.companyId == selectedCompanyId,
          orElse: () => RolesData(),
        );

// 4. Finally, extract its navigation items (or empty list if none)
        final navigationItems =
            matchingRole.navigationItems ?? <NavigationItem>[];

        saveNavigation(navigationItems);

        getUserNavigation();
        initscres();
      } else {
        hitAPIToGetNavPermissions();
        Future.delayed(Duration(milliseconds: 500), () {
          getUserNavigation();
          initscres();
        });
      }
    });
  }

  Future<void> refreshChats() async {
    // hitAPIToGetUser(myCompany);
    // futureChats = getTopSixRecentChats();
    // initData = await futureChats;
    update();
  }

  DateTime? currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime ?? DateTime.now()) >
            const Duration(seconds: 2)) {
      currentBackPressTime = now;
      toast("Press again to exit the app!");
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
