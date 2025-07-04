class ErrorResponseModel {
  int? status;
  String? message;
  String? userId;
  List<dynamic>? data;
  String? accessToken;

  ErrorResponseModel(
      {this.status, this.message, this.userId, this.data, this.accessToken});

  ErrorResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    userId = json['user_id'];
    if (json['data'] != null) {
      data = <Null>[];
      json['data'].forEach((v) {
        // data!.add(new Null.fromJson(v));
      });
    }
    accessToken = json['accessToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['user_id'] = this.userId;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['accessToken'] = this.accessToken;
    return data;
  }
}
