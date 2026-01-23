import 'package:AccuChat/Screens/Home/Models/get_folder_res_model.dart';

class UploadFolderMediaResModel {
  bool? success;
  int? code;
  String? message;
  List<FolderData>? data;

  UploadFolderMediaResModel({this.success, this.code, this.message, this.data});

  UploadFolderMediaResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = <FolderData>[];
      json['data'].forEach((v) {
        data!.add(new FolderData.fromJson(v));
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

