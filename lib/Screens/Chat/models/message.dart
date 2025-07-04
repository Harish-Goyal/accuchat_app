enum TaskStatus { Pending, Running, Done, Completed, Cancelled }

class Message {
  Message({
    required this.toId,
    required this.companyId,
    required this.msg,
    required this.read,
    required this.type,
    required this.fromId,
    required this.typing,
    required this.sent,
    this.replyToMsg,
    this.replyToSenderName,
    this.replyToType,
    this.forwardTrail,
    this.originalSenderId,
    this.originalSenderName,
    this.isTask = false,
    this.taskDetails,
    this.taskStartTime,
    required this.createdAt,
  });

  late final String toId;
  late final String msg;
  late final String read;
  late final bool typing;
  late final String fromId;
  late final String sent;
  String? companyId;
  late Type type;

  String? replyToMsg;
  String? replyToSenderName;
  Type? replyToType;

  String? originalSenderId;
  String? originalSenderName;
  List<Map<String, String>>? forwardTrail;

  bool? isTask;
  TaskDetails? taskDetails;
  String? taskStartTime;
  String? createdAt;

  Message.fromJson(Map<String, dynamic> json) {
    toId = json['toId'] ?? '';
    msg = json['msg'] ?? '';
    companyId = json['companyId'] ?? '';
    read = json['read'] ?? '';
    typing = json['typing'] ?? false;
    fromId = json['fromId'] ?? '';
    sent = json['sent'] ?? '';
    createdAt = json['createdAt'] ?? '';
    type = Type.values
        .firstWhere((e) => e.name == json['type'], orElse: () => Type.text);

    replyToMsg = json['replyToMsg'];
    replyToSenderName = json['replyToSenderName'];
    replyToType = json['replyToType'] != null
        ? Type.values.firstWhere((e) => e.name == json['replyToType'],
            orElse: () => Type.text)
        : null;

    originalSenderId = json['originalSenderId'];
    originalSenderName = json['originalSenderName'];

    forwardTrail = (json['forwardTrail'] as List?)?.map((e) {
      return Map<String, String>.from(e as Map);
    }).toList();

    isTask = json['isTask'] ?? false;
    taskStartTime = json['taskStartTime'];
    taskDetails = json['taskDetails'] != null
        ? TaskDetails.fromJson(json['taskDetails'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'toId': toId,
      'msg': msg,
      'read': read,
      'type': type.name,
      'typing': typing,
      'fromId': fromId,
      'sent': sent,
      'companyId': companyId,
      'isTask': isTask,
    };

    if (replyToMsg != null) data['replyToMsg'] = replyToMsg;
    if (replyToSenderName != null)
      data['replyToSenderName'] = replyToSenderName;
    if (replyToType != null) data['replyToType'] = replyToType!.name;
    if (originalSenderId != null) data['originalSenderId'] = originalSenderId;
    if (originalSenderName != null)
      data['originalSenderName'] = originalSenderName;
    if (forwardTrail != null && forwardTrail!.isNotEmpty) {
      data['forwardTrail'] = forwardTrail;
    }
    if (taskDetails != null) data['taskDetails'] = taskDetails!.toJson();
    if (taskStartTime != null) data['taskStartTime'] = taskStartTime;
    if (createdAt != null) data['createdAt'] = createdAt;

    return data;
  }
}

class TaskDetails {
  final String title;
  final String description;
  final String estimatedTime;
  String? startTime;
  String? endTime;
  List<Map<String, dynamic>>? attachments;
  String? taskStatus;

  TaskDetails({
    required this.title,
    required this.description,
    required this.estimatedTime,
    this.startTime,
    this.endTime,
    this.attachments,
    this.taskStatus = 'Pending',
  });

  factory TaskDetails.fromJson(Map<String, dynamic> json) => TaskDetails(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      estimatedTime: json['estimatedTime'] ?? '',
      startTime: json['startTime'],
      endTime: json['endTime'],
      taskStatus: json['status'] ?? 'Pending',
      attachments: (json['attachments'] as List?)?.map((e) {
        return Map<String, String>.from(e as Map);
      }).toList());

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'estimatedTime': estimatedTime,
        if (startTime != null) 'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
        if (taskStatus != null) 'status': taskStatus,
        if (attachments != null && attachments!.isNotEmpty)
          'attachments': attachments
      };
}

enum Type { text, image, video, doc }
