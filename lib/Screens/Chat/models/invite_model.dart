import 'package:AccuChat/Screens/Chat/models/company_model.dart';

class InvitationModel {
  final String id;
  final String companyId;
  CompanyModel? company;
  final String email;
   String? name;
  final String invitedBy;
  final String sentAt;
  final bool isAccepted;

  InvitationModel({
    required this.id,
    required this.companyId,
    required this.email,
    required this.name,
    required this.invitedBy,
    required this.sentAt,
    required this.company,
    this.isAccepted = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'companyId': companyId,
    'email': email,
    'invitedBy': invitedBy,
    'sentAt': sentAt,
    'name': name,
    'isAccepted': isAccepted,
     if (company != null) 'company' : company!.toJson()
  };

  factory InvitationModel.fromMap(Map<String, dynamic> map) => InvitationModel(
    id: map['id'],
    companyId: map['companyId'],
    email: map['email'],
      name: map['name'],
    invitedBy: map['invitedBy'],
    sentAt: map['sentAt'],
    isAccepted: map['isAccepted'],
      company : map['company'] != null
          ? CompanyModel.fromJson(map['company'])
          : null
  );
}
