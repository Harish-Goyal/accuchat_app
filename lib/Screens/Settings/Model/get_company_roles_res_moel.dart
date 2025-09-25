import 'get_nav_permission_res_model.dart';

class GetCompanyRolesResModel {
  bool? success;
  int? code;
  String? message;
  List<RolesData>? data;

  GetCompanyRolesResModel({this.success, this.code, this.message, this.data});

  GetCompanyRolesResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = <RolesData>[];
      json['data'].forEach((v) {
        data!.add(new RolesData.fromJson(v));
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

class RolesData {
  int? userCompanyRoleId;
  int? companyId;
  String? userRole;
  int? isAdmin;
  String? createdOn;
  String? updatedOn;
  int? isMember;
  int? isDefault;
  Company? company;
  List<NavigationItem>? navigationItems;

  RolesData(
      {this.userCompanyRoleId,
        this.companyId,
        this.userRole,
        this.isAdmin,
        this.createdOn,
        this.updatedOn,
        this.isMember,
        this.isDefault,
        this.company,
        this.navigationItems});

  // factory RolesData.fromJson(Map<String,dynamic> json) => RolesData(
  //   userCompanyRoleId: json['user_company_role_id'],
  //   companyId:         json['company_id'],
  //   navigationItems:   (json['navigation_items'] as List)
  //       .map((e) => NavigationItem.fromJson(e))
  //       .toList(),
  // );

  RolesData.fromJson(Map<String, dynamic> json) {
    userCompanyRoleId = json['user_company_role_id'];
    companyId = json['company_id'];
    userRole = json['user_role'];
    isAdmin = json['is_admin'];
    createdOn = json['created_on'];
    updatedOn = json['updated_on'];
    isMember = json['is_member'];
    isDefault = json['is_default'];
    company =
    json['company'] != null ? new Company.fromJson(json['company']) : null;
    if (json['navigation_items'] != null) {
      navigationItems = <NavigationItem>[];
      json['navigation_items'].forEach((v) {
        navigationItems!.add(new NavigationItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_company_role_id'] = this.userCompanyRoleId;
    data['company_id'] = this.companyId;
    data['user_role'] = this.userRole;
    data['is_admin'] = this.isAdmin;
    data['created_on'] = this.createdOn;
    data['updated_on'] = this.updatedOn;
    data['is_member'] = this.isMember;
    data['is_default'] = this.isDefault;
    if (this.company != null) {
      data['company'] = this.company!.toJson();
    }
    if (this.navigationItems != null) {
      data['navigation_items'] =
          this.navigationItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Company {
  int? companyId;
  String? companyName;
  String? address;
  String? email;
  String? phone;
  String? logo;

  Company(
      {this.companyId,
        this.companyName,
        this.address,
        this.email,
        this.phone,
        this.logo});

  Company.fromJson(Map<String, dynamic> json) {
    companyId = json['company_id'];
    companyName = json['company_name'];
    address = json['address'];
    email = json['email'];
    phone = json['phone'];
    logo = json['logo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['company_id'] = this.companyId;
    data['company_name'] = this.companyName;
    data['address'] = this.address;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['logo'] = this.logo;
    return data;
  }
}


