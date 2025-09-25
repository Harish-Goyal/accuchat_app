class AcceptInviteRes {
  bool? success;
  int? code;
  String? message;
  AcceptInviteData? data;

  AcceptInviteRes({this.success, this.code, this.message, this.data});

  AcceptInviteRes.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new AcceptInviteData.fromJson(json['data']) : null;
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

class AcceptInviteData {
  int? inviteId;
  int? senderId;
  int? companyId;
  String? toPhoneEmail;
  String? sentOn;
  String? acceptedOn;
  int? userCompanyRoleId;

  AcceptInviteData(
      {this.inviteId,
        this.senderId,
        this.companyId,
        this.toPhoneEmail,
        this.sentOn,
        this.acceptedOn,
        this.userCompanyRoleId});

  AcceptInviteData.fromJson(Map<String, dynamic> json) {
    inviteId = json['invite_id'];
    senderId = json['sender_id'];
    companyId = json['company_id'];
    toPhoneEmail = json['to_phone_email'];
    sentOn = json['sent_on'];
    acceptedOn = json['accepted_on'];
    userCompanyRoleId = json['user_company_role_id'];
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
    return data;
  }
}
