// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attribute_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttributeModelAdapter extends TypeAdapter<AttributeModel> {
  @override
  final int typeId = 2;

  @override
  AttributeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttributeModel(
      attributeKey: fields[0] as String,
      helperText: fields[1] as String,
      subHelperText: fields[2] as String,
      widgetType: fields[3] as String,
      subWidgetsType: fields[4] as String,
      dataType: fields[5] as String,
      values: (fields[6] as List).cast<AttributeValueModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, AttributeModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.attributeKey)
      ..writeByte(1)
      ..write(obj.helperText)
      ..writeByte(2)
      ..write(obj.subHelperText)
      ..writeByte(3)
      ..write(obj.widgetType)
      ..writeByte(4)
      ..write(obj.subWidgetsType)
      ..writeByte(5)
      ..write(obj.dataType)
      ..writeByte(6)
      ..write(obj.values);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttributeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
