import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'tag_model.g.dart';

@HiveType(typeId: 7)
class TagModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int colorValue;

  @HiveField(3)
  final DateTime createdAt;

  TagModel({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.createdAt,
  });

  factory TagModel.create({required String name, required Color color}) {
    return TagModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      colorValue: color.toARGB32(),
      createdAt: DateTime.now(),
    );
  }

  Color get color => Color(colorValue);

  TagModel copyWith({
    String? id,
    String? name,
    int? colorValue,
    DateTime? createdAt,
  }) {
    return TagModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
