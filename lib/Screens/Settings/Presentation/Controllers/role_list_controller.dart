import 'dart:convert';

import 'package:AccuChat/Screens/Settings/Model/get_company_roles_res_moel.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../Services/APIs/local_keys.dart';
import '../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../main.dart';
import '../../../Chat/models/role_model.dart';
import '../../../Chat/models/get_company_res_model.dart';
import '../../../Home/Presentation/Controller/company_service.dart';
import '../../Model/get_nav_permission_res_model.dart';

class RoleListController extends GetxController {
  // List<Role> roles = [];
  bool isLoading = true;

  @override
  void onInit() {
    getCompany();
    hitAPIToGetAllRolesAPI();
    super.onInit();
  }

  CompanyData? company = CompanyData();

  CompanyData? getCompany() {
    final svc = CompanyService.to;
    company = svc.selected;
    return company;
  }

  bool isLoadingRoles =true;

  GetCompanyRolesResModel companyRolesResModel = GetCompanyRolesResModel();
  List<RolesData> rolesList=[];
  hitAPIToGetAllRolesAPI() async {
    Get.find<PostApiServiceImpl>()
        .getCompanyRolesApiCall(company?.companyId)
        .then((value) async {
      isLoadingRoles=false;
      companyRolesResModel = value;
      rolesList = companyRolesResModel.data??[];

      update();
    }).onError((error, stackTrace) {
      isLoadingRoles=false;
      update();
    });
  }


  Map<String, List<NavigationItem>> groupedNav = {};

  void groupNavigationItems(List<NavigationItem> allNavItems) {
    groupedNav = {};
    for (var item in allNavItems) {
      groupedNav
          .putIfAbsent(item.navigationPlace??'', () => <NavigationItem>[])
          .add(item);
    }
  }

  // Navigate to edit screen
  void editRole(RolesData role) {

    if (kIsWeb) {
      Get.toNamed(AppRoutes.edit_role);
      saveRoles(role);
    } else {


      Get.toNamed(AppRoutes.edit_role, arguments: {'role': role});
    }
  }
}
