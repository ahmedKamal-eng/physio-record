

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:physio_record/models/patient_record.dart';


/// Returns a [Timestamp] after adding [months] to the current date.
Timestamp getTimestampAfterMonths(int months) {
  final currentDate = DateTime.now();

  // Calculate the new month and year, handling month overflow
  final newMonth = (currentDate.month + months - 1) % 12 + 1;
  final yearsToAdd = (currentDate.month + months - 1) ~/ 12;
  final newYear = currentDate.year + yearsToAdd;

  // Handle end-of-month edge cases
  final lastDayOfNewMonth = DateTime(newYear, newMonth + 1, 0).day;
  final newDay = currentDate.day > lastDayOfNewMonth
      ? lastDayOfNewMonth
      : currentDate.day;

  // Create the new DateTime object
  final newDate = DateTime(
    newYear,
    newMonth,
    newDay,
    currentDate.hour,
    currentDate.minute,
    currentDate.second,
    currentDate.millisecond,
  );

  // Convert the new DateTime to Firebase Timestamp
  return Timestamp.fromDate(newDate);
}



Timestamp getTimeAfterXMonth({required DateTime time,required int x}){


  // Calculate the date one month from now
  DateTime oneMonthFromNow = DateTime(
    time.year,
    time.month + x, // Add 1 to the current month
    time.day,
    time.hour,
    time.minute,
    time.second,
    time.millisecond,
    time.microsecond,
  );

  // If the current month is December (12), it will correctly wrap around to January of the next year
  // due to DateTime's handling of overflows.

  // Convert to Firestore Timestamp
  Timestamp timestamp = Timestamp.fromDate(oneMonthFromNow);
  print(oneMonthFromNow.year.toString() + "/"+oneMonthFromNow.month.toString());

  return timestamp;
}

FollowUp? getFollowUpById({required String id,required List<FollowUp> followUplist}){
  for(var item in followUplist)
  {
    if(item.id== id)
      {
        return item;
      }
  }
  // return FollowUp(date: date, text: text, id: id);
}


Future<PatientRecord> getPatientFromLocalById(String id)async
{
  var patientBox =
      await Hive.box<PatientRecord>(
      'patient_records');
  PatientRecord currentPatient = patientBox.values.firstWhere(
        (p) => p.id == id,
  );

  return currentPatient;
}

Future<FollowUp> getFollowUpFromLocalById(PatientRecord currentPatient,String id)async
{

  FollowUp followUp = currentPatient.followUpList.firstWhere(
        (f) => f.id == id,
  );

  return followUp;
}

Timestamp convertStringToTimestamp(String dateString) {
  // Define the format of your date string
  final DateFormat format = DateFormat('HH:mm d-M-y'); // Adjust the format as needed

    // Parse the string to DateTime
    DateTime dateTime = format.parse(dateString);

    // Convert DateTime to Timestamp
    Timestamp timestamp = Timestamp.fromDate(dateTime);
    return timestamp;
}

String convertTimestampToString(Timestamp timestamp) {
  // Convert Timestamp to DateTime
  DateTime dateTime = timestamp.toDate();

  // Define the desired format
  final DateFormat format = DateFormat('HH:mm d-M-y');

  // Format DateTime to String
  String formattedString = format.format(dateTime);

  return formattedString;
}

Future<void> deleteFile(String filePath) async {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  try {
    // Create a reference to the file you want to delete
    Reference ref = _storage.ref().child(filePath);

    // Delete the file
    await ref.delete();

    print('File deleted successfully.');
  } catch (e) {
    print('&delete file method&Failed to delete file: $e');
  }
}

bool hasTimestampPassed(Timestamp timestamp) {
  DateTime currentTime = DateTime.now(); // Get current date and time
  DateTime givenTime = timestamp.toDate(); // Convert Firestore Timestamp to DateTime

  // Return true if the given time is before the current time

  return givenTime.isBefore(currentTime);
}

Future<List<String>> fetchAndDownloadXRays(String recordId,String fileType) async {

  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<String> _filePaths = [];
  // Replace 'your-folder' with your Firebase Storage folder
  ListResult result = await _storage.ref('rays/$recordId/$fileType').listAll();

  // Get the directory to store downloaded files
  Directory appDocDir = await getApplicationDocumentsDirectory();

  for (var item in result.items) {
    // Download each file
    String fileName = item.name;
    String filePath = '${appDocDir.path}/$fileName';

    // Download the file
    await item.writeToFile(File(filePath));

    // Store the local file path in the list
    _filePaths.add(filePath);
    print('File downloaded to: $filePath');
  }
  return _filePaths;

}


Future<List<String>> fetchAndDownloadFiles(String file,String recordId, String followUpId) async {

  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<String> _filePaths = [];
    // Replace 'your-folder' with your Firebase Storage folder
    ListResult result = await _storage.ref('$file/$recordId/$followUpId').listAll();

    // Get the directory to store downloaded files
    Directory appDocDir = await getApplicationDocumentsDirectory();

    for (var item in result.items) {
      // Download each file
      String fileName = item.name;
      String filePath = '${appDocDir.path}/$fileName';

      // Download the file
      await item.writeToFile(File(filePath));

      // Store the local file path in the list
        _filePaths.add(filePath);
      print('File downloaded to: $filePath');
    }
    return _filePaths;

}

final plans = [
  {'name': 'Monthly', 'price': 100.0, 'duration': 30},
  {'name': 'Quarterly', 'price': 270.0, 'duration': 90},
  {'name': 'Yearly', 'price': 1000.0, 'duration': 365},
];


