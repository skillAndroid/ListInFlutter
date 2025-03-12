// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CountyAdapter extends TypeAdapter<County> {
  @override
  final int typeId = 5;

  @override
  County read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return County(
      value: fields[0] as String?,
      valueUz: fields[1] as String?,
      valueRu: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, County obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.value)
      ..writeByte(1)
      ..write(obj.valueUz)
      ..writeByte(2)
      ..write(obj.valueRu);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StateAdapter extends TypeAdapter<State> {
  @override
  final int typeId = 4;

  @override
  State read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return State(
      value: fields[0] as String?,
      valueUz: fields[1] as String?,
      valueRu: fields[2] as String?,
      counties: (fields[3] as List?)?.cast<County>(),
    );
  }

  @override
  void write(BinaryWriter writer, State obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.value)
      ..writeByte(1)
      ..write(obj.valueUz)
      ..writeByte(2)
      ..write(obj.valueRu)
      ..writeByte(3)
      ..write(obj.counties);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CountryAdapter extends TypeAdapter<Country> {
  @override
  final int typeId = 3;

  @override
  Country read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Country(
      value: fields[0] as String?,
      valueUz: fields[1] as String?,
      valueRu: fields[2] as String?,
      states: (fields[3] as List?)?.cast<State>(),
    );
  }

  @override
  void write(BinaryWriter writer, Country obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.value)
      ..writeByte(1)
      ..write(obj.valueUz)
      ..writeByte(2)
      ..write(obj.valueRu)
      ..writeByte(3)
      ..write(obj.states);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
