// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatHistoryDataAdapter extends TypeAdapter<ChatHistoryData> {
  @override
  final int typeId = 3;

  @override
  ChatHistoryData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatHistoryData(
      id: fields[0] as int?,
      userSendBy: fields[1] as dynamic,
      userReceiveBy: fields[2] as dynamic,
      msg: fields[3] as dynamic,
      isRead: fields[4] as dynamic,
      createdAt: fields[5] as dynamic,
      readOn: fields[6] as dynamic,
      referenceId: fields[7] as dynamic,
      message: fields[8] as LastMessage?,
      senderUser: fields[9] as SenderData?,
      receiverUser: fields[10] as SenderData?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatHistoryData obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userSendBy)
      ..writeByte(2)
      ..write(obj.userReceiveBy)
      ..writeByte(3)
      ..write(obj.msg)
      ..writeByte(4)
      ..write(obj.isRead)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.readOn)
      ..writeByte(7)
      ..write(obj.referenceId)
      ..writeByte(8)
      ..write(obj.message)
      ..writeByte(9)
      ..write(obj.senderUser)
      ..writeByte(10)
      ..write(obj.receiverUser);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatHistoryDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
