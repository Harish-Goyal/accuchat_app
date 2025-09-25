import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';

class RecentTaskUserData {
  bool? success;
  int? code;
  String? message;
  RecentTaskUser? data;

  RecentTaskUserData({this.success, this.code, this.message, this.data});

  RecentTaskUserData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new RecentTaskUser.fromJson(json['data']) : null;
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

class RecentTaskUser {
  int? page;
  int? limit;
  int? total;
  bool? hasMore;
  List<UserDataAPI>? rows;

  RecentTaskUser({this.page, this.limit, this.total, this.hasMore, this.rows});

  RecentTaskUser.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
    hasMore = json['has_more'];
    if (json['rows'] != null) {
      rows = <UserDataAPI>[];
      json['rows'].forEach((v) {
        rows!.add(new UserDataAPI.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['page'] = this.page;
    data['limit'] = this.limit;
    data['total'] = this.total;
    data['has_more'] = this.hasMore;
    if (this.rows != null) {
      data['rows'] = this.rows!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}



