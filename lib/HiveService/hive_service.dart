
import 'package:hive/hive.dart';

import '../models/user_model.dart';

class HiveService {
  static const String userBoxName = 'userBox';

  static Future<void> initializeHive() async {
    await Hive.openBox<UserModel>(userBoxName);
  }

  static Box<UserModel> get userBox => Hive.box<UserModel>(userBoxName);
}