import 'dart:convert';

import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/company_service.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/socket_controller.dart';
import 'package:AccuChat/Screens/Settings/Model/get_nav_permission_res_model.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import '../../Screens/Chat/api/session_alive.dart';
import '../../Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_home_controller.dart';
import '../../Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_screen_controller.dart';
import '../../Screens/Settings/Model/get_company_roles_res_moel.dart';
import '../hive_boot.dart';
import '../../main.dart';
import '../../utils/shares_pref_web.dart';
import '../storage_service.dart';
const String isFirstTime = 'isFirstTime';
const String isCompanyCreated = 'isCompanyCreated';
const String isFirstTimeChatKey = 'isFirstTimeChatKey';
const String isLoggedIn = 'isLoggedIn';
const String userId = 'userId';
const String user_mob = 'user_mob';
const String companyIDKey = 'companyIDKey';
const String userName = 'userName';
const String empIdKey = 'empIdKey';
const String userRoleId = 'userRoleId';
const String emailID = 'emailID';
const String domainName = 'domainName';
const String LOCALKEY_token = "LOCALKEY_token";
const String user_key = "user_key";
const String RefreshToken = "RefreshToken";
const String selectedCompany = "selectedCompany";
const String navigation_item_key = "navigation_item_key";
const String roles_data_key = "roles_data_key";

//Navigations Key
const String bottom_nav_key = "bottom_navigation";
const String recent_chat_screen_key = "recent_chat_screen";
const String chat_details_key = "chat_details";
const String recent_Task_screen_key = "recent_Task_screen";
const String task_details_key = "task_details";
const String manage_companies_key = "manage_companies";
const String update_company_key = "update_company";
const String settings_key = "settings";

const String rememberMe = 'rememberMe';
const String emailKey = 'emailKey';
const String passwordKey = 'passwordKey';
const String profileKey = 'profile_img';
const String logoKey = 'company_logo';
const String keyfirstName = 'keyfirstName';
const String keyId = 'keyId';
const String keylastName = 'keylastName';
const String keyemail = 'keyemail';
const String keyphone = 'keyphone';
const String keyaddress = 'keyaddress';
const String keybirthday = 'keybirthday';
const String keyprofileUrl = 'keyprofileUrl';
const String keyGender = 'keyGender';
const String wishListhData = 'wishListhData';
const String wishlistedStatus = 'wishlistedStatus';
const String lastSearchKey = 'wishlistedStatus';
const String privacy = 'privacy-policy';
const String legal = 'legal';
const String refundPolicy = 'refund-policy';
const String termsAndC = 'terms-conditions';
const String aboutUs = 'about-us';
const String userAgreement = 'user-agreement';
const String accomodationtype = "5";
const String facilitiesType = "6";
const String selected_company_box = "selected_company_box";

// void saveCompany(CompanyData data) {
//   storage.write(selectedCompany, data.toJson());
// }

void saveRoles(RolesData data) {
  StorageService.writeJson(roles_data_key, data.toJson());
}

// CompanyData? getCompany() {
//   final json = storage.read(selectedCompany);
//   if (json != null) {
//     return CompanyData.fromJson(Map<String, dynamic>.from(json));
//   }
//   return null;
// }

RolesData? getRolesData() {
  final json = StorageService.readJson(roles_data_key);
  if (json != null) {
    return RolesData.fromJson(Map<String, dynamic>.from(json));
  }
  return null;
}

bool _isLoggingOut = false;

Future<void> _disablePushOnLogout() async {
  final fcm = FirebaseMessaging.instance;

  try {
    // Example topics - replace with yours
    // await fcm.unsubscribeFromTopic('all');
    // await fcm.unsubscribeFromTopic('company_${CompanyService.to.companyId}');
    // await fcm.unsubscribeFromTopic('user_${Session.to.userId}');
  } catch (_) {}

  // 2) Remove token from backend
  try {
    final token = await fcm.getToken();
    if (token != null && token.isNotEmpty) {
      // call your API to remove this token for the user
      // await ApiService.removeFcmToken(token);
    }
  } catch (_) {}

  // 3) Delete token locally (optional but effective)
  try {
    await fcm.deleteToken();
  } catch (_) {}
}

Future<void> logoutLocal() async {
  if (_isLoggingOut) return;
  _isLoggingOut = true;

  customLoader.show();

  try {
    await _disablePushOnLogout();

    if (Get.isRegistered<SocketController>()) {
      try {
        Get.find<SocketController>().disconnect();
      } catch (_) {}
      Get.delete<SocketController>(force: true);
    }

    Get.delete<Session>(force: true);
    Get.delete<ChatScreenController>(force: true);
    Get.delete<ChatHomeController>(force: true);

    await StorageService.clear();
    await AppStorage().clear();

    if (Get.isRegistered<CompanyService>()) {
      try { await CompanyService.to.closeBox(); } catch (_) {}
      Get.delete<CompanyService>(force: true);
    }

    try { await HiveBoot.closeAndDeleteAll(deleteFromDisk: true); } catch (_) {}

  }catch(e){
    customLoader.hide();
    _isLoggingOut = false;
    // 3) Navigate after a tiny delay / next tick
    await Future.delayed(const Duration(milliseconds: 50));
    Get.offAllNamed(AppRoutes.login_r);
  } finally {
    // 1) Close overlays first (most important)
    try { Get.closeCurrentSnackbar(); } catch (_) {}
    try { Get.closeAllSnackbars(); } catch (_) {}

    // 2) Then hide your loader (if it uses overlay/dialog)
    customLoader.hide();
    customLoader.hide();

   _isLoggingOut = false;

    // 3) Navigate after a tiny delay / next tick
    await Future.delayed(const Duration(milliseconds: 50));
    Get.offAllNamed(AppRoutes.login_r);
  }
}


