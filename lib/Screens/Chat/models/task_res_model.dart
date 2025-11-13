
import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
class TaskHisResModel {
  bool? success;
  int? code;
  String? message;
  TaskRes? data;

  TaskHisResModel({this.success, this.code, this.message, this.data});

  TaskHisResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new TaskRes.fromJson(json['data']) : null;
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

class TaskRes {
  int? page;
  int? limit;
  int? total;
  int? totalPages;
  List<TaskData>? rows;

  TaskRes({this.page, this.limit, this.total, this.totalPages, this.rows});

  TaskRes.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
    totalPages = json['totalPages'];
    if (json['rows'] != null) {
      rows = <TaskData>[];
      json['rows'].forEach((v) {
        rows!.add(new TaskData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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

class TaskData {
  int? taskId;
  UserDataAPI? fromUser;
  UserDataAPI? toUser;
  String? title;
  String? details;
  String? createdOn;
  String? startDate;
  String? endDate;
  String? deadline;
  List<TaskMedia>? media;
  CurrentStatus? currentStatus;
  List<StatusHistory>? statusHistory;

  TaskData(
      {this.taskId,
        this.fromUser,
        this.toUser,
        this.title,
        this.details,
        this.createdOn,
        this.startDate,
        this.endDate,
        this.deadline,
        this.media,
        this.currentStatus,
        this.statusHistory});

  TaskData.fromJson(Map<String, dynamic> json) {
    taskId = json['task_id'];
    fromUser = json['from_user'] != null
        ? new UserDataAPI.fromJson(json['from_user'])
        : null;
    toUser =
    json['to_user'] != null ? new UserDataAPI.fromJson(json['to_user']) : null;
    title = json['title'];
    details = json['details'];
    createdOn = json['created_on'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    deadline = json['deadline'];
    if (json['media'] != null) {
      media = <TaskMedia>[];
      json['media'].forEach((v) {
        media!.add(new TaskMedia.fromJson(v));
      });
    }
    currentStatus = json['current_status'] != null
        ? new CurrentStatus.fromJson(json['current_status'])
        : null;
    if (json['status_history'] != null) {
      statusHistory = <StatusHistory>[];
      json['status_history'].forEach((v) {
        statusHistory!.add(new StatusHistory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['task_id'] = this.taskId;
    if (this.fromUser != null) {
      data['from_user'] = this.fromUser!.toJson();
    }
    if (this.toUser != null) {
      data['to_user'] = this.toUser!.toJson();
    }
    data['title'] = this.title;
    data['details'] = this.details;
    data['created_on'] = this.createdOn;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['deadline'] = this.deadline;
    if (this.media != null) {
      data['media'] = this.media!.map((v) => v.toJson()).toList();
    }
    if (this.currentStatus != null) {
      data['current_status'] = this.currentStatus!.toJson();
    }
    if (this.statusHistory != null) {
      data['status_history'] =
          this.statusHistory!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}



class TaskMedia {
  int? taskMediaId;
  int? taskId;
  int? mediaTypeId;
  String? fileName;
  TaskMediaType? mediaType;

  TaskMedia(
      {this.taskMediaId,
        this.taskId,
        this.mediaTypeId,
        this.fileName,
        this.mediaType});

  TaskMedia.fromJson(Map<String, dynamic> json) {
    taskMediaId = json['task_media_id'];
    taskId = json['task_id'];
    mediaTypeId = json['media_type_id'];
    fileName = json['file_name'];
    mediaType = json['media_type'] != null
        ? new TaskMediaType.fromJson(json['media_type'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['task_media_id'] = this.taskMediaId;
    data['task_id'] = this.taskId;
    data['media_type_id'] = this.mediaTypeId;
    data['file_name'] = this.fileName;
    if (this.mediaType != null) {
      data['media_type'] = this.mediaType!.toJson();
    }
    return data;
  }
}

class TaskMediaType {
  int? mediaTypeId;
  String? mediaType;
  String? mediaCode;
  int? isActive;

  TaskMediaType({this.mediaTypeId, this.mediaType, this.mediaCode, this.isActive});

  TaskMediaType.fromJson(Map<String, dynamic> json) {
    mediaTypeId = json['media_type_id'];
    mediaType = json['media_type'];
    mediaCode = json['media_code'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['media_type_id'] = this.mediaTypeId;
    data['media_type'] = this.mediaType;
    data['media_code'] = this.mediaCode;
    data['is_active'] = this.isActive;
    return data;
  }
}

class CurrentStatus {
  int? taskStatusId;
  String? name;

  CurrentStatus({this.taskStatusId, this.name});

  CurrentStatus.fromJson(Map<String, dynamic> json) {
    taskStatusId = json['task_status_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['task_status_id'] = this.taskStatusId;
    data['name'] = this.name;
    return data;
  }
}

class StatusHistory {
  int? taskLogId;
  int? taskStatusId;
  String? statusName;
  int? toId;
  int? fromId;
  String? createdOn;
  String? from_name;

  StatusHistory(
      {this.taskLogId,
        this.taskStatusId,
        this.statusName,
        this.from_name,
        this.toId,
        this.fromId,
        this.createdOn});

  StatusHistory.fromJson(Map<String, dynamic> json) {
    taskLogId = json['task_log_id'];
    taskStatusId = json['task_status_id'];
    statusName = json['status_name'];
    from_name = json['from_name'];
    toId = json['to_id'];
    fromId = json['from_id'];
    createdOn = json['created_on'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['task_log_id'] = this.taskLogId;
    data['task_status_id'] = this.taskStatusId;
    data['status_name'] = this.statusName;
    data['from_name'] = this.from_name;
    data['to_id'] = this.toId;
    data['from_id'] = this.fromId;
    data['created_on'] = this.createdOn;
    return data;
  }
}

