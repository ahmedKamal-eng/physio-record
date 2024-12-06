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
   bool? onlyInLocal;

  @HiveField(8)
  late bool updatedInLocal;

  @HiveField(9)
  List<String> followUpIdsOnlyInLocal = [];

  @HiveField(10)
  List<String> followUpIdsUpdatedOnlyInLocal = [];

  @HiveField(11)
  bool? isShared;

  @HiveField(12)
  List<String> doctorsId=[];

  @HiveField(13)
  List<String> rayImages=[];

  @HiveField(14)
  List<String> raysPDF=[];






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
      this.isShared=false,
      required this.doctorsId,
      required this.rayImages,
      required this.raysPDF,
      required this.followUpIdsOnlyInLocal,
      required this.followUpIdsUpdatedOnlyInLocal,
      f});

  factory PatientRecord.fromFirestore(DocumentSnapshot doc)  {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    //  List<FollowUp>? followUpList;
    // try {
    //   doc.reference.collection('followUp').get().then((v) {
    //     followUpList =
    //         v.docs.map((followUpDoc) => FollowUp.fromFirestore(followUpDoc))
    //             .toList();
    //   });
    // }catch(e)
    // {
    //   print("++++++++++patient Model:  "+e.toString());
    // }

    return PatientRecord(
        doctorsId: List<String>.from(data['doctorsIds'] ?? {}),
        patientName: data['patientName'],
        date:convertTimestampToString(data['date']),
        diagnosis: data['diagnosis'],
        mc: List<String>.from(data['mc']),
        program: data['program'],
        followUpList: [],
        id: data['id'],
        onlyInLocal: false,
        isShared: data['isShared'],
        followUpIdsOnlyInLocal: [],
        followUpIdsUpdatedOnlyInLocal: [],
        rayImages: List<String>.from(data['rayImages'] ?? {}) ?? [],
        raysPDF:List<String>.from(data['raysPDF'] ?? {}) ?? []
    );
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

   FollowUp.fromFirestore(DocumentSnapshot doc)  {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        date= convertTimestampToString(data['date']);
        text= data['text'];
        id= data['id'];
        doctorName=data['doctorName'] ?? '';
        image=List<String>.from(data['image']);
        docPath=List<String>.from(data['docPaths']);
        // docPath= fetchAndDownloadFiles('docs', data['RecordId'], data['RecordId']);
        // image= fetchAndDownloadFiles('images', data['RecordId'], data['RecordId']);
  }
}
