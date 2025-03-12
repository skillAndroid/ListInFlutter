// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubModelAdapter extends TypeAdapter<SubModel> {
  @override
  final int typeId = 4;

  @override
  SubModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubModel(
      modelId: fields[0] as String?,
      name: fields[1] as String?,
      nameUz: fields[2] as String?,
      nameRu: fields[3] as String?,
      attributeId: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SubModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.modelId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.nameUz)
      ..writeByte(3)
      ..write(obj.nameRu)
      ..writeByte(4)
      ..write(obj.attributeId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
