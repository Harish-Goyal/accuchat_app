import 'package:hive/hive.dart';

part 'user_chat_list_model.g.dart'; // Part file for the generated adapter

// Unique ID for the model
class UserChatListResModel {
  bool? success;
  int? code;
  String? message;
  List<UserChatListData>? body;

  UserChatListResModel({this.success, this.code, this.message, this.body});

  UserChatListResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    if (json['body'] != null) {
      body = <UserChatListData>[];
      json['body'].forEach((v) {
        body!.add(new UserChatListData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.body != null) {
      data['body'] = this.body!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

@HiveType(typeId: 0)
class UserChatListData {
   var isSelected = false;

  @HiveField(0)
  int? userId;

  @HiveField(1)
  String? userName;

  @HiveField(2)
  int? empId;

  @HiveField(3)
  int? status;

  @HiveField(4)
  String? userAbbr;

  @HiveField(5)
  int? isGroup;

  @HiveField(6)
  var isCollection;

  @HiveField(7)
  int? unreadMessageCount;

  @HiveField(8)
  Employee? employee;

  @HiveField(9)
  LastMessage? lastMessage;

  @HiveField(10)
  var createdBy;

  String? regdDate;

  int? userRoleId;

  int? canViewAll;

  int? canEditAll;

  int? canAddAll;

  var accessEmailCheckBox;
  int? canViewClientContact;
  var createdOn;


  var socketId;
  var password;

  UserChatListData(
      {this.userId,
      this.regdDate,
      this.userName,
      this.password,
      this.status,
      this.userRoleId,
      this.empId,
      this.canViewAll,
      this.canEditAll,
      this.canAddAll,
      this.userAbbr,
      this.accessEmailCheckBox,
      this.canViewClientContact,
      this.isGroup,
      this.isCollection,
      this.createdOn,
      this.createdBy,
      this.socketId,
      this.employee,
      this.unreadMessageCount,
      this.lastMessage});

  factory UserChatListData.fromMap(Map<String, dynamic> map) {
    return UserChatListData(
      userId: map['user_id'],
      userName: map['user_name'],
      empId: map['emp_id'],
      status: map['status'],
      userAbbr: map['user_abbr'],
      isGroup: map['is_group'],
      isCollection: map['is_collection'],
      unreadMessageCount: map['unread_message_count'],
      employee: map['employee'] ?? Employee(),
      lastMessage: map['last_message'] ?? LastMessage(),
    );
  }

  UserChatListData.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    regdDate = json['regd_date'];
    userName = json['user_name'];
    password = json['password'];
    status = json['status'];
    userRoleId = json['user_role_id'];
    empId = json['emp_id'];
    canViewAll = json['can_view_all'];
    canEditAll = json['can_edit_all'];
    canAddAll = json['can_add_all'];
    userAbbr = json['user_abbr'];
    accessEmailCheckBox = json['access_email_check_box'];
    canViewClientContact = json['can_view_client_contact'];
    isGroup = json['is_group'];
    isCollection = json['is_collection'];
    createdOn = json['created_on'];
    createdBy = json['created_by'];
    socketId = json['socket_id'];
    employee = json['employee'] != null
        ? new Employee.fromJson(json['employee'])
        : null;
    unreadMessageCount = json['unread_message_count'];
    lastMessage = json['last_message'] != null
        ? new LastMessage.fromJson(json['last_message'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['regd_date'] = this.regdDate;
    data['user_name'] = this.userName;
    data['password'] = this.password;
    data['status'] = this.status;
    data['user_role_id'] = this.userRoleId;
    data['emp_id'] = this.empId;
    data['can_view_all'] = this.canViewAll;
    data['can_edit_all'] = this.canEditAll;
    data['can_add_all'] = this.canAddAll;
    data['user_abbr'] = this.userAbbr;
    data['access_email_check_box'] = this.accessEmailCheckBox;
    data['can_view_client_contact'] = this.canViewClientContact;
    data['is_group'] = this.isGroup;
    data['is_collection'] = this.isCollection;
    data['created_on'] = this.createdOn;
    data['created_by'] = this.createdBy;
    data['socket_id'] = this.socketId;
    if (this.employee != null) {
      data['employee'] = this.employee!.toJson();
    }
    data['unread_message_count'] = this.unreadMessageCount;
    if (this.lastMessage != null) {
      data['last_message'] = this.lastMessage!.toJson();
    }
    return data;
  }
}

@HiveType(typeId: 1)
class Employee {
  @HiveField(0)
  int? empId;

  @HiveField(1)
  String? empName;

  @HiveField(2)
  String? empImage;

  @HiveField(3)
  String? empCode;

  @HiveField(4)
  String? empDob;

  @HiveField(5)
  String? empAnniversary;

  int? allProcessAllowed;
  int? designationId;
  int? departmentId;
  int? isCommon;

  Employee(
      {this.empId,
      this.empName,
      this.designationId,
      this.departmentId,
      this.isCommon,
      this.empCode,
      this.allProcessAllowed,
      this.empDob,
      this.empAnniversary,
      this.empImage});

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
        empId: map['emp_id'],
        empName: map['emp_name'],
        empImage: map['emp_image'],
        empCode: map['emp_code'],
        empDob: map['emp_dob'],
        empAnniversary: map['emp_anniversary']);
  }

  Employee.fromJson(Map<String, dynamic> json) {
    empId = json['emp_id'];
    empName = json['emp_name'];
    designationId = json['designation_id'];
    departmentId = json['department_id'];
    isCommon = json['is_common'];
    empCode = json['emp_code'];
    allProcessAllowed = json['all_process_allowed'];
    empDob = json['emp_dob'];
    empAnniversary = json['emp_anniversary'];
    empImage = json['emp_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['emp_id'] = this.empId;
    data['emp_name'] = this.empName;
    data['designation_id'] = this.designationId;
    data['department_id'] = this.departmentId;
    data['is_common'] = this.isCommon;
    data['emp_code'] = this.empCode;
    data['all_process_allowed'] = this.allProcessAllowed;
    data['emp_dob'] = this.empDob;
    data['emp_anniversary'] = this.empAnniversary;
    data['emp_image'] = this.empImage;
    return data;
  }
}

@HiveType(typeId: 2)
class LastMessage {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? msg;

  @HiveField(2)
  String? createdAt;

  @HiveField(3)
 var userSendBy;

  @HiveField(4)
  var userReceiveBy;

  @HiveField(5)
  var referenceId;

  @HiveField(6)
  var isRead;

  @HiveField(7)
  String? readOn;

  LastMessage(
      {this.id,
      this.userSendBy,
      this.userReceiveBy,
      this.msg,
      this.isRead,
      this.createdAt,
      this.readOn,
      this.referenceId});

  factory LastMessage.fromMap(Map<String, dynamic> map) {
    return LastMessage(
      id: map['id'],
      userSendBy: map['user_send_by'],
      userReceiveBy: map['user_receive_by'],
      msg: map['msg'],
      isRead: map['is_read'],
      createdAt: map['createdAt'],
      readOn: map['read_on'],
      referenceId: map['reference_id'],
    );
  }

  LastMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userSendBy = json['user_send_by'];
    userReceiveBy = json['user_receive_by'];
    msg = json['msg'];
    isRead = json['is_read'];
    createdAt = json['createdAt'];
    readOn = json['read_on'];
    referenceId = json['reference_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_send_by'] = this.userSendBy;
    data['user_receive_by'] = this.userReceiveBy;
    data['msg'] = this.msg;
    data['is_read'] = this.isRead;
    data['createdAt'] = this.createdAt;
    data['read_on'] = this.readOn;
    data['reference_id'] = this.referenceId;
    return data;
  }
}
