import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';

class GroupMemberAPIRes {
  bool? success;
  int? code;
  String? message;
  GroupMemData? data;

  GroupMemberAPIRes({this.success, this.code, this.message, this.data});

  GroupMemberAPIRes.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new GroupMemData.fromJson(json['data']) : null;
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

class GroupMemData {
  String? mode;
  int? memberCount;
  List<UserDataAPI>? members;

  GroupMemData({this.mode, this.memberCount, this.members});

  GroupMemData.fromJson(Map<String, dynamic> json) {
    mode = json['mode'];
    memberCount = json['member_count'];
    if (json['members'] != null) {
      members = <UserDataAPI>[];
      json['members'].forEach((v) {
        members!.add(new UserDataAPI.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mode'] = this.mode;
    data['member_count'] = this.memberCount;
    if (this.members != null) {
      data['members'] = this.members!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

/*class GMembers {
  int? groupUcId;
  int? groupMemberId;
  bool? isAdmin;
  bool? isBroadcast;
  int? userCompanyId;
  int? userId;
  String? userName;
  String? email;
  String? phone;
  String? avatarUrl;
  String? addedOn;

  GMembers(
      {this.groupUcId,
        this.groupMemberId,
        this.isAdmin,
        this.isBroadcast,
        this.userCompanyId,
        this.userId,
        this.userName,
        this.email,
        this.phone,
        this.avatarUrl,
        this.addedOn});

  GMembers.fromJson(Map<String, dynamic> json) {
    groupUcId = json['group_uc_id'];
    groupMemberId = json['group_member_id'];
    isAdmin = json['is_admin'];
    isBroadcast = json['is_broadcast'];
    userCompanyId = json['user_company_id'];
    userId = json['user_id'];
    userName = json['user_name'];
    email = json['email'];
    phone = json['phone'];
    avatarUrl = json['avatar_url'];
    addedOn = json['added_on'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['group_uc_id'] = this.groupUcId;
    data['group_member_id'] = this.groupMemberId;
    data['is_admin'] = this.isAdmin;
    data['is_broadcast'] = this.isBroadcast;
    data['user_company_id'] = this.userCompanyId;
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['avatar_url'] = this.avatarUrl;
    data['added_on'] = this.addedOn;
    return data;
  }
}*/
