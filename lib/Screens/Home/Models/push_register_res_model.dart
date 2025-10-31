class PushResgisterResModel {
  bool? success;
  int? code;
  String? message;
  Data? data;

  PushResgisterResModel({this.success, this.code, this.message, this.data});

  PushResgisterResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
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

class Data {
  Row? row;
  int? count;

  Data({this.row, this.count});

  Data.fromJson(Map<String, dynamic> json) {
    row = json['row'] != null ? new Row.fromJson(json['row']) : null;
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.row != null) {
      data['row'] = this.row!.toJson();
    }
    data['count'] = this.count;
    return data;
  }
}

class Row {
  String? pushTokenId;
  int? userId;
  String? platform;
  String? deviceId;
  String? token;

  Row(
      {this.pushTokenId,
        this.userId,
        this.platform,
        this.deviceId,
        this.token});

  Row.fromJson(Map<String, dynamic> json) {
    pushTokenId = json['push_token_id'];
    userId = json['user_id'];
    platform = json['platform'];
    deviceId = json['device_id'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['push_token_id'] = this.pushTokenId;
    data['user_id'] = this.userId;
    data['platform'] = this.platform;
    data['device_id'] = this.deviceId;
    data['token'] = this.token;
    return data;
  }
}
