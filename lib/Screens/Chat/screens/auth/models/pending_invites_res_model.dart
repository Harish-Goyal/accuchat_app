import 'package:AccuChat/Screens/Chat/models/get_company_res_model.dart';
import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';

class PendingInvitesResModel {
  bool? success;
  int? code;
  String? message;
  List<PendingInvitesList>? data;

  PendingInvitesResModel({this.success, this.code, this.message, this.data});

  PendingInvitesResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = <PendingInvitesList>[];
      json['data'].forEach((v) {
        data!.add(new PendingInvitesList.fromJson(v));
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

class PendingInvitesList {
  int? inviteId;
  String? toPhoneEmail;
  String? sentOn;
  UserDataAPI? sender;
  CompanyData? company;

  PendingInvitesList(
      {this.inviteId,
        this.toPhoneEmail,
        this.sentOn,
        this.sender,
        this.company});

  PendingInvitesList.fromJson(Map<String, dynamic> json) {
    inviteId = json['invite_id'];
    toPhoneEmail = json['to_phone_email'];
    sentOn = json['sent_on'];
    sender =
    json['sender'] != null ? new UserDataAPI.fromJson(json['sender']) : null;
    company =
    json['company'] != null ? new CompanyData.fromJson(json['company']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['invite_id'] = this.inviteId;
    data['to_phone_email'] = this.toPhoneEmail;
    data['sent_on'] = this.sentOn;
    if (this.sender != null) {
      data['sender'] = this.sender!.toJson();
    }
    if (this.company != null) {
      data['company'] = this.company!.toJson();
    }
    return data;
  }
}

