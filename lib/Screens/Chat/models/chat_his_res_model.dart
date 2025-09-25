class ChatHisResModel {
  int? companyId;
  int? chatId;
  int? fromId;
  int? toUserId;
  String? chatText;
  String? sentOn;
  int? isGroupChat;
  int? broadcastUserId;
  List<dynamic>? media;

  ChatHisResModel(
      {this.companyId,
        this.chatId,
        this.fromId,
        this.toUserId,
        this.chatText,
        this.sentOn,
        this.isGroupChat,
        this.broadcastUserId,
        this.media});

  ChatHisResModel.fromJson(Map<String, dynamic> json) {
    companyId = json['company_id'];
    chatId = json['chat_id'];
    fromId = json['from_id'];
    toUserId = json['to_user_id'];
    chatText = json['chat_text'];
    sentOn = json['sent_on'];
    isGroupChat = json['is_group_chat'];
    broadcastUserId = json['broadcast_user_id'];
    if (json['media'] != null) {
      media = <dynamic>[];
      json['media'].forEach((v) {
        // media!.add(new Null.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['company_id'] = this.companyId;
    data['chat_id'] = this.chatId;
    data['from_id'] = this.fromId;
    data['to_user_id'] = this.toUserId;
    data['chat_text'] = this.chatText;
    data['sent_on'] = this.sentOn;
    data['is_group_chat'] = this.isGroupChat;
    data['broadcast_user_id'] = this.broadcastUserId;
    if (this.media != null) {
      data['media'] = this.media!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

