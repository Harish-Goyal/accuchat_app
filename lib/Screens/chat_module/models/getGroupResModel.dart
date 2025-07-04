import 'package:hive/hive.dart';

import '../../Authentication/AuthResponseModel/loginResModel.dart';
part 'getGroupResModel.g.dart';

class GroupMemeberResModel {
  bool? success;
  int? code;
  String? message;
  List<GroupMemberData>? body;

  GroupMemeberResModel({this.success, this.code, this.message, this.body});

  GroupMemeberResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    if (json['body'] != null) {
      body = <GroupMemberData>[];
      json['body'].forEach((v) {
        body!.add(new GroupMemberData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.body != null) {
      data['body'] = this.body!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

@HiveType(typeId: 5)
class GroupMemberData {
  bool isSelectedmember = true;
  @HiveField(0)
  int? groupMemberId;
  @HiveField(1)
  int? groupId;
  @HiveField(2)
  int? memberId;
  @HiveField(3)
  int? isRole;
  @HiveField(4)
  String? createdOn;
  @HiveField(5)
  UserData? user;

  GroupMemberData(
      {this.groupMemberId,
        this.groupId,
        this.memberId,
        this.isRole,
        this.createdOn,
        this.user});

  GroupMemberData.fromJson(Map<String, dynamic> json) {
    groupMemberId = json['group_member_id'];
    groupId = json['group_id'];
    memberId = json['member_id'];
    isRole = json['is_role'];
    createdOn = json['created_on'];
    user = json['user'] != null ? new UserData.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['group_member_id'] = this.groupMemberId;
    data['group_id'] = this.groupId;
    data['member_id'] = this.memberId;
    data['is_role'] = this.isRole;
    data['created_on'] = this.createdOn;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}
