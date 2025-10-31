import 'dart:convert';

import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/company_service.dart';
import 'package:AccuChat/Screens/Settings/Model/get_nav_permission_res_model.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../Screens/Authentication/AuthResponseModel/loginResModel.dart';
import '../../Screens/Chat/models/get_company_res_model.dart';
import '../../Screens/Settings/Model/get_company_roles_res_moel.dart';
import '../../Screens/hive_boot.dart';
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

logoutLocal() async {
  // Get.find<CompanyService>().clear();
  // await Get.delete<CompanyService>(force: true);
  customLoader.show();
  await HiveBoot.closeAndDeleteAll(deleteFromDisk: true);
  // await HiveBoot.init();
  StorageService.remove(isFirstTime);
  StorageService.remove(isFirstTimeChatKey);
  StorageService.remove(user_mob);
  StorageService.remove(LOCALKEY_token);
  StorageService.remove(navigation_item_key);
  StorageService.remove(roles_data_key);
  StorageService.remove(bottom_nav_key);
  StorageService.remove(isLoggedIn);
  StorageService.remove(user_key);
  StorageService.clear();
  AppStorage().remove(LOCALKEY_token);
  AppStorage().remove(user_key);
  AppStorage().clear();
  Future.delayed(const Duration(milliseconds: 600),
      () => Get.offAllNamed(AppRoutes.login_r));
  customLoader.hide();
}

void saveNavigation(List<NavigationItem> data) {
  final navJson = data
      .map((nav) => nav.toJson()) // Map<String,dynamic>
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
    // web (SharedPreferences) – JSON string
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return UserDataAPI.fromJson(map);
  } else if (raw is Map) {
    // mobile (GetStorage) – already a map
    return UserDataAPI.fromJson(Map<String, dynamic>.from(raw));
  }
  return null;
}



class RememberMeModal {
  String? email;
  String? password;
  RememberMeModal({this.email, this.password});
}

class SaveUser {
  String? userid;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? address;
  String? birthday;
  String? profileUrl;
  String? gender;
  SaveUser({
    this.firstName,
    this.userid,
    this.lastName,
    this.email,
    this.phone,
    this.address,
    this.birthday,
    this.profileUrl,
    this.gender,
  });
}
