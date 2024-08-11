

import 'package:cloud_firestore/cloud_firestore.dart';

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

