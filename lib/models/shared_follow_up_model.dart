

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:physio_record/global_vals.dart';

class SharedFollowUpModel {
  final String recordId;
  final String date;
  final String doctorId;
  final String doctorName;
  final String id;
  final List<String> docPaths;  // This is now an array of strings
  final List<String> images;
  final String text;

  SharedFollowUpModel({
    required this.recordId,
    required this.date,
    required this.doctorId,
    required this.doctorName,
    required this.id,
    required this.docPaths,
    required this.images,
    required this.text,
  });

  factory SharedFollowUpModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return SharedFollowUpModel(
      recordId: data['RecordId'],
      date: data['date'] is Timestamp ? convertTimestampToString(data['date']) : data['date'],
      doctorId: data['doctorId'],
      doctorName: data['doctorName'],
      id: data['id'],
      docPaths: List<String>.from(data['docPaths']),  // docPaths is now an array of strings
      images: List<String>.from(data['image']),
      text: data['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RecordId': recordId,
      'date': date,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'id': id,
      'docPaths': docPaths,
      'image': images,
      'text': text,
    };
  }
}