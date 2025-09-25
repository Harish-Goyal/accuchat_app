// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_company_res_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompanyDataAdapter extends TypeAdapter<CompanyData> {
  @override
  final int typeId = 1;

  @override
  CompanyData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompanyData(
      companyId: fields[0] as int?,
      companyName: fields[1] as String?,
      address: fields[2] as String?,
      website: fields[3] as String?,
      email: fields[4] as String?,
      phone: fields[5] as String?,
      isAppCompany: fields[6] as int?,
      createdOn: fields[7] as String?,
      updatedOn: fields[8] as String?,
      isActive: fields[9] as int?,
      isDeleted: fields[10] as int?,
      logo: fields[11] as String?,
      createdBy: fields[12] as int?,
      userCompanies: fields[13] as UserCompanies?,
      creator: fields[14] as Creator?,
      members: (fields[15] as List?)?.cast<Members>(),
    );
  }

  @override
  void write(BinaryWriter writer, CompanyData obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.companyId)
      ..writeByte(1)
      ..write(obj.companyName)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.website)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.isAppCompany)
      ..writeByte(7)
      ..write(obj.createdOn)
      ..writeByte(8)
      ..write(obj.updatedOn)
      ..writeByte(9)
      ..write(obj.isActive)
      ..writeByte(10)
      ..write(obj.isDeleted)
      ..writeByte(11)
      ..write(obj.logo)
      ..writeByte(12)
      ..write(obj.createdBy)
      ..writeByte(13)
      ..write(obj.userCompanies)
      ..writeByte(14)
      ..write(obj.creator)
      ..writeByte(15)
      ..write(obj.members);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserCompaniesAdapter extends TypeAdapter<UserCompanies> {
  @override
  final int typeId = 2;

  @override
  UserCompanies read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserCompanies(
      userCompanyId: fields[0] as int?,
      userId: fields[1] as int?,
      companyId: fields[2] as int?,
      isActive: fields[3] as int?,
      userCompanyRoleId: fields[4] as int?,
      createdOn: fields[5] as String?,
      isDeleted: fields[6] as int?,
      invitedBy: fields[7] as int?,
      invitedOn: fields[8] as String?,
      joinedOn: fields[9] as String?,
      userCompanyRole: fields[10] as UserCompanyRole?,
    );
  }

  @override
  void write(BinaryWriter writer, UserCompanies obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.userCompanyId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.companyId)
      ..writeByte(3)
      ..write(obj.isActive)
      ..writeByte(4)
      ..write(obj.userCompanyRoleId)
      ..writeByte(5)
      ..write(obj.createdOn)
      ..writeByte(6)
      ..write(obj.isDeleted)
      ..writeByte(7)
      ..write(obj.invitedBy)
      ..writeByte(8)
      ..write(obj.invitedOn)
      ..writeByte(9)
      ..write(obj.joinedOn)
      ..writeByte(10)
      ..write(obj.userCompanyRole);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserCompaniesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserCompanyRoleAdapter extends TypeAdapter<UserCompanyRole> {
  @override
  final int typeId = 3;

  @override
  UserCompanyRole read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserCompanyRole(
      userRole: fields[0] as String?,
      isDefault: fields[1] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, UserCompanyRole obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.userRole)
      ..writeByte(1)
      ..write(obj.isDefault);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserCompanyRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CreatorAdapter extends TypeAdapter<Creator> {
  @override
  final int typeId = 4;

  @override
  Creator read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Creator(
      userId: fields[0] as int?,
      userName: fields[1] as String?,
      email: fields[2] as String?,
      phone: fields[3] as String?,
      allowedCompanies: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Creator obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.userName)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.allowedCompanies);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MembersAdapter extends TypeAdapter<Members> {
  @override
  final int typeId = 5;

  @override
  Members read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Members(
      userId: fields[0] as int?,
      userName: fields[1] as String?,
      email: fields[2] as String?,
      phone: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Members obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.userName)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MembersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
