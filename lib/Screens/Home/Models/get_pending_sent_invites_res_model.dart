import 'package:AccuChat/Screens/Chat/models/get_company_res_model.dart';

class PendingSentInvitesResModel {
  bool? success;
  int? code;
  String? message;
  List<SentInvitesData>? data;

  PendingSentInvitesResModel(
      {this.success, this.code, this.message, this.data});

  PendingSentInvitesResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = <SentInvitesData>[];
      json['data'].forEach((v) {
        data!.add(new SentInvitesData.fromJson(v));
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

class SentInvitesData {
  int? inviteId;
  int? senderId;
  int? companyId;
  String? toPhoneEmail;
  String? sentOn;
  String? acceptedOn;
  int? userCompanyRoleId;
  Sender? sender;
  CompanyData? company;

  SentInvitesData(
      {this.inviteId,
        this.senderId,
        this.companyId,
        this.toPhoneEmail,
        this.sentOn,
        this.acceptedOn,
        this.userCompanyRoleId,
        this.sender,
        this.company});

  SentInvitesData.fromJson(Map<String, dynamic> json) {
    inviteId = json['invite_id'];
    senderId = json['sender_id'];
    companyId = json['company_id'];
    toPhoneEmail = json['to_phone_email'];
    sentOn = json['sent_on'];
    acceptedOn = json['accepted_on'];
    userCompanyRoleId = json['user_company_role_id'];
    sender =
    json['sender'] != null ? new Sender.fromJson(json['sender']) : null;
    company =
    json['company'] != null ? new CompanyData.fromJson(json['company']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['invite_id'] = this.inviteId;
    data['sender_id'] = this.senderId;
    data['company_id'] = this.companyId;
    data['to_phone_email'] = this.toPhoneEmail;
    data['sent_on'] = this.sentOn;
    data['accepted_on'] = this.acceptedOn;
    data['user_company_role_id'] = this.userCompanyRoleId;
    if (this.sender != null) {
      data['sender'] = this.sender!.toJson();
    }
    if (this.company != null) {
      data['company'] = this.company!.toJson();
    }
    return data;
  }
}

class Sender {
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
  String? otp;
  int? allowedCompanies;
  int? isDeleted;

  Sender(
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
        this.otp,
        this.allowedCompanies,
        this.isDeleted});

  Sender.fromJson(Map<String, dynamic> json) {
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
    otp = json['otp'];
    allowedCompanies = json['allowed_companies'];
    isDeleted = json['is_deleted'];
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
    data['otp'] = this.otp;
    data['allowed_companies'] = this.allowedCompanies;
    data['is_deleted'] = this.isDeleted;
    return data;
  }
}

