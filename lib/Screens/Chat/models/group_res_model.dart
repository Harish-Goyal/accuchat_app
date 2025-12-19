import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';

class GroupResModel {
  bool? success;
  int? code;
  String? message;
  UserDataAPI? data;

  GroupResModel({this.success, this.code, this.message, this.data});

  GroupResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new UserDataAPI.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class GroupUser {
  int? userId;
  String? userName;
  String? phone;
  String? email;
  int? isActive;
  String? userImage;
  String? about;
  String? userKey;
  String? createdOn;
  String? updatedOn;
  int? allowedCompanies;
  int? isDeleted;
  int? userCompanyRoleId;
  int? isGroup;
  int? isBroadcast;

  GroupUser(
      {this.userId,
        this.userName,
        this.phone,
        this.email,
        this.isActive,
        this.userImage,
        this.about,
        this.userKey,
        this.createdOn,
        this.updatedOn,
        this.allowedCompanies,
        this.isDeleted,
        this.userCompanyRoleId,
        this.isGroup,
        this.isBroadcast});

  GroupUser.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    userName = json['user_name'];
    phone = json['phone'];
    email = json['email'];
    isActive = json['is_active'];
    userImage = json['user_image'];
    about = json['about'];
    userKey = json['user_key'];
    createdOn = json['created_on'];
    updatedOn = json['updated_on'];
    allowedCompanies = json['allowed_companies'];
    isDeleted = json['is_deleted'];
    userCompanyRoleId = json['user_company_role_id'];
    isGroup = json['is_group'];
    isBroadcast = json['is_broadcast'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['is_active'] = this.isActive;
    data['user_image'] = this.userImage;
    data['about'] = this.about;
    data['user_key'] = this.userKey;
    data['created_on'] = this.createdOn;
    data['updated_on'] = this.updatedOn;
    data['allowed_companies'] = this.allowedCompanies;
    data['is_deleted'] = this.isDeleted;
    data['user_company_role_id'] = this.userCompanyRoleId;
    data['is_group'] = this.isGroup;
    data['is_broadcast'] = this.isBroadcast;
    return data;
  }
}
