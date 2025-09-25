class MediaResModel {
  bool? success;
  int? code;
  String? message;
  MediaResData? data;

  MediaResModel({this.success, this.code, this.message, this.data});

  MediaResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new MediaResData.fromJson(json['data']) : null;
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

class MediaResData {
  MediaChatUSer? chat;
  List<MediaResA>? media;

  MediaResData({this.chat, this.media});

  MediaResData.fromJson(Map<String, dynamic> json) {
    chat = json['chat'] != null ? new MediaChatUSer.fromJson(json['chat']) : null;
    if (json['media'] != null) {
      media = <MediaResA>[];
      json['media'].forEach((v) {
        media!.add(new MediaResA.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.chat != null) {
      data['chat'] = this.chat!.toJson();
    }
    if (this.media != null) {
      data['media'] = this.media!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MediaChatUSer {
  int? chatId;
  int? fromId;
  int? toId;
  int? isGroupChat;
  String? chatText;
  int? broadcastUserId;
  int? repliedToId;
  String? repliedToText;
  String? repliedToTime;
  String? sentOn;

  MediaChatUSer(
      {this.chatId,
        this.fromId,
        this.toId,
        this.isGroupChat,
        this.chatText,
        this.broadcastUserId,
        this.repliedToId,
        this.repliedToText,
        this.repliedToTime,
        this.sentOn});

  MediaChatUSer.fromJson(Map<String, dynamic> json) {
    chatId = json['chat_id'];
    fromId = json['from_id'];
    toId = json['to_id'];
    isGroupChat = json['is_group_chat'];
    chatText = json['chat_text'];
    broadcastUserId = json['broadcast_user_id'];
    repliedToId = json['replied_to_id'];
    repliedToText = json['replied_to_text'];
    repliedToTime = json['replied_to_time'];
    sentOn = json['sent_on'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chat_id'] = this.chatId;
    data['from_id'] = this.fromId;
    data['to_id'] = this.toId;
    data['is_group_chat'] = this.isGroupChat;
    data['chat_text'] = this.chatText;
    data['broadcast_user_id'] = this.broadcastUserId;
    data['replied_to_id'] = this.repliedToId;
    data['replied_to_text'] = this.repliedToText;
    data['replied_to_time'] = this.repliedToTime;
    data['sent_on'] = this.sentOn;
    return data;
  }
}

class MediaResA {
  int? chatMediaId;
  String? fileName;
  String? mediaCode;

  MediaResA({this.chatMediaId, this.fileName, this.mediaCode});

  MediaResA.fromJson(Map<String, dynamic> json) {
    chatMediaId = json['chat_media_id'];
    fileName = json['file_name'];
    mediaCode = json['media_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chat_media_id'] = this.chatMediaId;
    data['file_name'] = this.fileName;
    data['media_code'] = this.mediaCode;
    return data;
  }
}
