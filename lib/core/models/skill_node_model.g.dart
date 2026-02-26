// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_node_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SkillNodeModelAdapter extends TypeAdapter<SkillNodeModel> {
  @override
  final int typeId = 12;

  @override
  SkillNodeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SkillNodeModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      statType: fields[3] as StatType,
      skillType: fields[4] as SkillType,
      maxLevel: fields[5] as int,
      currentLevel: fields[6] as int,
      costPerLevel: (fields[7] as List).cast<int>(),
      effectPerLevel: (fields[8] as List).cast<double>(),
      parentId: fields[9] as String?,
      requirements: (fields[10] as List).cast<String>(),
      treePositionX: fields[11] as int,
      treePositionY: fields[12] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SkillNodeModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.statType)
      ..writeByte(4)
      ..write(obj.skillType)
      ..writeByte(5)
      ..write(obj.maxLevel)
      ..writeByte(6)
      ..write(obj.currentLevel)
      ..writeByte(7)
      ..write(obj.costPerLevel)
      ..writeByte(8)
      ..write(obj.effectPerLevel)
      ..writeByte(9)
      ..write(obj.parentId)
      ..writeByte(10)
      ..write(obj.requirements)
      ..writeByte(11)
      ..write(obj.treePositionX)
      ..writeByte(12)
      ..write(obj.treePositionY);
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

class SkillTypeAdapter extends TypeAdapter<SkillType> {
  @override
  final int typeId = 17;

  @override
  SkillType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SkillType.passive;
      case 1:
        return SkillType.active;
      case 2:
        return SkillType.multiplier;
      case 3:
        return SkillType.unlock;
      default:
        return SkillType.passive;
    }
  }

  @override
  void write(BinaryWriter writer, SkillType obj) {
    switch (obj) {
      case SkillType.passive:
        writer.writeByte(0);
        break;
      case SkillType.active:
        writer.writeByte(1);
        break;
      case SkillType.multiplier:
        writer.writeByte(2);
        break;
      case SkillType.unlock:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
