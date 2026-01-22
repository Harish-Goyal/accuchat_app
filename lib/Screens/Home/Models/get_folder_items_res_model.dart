import 'package:AccuChat/Screens/Home/Models/get_folder_res_model.dart';

class FolderItemsResModel {
  bool? success;
  int? code;
  String? message;
  FolderItemsData? data;

  FolderItemsResModel({this.success, this.code, this.message, this.data});

  FolderItemsResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new FolderItemsData.fromJson(json['data']) : null;
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

class FolderItemsData {
  String? folderName;
  int? page;
  int? limit;
  int? total;
  int? totalPages;
  List<FolderData>? rows;

  FolderItemsData(
      {this.folderName,
        this.page,
        this.limit,
        this.total,
        this.totalPages,
        this.rows});

  FolderItemsData.fromJson(Map<String, dynamic> json) {
    folderName = json['folder_name'];
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
    totalPages = json['totalPages'];
    if (json['rows'] != null) {
      rows = <FolderData>[];
      json['rows'].forEach((v) {
        rows!.add(new FolderData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['folder_name'] = this.folderName;
    data['page'] = this.page;
    data['limit'] = this.limit;
    data['total'] = this.total;
    data['totalPages'] = this.totalPages;
    if (this.rows != null) {
      data['rows'] = this.rows!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

