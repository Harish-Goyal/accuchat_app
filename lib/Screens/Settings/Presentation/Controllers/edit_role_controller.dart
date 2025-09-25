import 'dart:convert';

import 'package:AccuChat/Screens/Settings/Presentation/Controllers/role_list_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../Services/APIs/local_keys.dart';
import '../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../main.dart';
import '../../../../utils/custom_flashbar.dart';
import '../../../Chat/models/get_company_res_model.dart';
import '../../../Home/Presentation/Controller/company_service.dart';
import '../../Model/get_company_roles_res_moel.dart';
import '../../Model/get_nav_permission_res_model.dart';

class EditRoleController extends GetxController {
  final roleNameController = TextEditingController();

  List<String> selectedPermissions = [];
  bool isLoading = true;
  RolesData? roleData;

  List<int> selectedPermissionsIds = [];


  @override
  void onInit() {

    hitAPIToGetNavPermissions();
    _getCompany();
    getArguments();
    fetchPermissions();
    super.onInit();
  }


  Map<String, List<NavigationItem>> get groupedSelected {
    final map = <String, List<NavigationItem>>{};
    for (final perm in navPermissionData) {
      if (selectedPermissionsIds.contains(perm.navigationItemId)) {
        map
            .putIfAbsent(perm.navigationPlace!, () => [])
            .add(perm);
      }
    }
    return map;
  }

  getArguments(){
    if (kIsWeb) {
      roleData = getRolesData();
      roleNameController.text = roleData?.userRole ?? '';
      selectedPermissions = List.from(
          roleData!.navigationItems!.map((v) => v.navigationItem ?? '')
              .toList());
    } else {
      if (Get.arguments != null) {
        roleData = Get.arguments['role'];
        roleNameController.text = roleData?.userRole ?? '';
        selectedPermissions = List.from(
            roleData!.navigationItems!.map((v) => v.navigationItem ?? '')
                .toList());
      }
    }
  }

  CompanyData? myCompany = CompanyData();
  _getCompany(){
    final svc     = Get.find<CompanyService>();
    myCompany = svc.selected;
    update();


  }


  List<NavigationItem> permissions = [];
  List<NavigationItem> navPermissionData = [];

  bool isLoadingPer = true;

  hitAPIToGetNavPermissions() async {
    Get.find<PostApiServiceImpl>()
        .getNavigationPermissionApiCall()
        .then((value) async {
      isLoadingPer=false;
      navPermissionData = value.data??[];
      update();
    }).onError((error, stackTrace) {
      isLoadingPer=false;
      update();
    });
  }

  List<int>? selectedIds;
  List<String>? selectedNames;
  Future<void> fetchPermissions() async {
    permissions = navPermissionData;
    permissions = roleData?.navigationItems??[];
    selectedIds = permissions.map((e) => e.navigationItemId ?? 0).toList();
    selectedNames = permissions.map((e) => e.navigationItem ?? '').toList();
    selectedPermissionsIds= selectedIds??[];
    selectedPermissions= selectedNames??[];
    isLoading = false;
    update();
  }

  void togglePermission(String perm) {
    if (selectedPermissions.contains(perm)) {
      selectedPermissions.remove(perm);
    } else {
      selectedPermissions.add(perm);
    }
    update();
  }

  void selectIds(id) {
    if (selectedPermissionsIds.contains(id)) {
      selectedPermissionsIds.remove(id);
    } else {
      selectedPermissionsIds.add(id);
    }
    update();
  }


  void removePermission(String perm) {
    selectedPermissions.remove(perm);
    update();
  }


  updateRoleApi() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    customLoader.show();
    var reqData = {
      "company_id": myCompany?.companyId,
      "user_role":roleNameController.text.trim(),
      "is_admin": 0,
      "navigation_items": selectedPermissionsIds
    };

    Get.find<PostApiServiceImpl>()
        .updateRoleApiCall(dataBody: reqData,roleId: roleData?.userCompanyRoleId)
        .then((value) {
      customLoader.hide();
      Get.back();
      toast(value.message??'');
      Get.find<RoleListController>().hitAPIToGetAllRolesAPI();
      update();
    }).onError((error, stackTrace) {
      update();
      Get.back();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }

}