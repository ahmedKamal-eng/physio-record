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
      id: fields[6] as String,
      onlyInLocal: fields[7] as bool?,
      updatedInLocal: fields[8] as bool,
      isShared: fields[11] as bool?,
      doctorsId: (fields[12] as List).cast<String>(),
      rayImages: (fields[13] as List).cast<String>(),
      raysPDF: (fields[14] as List).cast<String>(),
      followUpIdsOnlyInLocal: (fields[9] as List).cast<String>(),
      followUpIdsUpdatedOnlyInLocal: (fields[10] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PatientRecord obj) {
    writer
      ..writeByte(15)
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
      ..write(obj.followUpList)
      ..writeByte(6)
      ..write(obj.id)
      ..writeByte(7)
      ..write(obj.onlyInLocal)
      ..writeByte(8)
      ..write(obj.updatedInLocal)
      ..writeByte(9)
      ..write(obj.followUpIdsOnlyInLocal)
      ..writeByte(10)
      ..write(obj.followUpIdsUpdatedOnlyInLocal)
      ..writeByte(11)
      ..write(obj.isShared)
      ..writeByte(12)
      ..write(obj.doctorsId)
      ..writeByte(13)
      ..write(obj.rayImages)
      ..writeByte(14)
      ..write(obj.raysPDF);
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
      image: (fields[2] as List?)?.cast<String>(),
      docPath: (fields[3] as List?)?.cast<String>(),
      id: fields[4] as String,
      doctorName: fields[7] as String?,
      onlyInLocal: fields[5] as bool,
      updatedInLocal: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FollowUp obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.image)
      ..writeByte(3)
      ..write(obj.docPath)
      ..writeByte(4)
      ..write(obj.id)
      ..writeByte(5)
      ..write(obj.onlyInLocal)
      ..writeByte(6)
      ..write(obj.updatedInLocal)
      ..writeByte(7)
      ..write(obj.doctorName);
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
