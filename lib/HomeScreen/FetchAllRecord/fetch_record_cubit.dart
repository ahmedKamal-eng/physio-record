import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:physio_record/global_vals.dart';
import '../../models/patient_record.dart';
import 'fetch_record_state.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';


class FetchRecordCubit extends Cubit<FetchRecordState> {
  FetchRecordCubit() : super(FetchRecordInitial());

  List<PatientRecord> patientRecords=[];
  List<PatientRecord>? filteredPatientRecords = [];
  bool isFiltered = false;

  fetchAllRecord() async {
    emit(FetchRecordLoading());
    try {
      var recordBox = await Hive.box<PatientRecord>('patient_records');
      patientRecords = recordBox.values.toList();
      emit(FetchRecordSuccess());
    } catch (e) {
      print("###########################################################${e.toString()}");
      emit(FetchRecordError(error: e.toString()));
    }
  }

  uploadLocalRecordsToFirestore() async {
    emit(UploadLocalDataLoading());
    try {
      for (var patient in patientRecords) {
        if (patient.onlyInLocal == true) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('records')
              .doc(patient.id)
              .set({
            "patientName": patient.patientName,
            'id': patient.id,
            "date": patient.date,
            "diagnosis": patient.diagnosis,
            'mc': patient.mc,
            'program': patient.program,
          }).whenComplete(() {
            patient.onlyInLocal = false;
            patient.save();
          });
        }
      }

      List<String> imageURLs = [];

      List<String> docURLs = [];

      for (var patient in patientRecords!) {
        if (patient.followUpIdsOnlyInLocal.isNotEmpty) {
          for (var followUpId in patient.followUpIdsOnlyInLocal) {
            for (FollowUp followUp in patient.followUpList) {
              if (patient.followUpIdsOnlyInLocal.indexOf(followUp.id) != -1) {
                if (followUp.image?.isNotEmpty ?? false) {
                  for (var imagePath in followUp.image!) {
                    File file = File(imagePath);
                    final fileName = path.basename(file.path);
                    final storageRef = FirebaseStorage.instance
                        .ref()
                        .child('images/$fileName');
                    await storageRef.putFile(file);
                    final downloadURL = await storageRef.getDownloadURL();
                    imageURLs.add(downloadURL);
                  }
                }

                if (followUp.docPath?.isNotEmpty ?? false) {
                  for (var docPath in followUp.docPath!) {
                    File file = File(docPath);
                    final fileName = path.basename(file.path);
                    final storageRef =
                        FirebaseStorage.instance.ref().child('docs/$fileName');
                    await storageRef.putFile(file);
                    final downloadURL = await storageRef.getDownloadURL();
                    docURLs.add(downloadURL);
                  }
                }
              }
            }

            FirebaseFirestore.instance
                .collection("users")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection("records")
                .doc(patient.id)
                .collection('followUp')
                .doc(followUpId)
                .set({
              'id': followUpId,
              'date': getFollowUpById(
                      id: followUpId, followUplist: patient.followUpList)!
                  .date,
              'text': getFollowUpById(
                          id: followUpId, followUplist: patient.followUpList)!
                      .text ??
                  "",
              "image": imageURLs,
              "docPaths": getFollowUpById(
                      id: followUpId, followUplist: patient.followUpList)!
                  .docPath
            });
          }
          patient.followUpIdsOnlyInLocal = [];
          patient.save();
        }
      }
      emit(UploadLocalDataSuccess());
    } catch (e) {
      emit(UploadLocalDataError(error: e.toString()));
    }
  }

  updateRecordInFirestore() async {
    for (var patient in patientRecords!) {
      if (patient.updatedInLocal) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('records')
            .doc(patient.id)
            .update({
          "diagnosis": patient.diagnosis,
          "mc": patient.mc,
          "patientName": patient.patientName,
          "program": patient.program
        });
        patient.updatedInLocal=false;
        patient.save();
      }
      ;
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
