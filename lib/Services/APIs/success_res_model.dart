import 'package:AccuChat/Screens/Authentication/AuthResponseModel/loginResModel.dart';

class SuccessResponseModel {
  int? status;
  String? message;
  UserData? data;

  SuccessResponseModel({this.status, this.message});

  SuccessResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['body'] != null ? new UserData.fromJson(json['body']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['body'] = this.data!.toJson();
    }
    return data;
  }
}
