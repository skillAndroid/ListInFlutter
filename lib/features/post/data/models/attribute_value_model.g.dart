// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attribute_value_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttributeValueModelAdapter extends TypeAdapter<AttributeValueModel> {
  @override
  final int typeId = 3;

  @override
  AttributeValueModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttributeValueModel(
      attributeValueId: fields[0] as String,
      attributeKeyId: fields[1] as String,
      value: fields[2] as String,
      list: (fields[3] as List).cast<SubModel>(),
    )..isMarkedForRemoval = fields[4] as bool;
  }

  @override
  void write(BinaryWriter writer, AttributeValueModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.attributeValueId)
      ..writeByte(1)
      ..write(obj.attributeKeyId)
      ..writeByte(2)
      ..write(obj.value)
      ..writeByte(3)
      ..write(obj.list)
      ..writeByte(4)
      ..write(obj.isMarkedForRemoval);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttributeValueModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
