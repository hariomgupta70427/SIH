// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScanHistoryAdapter extends TypeAdapter<ScanHistory> {
  @override
  final int typeId = 0;

  @override
  ScanHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanHistory(
      qrData: fields[0] as String,
      scanTime: fields[1] as DateTime,
      partName: fields[2] as String?,
      partType: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ScanHistory obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.qrData)
      ..writeByte(1)
      ..write(obj.scanTime)
      ..writeByte(2)
      ..write(obj.partName)
      ..writeByte(3)
      ..write(obj.partType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
