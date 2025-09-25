import 'package:hive/hive.dart';
part 'loginResModel.g.dart';

class LoginResModel {
  int? status;
  String? message;
  String? userId;
  UserData? data;
  String? accessToken;

  LoginResModel(
      {this.status, this.message, this.userId, this.data, this.accessToken});

  LoginResModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    userId = json['user_id'];
    data = json['data'] != null ? new UserData.fromJson(json['data']) : null;
    accessToken = json['accessToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['user_id'] = this.userId;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['accessToken'] = this.accessToken;
    return data;
  }
}

@HiveType(typeId: 6)
class UserData {
  @HiveField(0)
  var userId;

  @HiveField(1)
  var regdDate;

  @HiveField(2)
  var userName;

  @HiveField(3)
  var status;

  @HiveField(4)
  var userRoleId;

  @HiveField(5)
  var empId;

  @HiveField(6)
  var userAbbr;

  @HiveField(7)
  var empName;

  @HiveField(8)
  var empImage;

  @HiveField(9)
  var empDob;

  @HiveField(10)
  var empAnniversary;

  @HiveField(11)
  var isGroup;

  @HiveField(12)
  var isCollection;

  @HiveField(13)
  var otp;


  var accessEmailCheckBox;
  var canViewClientContact;
  var canViewAll;
  var canEditAll;
  var canAddAll;
  var token;
  var password;
  UserData(
      {this.userId,
        this.regdDate,
        this.userName,
        this.password,
        this.status,
        this.userRoleId,
        this.empId,
        this.canViewAll,
        this.canEditAll,
        this.canAddAll,
        this.userAbbr,
        this.token,
        this.accessEmailCheckBox,
        this.canViewClientContact,
        this.empName,
        this.empImage,
        this.otp,
        this.empDob,
        this.isCollection,
        this.isGroup,
        this.empAnniversary});

  UserData.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    regdDate = json['regd_date'];
    userName = json['user_name'];
    otp = json['otp'];
    password = json['password'];
    status = json['status'];
    userRoleId = json['user_role_id'];
    token = json['token'];
    empId = json['emp_id'];
    canViewAll = json['can_view_all'];
    canEditAll = json['can_edit_all'];
    canAddAll = json['can_add_all'];
    userAbbr = json['user_abbr'];
    accessEmailCheckBox = json['access_email_check_box'];
    canViewClientContact = json['can_view_client_contact'];
    empName = json['emp_name'];
    empImage = json['emp_image'];
    empDob = json['emp_dob'];
    empAnniversary = json['emp_anniversary'];
    isGroup = json['is_group'];
    isCollection = json['is_collection'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['regd_date'] = this.regdDate;
    data['user_name'] = this.userName;
    data['password'] = this.password;
    data['status'] = this.status;
    data['otp'] = this.otp;
    data['user_role_id'] = this.userRoleId;
    data['token'] = this.token;
    data['emp_id'] = this.empId;
    data['can_view_all'] = this.canViewAll;
    data['can_edit_all'] = this.canEditAll;
    data['can_add_all'] = this.canAddAll;
    data['user_abbr'] = this.userAbbr;
    data['access_email_check_box'] = this.accessEmailCheckBox;
    data['can_view_client_contact'] = this.canViewClientContact;
    data['emp_name'] = this.empName;
    data['emp_image'] = this.empImage;
    data['emp_dob'] = this.empDob;
    data['is_group'] = this.isGroup;
    data['is_collection'] = this.isCollection;
    data['emp_anniversary'] = this.empAnniversary;
    return data;
  }
}
