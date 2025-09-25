import 'package:AccuChat/Screens/Chat/models/task_res_model.dart';

class SingleTaskRes {
  bool? success;
  int? code;
  String? message;
  TaskData? data;

  SingleTaskRes({this.success, this.code, this.message, this.data});

  SingleTaskRes.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new TaskData.fromJson(json['data']) : null;
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

class SingleTaskData {
  int? taskId;
  int? fromId;
  int? toId;
  String? title;
  String? description;
  String? deadline;
  int? taskStatusId;
  int? currentFromId;
  String? createdOn;
  List<TaskMedia>? media;
  List<Logs>? logs;
  Status? status;

  SingleTaskData(
      {this.taskId,
        this.fromId,
        this.toId,
        this.title,
        this.description,
        this.deadline,
        this.taskStatusId,
        this.currentFromId,
        this.createdOn,
        this.media,
        this.logs,
        this.status});

  SingleTaskData.fromJson(Map<String, dynamic> json) {
    taskId = json['task_id'];
    fromId = json['from_id'];
    toId = json['to_id'];
    title = json['title'];
    description = json['description'];
    deadline = json['deadline'];
    taskStatusId = json['task_status_id'];
    currentFromId = json['current_from_id'];
    createdOn = json['created_on'];
    if (json['media'] != null) {
      media = <TaskMedia>[];
      json['media'].forEach((v) {
        media!.add(new TaskMedia.fromJson(v));
      });
    }
    if (json['logs'] != null) {
      logs = <Logs>[];
      json['logs'].forEach((v) {
        logs!.add(new Logs.fromJson(v));
      });
    }
    status =
    json['status'] != null ? new Status.fromJson(json['status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['task_id'] = this.taskId;
    data['from_id'] = this.fromId;
    data['to_id'] = this.toId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['deadline'] = this.deadline;
    data['task_status_id'] = this.taskStatusId;
    data['current_from_id'] = this.currentFromId;
    data['created_on'] = this.createdOn;
    if (this.media != null) {
      data['media'] = this.media!.map((v) => v.toJson()).toList();
    }
    if (this.logs != null) {
      data['logs'] = this.logs!.map((v) => v.toJson()).toList();
    }
    if (this.status != null) {
      data['status'] = this.status!.toJson();
    }
    return data;
  }
}

class Logs {
  int? taskLogId;
  int? taskId;
  int? taskStatusId;
  int? fromId;
  int? toId;
  String? createdOn;
  Status? status;
  AssignedTo? assignedTo;

  Logs(
      {this.taskLogId,
        this.taskId,
        this.taskStatusId,
        this.fromId,
        this.toId,
        this.createdOn,
        this.status,
        this.assignedTo});

  Logs.fromJson(Map<String, dynamic> json) {
    taskLogId = json['task_log_id'];
    taskId = json['task_id'];
    taskStatusId = json['task_status_id'];
    fromId = json['from_id'];
    toId = json['to_id'];
    createdOn = json['created_on'];
    status =
    json['status'] != null ? new Status.fromJson(json['status']) : null;
    assignedTo = json['assigned_to'] != null
        ? new AssignedTo.fromJson(json['assigned_to'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['task_log_id'] = this.taskLogId;
    data['task_id'] = this.taskId;
    data['task_status_id'] = this.taskStatusId;
    data['from_id'] = this.fromId;
    data['to_id'] = this.toId;
    data['created_on'] = this.createdOn;
    if (this.status != null) {
      data['status'] = this.status!.toJson();
    }
    if (this.assignedTo != null) {
      data['assigned_to'] = this.assignedTo!.toJson();
    }
    return data;
  }
}

class Status {
  int? taskStatusId;
  String? status;
  int? isActive;
  int? sortingIndex;

  Status({this.taskStatusId, this.status, this.isActive, this.sortingIndex});

  Status.fromJson(Map<String, dynamic> json) {
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

class AssignedTo {
  int? userCompanyId;
  int? userId;
  int? companyId;
  int? isActive;
  int? userCompanyRoleId;
  String? createdOn;
  int? isDeleted;
  Null? invitedBy;
  Null? invitedOn;
  String? joinedOn;
  int? isAdmin;
  int? isGroup;
  int? isBroadcast;
  Null? createdBy;

  AssignedTo(
      {this.userCompanyId,
        this.userId,
        this.companyId,
        this.isActive,
        this.userCompanyRoleId,
        this.createdOn,
        this.isDeleted,
        this.invitedBy,
        this.invitedOn,
        this.joinedOn,
        this.isAdmin,
        this.isGroup,
        this.isBroadcast,
        this.createdBy});

  AssignedTo.fromJson(Map<String, dynamic> json) {
    userCompanyId = json['user_company_id'];
    userId = json['user_id'];
    companyId = json['company_id'];
    isActive = json['is_active'];
    userCompanyRoleId = json['user_company_role_id'];
    createdOn = json['created_on'];
    isDeleted = json['is_deleted'];
    invitedBy = json['invited_by'];
    invitedOn = json['invited_on'];
    joinedOn = json['joined_on'];
    isAdmin = json['is_admin'];
    isGroup = json['is_group'];
    isBroadcast = json['is_broadcast'];
    createdBy = json['created_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_company_id'] = this.userCompanyId;
    data['user_id'] = this.userId;
    data['company_id'] = this.companyId;
    data['is_active'] = this.isActive;
    data['user_company_role_id'] = this.userCompanyRoleId;
    data['created_on'] = this.createdOn;
    data['is_deleted'] = this.isDeleted;
    data['invited_by'] = this.invitedBy;
    data['invited_on'] = this.invitedOn;
    data['joined_on'] = this.joinedOn;
    data['is_admin'] = this.isAdmin;
    data['is_group'] = this.isGroup;
    data['is_broadcast'] = this.isBroadcast;
    data['created_by'] = this.createdBy;
    return data;
  }
}
