import '../models/user_model.dart';
import 'hive_service.dart';

Future<void> saveUserData(UserModel user) async {
  final box = HiveService.userBox;

  // Save the user data
  await box.put('currentUser', user);
}


UserModel? getCurrentUser() {
  final box = HiveService.userBox;

  // Retrieve the user data
  return box.get('currentUser');
}


Future<void> deleteUserData() async {
  final box = HiveService.userBox;

  // Remove the user data
  await box.delete('currentUser');
}
