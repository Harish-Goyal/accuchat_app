abstract class Serializable {
  Map<String, dynamic> toJson();
}
class ApiResponse<T extends Serializable> {
  int status;
  String message;
  T data;
  ApiResponse({required this.status, required this.message, required this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json, Function(Map<String, dynamic>) create) {
    return ApiResponse<T>(
      status: json["status"],
      message: json["message"],
      data: (json["data"]!=null)?
      create(json["data"]):null,
    );
  }

  Map<String, dynamic> toJson() => {
    "status": this.status,
    "message": this.message,
    "data": this.data.toJson(),
  };
}

class ApiResponse2 <T extends Serializable> {
  int? status;
  String? message;
  List<T>? data;


  ApiResponse2({required this.status, required this.message, required this.data});

  ApiResponse2.fromJson(Map<String, dynamic> json,T Function(dynamic) create) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <T>[];
      json['data'].forEach((v) {
        data!.add(
            create(v
            )
        );

      });
    }

  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

