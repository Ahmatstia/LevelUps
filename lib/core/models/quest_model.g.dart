// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestModelAdapter extends TypeAdapter<QuestModel> {
  @override
  final int typeId = 12;

  @override
  QuestModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestModel(
      id: fields[0] as String,
      type: fields[1] as QuestType,
      title: fields[2] as String,
      description: fields[3] as String,
      rewardXp: fields[4] as int,
      targetValue: fields[5] as int,
      currentValue: fields[6] as int,
      isCompleted: fields[7] as bool,
      expiresAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, QuestModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.rewardXp)
      ..writeByte(5)
      ..write(obj.targetValue)
      ..writeByte(6)
      ..write(obj.currentValue)
      ..writeByte(7)
      ..write(obj.isCompleted)
      ..writeByte(8)
      ..write(obj.expiresAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuestTypeAdapter extends TypeAdapter<QuestType> {
  @override
  final int typeId = 11;

  @override
  QuestType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QuestType.daily;
      case 1:
        return QuestType.weekly;
      case 2:
        return QuestType.monthly;
      default:
        return QuestType.daily;
    }
  }

  @override
  void write(BinaryWriter writer, QuestType obj) {
    switch (obj) {
      case QuestType.daily:
        writer.writeByte(0);
        break;
      case QuestType.weekly:
        writer.writeByte(1);
        break;
      case QuestType.monthly:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
