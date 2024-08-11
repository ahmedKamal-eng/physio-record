import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
part 'patient_record.g.dart';

@HiveType(typeId: 0)
class PatientRecord extends HiveObject {
  @HiveField(0)
  late String patientName;

  @HiveField(1)
  late String date;

  @HiveField(2)
  late String diagnosis;

  @HiveField(3)
  late List<String> mc;

  @HiveField(4)
  late String program;

  @HiveField(5)
  List<FollowUp> followUpList = [];

  @HiveField(6)
  late String id;

  @HiveField(7)
  late bool onlyInLocal;

  PatientRecord(
      {required this.patientName,
      required this.date,
      required this.diagnosis,
      required this.mc,
      required this.program,
      required this.followUpList,
      required this.id,
      required this.onlyInLocal});

  factory PatientRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PatientRecord(
        patientName: data['patientName'],
        date: data['date'],
        diagnosis: data['diagnosis'],
        mc: data['mc'],
        program: data['program'],
        followUpList: [],
        id: data['id'],
        onlyInLocal: false);
  }
}

@HiveType(typeId: 1)
class FollowUp {
  @HiveField(0)
  late String date;
  @HiveField(1)
  late String text;
  @HiveField(2)
  List<String>? image;
  @HiveField(3)
  List<String>? docPath;

  FollowUp({required this.date, required this.text, this.image, this.docPath});
}
