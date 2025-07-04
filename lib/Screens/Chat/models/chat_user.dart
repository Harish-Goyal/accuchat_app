import '../../../utils/helper_widget.dart' as Helper;
import 'company_model.dart';

class ChatUser {
  ChatUser({
    required this.image,
    required this.xStikers,
    required this.about,
    required this.phone,
    required this.name,
    required this.createdAt,
    required this.isOnline,
    required this.company,
    this.selectedCompany,
    required this.id,
    required this.role,
    required this.lastActive,
    required this.email,
    required this.isTyping,
    required this.pushToken,
    required this.lastMessageTime,
  });
  var image;
  var xStikers;
  var about;
  var name;
  List<CompanyModel>? company;
  CompanyModel? selectedCompany;
  var phone;
  var createdAt;
  var isOnline;
  var isTyping;
  var id;
  var role;
  var companyId;
  var lastActive;
  var email;
  var pushToken;
  var lastMessageTime;

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    phone = json['phone'] ?? '';
    xStikers = json['xStikers'] ?? '';
    createdAt = Helper.parseTimestamp(json['created_at'] ?? '');
    isOnline = json['is_online'] ?? '';
    isTyping = json['is_typing'] ?? '';
    id = json['id'] ?? '';
    role = json['role'] ?? '';
    companyId = json['companyId'] ?? '';

    lastActive = Helper.parseTimestamp(json['last_active']);
    lastMessageTime = Helper.parseTimestamp(json['lastMessageTime'] ?? '');
    email = json['email'] ?? '';
    pushToken = json['push_token'] ?? '';

    if (json['company'] != null) {
      company = <CompanyModel>[];
      json['company'].forEach((v) {
        company!.add(CompanyModel.fromJson(v));
      });
    }

    selectedCompany =
        json['selectedCompany'] != null ? CompanyModel.fromJson(json['selectedCompany']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['about'] = about;
    data['phone'] = phone;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['xStikers'] = xStikers;
    data['is_online'] = isOnline;
    data['is_typing'] = isTyping;
    data['id'] = id;
    data['role'] = role;
    data['companyId'] = companyId;
    data['last_active'] = lastActive;
    data['lastMessageTime'] = lastMessageTime;
    data['email'] = email;
    data['push_token'] = pushToken;

    if (this.company != null) {
      data['company'] = this.company!.map((v) => v.toJson()).toList();
    }
    else {
      data['company'] = null;
    }

    if (selectedCompany != null) {
      data['selectedCompany'] = selectedCompany!.toJson();
    } else {
      data['selectedCompany'] = null;
    }
    return data;
  }
}

class ChatGroup {
  final String? id;
   String companyId;
  final String? name;
  final String? image;
  final String? createdBy;
  final String? createdAt;
  var lastActive;
  var email;
  final List<String>? members;
  final List<String>? admins;
  String? lastMessage;
  String? lastMessageTime;
  var isOnline;
  var isTyping;

  ChatGroup({
    this.id,
    required this.companyId,
    this.name,
    this.image,
    this.createdBy,
    this.createdAt,
    this.members,
    this.admins,
    this.lastMessage = '',
    this.lastMessageTime = '',
    this.email,
    this.isOnline,
    this.isTyping,
    this.lastActive,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'companyId': companyId,
        'name': name,
        'image': image,
        'createdBy': createdBy,
        'createdAt': createdAt,
        'members': members,
        'admins': admins,
        'lastMessage': lastMessage,
        'lastMessageTime': lastMessageTime,
        'last_active': lastActive,
        'email': email,
        'is_online': isOnline,
        'is_typing': isTyping,
      };

  factory ChatGroup.fromJson(Map<String, dynamic> json) => ChatGroup(
        id: json['id'],
        companyId: json['companyId'],
        name: json['name'],
        image: json['image'],
        createdBy: json['createdBy'],
        createdAt: Helper.parseTimestamp(json['createdAt']),
        members: List<String>.from(json['members']),
        admins: List<String>.from(json['admins']),
        lastMessage: json['lastMessage'] ?? '',
        lastMessageTime: Helper.parseTimestamp(json['lastMessageTime'] ?? ''),
        lastActive: Helper.parseTimestamp(json['last_active'] ?? ''),
        email: json['email'] ?? '',
        isOnline: json['is_online'] ?? '',
        isTyping: json['is_typing'] ?? '',
      );
}

class BroadcastChat {
  String id;
  String companyId;
  String name;
  String createdBy;
  String createdAt;
  String? image;
  String? lastMessage;
  List<String> members;
  String? lastMessageTime;
  // String? lastActive;

  BroadcastChat({
    required this.id,
    required this.companyId,
    required this.name,
    required this.createdAt,
    required this.createdBy,
    this.image,
    required this.members,
    required this.lastMessage,
    this.lastMessageTime,
    // this.lastActive,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'companyId': companyId,
        'name': name,
        'image': image,
        'createdBy': createdBy,
        'createdAt': createdAt,
        'members': members,
        'lastMessage': lastMessage,
        'lastMessageTime': lastMessageTime,
        // 'lastActive': lastActive,
      };

  factory BroadcastChat.fromJson(Map<String, dynamic> json) {
    return BroadcastChat(
      id: json['id'] ?? '',
      companyId: json['companyId'] ?? '',
      name: json['name'] ?? '',
      createdAt: json['createdAt'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      createdBy: json['createdBy'] ?? '',
      image: json['image'],
      members: List<String>.from(json['members'] ?? []),
      // lastActive: Helper.parseTimestamp(json['last_active'] ?? ''),
      lastMessageTime: Helper.parseTimestamp(json['lastMessageTime'] ?? ''),
    );
  }
}
