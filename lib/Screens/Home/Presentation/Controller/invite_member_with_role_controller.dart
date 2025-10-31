import 'package:AccuChat/Screens/Chat/api/apis.dart';
import 'package:AccuChat/Screens/Chat/models/get_company_res_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../main.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/custom_flashbar.dart';
import '../../../Chat/helper/notification_service.dart';
import '../../../Settings/Model/get_company_roles_res_moel.dart';
import 'company_service.dart';
class InviteUser {
  final String name;
  final String mobile;
  bool? isSelected;

  InviteUser({
    required this.name,
    required this.mobile,
    this.isSelected,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is InviteUser &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              mobile == other.mobile;

  @override
  int get hashCode => name.hashCode ^ mobile.hashCode;
}



class InviteUserRoleController extends GetxController {
  List<InviteUser> users = [];
  var companyId;

  List<TextEditingController> nameControllers =[];


  @override
  void onInit() {
    _getCom();
    initData();
    hitAPIToGetAllRolesAPI();
    super.onInit();
  }

  final allRoles = ['Admin', 'Member', 'Viewer'];



  void toggleRole(InviteUser user, bool? val) {

    user.isSelected = val;
    update();
  }

  String selectedRole = '';

  void selectAllRoles() {
    for (var user in users) {
      user.isSelected = true;
    }
    update();
  }

  void deselectAllRoles() {
    for (var user in users) {
      user.isSelected = false;
    }
    update();
  }

  List<String> phoneList = [];
  initData(){
    if (Get.arguments != null) {
      users = Get.arguments['selectedUser'];
      companyId = Get.arguments['companyId'];
      phoneList = Get.arguments['contactList'];
      selectedInvitesContacts.addAll([ReqInviteModel()]);
      ensureInviteFormKeysLength(users.length);
      nameControllers= List.generate(users.length, (i)=>TextEditingController(text:users[i].name??'' ));
    }

  }

  // in your <some>Controller (the same 'controller' you use in the builder)
  final List<GlobalKey<FormState>> inviteFormKeys = [];

// Call this whenever users list length can change (e.g., after fetch/filter)
  void ensureInviteFormKeysLength(int len) {
    while (inviteFormKeys.length < len) {
      inviteFormKeys.add(GlobalKey<FormState>());
    }
    // optional: if list shrinks, you can keep extra keys (no harm), or trim:
    // if (inviteFormKeys.length > len) inviteFormKeys.removeRange(len, inviteFormKeys.length);
  }

  CompanyData? myCompany =CompanyData();
  _getCom(){
    final svc = Get.find<CompanyService>();
    myCompany = svc.selected;
  }

  List<ReqInviteModel> selectedInvitesContacts = [];

  hitAPIToSendInvites() async {
    customLoader.show();
    Map<String, dynamic> postData = {
      "companyId": myCompany?.companyId,
      "companyUserInvites": selectedInvitesContacts.map((v)=>v.toJson()).toList()
    };
    Get.find<PostApiServiceImpl>()
        .sendInvitesToJoinCompanyAPI(dataBody: postData)
        .then((value) async {
      toast(value.message);
      Get.offAllNamed(AppRoutes.home);
      customLoader.hide();
      Get.back();
      update();




    }).onError((error, stackTrace) {
      update();
    });
  }


  bool isLoadingRoles =true;

  GetCompanyRolesResModel companyRolesResModel = GetCompanyRolesResModel();
  List<RolesData> rolesList=[];
  hitAPIToGetAllRolesAPI() async {
    Get.find<PostApiServiceImpl>()
        .getCompanyRolesApiCall(companyId)
        .then((value) async {
      isLoadingRoles=false;
      companyRolesResModel = value;
      rolesList = companyRolesResModel.data??[];
      update();


      if (rolesList.isNotEmpty) {
        final defaultRole = rolesList
            .firstWhere(
              (r) => r.isDefault == 1,
          orElse: () => rolesList.first,
        )
            .userCompanyRoleId;
        selectedInvitesContacts = users
            .map((user) => ReqInviteModel(
          toPhone: user.mobile,
          name: user.name??'',
          roleId: defaultRole,
        )).toList();
      }
    }).onError((error, stackTrace) {
      isLoadingRoles=false;
      update();
    });
  }


  void updateRoleForUser(String mobile, int roleId,name ,i) {
    final index = selectedInvitesContacts.indexWhere((e) => e.toPhone == mobile);
    if (index != -1) {
      selectedInvitesContacts[index].roleId = roleId;
      // ✅ added: keep latest text-field name in payload
      selectedInvitesContacts[index].name = nameControllers[i].text.trim();
    } else {
      selectedInvitesContacts.add(ReqInviteModel(
        toPhone: mobile,
        name: nameControllers[i].text.trim(),
        roleId: roleId,
      ));
    }
    update();
  }


  int? getRoleIdForUser(String mobile) {
    return selectedInvitesContacts
        .firstWhereOrNull((e) => e.toPhone == mobile)
        ?.roleId;
  }

  String getRoleNameForUser(String mobile) {
    final roleId = getRoleIdForUser(mobile);
    return rolesList
        .firstWhereOrNull((r) => r.userCompanyRoleId == roleId)
        ?.userRole ??
        (rolesList.isNotEmpty ? rolesList.first.userRole ?? '' : '');
  }
}


class ReqInviteModel{
  String? toPhone;
  String? name;
  int? roleId;

  ReqInviteModel({this.toPhone,this.roleId,this.name});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['to_phone_email'] = this.toPhone;
    data['user_company_role_id'] = this.roleId;
    data['contact_name'] = this.name;
    return data;
  }

}
