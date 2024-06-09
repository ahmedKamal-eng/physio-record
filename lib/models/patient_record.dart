
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
   List<FollowUp> followUpList=[];



  PatientRecord({
    required this.patientName,
    required this.date,
    required this.diagnosis,
    required this.mc,
    required this.program,
    required this.followUpList
  });
}


@HiveType(typeId: 1)
class FollowUp{
  @HiveField(0)
  late String date;
  @HiveField(1)
  late String text;

  FollowUp({required this.date,required this.text});
}