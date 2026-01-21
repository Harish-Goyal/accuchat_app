import 'package:AccuChat/Screens/Home/Models/get_folder_res_model.dart';

class CreateFolderResModel {
  bool? success;
  int? code;
  String? message;
  FolderData? data;

  CreateFolderResModel({this.success, this.code, this.message, this.data});

  CreateFolderResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new FolderData.fromJson(json['data']) : null;
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


