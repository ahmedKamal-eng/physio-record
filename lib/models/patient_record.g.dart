// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PatientRecordAdapter extends TypeAdapter<PatientRecord> {
  @override
  final int typeId = 0;

  @override
  PatientRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PatientRecord(
      patientName: fields[0] as String,
      date: fields[1] as String,
      diagnosis: fields[2] as String,
      mc: (fields[3] as List).cast<String>(),
      program: fields[4] as String,
      followUpList: (fields[5] as List).cast<FollowUp>(),
    );
  }

  @override
  void write(BinaryWriter writer, PatientRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.patientName)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.diagnosis)
      ..writeByte(3)
      ..write(obj.mc)
      ..writeByte(4)
      ..write(obj.program)
      ..writeByte(5)
      ..write(obj.followUpList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FollowUpAdapter extends TypeAdapter<FollowUp> {
  @override
  final int typeId = 1;

  @override
  FollowUp read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FollowUp(
      date: fields[0] as String,
      text: fields[1] as String,
      image: fields[2] as String?,
      docPath: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FollowUp obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.image)
      ..writeByte(3)
      ..write(obj.docPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FollowUpAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
