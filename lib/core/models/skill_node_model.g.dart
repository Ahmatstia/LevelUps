// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_node_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SkillNodeModelAdapter extends TypeAdapter<SkillNodeModel> {
  @override
  final int typeId = 13;

  @override
  SkillNodeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SkillNodeModel(
      id: fields[0] as String,
      statType: fields[1] as StatType,
      name: fields[2] as String,
      description: fields[3] as String,
      currentLevel: fields[4] as int,
      maxLevel: fields[5] as int,
      baseCost: fields[6] as int,
      costMultiplier: fields[7] as double,
      parentIds: (fields[8] as List).cast<String>(),
      isUnlocked: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SkillNodeModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.statType)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.currentLevel)
      ..writeByte(5)
      ..write(obj.maxLevel)
      ..writeByte(6)
      ..write(obj.baseCost)
      ..writeByte(7)
      ..write(obj.costMultiplier)
      ..writeByte(8)
      ..write(obj.parentIds)
      ..writeByte(9)
      ..write(obj.isUnlocked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillNodeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
