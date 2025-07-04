import 'package:AccuChat/Screens/chat_module/models/user_chat_list_model.dart';
import 'package:hive/hive.dart';
part 'chat_detail_model.g.dart';

class ChatDetailResModel {
  SenderData? senderId;
  SenderData? receiverId;
  var message;
  var referenceId;
  var createdAt;
  LastMessage? messageReplyData;

  ChatDetailResModel(
      {this.senderId,
        this.receiverId,
        this.message,
        this.referenceId,
        this.messageReplyData,
        this.createdAt});

  ChatDetailResModel.fromJson(Map<String, dynamic> json) {
    senderId = json['sender_id'] != null
        ? new SenderData.fromJson(json['sender_id'])
        : null;
    receiverId = json['receiver_id'] != null
        ? new SenderData.fromJson(json['receiver_id'])
        : null;
    message = json['message'];
    referenceId = json['reference_id'];
    createdAt = json['created_at'];
    messageReplyData =
    json['reply'] != null ? new LastMessage.fromJson(json['reply']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.senderId != null) {
      data['sender_id'] = this.senderId!.toJson();
    }
    if (this.receiverId != null) {
      data['receiver_id'] = this.receiverId!.toJson();
    }
    data['message'] = this.message;
    data['reference_id'] = this.referenceId;
    data['created_at'] = this.createdAt;
    if (this.messageReplyData != null) {
      data['reply'] = this.messageReplyData!.toJson();
    }
    return data;
  }
}



@HiveType(typeId: 4)
class SenderData {
  @HiveField(0)
  var userId;

  @HiveField(1)
  var userName;

  @HiveField(2)
  var status;

  @HiveField(3)
  var empId;

  @HiveField(4)
  var userAbbr;

  @HiveField(5)
  var isGroup;

  @HiveField(6)
  var isCollection;




  var userRoleId;
  var regdDate;
  var password;
  var accessEmailCheckBox;
  var canViewClientContact;
  var createdOn;
  var socketId;
  var canViewAll;
  var canEditAll;
  var canAddAll;

  SenderData(
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
        this.socketId});

  SenderData.fromJson(Map<String, dynamic> json) {
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
    socketId = json['socket_id'];
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
    data['socket_id'] = this.socketId;
    return data;
  }
}
