// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      name: fields[0] as String,
      level: fields[1] as int,
      totalXp: fields[2] as int,
      streak: fields[3] as int,
      intelligence: fields[4] as int,
      discipline: fields[5] as int,
      health: fields[6] as int,
      wealth: fields[7] as int,
      lastTaskDate: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.totalXp)
      ..writeByte(3)
      ..write(obj.streak)
      ..writeByte(4)
      ..write(obj.intelligence)
      ..writeByte(5)
      ..write(obj.discipline)
      ..writeByte(6)
      ..write(obj.health)
      ..writeByte(7)
      ..write(obj.wealth)
      ..writeByte(8)
      ..write(obj.lastTaskDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
