import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:physio_record/global_vals.dart';
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

  @HiveField(8)
  late bool updatedInLocal;

  @HiveField(9)
  List<String> followUpIdsOnlyInLocal = [];

  @HiveField(10)
  List<String> followUpIdsUpdatedOnlyInLocal = [];

  PatientRecord(
      {required this.patientName,
      required this.date,
      required this.diagnosis,
      required this.mc,
      required this.program,
      required this.followUpList,
      required this.id,
      this.onlyInLocal = false,
      this.updatedInLocal = false,
      required this.followUpIdsOnlyInLocal,
      required this.followUpIdsUpdatedOnlyInLocal,
      f});

  factory PatientRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PatientRecord(
        patientName: data['patientName'],
        date:convertTimestampToString(data['date']),
        diagnosis: data['diagnosis'],
        mc: List<String>.from(data['mc']),
        program: data['program'],
        followUpList: [],
        id: data['id'],
        onlyInLocal: false,
        followUpIdsOnlyInLocal: [],
        followUpIdsUpdatedOnlyInLocal: []);
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
  @HiveField(4)
  late String id;
  @HiveField(5)
  late bool onlyInLocal;
  @HiveField(6)
  late bool updatedInLocal;

  FollowUp(
      {required this.date,
      required this.text,
      this.image,
      this.docPath,
      required this.id,
      this.onlyInLocal = false,
      this.updatedInLocal = false});

   FollowUp.fromFirestore(DocumentSnapshot doc)  {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        date= convertTimestampToString(data['date']);
        text= data['text'];
        id= data['id'];
        image=List<String>.from(data['image']);
        docPath=List<String>.from(data['docPaths']);


        // docPath= fetchAndDownloadFiles('docs', data['RecordId'], data['RecordId']);
        // image= fetchAndDownloadFiles('images', data['RecordId'], data['RecordId']);
  }
}
