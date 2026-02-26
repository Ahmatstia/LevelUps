// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtask_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubtaskModelAdapter extends TypeAdapter<SubtaskModel> {
  @override
  final int typeId = 8;

  @override
  SubtaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubtaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      isCompleted: fields[2] as bool,
      createdAt: fields[3] as DateTime,
      completedAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SubtaskModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubtaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
