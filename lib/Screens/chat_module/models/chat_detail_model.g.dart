// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_detail_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SenderDataAdapter extends TypeAdapter<SenderData> {
  @override
  final int typeId = 4;

  @override
  SenderData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SenderData(
      userId: fields[0] as dynamic,
      userName: fields[1] as dynamic,
      status: fields[2] as dynamic,
      empId: fields[3] as dynamic,
      userAbbr: fields[4] as dynamic,
      isGroup: fields[5] as dynamic,
      isCollection: fields[6] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, SenderData obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.userName)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.empId)
      ..writeByte(4)
      ..write(obj.userAbbr)
      ..writeByte(5)
      ..write(obj.isGroup)
      ..writeByte(6)
      ..write(obj.isCollection);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SenderDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
