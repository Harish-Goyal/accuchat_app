class AllMediaResModel {
  bool? success;
  int? code;
  String? message;
  MediaData? data;

  AllMediaResModel({this.success, this.code, this.message, this.data});

  AllMediaResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new MediaData.fromJson(json['data']) : null;
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

class MediaData {
  int? page;
  int? pageSize;
  int? total;
  int? totalPages;
  List<Items>? items;

  MediaData({this.page, this.pageSize, this.total, this.totalPages, this.items});

  MediaData.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    pageSize = json['page_size'];
    total = json['total'];
    totalPages = json['total_pages'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['page'] = this.page;
    data['page_size'] = this.pageSize;
    data['total'] = this.total;
    data['total_pages'] = this.totalPages;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Items {
  int? id;
  String? source;
  int? sourceId;
  MediaTypeAPI? mediaType;
  String? fileName;
  String? orgFileName;
  String? uploadedOn;

  Items(
      {this.id,
        this.source,
        this.sourceId,
        this.mediaType,
        this.orgFileName,
        this.fileName,
        this.uploadedOn});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    source = json['source'];
    sourceId = json['source_id'];
    orgFileName = json['org_file_name'];
    mediaType = json['media_type'] != null
        ? new MediaTypeAPI.fromJson(json['media_type'])
        : null;
    fileName = json['file_name'];
    uploadedOn = json['uploaded_on'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['source'] = this.source;
    data['source_id'] = this.sourceId;
    data['org_file_name'] = this.orgFileName;
    if (this.mediaType != null) {
      data['media_type'] = this.mediaType!.toJson();
    }
    data['file_name'] = this.fileName;
    data['uploaded_on'] = this.uploadedOn;
    return data;
  }
}

class MediaTypeAPI {
  int? id;
  String? code;
  String? name;

  MediaTypeAPI({this.id, this.code, this.name});

  MediaTypeAPI.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name'] = this.name;
    return data;
  }
}
