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
      attributeKeyUz: fields[1] as String,
      attributeKeyRu: fields[2] as String,
      helperText: fields[3] as String,
      helperTextUz: fields[4] as String,
      helperTextRu: fields[5] as String,
      subHelperText: fields[6] as String,
      subHelperTextUz: fields[7] as String,
      subHelperTextRu: fields[8] as String,
      widgetType: fields[9] as String,
      subWidgetsType: fields[10] as String,
      filterText: fields[11] as String,
      filterTextUz: fields[12] as String,
      filterTextRu: fields[13] as String,
      subFilterText: fields[14] as String,
      subFilterTextUz: fields[15] as String,
      subFilterTextRu: fields[16] as String,
      filterWidgetType: fields[17] as String,
      subFilterWidgetType: fields[18] as String,
      dataType: fields[19] as String,
      values: (fields[20] as List).cast<AttributeValueModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, AttributeModel obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.attributeKey)
      ..writeByte(1)
      ..write(obj.attributeKeyUz)
      ..writeByte(2)
      ..write(obj.attributeKeyRu)
      ..writeByte(3)
      ..write(obj.helperText)
      ..writeByte(4)
      ..write(obj.helperTextUz)
      ..writeByte(5)
      ..write(obj.helperTextRu)
      ..writeByte(6)
      ..write(obj.subHelperText)
      ..writeByte(7)
      ..write(obj.subHelperTextUz)
      ..writeByte(8)
      ..write(obj.subHelperTextRu)
      ..writeByte(9)
      ..write(obj.widgetType)
      ..writeByte(10)
      ..write(obj.subWidgetsType)
      ..writeByte(11)
      ..write(obj.filterText)
      ..writeByte(12)
      ..write(obj.filterTextUz)
      ..writeByte(13)
      ..write(obj.filterTextRu)
      ..writeByte(14)
      ..write(obj.subFilterText)
      ..writeByte(15)
      ..write(obj.subFilterTextUz)
      ..writeByte(16)
      ..write(obj.subFilterTextRu)
      ..writeByte(17)
      ..write(obj.filterWidgetType)
      ..writeByte(18)
      ..write(obj.subFilterWidgetType)
      ..writeByte(19)
      ..write(obj.dataType)
      ..writeByte(20)
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
