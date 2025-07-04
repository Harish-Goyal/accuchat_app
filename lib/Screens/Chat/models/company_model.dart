class CompanyModel {
   String? id;
  String? name;
  String? logoUrl;
  String? address;
  String? websiteURL;
  String? createdBy;
  int? allowedCompany;
  String? email;
  String? phone;
  String? adminUserId;
  List<String>? members;
  String? createdAt;

  CompanyModel({
    this.id,
    required this.name,
    this.logoUrl,
    this.email,
    this.websiteURL,
    this.allowedCompany = 10,
    this.phone,
    this.address,
    this.createdBy,
    this.adminUserId,
    this.members,
    this.createdAt,
  });

  CompanyModel copyWith({
    String? logoUrl,
    // add other fields if needed
  }) {
    return CompanyModel(
      id: id,
      name: name,
      logoUrl: logoUrl ?? this.logoUrl,
      address: address,
      createdBy: createdBy,
      allowedCompany: allowedCompany,
      email: email,
      phone: phone,
      websiteURL: websiteURL,
      adminUserId: adminUserId,
      members: members,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'logoUrl': logoUrl,
    'websiteURL': websiteURL,
    'address': address,
    'createdBy': createdBy,
    'members': members,
    'allowedCompany': allowedCompany,
    'email': email,
    'phone': phone,
    'createdAt': createdAt,
    'adminUserId': adminUserId,
  };

  factory CompanyModel.fromJson(Map<String, dynamic> json) => CompanyModel(
    id: json['id'],
    name: json['name'],
    logoUrl: json['logoUrl'],
    email: json['email'],
    phone: json['phone'],
    websiteURL: json['websiteURL'],
    address: json['address'],
    allowedCompany: json['allowedCompany'],
    createdBy: json['createdBy'],
    members: List<String>.from(json['members'] ?? []),
    createdAt: json['createdAt'],
    adminUserId: json['adminUserId'],
  );
}
