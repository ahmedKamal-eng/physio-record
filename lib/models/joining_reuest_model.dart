
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:physio_record/global_vals.dart';

class JoiningRequestModel {
  final String adminId;
  final String adminImage;
  final String adminName;
  final String centerId;
  final String centerName;
  final String date;
  final String requestId;

  JoiningRequestModel({
    required this.adminId,
    required this.adminImage,
    required this.adminName,
    required this.centerId,
    required this.centerName,
    required this.date,
    required this.requestId,
  });

  factory JoiningRequestModel.fromJson(DocumentSnapshot doc) {
    Map<String, dynamic> json = doc.data() as Map<String, dynamic>;
    return JoiningRequestModel(
      adminId: json['adminId'] ?? '',
      adminImage: json['adminImage'] ?? '',
      adminName: json['adminName'] ?? '',
      centerId: json['centerId'] ?? '',
      centerName: json['centerName'] ?? '',
      date:convertTimestampToString (json['date'] as Timestamp),
      requestId: json['requestId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adminId': adminId,
      'adminImage': adminImage,
      'adminName': adminName,
      'centerId': centerId,
      'centerName': centerName,
      'date': convertStringToTimestamp(date),
      'requestId': requestId,
    };
  }
}
