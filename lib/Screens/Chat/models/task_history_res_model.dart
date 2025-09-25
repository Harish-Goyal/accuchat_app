class TaskHisResModel {
  bool? success;
  int? code;
  String? message;
  Data? data;

  TaskHisResModel({this.success, this.code, this.message, this.data});

  TaskHisResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
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

class Data {
  int? page;
  int? limit;
  int? total;
  int? totalPages;
  List<Rows>? rows;

  Data({this.page, this.limit, this.total, this.totalPages, this.rows});

  Data.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
    totalPages = json['totalPages'];
    if (json['rows'] != null) {
      rows = <Rows>[];
      json['rows'].forEach((v) {
        rows!.add(new Rows.fromJson(v));
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

class Rows {
  int? taskId;
  FromUser? fromUser;
  ToUser? toUser;
  String? title;
  String? details;
  String? createdOn;
  String? startDate;
  String? endDate;
  String? deadline;
  List<Media>? media;
  CurrentStatus? currentStatus;
  List<StatusHistory>? statusHistory;

  Rows(
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

  Rows.fromJson(Map<String, dynamic> json) {
    taskId = json['task_id'];
    fromUser = json['from_user'] != null
        ? new FromUser.fromJson(json['from_user'])
        : null;
    toUser =
    json['to_user'] != null ? new ToUser.fromJson(json['to_user']) : null;
    title = json['title'];
    details = json['details'];
    createdOn = json['created_on'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    deadline = json['deadline'];
    if (json['media'] != null) {
      media = <Media>[];
      json['media'].forEach((v) {
        media!.add(new Media.fromJson(v));
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

class FromUser {
  int? userId;
  String? userName;
  String? phone;
  Null? email;
  int? isActive;
  String? userImage;
  String? about;
  Null? userKey;
  String? createdOn;
  String? updatedOn;
  Null? otp;
  int? allowedCompanies;
  int? isDeleted;
  Null? userCompanyRoleId;
  Null? isGroup;
  Null? isBroadcast;

  FromUser(
      {this.userId,
        this.userName,
        this.phone,
        this.email,
        this.isActive,
        this.userImage,
        this.about,
        this.userKey,
        this.createdOn,
        this.updatedOn,
        this.otp,
        this.allowedCompanies,
        this.isDeleted,
        this.userCompanyRoleId,
        this.isGroup,
        this.isBroadcast});

  FromUser.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    userName = json['user_name'];
    phone = json['phone'];
    email = json['email'];
    isActive = json['is_active'];
    userImage = json['user_image'];
    about = json['about'];
    userKey = json['user_key'];
    createdOn = json['created_on'];
    updatedOn = json['updated_on'];
    otp = json['otp'];
    allowedCompanies = json['allowed_companies'];
    isDeleted = json['is_deleted'];
    userCompanyRoleId = json['user_company_role_id'];
    isGroup = json['is_group'];
    isBroadcast = json['is_broadcast'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['is_active'] = this.isActive;
    data['user_image'] = this.userImage;
    data['about'] = this.about;
    data['user_key'] = this.userKey;
    data['created_on'] = this.createdOn;
    data['updated_on'] = this.updatedOn;
    data['otp'] = this.otp;
    data['allowed_companies'] = this.allowedCompanies;
    data['is_deleted'] = this.isDeleted;
    data['user_company_role_id'] = this.userCompanyRoleId;
    data['is_group'] = this.isGroup;
    data['is_broadcast'] = this.isBroadcast;
    return data;
  }
}

class ToUser {
  int? userId;
  String? userName;
  String? phone;
  String? email;
  int? isActive;
  String? userImage;
  String? about;
  String? userKey;
  String? createdOn;
  String? updatedOn;
  int? allowedCompanies;
  int? isDeleted;
  int? userCompanyRoleId;
  int? isGroup;
  int? isBroadcast;

  ToUser(
      {this.userId,
        this.userName,
        this.phone,
        this.email,
        this.isActive,
        this.userImage,
        this.about,
        this.userKey,
        this.createdOn,
        this.updatedOn,
        this.allowedCompanies,
        this.isDeleted,
        this.userCompanyRoleId,
        this.isGroup,
        this.isBroadcast});

  ToUser.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    userName = json['user_name'];
    phone = json['phone'];
    email = json['email'];
    isActive = json['is_active'];
    userImage = json['user_image'];
    about = json['about'];
    userKey = json['user_key'];
    createdOn = json['created_on'];
    updatedOn = json['updated_on'];
    allowedCompanies = json['allowed_companies'];
    isDeleted = json['is_deleted'];
    userCompanyRoleId = json['user_company_role_id'];
    isGroup = json['is_group'];
    isBroadcast = json['is_broadcast'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['is_active'] = this.isActive;
    data['user_image'] = this.userImage;
    data['about'] = this.about;
    data['user_key'] = this.userKey;
    data['created_on'] = this.createdOn;
    data['updated_on'] = this.updatedOn;
    data['allowed_companies'] = this.allowedCompanies;
    data['is_deleted'] = this.isDeleted;
    data['user_company_role_id'] = this.userCompanyRoleId;
    data['is_group'] = this.isGroup;
    data['is_broadcast'] = this.isBroadcast;
    return data;
  }
}

class Media {
  int? taskMediaId;
  int? taskId;
  int? mediaTypeId;
  String? fileName;
  MediaType? mediaType;

  Media(
      {this.taskMediaId,
        this.taskId,
        this.mediaTypeId,
        this.fileName,
        this.mediaType});

  Media.fromJson(Map<String, dynamic> json) {
    taskMediaId = json['task_media_id'];
    taskId = json['task_id'];
    mediaTypeId = json['media_type_id'];
    fileName = json['file_name'];
    mediaType = json['media_type'] != null
        ? new MediaType.fromJson(json['media_type'])
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

class MediaType {
  int? mediaTypeId;
  String? mediaType;
  String? mediaCode;
  int? isActive;

  MediaType({this.mediaTypeId, this.mediaType, this.mediaCode, this.isActive});

  MediaType.fromJson(Map<String, dynamic> json) {
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

  StatusHistory(
      {this.taskLogId,
        this.taskStatusId,
        this.statusName,
        this.toId,
        this.fromId,
        this.createdOn});

  StatusHistory.fromJson(Map<String, dynamic> json) {
    taskLogId = json['task_log_id'];
    taskStatusId = json['task_status_id'];
    statusName = json['status_name'];
    toId = json['to_id'];
    fromId = json['from_id'];
    createdOn = json['created_on'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['task_log_id'] = this.taskLogId;
    data['task_status_id'] = this.taskStatusId;
    data['status_name'] = this.statusName;
    data['to_id'] = this.toId;
    data['from_id'] = this.fromId;
    data['created_on'] = this.createdOn;
    return data;
  }
}
