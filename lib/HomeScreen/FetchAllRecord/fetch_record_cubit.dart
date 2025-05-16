import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:physio_record/Cubits/GetUserDataCubit/get_user_data_cubit.dart';
import 'package:physio_record/global_vals.dart';
import '../../models/patient_record.dart';
import 'fetch_record_state.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';

class FetchRecordCubit extends Cubit<FetchRecordState> {
  FetchRecordCubit() : super(FetchRecordInitial());

  List<PatientRecord> patientRecords = [];
  List<PatientRecord>? filteredPatientRecords = [];
  bool isFiltered = false;

  fetchAllRecord() async {
    emit(FetchRecordLoading());
    try {
      var recordBox = await Hive.box<PatientRecord>('patient_records');
      patientRecords = recordBox.values.toList();
      print(patientRecords.length.toString() +
          " records in Local __________________________");

      emit(FetchRecordSuccess());
    } catch (e) {
      print(
          "###########################################################${e.toString()}");
      emit(FetchRecordError(error: e.toString()));
    }
  }

  Future<List<String>> _uploadFollowUpImagesToFireStorage(
      List<String> imagesPaths, String patientId, String followUpId) async {
    if (imagesPaths.isNotEmpty) {
      List<String> imageURLs = [];
      for (String imagePath in imagesPaths) {
        File file = File(imagePath);
        final fileName = path.basename(file.path);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('images/$patientId/$followUpId/$fileName');
        await storageRef.putFile(file);
        final downloadURL = await storageRef.getDownloadURL();
        imageURLs.add(downloadURL);
      }
      return imageURLs;
    } else {
      return [];
    }
  }

  Future<List<String>> _uploadFollowUpPDFToFireStorage(
      List<String> pdfPaths, String patientId, String followUpId) async {
    if (pdfPaths.isNotEmpty) {
      List<String> pdfURLs = [];
      for (String pdfPath in pdfPaths) {
        File file = File(pdfPath);
        final fileName = path.basename(file.path);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('docs/$patientId/$followUpId/$fileName');
        await storageRef.putFile(file);
        final downloadURL = await storageRef.getDownloadURL();
        pdfURLs.add(downloadURL);
      }
      return pdfURLs;
    } else {
      return [];
    }
  }

