

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:physio_record/global_vals.dart';

class SharedRecordModel {

  final String id;
  final String diagnosis;
  final List<String> doctorsIds;
  final String patientName;
  final String program;
  final List<String> mc;
  final String date;

  SharedRecordModel({
    required this.id,
    required this.diagnosis,
    required this.doctorsIds,
    required this.patientName,
    required this.program,
    required this.mc,
    required this.date,
  });

  factory SharedRecordModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return SharedRecordModel(
      id: data['id'],
      diagnosis: data['diagnosis'],
      doctorsIds: List<String>.from(data['doctorsIds']),
      patientName: data['patientName'],
      program: data['program'],
      mc: List<String>.from(data['mc']),
      date: convertTimestampToString(data['date']),  // Convert Timestamp to DateTime
    );
  }

  // To convert the model back to JSON format for saving to Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'diagnosis': diagnosis,
      'doctorsIds': doctorsIds,
      'patientName': patientName,
      'program': program,
      'mc': mc,
      'date': date,  // DateTime will be automatically handled by Firestore
    };
  }


}