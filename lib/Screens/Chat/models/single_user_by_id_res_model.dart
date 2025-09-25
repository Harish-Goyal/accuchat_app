import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';

class SingleUserResModel {
  bool? success;
  int? code;
  String? message;
  UserDataAPI? data;

  SingleUserResModel({this.success, this.code, this.message, this.data});

  SingleUserResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new UserDataAPI.fromJson(json['data']) : null;
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

