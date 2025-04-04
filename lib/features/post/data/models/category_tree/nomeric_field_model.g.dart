// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nomeric_field_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NomericFieldModelAdapter extends TypeAdapter<NomericFieldModel> {
  @override
  final int typeId = 5;

  @override
  NomericFieldModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NomericFieldModel(
      id: fields[0] as String,
      fieldName: fields[1] as String,
      fieldNameUz: fields[2] as String,
      fieldNameRu: fields[3] as String,
      description: fields[4] as String,
      descriptionUz: fields[5] as String,
      descriptionRu: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NomericFieldModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fieldName)
      ..writeByte(2)
      ..write(obj.fieldNameUz)
      ..writeByte(3)
      ..write(obj.fieldNameRu)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.descriptionUz)
      ..writeByte(6)
      ..write(obj.descriptionRu);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NomericFieldModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
