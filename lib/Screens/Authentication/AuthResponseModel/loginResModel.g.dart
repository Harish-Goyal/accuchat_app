// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loginResModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserDataAdapter extends TypeAdapter<UserData> {
  @override
  final int typeId = 6;

  @override
  UserData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserData(
      userId: fields[0] as dynamic,
      regdDate: fields[1] as dynamic,
      userName: fields[2] as dynamic,
      status: fields[3] as dynamic,
      userRoleId: fields[4] as dynamic,
      empId: fields[5] as dynamic,
      userAbbr: fields[6] as dynamic,
      empName: fields[7] as dynamic,
      empImage: fields[8] as dynamic,
      empDob: fields[9] as dynamic,
      isCollection: fields[12] as dynamic,
      isGroup: fields[11] as dynamic,
      empAnniversary: fields[10] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, UserData obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.regdDate)
      ..writeByte(2)
      ..write(obj.userName)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.userRoleId)
      ..writeByte(5)
      ..write(obj.empId)
      ..writeByte(6)
      ..write(obj.userAbbr)
      ..writeByte(7)
      ..write(obj.empName)
      ..writeByte(8)
      ..write(obj.empImage)
      ..writeByte(9)
      ..write(obj.empDob)
      ..writeByte(10)
      ..write(obj.empAnniversary)
      ..writeByte(11)
      ..write(obj.isGroup)
      ..writeByte(12)
      ..write(obj.isCollection);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
