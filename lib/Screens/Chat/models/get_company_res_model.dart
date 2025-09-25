import 'package:hive/hive.dart';
part 'get_company_res_model.g.dart';



class CompanyResModel {


  bool? success;
  int? code;
  String? message;
  List<CompanyData>? data;

  CompanyResModel({this.success, this.code, this.message, this.data});

  CompanyResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = <CompanyData>[];
      json['data'].forEach((v) {
        data!.add(new CompanyData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

@HiveType(typeId: 1)
class CompanyData {
  @HiveField(0)
  int? companyId;
   @HiveField(1)
  String? companyName;
   @HiveField(2)
  String? address;
   @HiveField(3)
  String? website;
   @HiveField(4)
  String? email;
   @HiveField(5)
  String? phone;
   @HiveField(6)
  int? isAppCompany;
   @HiveField(7)
  String? createdOn;
   @HiveField(8)
  String? updatedOn;
   @HiveField(9)
  int? isActive;
   @HiveField(10)
  int? isDeleted;
   @HiveField(11)
  String? logo;
   @HiveField(12)
  int? createdBy;
   @HiveField(13)
  UserCompanies? userCompanies;
   @HiveField(14)
  Creator? creator;
   @HiveField(15)
  List<Members>? members;

  CompanyData(
      {this.companyId,
        this.companyName,
        this.address,
        this.website,
        this.email,
        this.phone,
        this.isAppCompany,
        this.createdOn,
        this.updatedOn,
        this.isActive,
        this.isDeleted,
        this.logo,
        this.createdBy,
        this.userCompanies,
        this.creator,
        this.members});

  CompanyData.fromJson(Map<String, dynamic> json) {
    companyId = json['company_id'];
    companyName = json['company_name'];
    address = json['address'];
    website = json['website'];
    email = json['email'];
    phone = json['phone'];
    isAppCompany = json['is_app_company'];
    createdOn = json['created_on'];
    updatedOn = json['updated_on'];
    isActive = json['is_active'];
    isDeleted = json['is_deleted'];
    logo = json['logo'];
    createdBy = json['created_by'];
    userCompanies = json['user_companies'] != null
        ? new UserCompanies.fromJson(json['user_companies'])
        : null;
    creator =
    json['creator'] != null ? new Creator.fromJson(json['creator']) : null;
    if (json['company_members'] != null) {
      members = <Members>[];
      json['company_members'].forEach((v) {
        members!.add(new Members.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['company_id'] = this.companyId;
    data['company_name'] = this.companyName;
    data['address'] = this.address;
    data['website'] = this.website;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['is_app_company'] = this.isAppCompany;
    data['created_on'] = this.createdOn;
    data['updated_on'] = this.updatedOn;
    data['is_active'] = this.isActive;
    data['is_deleted'] = this.isDeleted;
    data['logo'] = this.logo;
    data['created_by'] = this.createdBy;
    if (this.userCompanies != null) {
      data['user_companies'] = this.userCompanies!.toJson();
    }
    if (this.creator != null) {
      data['creator'] = this.creator!.toJson();
    }
    if (this.members != null) {
      data['company_members'] = this.members!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


@HiveType(typeId: 2)
class UserCompanies {
  @HiveField(0)
  int? userCompanyId;

  @HiveField(1)
  int? userId;

  @HiveField(2)
  int? companyId;

  @HiveField(3)
  int? isActive;

  @HiveField(4)
  int? userCompanyRoleId;

  @HiveField(5)
  String? createdOn;

  @HiveField(6)
  int? isDeleted;

  @HiveField(7)
  int? invitedBy;

  @HiveField(8)
  String? invitedOn;

  @HiveField(9)
  String? joinedOn;

  @HiveField(10)
  UserCompanyRole? userCompanyRole;

  UserCompanies(
      {this.userCompanyId,
        this.userId,
        this.companyId,
        this.isActive,
        this.userCompanyRoleId,
        this.createdOn,
        this.isDeleted,
        this.invitedBy,
        this.invitedOn,
        this.joinedOn,
        this.userCompanyRole});

  UserCompanies.fromJson(Map<String, dynamic> json) {
    userCompanyId = json['user_company_id'];
    userId = json['user_id'];
    companyId = json['company_id'];
    isActive = json['is_active'];
    userCompanyRoleId = json['user_company_role_id'];
    createdOn = json['created_on'];
    isDeleted = json['is_deleted'];
    invitedBy = json['invited_by'];
    invitedOn = json['invited_on'];
    joinedOn = json['joined_on'];
    userCompanyRole = json['user_company_role'] != null
        ? new UserCompanyRole.fromJson(json['user_company_role'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_company_id'] = this.userCompanyId;
    data['user_id'] = this.userId;
    data['company_id'] = this.companyId;
    data['is_active'] = this.isActive;
    data['user_company_role_id'] = this.userCompanyRoleId;
    data['created_on'] = this.createdOn;
    data['is_deleted'] = this.isDeleted;
    data['invited_by'] = this.invitedBy;
    data['invited_on'] = this.invitedOn;
    data['joined_on'] = this.joinedOn;
    if (this.userCompanyRole != null) {
      data['user_company_role'] = this.userCompanyRole!.toJson();
    }
    return data;
  }
}
@HiveType(typeId: 3)
class UserCompanyRole {
    @HiveField(0)
  String? userRole;
    @HiveField(1)
  int? isDefault;

  UserCompanyRole({this.userRole, this.isDefault});

  UserCompanyRole.fromJson(Map<String, dynamic> json) {
    userRole = json['user_role'];
    isDefault = json['is_default'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_role'] = this.userRole;
    data['is_default'] = this.isDefault;
    return data;
  }
}
@HiveType(typeId: 4)
class Creator {
  @HiveField(0)
  int? userId;
  @HiveField(1)
  String? userName;
  @HiveField(2)
  String? email;
  @HiveField(3)
  String? phone;
  @HiveField(4)
  int? allowedCompanies;

  Creator(
      {this.userId,
        this.userName,
        this.email,
        this.phone,
        this.allowedCompanies});

  Creator.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    userName = json['user_name'];
    email = json['email'];
    phone = json['phone'];
    allowedCompanies = json['allowed_companies'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['allowed_companies'] = this.allowedCompanies;
    return data;
  }
}
@HiveType(typeId: 5)
class Members {
  @HiveField(0)
  int? userId;
  @HiveField(1)
  String? userName;
  @HiveField(2)
  String? email;
  @HiveField(3)
  String? phone;

  Members({this.userId, this.userName, this.email, this.phone});

  Members.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    userName = json['user_name'];
    email = json['email'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['email'] = this.email;
    data['phone'] = this.phone;
    return data;
  }
}
