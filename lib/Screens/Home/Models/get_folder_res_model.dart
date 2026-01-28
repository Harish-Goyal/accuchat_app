class GetFolderResModel {
  bool? success;
  int? code;
  String? message;
  FolderResData? data;

  GetFolderResModel({this.success, this.code, this.message, this.data});

  GetFolderResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new FolderResData.fromJson(json['data']) : null;
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


class FolderResData {
  int? page;
  int? limit;
  int? total;
  int? totalPages;
  List<FolderData>? rows;

  FolderResData({this.page, this.limit, this.total, this.totalPages, this.rows});

  FolderResData.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
    totalPages = json['totalPages'];
    if (json['rows'] != null) {
      rows = <FolderData>[];
      json['rows'].forEach((v) {
        rows!.add(new FolderData.fromJson(v));
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


class FolderData {
  int? userGalleryId;
  int? userCompanyId;
  String? fileName;
  String? filePath;
  String? title;
  String? folderName;
  String? keyWords;
  String? totalItems;
  int? parentUserCompanyId;
  int? mediaTypeId;
  int? chatMediaId;
  String? createdOn;

  FolderData(
      {this.userGalleryId,
        this.userCompanyId,
        this.fileName,
        this.filePath,
        this.title,
        this.folderName,
        this.totalItems,
        this.keyWords,
        this.parentUserCompanyId,
        this.mediaTypeId,
        this.chatMediaId,
        this.createdOn});

  bool get isFolder => filePath == null || filePath!.isEmpty;

  FolderData.fromJson(Map<String, dynamic> json) {
    userGalleryId = json['user_gallery_id'];
    userCompanyId = json['user_company_id'];
    fileName = json['file_name'];
    filePath = json['file_path'];
    title = json['title'];
    folderName = json['folder_name'];
    keyWords = json['key_words'];
    parentUserCompanyId = json['parent_user_company_id'];
    mediaTypeId = json['media_type_id'];
    chatMediaId = json['chat_media_id'];
    totalItems = json['total_items'];
    createdOn = json['created_on'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_gallery_id'] = this.userGalleryId;
    data['user_company_id'] = this.userCompanyId;
    data['file_name'] = this.fileName;
    data['file_path'] = this.filePath;
    data['title'] = this.title;
    data['folder_name'] = this.folderName;
    data['key_words'] = this.keyWords;
    data['total_items'] = this.totalItems;
    data['parent_user_company_id'] = this.parentUserCompanyId;
    data['media_type_id'] = this.mediaTypeId;
    data['chat_media_id'] = this.chatMediaId;
    data['created_on'] = this.createdOn;
    return data;
  }
}


