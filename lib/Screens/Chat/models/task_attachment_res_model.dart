class TaskAttachmentResModel {
  bool? success;
  int? code;
  String? message;
  TaskAttaData? data;

  TaskAttachmentResModel({this.success, this.code, this.message, this.data});

  TaskAttachmentResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new TaskAttaData.fromJson(json['data']) : null;
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

class TaskAttaData {
  List<AttachmentFiles>? files;

  TaskAttaData({this.files});

  TaskAttaData.fromJson(Map<String, dynamic> json) {
    if (json['files'] != null) {
      files = <AttachmentFiles>[];
      json['files'].forEach((v) {
        files!.add(new AttachmentFiles.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.files != null) {
      data['files'] = this.files!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AttachmentFiles {
  String? fileName;
  String? originalName;
  String? mimeType;
  int? size;
  String? url;

  AttachmentFiles({this.fileName, this.originalName, this.mimeType, this.size, this.url});

  AttachmentFiles.fromJson(Map<String, dynamic> json) {
    fileName = json['file_name'];
    originalName = json['original_name'];
    mimeType = json['mime_type'];
    size = json['size'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['file_name'] = this.fileName;
    data['original_name'] = this.originalName;
    data['mime_type'] = this.mimeType;
    data['size'] = this.size;
    data['url'] = this.url;
    return data;
  }
}
