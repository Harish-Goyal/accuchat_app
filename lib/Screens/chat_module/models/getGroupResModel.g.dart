// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'getGroupResModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GroupMemberDataAdapter extends TypeAdapter<GroupMemberData> {
  @override
  final int typeId = 5;

  @override
  GroupMemberData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroupMemberData(
      groupMemberId: fields[0] as int?,
      groupId: fields[1] as int?,
      memberId: fields[2] as int?,
      isRole: fields[3] as int?,
      createdOn: fields[4] as String?,
      user: fields[5] as UserData?,
    );
  }

  @override
  void write(BinaryWriter writer, GroupMemberData obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.groupMemberId)
      ..writeByte(1)
      ..write(obj.groupId)
      ..writeByte(2)
      ..write(obj.memberId)
      ..writeByte(3)
      ..write(obj.isRole)
      ..writeByte(4)
      ..write(obj.createdOn)
      ..writeByte(5)
      ..write(obj.user);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupMemberDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
