import '../screens/auth/models/get_uesr_Res_model.dart';

class RecentChatsUserResModel {
  bool? success;
  int? code;
  String? message;
  RecentChatUserData? data;

  RecentChatsUserResModel({this.success, this.code, this.message, this.data});

  RecentChatsUserResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new RecentChatUserData.fromJson(json['data']) : null;
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

class RecentChatUserData {
  int? page;
  int? limit;
  int? total;
  bool? hasMore;
  List<UserDataAPI>? rows;

  RecentChatUserData({this.page, this.limit, this.total, this.hasMore, this.rows});

  RecentChatUserData.fromJson(Map<String, dynamic> json) {
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

class RecentChatUserList {
  int? userId;
  int? userCompanyId;
  String? userName;
  String? userImage;
  String? phone;
  String? email;
  String? about;
  String? createdOn;
  LastMessage? lastMessage;
  int? pendingCount;

  RecentChatUserList(
      {this.userId,
        this.userCompanyId,
        this.userName,
        this.userImage,
        this.lastMessage,
        this.pendingCount,
        this.phone,
        this.email,
        this.about,
        this.createdOn,
        });

  RecentChatUserList.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    userCompanyId = json['user_company_id'];
    userName = json['user_name'];
    userImage = json['user_image'];
    phone = json['phone'];
    email = json['email'];
    about = json['about'];
    createdOn = json['createdOn'];
    lastMessage = json['last_message'] != null
        ? new LastMessage.fromJson(json['last_message'])
        : null;
    pendingCount = json['pending_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['user_company_id'] = this.userCompanyId;
    data['user_name'] = this.userName;
    data['user_image'] = this.userImage;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['about'] = this.about;
    data['createdOn'] = this.createdOn;
    if (this.lastMessage != null) {
      data['last_message'] = this.lastMessage!.toJson();
    }
    data['pending_count'] = this.pendingCount;
    return data;
  }
}

class LastMessage {
  int? id;
  String? message;
  String? messageTime;

  LastMessage({this.id, this.message, this.messageTime});

  LastMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    message = json['message'];
    messageTime = json['message_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['message'] = this.message;
    data['message_time'] = this.messageTime;
    return data;
  }
}
