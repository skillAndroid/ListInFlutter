// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_category_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChildCategoryModelAdapter extends TypeAdapter<ChildCategoryModel> {
  @override
  final int typeId = 1;

  @override
  ChildCategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChildCategoryModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      attributes: (fields[3] as List).cast<AttributeModel>(),
      logoUrl: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ChildCategoryModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.attributes)
      ..writeByte(4)
      ..write(obj.logoUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChildCategoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
