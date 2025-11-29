import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Views/chat_screen.dart';

import '../api/apis.dart';
enum ChatMediaType { TEXT,IMAGE, VID, DOC , AUD,other}
class ChatHisResModelAPI {
  bool? success;
  int? code;
  String? message;
  ChatHistoryRes? data;

  ChatHisResModelAPI({this.success, this.code, this.message, this.data});

  ChatHisResModelAPI.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new ChatHistoryRes.fromJson(json['data']) : null;
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

class ChatHistoryRes {
  int? page;
  int? limit;
  int? total;
  int? totalPages;
  List<ChatHisList>? rows;

  ChatHistoryRes({this.page, this.limit, this.total, this.totalPages, this.rows});

  ChatHistoryRes.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
    totalPages = json['totalPages'];
    if (json['rows'] != null) {
      rows = <ChatHisList>[];
      json['rows'].forEach((v) {
        rows!.add(new ChatHisList.fromJson(v));
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

class ChatHisList {
  int? chatId;
  UserDataAPI? fromUser;
  UserDataAPI? toUser;
  String? message;
  int? isActivity;
  int? isForwarded;
  String? sentOn;
  String? readOn;
  int? pendingCount;
  int? isGroupChat;
  int? broadcastUserId;
  int? replyToId;
  String? replyToText;
  String? replyToTime;
  String? replyToName;
  List<MediaList>? media;

  ChatHisList({this.chatId,this.replyToId,
    this.replyToText,
    this.isForwarded,
    this.readOn,
    this.pendingCount,
    this.replyToTime,
    this.replyToName,
    this.media,this.isGroupChat,this.broadcastUserId,this.isActivity, this.fromUser, this.toUser, this.message, this.sentOn});

  ChatHisList.fromJson(Map<String, dynamic> json) {
    chatId = json['chat_id'];
    replyToId = json['reply_to_id'];
    isForwarded = json['is_forwarded'];
    pendingCount = json['pending-count'];
    replyToText = json['reply_to_text'];
    replyToName = json['reply_to_name'];
    readOn=json['read_on'];
    replyToTime = json['reply_to_time'];
    isActivity = json['is_group_activity'];
    broadcastUserId = json['broadcast_user_id'];
    isGroupChat = json['is_group_chat'];
    fromUser = json['from_user'] != null
        ? new UserDataAPI.fromJson(json['from_user'])
        : null;
    toUser =
    json['to_user'] != null ? new UserDataAPI.fromJson(json['to_user']) : null;
    message = json['message'];
    sentOn = json['sent_on'];
    readOn = json['read_on'];
    if (json['media'] != null) {
      media = <MediaList>[];
      json['media'].forEach((v) {
        media!.add(new MediaList.fromJson(v));
      });
    }
  }
  static DateTime? parseReadOn(String? v) {
    if (v == null) return null;
    try {
      // Handles "2025-09-09T05:14:55.100Z" (UTC)
      final dt = DateTime.parse(v.toString());
      return dt.isUtc ? dt.toLocal() : dt; // show in device local time (IST for you)
    } catch (_) {
      return null;
    }
  }

  bool get isMe => fromUser?.userId == APIs.me.userId;
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chat_id'] = this.chatId;
    data['is_group_activity'] = this.isActivity;
    data['is_forwarded'] = this.isForwarded;
    data['reply_to_name'] = this.replyToName;
    data['is_group_chat'] = this.isGroupChat;
    data['pending_count'] = this.pendingCount;
    data['reply_to_id'] = this.replyToId;
    data['reply_to_text'] = this.replyToText;
    data['reply_to_time'] = this.replyToTime;
    data['broadcast_user_id'] = this.broadcastUserId;
    if (this.fromUser != null) {
      data['from_user'] = this.fromUser!.toJson();
    }
    if (this.toUser != null) {
      data['to_user'] = this.toUser!.toJson();
    }
    data['message'] = this.message;
    if (this.media != null) {
      data['media'] = this.media!.map((v) => v.toJson()).toList();
    }
    data['sent_on'] = this.sentOn;
    data['read_on'] = this.readOn;
    return data;
  }


  ChatHisList copyWith({
    int? chatId,
    UserDataAPI? fromUser,
    UserDataAPI? toUser,
    String? message,
    int? isActivity,
    String? sentOn,
    int? isGroupChat,
    int? broadcastUserId,
    bool? isTask,
    int? replyToId,
    String? replyToText,
    String? replyToTime,
    List<MediaList>? media,
  }) {
    return ChatHisList(
      chatId: chatId ?? this.chatId,
      fromUser: fromUser ?? this.fromUser,
      toUser: toUser ?? this.toUser,
      message: message ?? this.message,
      isActivity: isActivity ?? this.isActivity,
      sentOn: sentOn ?? this.sentOn,
      isGroupChat: isGroupChat ?? this.isGroupChat,
      broadcastUserId: broadcastUserId ?? this.broadcastUserId,
      replyToId: replyToId ?? this.replyToId,
      replyToText: replyToText ?? this.replyToText,
      replyToTime: replyToTime ?? this.replyToTime,
      media: media ?? this.media,
    );
  }

}


class MediaList {
  int? chatMediaId;
  int? chatId;
  int? mediaTypeId;
  String? fileName;
  String? orgFileName;
  MediaTypeAPI? mediaType;

  MediaList(
      {this.chatMediaId,
        this.chatId,
        this.mediaTypeId,
        this.fileName,
        this.orgFileName,
        this.mediaType});

  MediaList.fromJson(Map<String, dynamic> json) {
    chatMediaId = json['chat_media_id'];
    chatId = json['chat_id'];
    mediaTypeId = json['media_type_id'];
    fileName = json['file_name'];
    orgFileName = json['org_file_name'];
    mediaType = json['media_type'] != null
        ? new MediaTypeAPI.fromJson(json['media_type'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chat_media_id'] = this.chatMediaId;
    data['chat_id'] = this.chatId;
    data['media_type_id'] = this.mediaTypeId;
    data['org_file_name'] = this.orgFileName;
    data['file_name'] = this.fileName;
    if (this.mediaType != null) {
      data['media_type'] = this.mediaType!.toJson();
    }
    return data;
  }


}

class MediaTypeAPI {
  int? mediaTypeId;
  String? mediaType;
  String? mediaCode;
  int? isActive;

  MediaTypeAPI({this.mediaTypeId, this.mediaType, this.mediaCode, this.isActive});

  MediaTypeAPI.fromJson(Map<String, dynamic> json) {
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

  static ChatMediaType fromCode(String? code, {String? fileName}) {
    final c = (code ?? '').toUpperCase();
    if (c == 'IMAGE') return ChatMediaType.IMAGE;
    if (c == 'VIDEO') return ChatMediaType.VID;
    if (c == 'AUDIO') return ChatMediaType.AUD; // <-- fixed

    // Fallback by extension
    final ext = (fileName ?? '').toLowerCase();
    if (ext.endsWith('.jpg') || ext.endsWith('.jpeg') || ext.endsWith('.png') || ext.endsWith('.webp')) {
      return ChatMediaType.IMAGE;
    }
    if (ext.endsWith('.mp4') || ext.endsWith('.mov') || ext.endsWith('.mkv')) {
      return ChatMediaType.VID;
    }
    if (ext.endsWith('.mp3') || ext.endsWith('.aac') || ext.endsWith('.wav')) {
      return ChatMediaType.AUD;
    }
    if (ext.endsWith('.pdf') || ext.endsWith('.doc') || ext.endsWith('.docx') ||
        ext.endsWith('.xls') || ext.endsWith('.xlsx') || ext.endsWith('.ppt') ||
        ext.endsWith('.pptx') || ext.endsWith('.txt')) {
      return ChatMediaType.DOC;
    }
    return ChatMediaType.other;
  }


}



