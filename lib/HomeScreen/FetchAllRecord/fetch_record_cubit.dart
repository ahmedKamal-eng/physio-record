
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../../models/patient_record.dart';
import 'fetch_record_state.dart';

class FetchRecordCubit extends Cubit<FetchRecordState> {
  FetchRecordCubit() : super(FetchRecordInitial());

  List<PatientRecord>? patientRecords;
  List<PatientRecord>? filteredPatientRecords = [];
  bool isFiltered = false;

  fetchAllRecord() async {
    emit(FetchRecordLoading());
    try {


          var recordBox = Hive.box<PatientRecord>('patient_records');
          patientRecords = recordBox.values.toList();



      emit(FetchRecordSuccess());
    } catch (e) {
      emit(FetchRecordError(error: e.toString()));
    }
  }

  uploadLocalRecordsToFirestore()async {
    for (var patient in patientRecords!) {
      if (patient.onlyInLocal == true) {
       await  FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('records')
            .doc(patient.id)
            .set({  "patientName": patient.patientName,
          'id':patient.id,
          "date": patient.date,
          "diagnosis": patient.diagnosis,
          'mc': patient.mc,
          'program': patient.program,}).whenComplete((){
            patient.onlyInLocal=false;
            patient.save();
        });
      }
    }
  }

  clearFilter() {
    isFiltered = false;
    emit(ClearFilter());
  }

  void filterPatientsByDate(DateTime filterDate) {
    emit(FilterRecordsLoading());
    try {
      DateFormat formatter;
      formatter = DateFormat("HH:mm d-M-y");
      // final DateTime parsedDate = formatter.parse(filterDate);
      var recordBox = Hive.box<PatientRecord>('patient_records');

      filteredPatientRecords = recordBox.values.where((patient) {
        DateTime parsedDate = formatter.parse(patient.date);

        // DateTime patientDate = dateFormat.parse(patient.date);
        return parsedDate.year == filterDate.year &&
            parsedDate.month == filterDate.month &&
            parsedDate.day == filterDate.day;
      }).toList();
      isFiltered = true;
      emit(FilterRecordsSuccess());
    } catch (e) {
      emit(FilterRecordsError(error: e.toString()));
    }
  }
}
