
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalCenterModel {
  final String adminId;
  final String adminImage;
  final String adminName;
  final String adminSpecialization;
  final String centerId;
  final DateTime createdAt;
  final int doctorCount;
  final int recordCount;
  final List<String> doctorsIds;
  final DateTime endDate;
  final String imageUrl;
  final String name;
  final DateTime startDate;
  final List<String> wantToJoin;

  MedicalCenterModel({
    required this.adminId,
    required this.adminImage,
    required this.adminName,
    required this.adminSpecialization,
    required this.centerId,
    required this.createdAt,
    required this.doctorCount,
    required this.doctorsIds,
    required this.endDate,
    required this.imageUrl,
    required this.name,
    required this.startDate,
    required this.wantToJoin,
    required this.recordCount
  });

  factory MedicalCenterModel.fromJson(DocumentSnapshot doc) {
    Map<String, dynamic> json = doc.data() as Map<String, dynamic>;
    return MedicalCenterModel(
      adminId: json['adminId'] ?? '',
      adminImage: json['adminImage'] ?? '',
      adminName: json['adminName'] ?? '',
      adminSpecialization: json['adminSpecialization'] ?? '',
      centerId: json['centerId'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      doctorCount: json['doctorCount'] ?? 0,
      recordCount: json['recordCount'] ?? 0,
      doctorsIds: List<String>.from(json['doctorsIds'] ?? []),
      endDate: (json['endDate'] as Timestamp).toDate(),
      imageUrl: json['imageUrl'] ?? '',
      name: json['name'] ?? '',
      startDate: (json['startDate'] as Timestamp).toDate(),
      wantToJoin: List<String>.from(json['want_to_join'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adminId': adminId,
      'adminImage': adminImage,
      'adminName': adminName,
      'adminSpecialization': adminSpecialization,
      'centerId': centerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'doctorCount': doctorCount,
      'doctorsIds': doctorsIds,
      'endDate': Timestamp.fromDate(endDate),
      'imageUrl': imageUrl,
      'name': name,
      'startDate': Timestamp.fromDate(startDate),
      'want_to_join': wantToJoin,
    };
  }
}
