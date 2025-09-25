import 'get_company_res_model.dart';

class CreateCompanyResModel {
  bool? success;
  int? code;
  String? message;
  CompanyData? data;

  CreateCompanyResModel({this.success, this.code, this.message, this.data});

  CreateCompanyResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new CompanyData.fromJson(json['data']) : null;
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

