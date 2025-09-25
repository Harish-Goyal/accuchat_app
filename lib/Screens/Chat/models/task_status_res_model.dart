class TaskStatusResModel {
  bool? success;
  int? code;
  String? message;
  List<StatusData>? data;

  TaskStatusResModel({this.success, this.code, this.message, this.data});

  TaskStatusResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = <StatusData>[];
      json['data'].forEach((v) {
        data!.add(new StatusData.fromJson(v));
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

class StatusData {
  int? taskStatusId;
  String? status;
  int? isActive;
  int? sortingIndex;

  StatusData({this.taskStatusId, this.status, this.isActive, this.sortingIndex});

  StatusData.fromJson(Map<String, dynamic> json) {
    taskStatusId = json['task_status_id'];
    status = json['status'];
    isActive = json['is_active'];
    sortingIndex = json['sorting_index'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['task_status_id'] = this.taskStatusId;
    data['status'] = this.status;
    data['is_active'] = this.isActive;
    data['sorting_index'] = this.sortingIndex;
    return data;
  }
}
