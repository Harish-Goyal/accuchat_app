// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_chat_list_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserChatListDataAdapter extends TypeAdapter<UserChatListData> {
  @override
  final int typeId = 0;

  @override
  UserChatListData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserChatListData(
      userId: fields[0] as int?,
      userName: fields[1] as String?,
      status: fields[3] as int?,
      empId: fields[2] as int?,
      userAbbr: fields[4] as String?,
      isGroup: fields[5] as int?,
      isCollection: fields[6] as dynamic,
      createdBy: fields[10] as dynamic,
      employee: fields[8] as Employee?,
      unreadMessageCount: fields[7] as int?,
      lastMessage: fields[9] as LastMessage?,
    );
  }

  @override
  void write(BinaryWriter writer, UserChatListData obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.userName)
      ..writeByte(2)
      ..write(obj.empId)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.userAbbr)
      ..writeByte(5)
      ..write(obj.isGroup)
      ..writeByte(6)
      ..write(obj.isCollection)
      ..writeByte(7)
      ..write(obj.unreadMessageCount)
      ..writeByte(8)
      ..write(obj.employee)
      ..writeByte(9)
      ..write(obj.lastMessage)
      ..writeByte(10)
      ..write(obj.createdBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserChatListDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmployeeAdapter extends TypeAdapter<Employee> {
  @override
  final int typeId = 1;

  @override
  Employee read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Employee(
      empId: fields[0] as int?,
      empName: fields[1] as String?,
      empCode: fields[3] as String?,
      empDob: fields[4] as String?,
      empAnniversary: fields[5] as String?,
      empImage: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Employee obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.empId)
      ..writeByte(1)
      ..write(obj.empName)
      ..writeByte(2)
      ..write(obj.empImage)
      ..writeByte(3)
      ..write(obj.empCode)
      ..writeByte(4)
      ..write(obj.empDob)
      ..writeByte(5)
      ..write(obj.empAnniversary);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LastMessageAdapter extends TypeAdapter<LastMessage> {
  @override
  final int typeId = 2;

  @override
  LastMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LastMessage(
      id: fields[0] as int?,
      userSendBy: fields[3] as dynamic,
      userReceiveBy: fields[4] as dynamic,
      msg: fields[1] as String?,
      isRead: fields[6] as dynamic,
      createdAt: fields[2] as String?,
      readOn: fields[7] as String?,
      referenceId: fields[5] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, LastMessage obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.msg)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.userSendBy)
      ..writeByte(4)
      ..write(obj.userReceiveBy)
      ..writeByte(5)
      ..write(obj.referenceId)
      ..writeByte(6)
      ..write(obj.isRead)
      ..writeByte(7)
      ..write(obj.readOn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LastMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