  //upload Local Records-------
  uploadLocalRecord() async {
    try {
      for (var patient in patientRecords) {
        if (patient.onlyInLocal ?? false) {
          List<String> imageURLs = [];
          List<String> pdfURLs = [];
          if (patient.rayImages.isNotEmpty) {
            for (String imagePath in patient.rayImages) {
              File file = File(imagePath);
              final fileName = path.basename(file.path);
              final storageRef = FirebaseStorage.instance
                  .ref()
                  .child('rays/${patient.id}/images/$fileName');
              await storageRef.putFile(file);
              final downloadURL = await storageRef.getDownloadURL();
              imageURLs.add(downloadURL);
            }
          }

          if (patient.raysPDF.isNotEmpty) {
            for (String pdfPath in patient.raysPDF) {
              File file = File(pdfPath);
              final fileName = path.basename(file.path);
              final storageRef = FirebaseStorage.instance
                  .ref()
                  .child('rayes/${patient.id}/pdf/$fileName');
              await storageRef.putFile(file);
              final downloadURL = await storageRef.getDownloadURL();
              pdfURLs.add(downloadURL);
            }
          }

          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('records')
              .doc(patient.id)
              .set({
            "patientName": patient.patientName,
            'id': patient.id,
            "date": patient.date is Timestamp
                ? patient.date
                : convertStringToTimestamp(patient.date),
            "diagnosis": patient.diagnosis,
            'mc': patient.mc,
            "isShared": false,
            'program': patient.program,
            'age': patient!.age,
            'gender': patient!.gender,
            'job': patient!.job,
            'phoneNumber': patient!.phoneNumer,
            'knownAllergies': patient!.knownAllergies,
            'medicalHistory': patient!.medicalHistory,
            'medication': patient!.medication,
            'reasonForVisit': patient!.reasonForVisit,
            'conditionAssessment': patient!.conditionAssessment,
            "rayImages": imageURLs,
            "raysPDF": pdfURLs
          }).whenComplete(() {
            patient.onlyInLocal = false;
            patient.save();
          });
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
  //___________________________

  //upload local followUp________
  uploadFollowUpOnlyInLocal(String doctorName) async {
    var recordBox = await Hive.box<PatientRecord>('patient_records');
    List<PatientRecord> patients = recordBox.values.toList();

    for (PatientRecord patientRecord in patients) {
      if (patientRecord.followUpOnlyInLocal.isNotEmpty) {
        for (FollowUp followUpInLocal in patientRecord.followUpOnlyInLocal) {
          followUpInLocal.doctorName = doctorName;
          patientRecord.save();

          if (patientRecord.isShared ?? false) {
            for (String doctorId in patientRecord.doctorsId) {
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(doctorId)
                  .collection("records")
                  .doc(patientRecord.id)
                  .collection('followUp')
                  .doc(followUpInLocal.id)
                  .set({
                "RecordId": patientRecord.id,
                "doctorId": FirebaseAuth.instance.currentUser!.uid,
                "doctorName": followUpInLocal.doctorName,
                'id': followUpInLocal.id,
                'date': convertStringToTimestamp(followUpInLocal.date),
                'text': followUpInLocal.text ?? "",
                "image": await _uploadFollowUpImagesToFireStorage(
                    followUpInLocal.image ?? [],
                    patientRecord.id,
                    followUpInLocal.id),
                "docPaths": await _uploadFollowUpPDFToFireStorage(
                    followUpInLocal.docPath ?? [],
                    patientRecord.id,
                    followUpInLocal.id),
              });
            }
          } else {
            await FirebaseFirestore.instance
                .collection("users")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection("records")
                .doc(patientRecord.id)
                .collection('followUp')
                .doc(followUpInLocal.id)
                .set({
              "RecordId": patientRecord.id,
              "doctorId": FirebaseAuth.instance.currentUser!.uid,
              "doctorName": followUpInLocal.doctorName,
              'id': followUpInLocal.id,
              'date': followUpInLocal.date,
              'text': followUpInLocal.text ?? "",
              "image": await _uploadFollowUpImagesToFireStorage(
                  followUpInLocal.image ?? [],
                  patientRecord.id,
                  followUpInLocal.id),
              "docPaths": await _uploadFollowUpPDFToFireStorage(
                  followUpInLocal.docPath ?? [],
                  patientRecord.id,
                  followUpInLocal.id),
            });
          }
        }

        patientRecord.followUpOnlyInLocal = [];
        patientRecord.save();
      }
    }
  }

  updateRecordInFirestore() async {
    for (var patient in patientRecords!) {
      if (patient.updatedInLocal) {
        if (patient.isShared ?? false) {
          for (String id in patient.doctorsId) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(id)
                .collection('records')
                .doc(patient.id)
                .update({
              "diagnosis": patient.diagnosis,
              "mc": patient.mc,
              "patientName": patient.patientName,
              "program": patient.program,
              'age': patient!.age,
              'gender': patient!.gender,
              'job': patient!.job,
              'phoneNumber': patient!.phoneNumer,
              'knownAllergies': patient!.knownAllergies,
              'medicalHistory': patient!.medicalHistory,
              'medication': patient!.medication,
              'reasonForVisit': patient!.reasonForVisit,
              'conditionAssessment': patient!.conditionAssessment,
            });
          }
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('records')
              .doc(patient.id)
              .update({
            "diagnosis": patient.diagnosis,
            "mc": patient.mc,
            "patientName": patient.patientName,
            "program": patient.program,
            'age': patient!.age,
            'gender': patient!.gender,
            'job': patient!.job,
            'phoneNumber': patient!.phoneNumer,
            'knownAllergies': patient!.knownAllergies,
            'medicalHistory': patient!.medicalHistory,
            'medication': patient!.medication,
            'reasonForVisit': patient!.reasonForVisit,
            'conditionAssessment': patient!.conditionAssessment,
          });
        }

        patient.updatedInLocal = false;
        patient.save();
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

  void filterSharedPatient() {
    emit(FilterRecordsLoading());
    try {
      var recordBox = Hive.box<PatientRecord>('patient_records');
      filteredPatientRecords = recordBox.values.where((patient) {
        return patient.isShared!;
      }).toList();
      isFiltered = true;
      emit(FilterRecordsSuccess());
    } catch (e) {
      emit(FilterRecordsError(error: e.toString()));
    }
  }

  void filterNotSharedPatient() {
    emit(FilterRecordsLoading());
    try {
      var recordBox = Hive.box<PatientRecord>('patient_records');
      filteredPatientRecords = recordBox.values.where((patient) {
        return !patient.isShared!;
      }).toList();
      isFiltered = true;
      emit(FilterRecordsSuccess());
    } catch (e) {
      emit(FilterRecordsError(error: e.toString()));
    }
  }
}
