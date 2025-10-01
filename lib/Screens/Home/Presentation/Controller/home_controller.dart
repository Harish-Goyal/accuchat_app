import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Screens/Chat/models/get_company_res_model.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_home_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_home_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/compnaies_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/socket_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../Services/APIs/auth_service/auth_api_services_impl.dart';
import '../../../../Services/APIs/local_keys.dart';
import '../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../Services/subscription/billing_controller.dart';
import '../../../../Services/subscription/billing_service.dart';
import '../../../../main.dart';
import '../../../../utils/custom_flashbar.dart';
import '../../../Chat/api/apis.dart';
import '../../../Chat/screens/auth/models/get_uesr_Res_model.dart';
import '../../../Chat/screens/chat_tasks/Presentation/Views/chat_home_screen.dart';
import '../../../Chat/screens/chat_tasks/Presentation/Views/task_home_screen.dart';
import '../../../Settings/Model/get_company_roles_res_moel.dart';
import '../../../Settings/Model/get_nav_permission_res_model.dart';
import '../View/companies_screen.dart';
import 'company_service.dart';
class DashboardController extends GetxController with WidgetsBindingObserver{
  var currentIndex = 0;
  UserDataAPI? user;


  void updateIndex(int index) {
    currentIndex = index;

    update();

  }


  List<Widget> screens = [];

  List<BottomNavigationBarItem>  barItems=[];
  initscres() {
    Get.put<SocketController>(SocketController(), permanent: true);
    Get.lazyPut(() => DashboardController(), fenix: true);
    Get.lazyPut(() => ChatHomeController(), fenix: true);
    Get.lazyPut(() => TaskHomeController(), fenix: true);
    Get.lazyPut(() => CompaniesController(), fenix: true);
    callNetworkCheck();
    WidgetsBinding.instance.addObserver(this);
    screens= bottomNavItems
        .map((nav) => screenFor(nav))
        .toList();
    barItems = bottomNavItems.map((nav) {
      return BottomNavigationBarItem(
        icon: Image.asset(iconFor(nav),height: 22,),
        label: nav.navigationItem,
      );
    }).toList();

  }
  Widget screenFor(NavigationItem nav) {
    switch (nav.navigationItem) {
      case 'Chat Button':
        return ChatsHomeScreen();
      case 'Task Button':
        return TaskHomeScreen();
      case 'Companies Button':
        return  CompaniesScreen();
      default:
        return Container();  // fallback
    }
  }



  String iconFor(NavigationItem nav) {
    switch (nav.navigationItem) {
      case 'Chat Button': return chatHome;
      case 'Task Button': return tasksHome;
      case 'Companies Button': return connectedAppIcon;
      default: return appIcon;
    }
  }


  callNetworkCheck() async {
    await checkNetworkConnection(Get.context!);
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
  void onInit() async{
    getCompany();

    refreshChats();
    // getTopSixRecentChats();
    // futureChats = getTopSixRecentChats();
    super.onInit();
  }



  List<NavigationItem>? userNav=[];


  CompanyData? myCompany = CompanyData();
  getCompany()async{
    final svc     = Get.find<CompanyService>();

    myCompany = svc.selected;
    Future.delayed(const Duration(milliseconds: 400),(){
      hitAPIToGetUser();
    });

  }


  List<RolesData> rolesList=[];
  Future<void> hitAPIToGetAllRolesAPI() async {
    Get.find<PostApiServiceImpl>()
        .getCompanyRolesApiCall(myCompany?.companyId)
        .then((value) async {
      rolesList = value.data??[];
      update();
    }).onError((error, stackTrace) {
      update();
    });
  }
  List<NavigationItem> bottomNavItems=[];

  getUserNavigation(){
    userNav = getNavigation();
    update();

    userNav = (userNav??[])
        .where((nav) => nav.navigationPlace == bottom_nav_key)
        .toList();

    print(userNav?.map((v)=>v.toJson()));

    bottomNavItems =(userNav??[])
        .where((nav) => nav.navigationPlace == bottom_nav_key && nav.isActive == 1)
        .toList()
    // sort by your configured order
      ..sort((a, b) => (a.sortingOrder??0).compareTo(b.sortingOrder??0));

    print(bottomNavItems.map((v)=>v.toJson()));

  }


  bool isLoadingPer = true;

  hitAPIToGetNavPermissions() async {
    print("userData==========");
    print(userData.userName);
    Get.find<PostApiServiceImpl>()
        .getNavPerUSerApiCall(comId: myCompany?.companyId??0,userComId: userData.userCompany?.userCompanyRoleId??0)
        .then((value) async {
      isLoadingPer=false;
      userNav = value.data??[];
      saveNavigation(userNav??[]);
      update();
    }).onError((error, stackTrace) {
      isLoadingPer=false;
      update();
    });
  }




  int length = 0;

  late Future<List<Map<String,dynamic>>> futureChats;

  var initData;


  UserDataAPI userData = UserDataAPI();

  Future<void> hitAPIToGetUser() async {
    FocusManager.instance.primaryFocus!.unfocus();
    Get.find<AuthApiServiceImpl>()
        .getUserApiCall(companyId: myCompany?.companyId??0)
        .then((value) async {
      userData = value.data!;
      await APIs.getFirebaseMessagingToken();
      saveUser(userData);
      storage.write(userId, userData.userId);
      storage.write(user_mob, userData.phone??'');

      _navigationLogic();

    }).onError((error, stackTrace) {
      customLoader.hide();
      errorDialog(error.toString());
      update();
    });
  }



  _navigationLogic() async {
    await  hitAPIToGetAllRolesAPI();

    Future.delayed(Duration(milliseconds: 800),(){

      if(myCompany?.userCompanies?.userCompanyRoleId!=null || myCompany?.userCompanies?.userCompanyRole!=null) {
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
        final navigationItems = matchingRole.navigationItems ??
            <NavigationItem>[];

        saveNavigation(navigationItems);

        getUserNavigation();
        initscres();
      }else{

        hitAPIToGetNavPermissions();
        Future.delayed(Duration(milliseconds: 500),(){
          getUserNavigation();
          initscres();
        });
      }
    });

  }


  Future<void> refreshChats() async {
    hitAPIToGetUser();
    // futureChats = getTopSixRecentChats();
    // initData = await futureChats;
    update();
  }

  DateTime? currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime??DateTime.now()) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      toast( "Press again to exit the app!");
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
