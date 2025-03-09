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
      nameUz: fields[2] as String,
      nameRu: fields[3] as String,
      description: fields[4] as String,
      descriptionUz: fields[5] as String,
      descriptionRu: fields[6] as String,
      attributes: (fields[7] as List).cast<AttributeModel>(),
      logoUrl: fields[8] as String,
      numericFields: (fields[9] as List).cast<NomericFieldModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, ChildCategoryModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.nameUz)
      ..writeByte(3)
      ..write(obj.nameRu)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.descriptionUz)
      ..writeByte(6)
      ..write(obj.descriptionRu)
      ..writeByte(7)
      ..write(obj.attributes)
      ..writeByte(8)
      ..write(obj.logoUrl)
      ..writeByte(9)
      ..write(obj.numericFields);
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
