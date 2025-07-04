import 'package:AccuChat/Screens/chat_module/models/chat_detail_model.dart';
import 'package:AccuChat/Screens/chat_module/models/user_chat_list_model.dart';
import 'package:hive/hive.dart';
part 'chat_history_model.g.dart'; // Part file for the generated adapter

class ChatHistoryResModel {
  bool? success;
  int? code;
  String? message;
  List<ChatHistoryData>? body;

  ChatHistoryResModel({this.success, this.code, this.message, this.body});

  ChatHistoryResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    if (json['body'] != null) {
      body = <ChatHistoryData>[];
      json['body'].forEach((v) {
        body!.add(new ChatHistoryData.fromJson(v));
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

@HiveType(typeId: 3) // Unique typeId for Tasks_Chat History
class ChatHistoryData {
  @HiveField(0)
  int? id;

  @HiveField(1)
  var userSendBy;

  @HiveField(2)
  var userReceiveBy;

  @HiveField(3)
  var msg;

  @HiveField(4)
  var isRead;

  @HiveField(5)
  var createdAt;

  @HiveField(6)
  var readOn;

  @HiveField(7)
  var referenceId;

  @HiveField(8)
  LastMessage? message;

  @HiveField(9)
  SenderData? senderUser;

  @HiveField(10)
  SenderData? receiverUser;

  ChatHistoryData(
      {this.id,
      this.userSendBy,
      this.userReceiveBy,
      this.msg,
      this.isRead,
      this.createdAt,
      this.readOn,
      this.referenceId,
      this.message,
      this.senderUser,
      this.receiverUser});


  factory ChatHistoryData.fromMap(Map<String, dynamic> map) {
    return ChatHistoryData(
      id:  map['id'],
      userSendBy:  map['user_send_by'],
      userReceiveBy:  map['user_receive_by'],
      msg:  map['msg'],
      isRead:  map['is_read'],
      createdAt:  map['createdAt'],
      readOn:  map['read_on'],
      referenceId:  map['reference_id'],
      message:  map['message'] ?? LastMessage(),
      senderUser:  map['sender_user'] ?? SenderData(),
      receiverUser:  map['receiver_user'] ?? SenderData(),
    );
  }

  ChatHistoryData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userSendBy = json['user_send_by'];
    userReceiveBy = json['user_receive_by'];
    msg = json['msg'];
    isRead = json['is_read'];
    createdAt = json['createdAt'];
    readOn = json['read_on'];
    referenceId = json['reference_id'];
    message = json['message'] != null
        ? new LastMessage.fromJson(json['message']) : null;
    senderUser = json['sender_user'] != null
        ? new SenderData.fromJson(json['sender_user'])
        : null;
    receiverUser = json['receiver_user'] != null
        ? new SenderData.fromJson(json['receiver_user'])
        : null;
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
    if (this.message != null) {
      data['message'] = this.message!.toJson();
    }
    if (this.senderUser != null) {
      data['sender_user'] = this.senderUser!.toJson();
    }
    if (this.receiverUser != null) {
      data['receiver_user'] = this.receiverUser!.toJson();
    }
    return data;
  }
}
