import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:physio_record/global_vals.dart';

class UserModel {
  final String id;
  final String status;
  final String registrationTime;
  final String startTime;
  final String endTime;
  final String userName;
  final String imagePath;
  final String imageUrl;
  final String medicalSpecialization;
  final String email;

  UserModel(
    this.id,
    this.status,
    this.registrationTime,
    this.startTime,
    this.endTime,
    this.userName,
    this.email,
    this.imagePath,
    this.imageUrl,
    this.medicalSpecialization,
  );

  factory UserModel.fromJson(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      data['id'],
      data['status'],
      convertTimestampToString(data['registrationTime']),
      convertTimestampToString(data['startTime']),
      convertTimestampToString(data['endTime']),
      data['userName'],
      data['email'],
      data['imagePath'],
      data['imageUrl'],
      data['medicalSpecialization']
    );
  }
}
