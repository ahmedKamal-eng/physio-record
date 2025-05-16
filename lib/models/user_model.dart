import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:physio_record/global_vals.dart';
part 'user_model.g.dart';

@HiveType(typeId: 2)
class UserModel extends HiveObject {


  @HiveField(0)
  final String id;

  @HiveField(1)
  final String status;

  @HiveField(2)
  final String registrationTime;

  @HiveField(3)
  String? startTime;

  @HiveField(4)
  String? endTime;

  @HiveField(5)
  final String userName;

  @HiveField(6)
  final String imagePath;

  @HiveField(7)
  final String imageUrl;

  @HiveField(8)
  final String medicalSpecialization;

  @HiveField(9)
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
