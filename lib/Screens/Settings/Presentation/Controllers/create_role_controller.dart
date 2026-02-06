import 'package:AccuChat/Screens/Chat/models/get_company_res_model.dart';
import 'package:AccuChat/Screens/Settings/Model/get_nav_permission_res_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../main.dart';
import '../../../../utils/custom_flashbar.dart';
import '../../../Chat/helper/dialogs.dart';
import '../../../Home/Presentation/Controller/company_service.dart';

class CreateRoleController extends GetxController {
  final roleNameController = TextEditingController();
  String? selectedPermission;

  List<String> selectedPermissions = [];
  List<int> selectedPermissionsIds = [];
  bool isLoading = true;
  bool? isPerNotSelected;

  CompanyData? company = CompanyData();



  @override
  void onInit() {
    getCompany();
    hitAPIToGetNavPermissions();
    super.onInit();
  }



  CompanyData? getCompany() {
    final svc = CompanyService.to;
    company =svc.selected;
    update();
    return null;
  }


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

  createRoleApi() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    customLoader.show();
    var reqData = {
      "company_id": company?.companyId,
      "user_role":roleNameController.text.trim(),
      "is_admin": 0,
      "navigation_items": selectedPermissionsIds
    };

    Get.find<PostApiServiceImpl>()
        .createRoleApiCall(dataBody: reqData)
        .then((value) {
      customLoader.hide();
      Get.back();
      toast(value.message??'');
      update();
    }).onError((error, stackTrace) {
      update();
      Get.back();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }

  void onSubmit() {
    if (roleNameController.text.isEmpty || selectedPermission == null) {
      Dialogs.showSnackbar(Get.context!, 'Please fill all fields');
      return;
    }

    final payload = {
      'role_name': roleNameController.text,
      'permission': selectedPermission,
    };

    Dialogs.showSnackbar(Get.context!, 'Role created successfully');
    roleNameController.clear();
    selectedPermission = null;
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




}