/*
Future<void> logoutLocal() async {
  if (_isLoggingOut) return;
  _isLoggingOut = true;
  customLoader.show();
  try {
    _disablePushOnLogout();
    try {
      if (Get.isRegistered<SocketController>()) {
        final s = Get.find<SocketController>();
        s.disconnect();
        Get.delete<SocketController>(force: true);
      }
    } catch (_) {}

    if (Get.isRegistered<Session>()) {
      Get.delete<Session>(force: true);
    }
    if (Get.isRegistered<ChatScreenController>()) {
      Get.delete<ChatScreenController>(force: true);
    }
    if (Get.isRegistered<ChatHomeController>()) {
      Get.delete<ChatHomeController>(force: true);
    }
    await StorageService.clear();
    await AppStorage().clear();

    if (Get.isRegistered<CompanyService>()) {
      try { await CompanyService.to.closeBox(); } catch (_) {}
      Get.delete<CompanyService>(force: true);
    }
    try {
      await HiveBoot.closeAndDeleteAll(deleteFromDisk: true);
    } catch (_) {}
  } finally {
    customLoader.hide();
    await Future.delayed(const Duration(milliseconds: 50));
    Get.offAllNamed(AppRoutes.login_r);
    _isLoggingOut = false;
  }
}*/



/*
Future<void> logoutLocal() async {
  customLoader.show();

  // 1️⃣ DISCONNECT SOCKET (MOST IMPORTANT)
  try {
    Get.find<SocketController>().disconnect();
    Get.delete<SocketController>(force: true);
  } catch (_) {}

  if (Get.isRegistered<Session>()) {
    await Get.delete<Session>(force: true);
  }
  if (Get.isRegistered<ChatScreenController>()) {
    await Get.delete<ChatScreenController>(force: true);
  }
  if (Get.isRegistered<ChatHomeController>()) {
    await Get.delete<ChatHomeController>(force: true);
  }

  // 4. STORAGE CLEAR
  await StorageService.clear();
  await AppStorage().clear();

  // 5. COMPANY SERVICE
  if (Get.isRegistered<CompanyService>()) {
    try { await CompanyService.to.closeBox(); } catch (_) {}
    await Get.delete<CompanyService>(force: true);
  }

  // 6. HIVE
  await HiveBoot.closeAndDeleteAll(deleteFromDisk: true);

  // 7. NAVIGATION
  Get.offAllNamed(AppRoutes.login_r);

  customLoader.hide();
}*/


void saveNavigation(List<NavigationItem> data) {
  final navJson = data
      .map((nav) => nav.toJson())
      .toList();
  StorageService.writeJsonList(navigation_item_key, navJson);
}

List<NavigationItem>? getNavigation() {
  final json = StorageService.readJsonList(navigation_item_key);
  if (json != null) {
    final storedNavs = (json)
        .map((e) => NavigationItem.fromJson(e))
        .toList();
    return storedNavs;
  }
  return null;
}

// RememberMeModal? getRememberMe() {
//   String? email = storage.read(emailKey);
//   String? password = storage.read(passwordKey);
//   if ((email ?? "").isNotEmpty && (password ?? "").isNotEmpty) {
//     return RememberMeModal(email: email, password: password);
//   }
// }

Future<void> saveUser(UserDataAPI? user) async {
  if (user == null) {
    await AppStorage().remove(user_key);
  } else {
    await AppStorage().write(user_key, jsonEncode(user.toJson()));
  }
}

// READ
/*Future<UserDataAPI?> getUser() async {
  final jsonStr = AppStorage().read<String>(user_key);
  if (jsonStr == null || jsonStr.isEmpty) return null;
  return UserDataAPI.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
}*/

/*UserDataAPI? getUser() {
  final json = storage.read(user_key);
  if (json != null) {
    return UserDataAPI.fromJson(Map<String, dynamic>.from(json));
  }
  return null;
}*/

UserDataAPI? getUser() {
  final raw = AppStorage().read<dynamic>(user_key);
  if (raw == null) return null;
  if (raw is String) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return UserDataAPI.fromJson(map);
  } else if (raw is Map) {
    return UserDataAPI.fromJson(Map<String, dynamic>.from(raw));
  }
  return null;
}




