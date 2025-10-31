class GetUserResModel {
  bool? success;
  int? code;
  String? message;
  UserDataAPI? data;

  GetUserResModel({this.success, this.code, this.message, this.data});

  GetUserResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new UserDataAPI.fromJson(json['data']) : null;
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

class UserDataAPI {
  int? userId;
  String? userName;
  String? displayName;
  String? phone;
  int? createdBy;
  int? isAdmin;
  String? email;
  String? about;
  String? createdOn;
  int? isActive;
  String? userImage;
  String? userKey;
  String? updatedOn;
  String? otp;
  int? allowedCompanies;
  int? isDeleted;
  UserCompany? userCompany;
  LastMessage? lastMessage;
  int? memberCount;
  int? pendingCount;
  int? invitedBy;
  String? invitedOn;
  String? joinedOn;
  int? open_count;
  String? pushToken;

  UserDataAPI(
      {this.userId,
        this.userName,
        this.phone,
        this.email,
        this.createdBy,
        this.isAdmin,
        this.displayName,
        this.open_count,
        this.isActive,
        this.userImage,
        this.memberCount,
        this.about,
        this.userKey,
        this.invitedBy,
        this.invitedOn,
        this.joinedOn,
        this.pushToken,
        this.lastMessage,
        this.pendingCount,
        this.createdOn,
        this.updatedOn,
        this.otp,
        this.allowedCompanies,
        this.isDeleted,
        this.userCompany});

  UserDataAPI.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    createdBy = json['created_by'];
    memberCount = json['member_count'];
    displayName = json['display_name'];
    userName = json['user_name'];
    open_count = json['open_count'];
    phone = json['phone'];
    email = json['email'];
    isAdmin = json['is_admin'];
    isActive = json['is_active'];
    userImage = json['user_image'];
    about = json['about'];
    userKey = json['user_key'];
    createdOn = json['created_on'];
    updatedOn = json['updated_on'];
    invitedBy = json['invited_by'];
    invitedOn = json['invited_on'];
    joinedOn = json['joined_on'];
    lastMessage = json['last_message'] != null
        ? new LastMessage.fromJson(json['last_message'])
        : null;
    pendingCount = json['pending_count'];
    otp = json['otp'];
    allowedCompanies = json['allowed_companies'];
    isDeleted = json['is_deleted'];
    userCompany = json['user_company'] != null
        ? new UserCompany.fromJson(json['user_company'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['display_name'] = this.displayName;
    data['open_count'] = this.open_count;
    data['is_admin'] = this.isAdmin;
    data['created_by'] = this.createdBy;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['member_count'] = this.memberCount;
    data['is_active'] = this.isActive;
    data['user_image'] = this.userImage;
    data['about'] = this.about;
    data['user_key'] = this.userKey;
    data['created_on'] = this.createdOn;
    data['updated_on'] = this.updatedOn;
    data['invited_by'] = this.invitedBy;
    data['invited_on'] = this.invitedOn;
    data['joined_on'] = this.joinedOn;
    if (this.lastMessage != null) {
      data['last_message'] = this.lastMessage!.toJson();
    }
    data['pending_count'] = this.pendingCount;
    data['otp'] = this.otp;
    data['allowed_companies'] = this.allowedCompanies;
    data['is_deleted'] = this.isDeleted;
    if (this.userCompany != null) {
      data['user_company'] = this.userCompany!.toJson();
    }
    return data;
  }
}


class LastMessage {
  int? id;
  String? message;
  String? messageTime;

  LastMessage({this.id, this.message, this.messageTime});

  LastMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    message = json['message'];
    messageTime = json['message_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['message'] = this.message;
    data['message_time'] = this.messageTime;
    return data;
  }
}

class UserCompany {
  int? userCompanyId;
  int? userId;
  int? companyId;
  int? isActive;
  int? userCompanyRoleId;
  String? createdOn;
  int? isDeleted;
  int? invitedBy;
  int? isBroadcast;
  int? isGroup;
  String? invitedOn;
  String? joinedOn;
  UserCompanyRole? userCompanyRole;
  UCompany? company;

  UserCompany(
      {this.userCompanyId,
        this.userId,
        this.companyId,
        this.isActive,
        this.userCompanyRoleId,
        this.createdOn,
        this.isDeleted,
        this.invitedBy,
        this.isBroadcast,
        this.isGroup,
        this.invitedOn,
        this.joinedOn,
        this.userCompanyRole,
        this.company});

  UserCompany.fromJson(Map<String, dynamic> json) {
    userCompanyId = json['user_company_id'];
    userId = json['user_id'];
    companyId = json['company_id'];
    isActive = json['is_active'];
    userCompanyRoleId = json['user_company_role_id'];
    createdOn = json['created_on'];
    isDeleted = json['is_deleted'];
    invitedBy = json['invited_by'];
    invitedOn = json['invited_on'];
    isBroadcast = json['is_broadcast'];
    isGroup = json['is_group'];
    joinedOn = json['joined_on'];
    userCompanyRole = json['user_company_role'] != null
        ? new UserCompanyRole.fromJson(json['user_company_role'])
        : null;
    company =
    json['company'] != null ? new UCompany.fromJson(json['company']) : null;
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
    data['is_broadcast'] = this.isBroadcast;
    data['is_group'] = this.isGroup;
    data['invited_on'] = this.invitedOn;
    data['joined_on'] = this.joinedOn;
    if (this.userCompanyRole != null) {
      data['user_company_role'] = this.userCompanyRole!.toJson();
    }
    if (this.company != null) {
      data['company'] = this.company!.toJson();
    }
    return data;
  }
}

class UserCompanyRole {
  String? userRole;
  int? isDefault;

  UserCompanyRole({this.userRole});

  UserCompanyRole.fromJson(Map<String, dynamic> json) {
    userRole = json['user_role'];
    isDefault = json['is_default'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_role'] = this.userRole;
    data['is_default'] = this.isDefault;
    return data;
  }
}

class UCompany {
  int? companyId;
  String? companyName;
  String? address;
  String? website;
  String? email;
  String? phone;
  int? isAppCompany;
  String? createdOn;
  String? updatedOn;
  int? isActive;
  int? isDeleted;
  String? logo;
  int? createdBy;

  UCompany(
      {this.companyId,
        this.companyName,
        this.address,
        this.website,
        this.email,
        this.phone,
        this.isAppCompany,
        this.createdOn,
        this.updatedOn,
        this.isActive,
        this.isDeleted,
        this.logo,
        this.createdBy});

  UCompany.fromJson(Map<String, dynamic> json) {
    companyId = json['company_id'];
    companyName = json['company_name'];
    address = json['address'];
    website = json['website'];
    email = json['email'];
    phone = json['phone'];
    isAppCompany = json['is_app_company'];
    createdOn = json['created_on'];
    updatedOn = json['updated_on'];
    isActive = json['is_active'];
    isDeleted = json['is_deleted'];
    logo = json['logo'];
    createdBy = json['created_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['company_id'] = this.companyId;
    data['company_name'] = this.companyName;
    data['address'] = this.address;
    data['website'] = this.website;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['is_app_company'] = this.isAppCompany;
    data['created_on'] = this.createdOn;
    data['updated_on'] = this.updatedOn;
    data['is_active'] = this.isActive;
    data['is_deleted'] = this.isDeleted;
    data['logo'] = this.logo;
    data['created_by'] = this.createdBy;
    return data;
  }
}



class Autogenerated {
  bool? success;
  int? code;
  String? message;
  List<Data>? data;

  Autogenerated({this.success, this.code, this.message, this.data});

  Autogenerated.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
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

class Data {
  int? userCompanyId;
  int? userId;
  int? companyId;
  int? isActive;
  int? userCompanyRoleId;
  String? createdOn;
  int? isDeleted;
  int? invitedBy;
  String? invitedOn;
  String? joinedOn;
  int? isAdmin;
  int? isGroup;
  int? isBroadcast;
  String? userName;
  String? phone;
  Null? email;
  String? userImage;
  String? about;
  String? updatedOn;
  int? allowedCompanies;

  Data(
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
        this.userName,
        this.phone,
        this.email,
        this.userImage,
        this.about,
        this.updatedOn,
        this.allowedCompanies});

  Data.fromJson(Map<String, dynamic> json) {
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
    userName = json['user_name'];
    phone = json['phone'];
    email = json['email'];
    userImage = json['user_image'];
    about = json['about'];
    updatedOn = json['updated_on'];
    allowedCompanies = json['allowed_companies'];
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
    data['user_name'] = this.userName;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['user_image'] = this.userImage;
    data['about'] = this.about;
    data['updated_on'] = this.updatedOn;
    data['allowed_companies'] = this.allowedCompanies;
    return data;
  }
}

