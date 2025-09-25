import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';

class ComMemResModel {
  bool? success;
  int? code;
  String? message;
  List<UserDataAPI>? data;

  ComMemResModel({this.success, this.code, this.message, this.data});

  ComMemResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = <UserDataAPI>[];
      json['data'].forEach((v) {
        data!.add(new UserDataAPI.fromJson(v));
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

