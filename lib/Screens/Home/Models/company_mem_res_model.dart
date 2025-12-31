import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';

class ComMemResModel {
  bool? success;
  int? code;
  String? message;
  ComMemData? data;


  ComMemResModel({this.success, this.code, this.message, this.data});

  ComMemResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new ComMemData.fromJson(json['data']) : null;
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

class ComMemData {
  List<UserDataAPI>? records;
  Pagination? pagination;

  ComMemData({this.records, this.pagination});

  ComMemData.fromJson(Map<String, dynamic> json) {
    if (json['records'] != null) {
      records = <UserDataAPI>[];
      json['records'].forEach((v) {
        records!.add(new UserDataAPI.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.records != null) {
      data['records'] = this.records!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}


class Pagination {
  int? page;
  int? limit;
  int? totalRecords;
  int? totalPages;

  Pagination({this.page, this.limit, this.totalRecords, this.totalPages});

  Pagination.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    limit = json['limit'];
    totalRecords = json['total_records'];
    totalPages = json['total_pages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['page'] = this.page;
    data['limit'] = this.limit;
    data['total_records'] = this.totalRecords;
    data['total_pages'] = this.totalPages;
    return data;
  }
}




class TaskMemResponse {
  bool? success;
  int? code;
  String? message;
  List<UserDataAPI>? data;

  TaskMemResponse({this.success, this.code, this.message, this.data});

  TaskMemResponse.fromJson(Map<String, dynamic> json) {
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