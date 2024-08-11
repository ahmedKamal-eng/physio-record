class UserModel {
  final String id;
  final String status;
  final DateTime registrationTime;
  final DateTime startTime;
  final DateTime endTime;
  final String userName;
  final String email;

  UserModel(
    this.id,
    this.status,
    this.registrationTime,
    this.startTime,
    this.endTime,
    this.userName,
    this.email,
  );

  factory UserModel.fromJson(data) {
    return UserModel(
      data['id'],
      data['status'],
      data['registrationTime'],
      data['startTime'],
      data['endTime'],
      data['userName'],
      data['email'],
    );
  }
}
