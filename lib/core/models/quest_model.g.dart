// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestModelAdapter extends TypeAdapter<QuestModel> {
  @override
  final int typeId = 11;

  @override
  QuestModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as QuestType,
      difficulty: fields[4] as QuestDifficulty,
      targetStat: fields[5] as String,
      targetValue: fields[6] as int,
      currentValue: fields[7] as int,
      isCompleted: fields[8] as bool,
      isClaimed: fields[9] as bool,
      createdAt: fields[10] as DateTime,
      expiresAt: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, QuestModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.difficulty)
      ..writeByte(5)
      ..write(obj.targetStat)
      ..writeByte(6)
      ..write(obj.targetValue)
      ..writeByte(7)
      ..write(obj.currentValue)
      ..writeByte(8)
      ..write(obj.isCompleted)
      ..writeByte(9)
      ..write(obj.isClaimed)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
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
  final int typeId = 15;

  @override
  QuestType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QuestType.daily;
      case 1:
        return QuestType.weekly;
      case 2:
        return QuestType.monthly;
      case 3:
        return QuestType.special;
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
      case QuestType.special:
        writer.writeByte(3);
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

class QuestDifficultyAdapter extends TypeAdapter<QuestDifficulty> {
  @override
  final int typeId = 16;

  @override
  QuestDifficulty read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QuestDifficulty.easy;
      case 1:
        return QuestDifficulty.medium;
      case 2:
        return QuestDifficulty.hard;
      case 3:
        return QuestDifficulty.epic;
      default:
        return QuestDifficulty.easy;
    }
  }

  @override
  void write(BinaryWriter writer, QuestDifficulty obj) {
    switch (obj) {
      case QuestDifficulty.easy:
        writer.writeByte(0);
        break;
      case QuestDifficulty.medium:
        writer.writeByte(1);
        break;
      case QuestDifficulty.hard:
        writer.writeByte(2);
        break;
      case QuestDifficulty.epic:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestDifficultyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
