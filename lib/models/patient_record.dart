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
  late List<String> program;

  @HiveField(5)
  List<FollowUp> followUpList = [];

  @HiveField(6)
  late String id;

  @HiveField(7)
  bool? onlyInLocal;

  @HiveField(8)
  late bool updatedInLocal;

  @HiveField(9)
  List<FollowUp> followUpOnlyInLocal = [];

  @HiveField(10)
  List<String> followUpIdsUpdatedOnlyInLocal = [];

  @HiveField(11)
  bool? isShared;

  @HiveField(12)
  List<String> doctorsId = [];

  @HiveField(13)
  List<String> rayImages = [];

  @HiveField(14)
  List<String> raysPDF = [];

  @HiveField(15)
  int? age;

  @HiveField(16)
  String? gender;

  @HiveField(17)
  List<String> medicalHistory = [];

  @HiveField(18)
  List<String> medication = [];

  @HiveField(19)
  List<String> knownAllergies = [];
  @HiveField(20)
  int? phoneNumer;
  @HiveField(21)
  String? job;
  @HiveField(22)
  String? reasonForVisit;
  @HiveField(23)
  String? conditionAssessment;

  @HiveField(24)
  String? doctorName;

  @HiveField(25)
  String? doctorImage;

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
      this.isShared = false,
      required this.doctorsId,
      required this.rayImages,
      required this.raysPDF,
      required this.followUpOnlyInLocal,
      required this.followUpIdsUpdatedOnlyInLocal,
      required this.age,
      required this.gender,
      required this.medicalHistory,
      required this.medication,
      required this.knownAllergies,
      required this.phoneNumer,
      required this.job,
      required this.reasonForVisit,
      required this.conditionAssessment,
      this.doctorName,
      this.doctorImage,
      });

  factory PatientRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PatientRecord(
        doctorsId: List<String>.from(data['doctorsIds'] ?? {}),
        patientName: data['patientName'],
        date: convertTimestampToString(data['date']),
        diagnosis: data['diagnosis'],
        mc: List<String>.from(data['mc']),
        program: List<String>.from(data['program']),
        followUpList: [],
        id: data['id'],
        onlyInLocal: false,
        isShared: data['isShared'],
        followUpOnlyInLocal: [],
        followUpIdsUpdatedOnlyInLocal: [],
        rayImages: List<String>.from(data['rayImages'] ?? {}) ?? [],
        raysPDF: List<String>.from(data['raysPDF'] ?? {}) ?? [],
        medicalHistory: List<String>.from(data['medicalHistory'] ?? {}) ?? [],
        medication: List<String>.from(data['medication'] ?? {}) ?? [],
        knownAllergies: List<String>.from(data['knownAllergies'] ?? {}) ?? [],
        age: data['age'],
        gender: data['gender'],
        phoneNumer: data['phoneNumber'],
        job: data['job'],
        reasonForVisit: data['reasonForVisit'],
        conditionAssessment: data['conditionAssessment'],
        doctorName: data['doctorName'],
        doctorImage: data['doctorImage'],

    );
  }
}

@HiveType(typeId: 1)
class FollowUp extends HiveObject {
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
  bool? onlyInLocal;
  @HiveField(6)
  bool? updatedInLocal;
  @HiveField(7)
  String? doctorName;

  FollowUp(
      {required this.date,
      required this.text,
      this.image,
      this.docPath,
      required this.id,
      this.doctorName,
      this.onlyInLocal = false,
      this.updatedInLocal = false});

  FollowUp.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    date = data['date'] is Timestamp
        ? convertTimestampToString(data['date'])
        : data['date'];
    text = data['text'];
    id = data['id'];
    doctorName = data['doctorName'] ?? '';
    image = List<String>.from(data['image']);
    docPath = List<String>.from(data['docPaths']);
  }
}
