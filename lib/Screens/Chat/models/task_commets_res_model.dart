import 'package:AccuChat/Screens/Chat/models/chat_history_response_model.dart';
import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';

class TaskCommentsResModel {
  bool? success;
  int? page;
  int? limit;
  List<TaskComments>? rows;

  TaskCommentsResModel({this.success, this.page, this.limit, this.rows});

  TaskCommentsResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    page = json['page'];
    limit = json['limit'];
    if (json['rows'] != null) {
      rows = <TaskComments>[];
      json['rows'].forEach((v) {
        rows!.add(new TaskComments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['page'] = this.page;
    data['limit'] = this.limit;
    if (this.rows != null) {
      data['rows'] = this.rows!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TaskComments {
  int? taskCommentId;
  UserDataAPI? fromUser;
  UserDataAPI? toUser;
  String? commentText;
  String? sentOn;
  int? isDeleted;
  List<MediaList>? media;

  TaskComments(
      {this.taskCommentId,
        this.fromUser,
        this.toUser,
        this.commentText,
        this.sentOn,
        this.media,
        this.isDeleted});

  TaskComments.fromJson(Map<String, dynamic> json) {
    taskCommentId = json['task_comment_id'];
    fromUser = json['from_user'] != null
        ? new UserDataAPI.fromJson(json['from_user'])
        : null;
    toUser =
    json['to_user'] != null ? new UserDataAPI.fromJson(json['to_user']) : null;
    commentText = json['comment_text'];
    sentOn = json['sent_on'];
    isDeleted = json['is_deleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['task_comment_id'] = this.taskCommentId;
    if (this.fromUser != null) {
      data['from_user'] = this.fromUser!.toJson();
    }
    if (this.toUser != null) {
      data['to_user'] = this.toUser!.toJson();
    }
    data['comment_text'] = this.commentText;
    data['sent_on'] = this.sentOn;
    data['is_deleted'] = this.isDeleted;
    return data;
  }
}

