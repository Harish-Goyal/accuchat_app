import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/invitations_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/invite_member_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/profile_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/update_comapny_controller.dart';
import 'package:get/get.dart';

import '../Presentation/Controller/company_members_controller.dart';
import '../Presentation/Controller/compnaies_controller.dart';
import '../Presentation/Controller/invite_member_with_role_controller.dart';

class DashboardBinding extends Bindings{
  @override
  void dependencies() {
    Get.put<DashboardController>(DashboardController());
  }

}

class ConnectAPPBinding extends Bindings{
  @override
  void dependencies() {
    Get.put<CompaniesController>(CompaniesController());
  }

}
class InviteMemBinding extends Bindings{
  @override
  void dependencies() {
    Get.put<InviteMemberController>(InviteMemberController());
  }
}


class InvitationsBinding extends Bindings{
  @override
  void dependencies() {
    Get.put<InvitationsController>(InvitationsController());
  }

}

class CompanyMemberBinding extends Bindings{
  @override
  void dependencies() {
    Get.put<CompanyMemberController>(CompanyMemberController());
  }
}

class UpdateCompanyBinding extends Bindings{
  @override
  void dependencies() {
    Get.put<UpdateCompanyController>(UpdateCompanyController());
  }
}


class HProfileBinding extends Bindings{
  @override
  void dependencies() {
    Get.put<HProfileController>(HProfileController());
  }
}

class InviteUserRoleBinding extends Bindings{
  @override
  void dependencies() {
    Get.put<InviteUserRoleController>(InviteUserRoleController());
  }
}