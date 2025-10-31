class AllMemberResModel {
  bool? success;
  int? code;
  String? message;
  List<AllMemberData>? data;

  AllMemberResModel({this.success, this.code, this.message, this.data});

  AllMemberResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = <AllMemberData>[];
      json['data'].forEach((v) {
        data!.add(new AllMemberData.fromJson(v));
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

class AllMemberData {
  int? companyId;
  String? phone;
  String? source;

  AllMemberData({this.companyId, this.phone, this.source});

  AllMemberData.fromJson(Map<String, dynamic> json) {
    companyId = json['company_id'];
    phone = json['phone'];
    source = json['source'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['company_id'] = this.companyId;
    data['phone'] = this.phone;
    data['source'] = this.source;
    return data;
  }
}
