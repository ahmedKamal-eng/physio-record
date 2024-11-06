


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:physio_record/global_vals.dart';

class ShareRequestModel{
final bool doctorsSharedThisRecord;
final List<String> doctorIds;

  final String date;
  final String diagnosis;
  final String doctorImage;
  final String doctorName;
  final String patientName;
  final String recordId;
  final String requestId;
  final String senderId;

  ShareRequestModel( {
    required this.doctorIds,
    required this.date,
    required this.doctorsSharedThisRecord,
    required this.diagnosis,
    required this.doctorImage,
    required this.doctorName,
    required this.patientName,
    required this.recordId,
    required this.requestId,
    required this.senderId,
  });

  // Factory method to convert Firestore data to Record instance
  factory ShareRequestModel.fromFirestore(DocumentSnapshot doc) {

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ShareRequestModel(
      date: convertTimestampToString(data['date']),
      doctorIds:  List<String>.from(data['doctorIds'] ?? []),
      doctorsSharedThisRecord: data['doctorsSharedThisRecord'] ?? false,
      diagnosis: data['diagnosis'] ?? '',
      doctorImage: data['doctorImage'] ?? '',
      doctorName: data['doctorName'] ?? '',
      patientName: data['patientName'] ?? '',
      recordId: data['recordId'] ?? '',
      requestId: data['requestId'] ?? '',
      senderId: data['senderId'] ?? '',
    );
  }

  // Method to convert Record instance to Firestore format
  // Map<String, dynamic> toFirestore() {
  //   return {
  //     'date': Timestamp.fromDate(date),
  //     'diagnosis': diagnosis,
  //     'doctorImage': doctorImage,
  //     'doctorName': doctorName,
  //     'patientName': patientName,
  //     'recordId': recordId,
  //     'requestId': requestId,
  //     'senderId': senderId,
  //   };
  // }
}