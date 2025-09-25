import 'package:AccuChat/Screens/Settings/Presentation/Controllers/create_role_controller.dart';
import 'package:AccuChat/Screens/Settings/Presentation/Controllers/edit_role_controller.dart';
import 'package:AccuChat/Screens/Settings/Presentation/Controllers/settings_controller.dart';
import 'package:get/get.dart';

import '../Presentation/Controllers/all_settings_controller.dart';
import '../Presentation/Controllers/role_list_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SettingsController>(SettingsController());
  }
}

class AllSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AllSettingsController>(AllSettingsController());
  }
}

class CreateRoleBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CreateRoleController>(CreateRoleController());
  }
}

class RoleListBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<RoleListController>(RoleListController());
  }
}class EditRoleBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<EditRoleController>(EditRoleController());
  }
}