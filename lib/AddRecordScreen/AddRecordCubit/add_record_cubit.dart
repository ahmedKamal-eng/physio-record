import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:physio_record/AddRecordScreen/AddRecordCubit/add_record_states.dart';
import 'package:physio_record/HiveService/user_functions.dart';
import 'package:physio_record/global_vals.dart';
import 'package:physio_record/models/medical_center_model.dart';
import 'package:physio_record/models/patient_record.dart';
import 'package:path/path.dart' as path;


class AddRecordCubit extends Cubit<AddRecordState> {
  AddRecordCubit() : super(AddRecordInitial());

  addRecord(PatientRecord patientRecord, List<String>? rayImages,
      List<String>? raysPdf, bool fromCenter,
      [MedicalCenterModel? centerModel])
  async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    var recordBox = Hive.box<PatientRecord>('patient_records');

    emit(AddRecordLoading());
    try {
      if (connectivityResult.contains(ConnectivityResult.none)) {
        recordBox.add(patientRecord);
        patientRecord.onlyInLocal = true;
        patientRecord.save();
      } else {
        //add images to firestorage
        List<String> raysImagesUrl = [];
        if (rayImages?.isNotEmpty ?? false) {
          for (var imagePath in rayImages!) {
            File file = File(imagePath);
            final fileName = path.basename(file.path);
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('rays/${patientRecord.id}/images/$fileName');
            await storageRef.putFile(file);
            final downloadURL = await storageRef.getDownloadURL();
            raysImagesUrl.add(downloadURL);
          }
        }
        //_______________________

        //add PDF to firestorage
        List<String> raysPdfUrl = [];
        if (raysPdf?.isNotEmpty ?? false) {
          for (var docPath in raysPdf!) {
            File file = File(docPath);
            final fileName = path.basename(file.path);
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('rays/${patientRecord.id}/pdf/$fileName');
            await storageRef.putFile(file);
            final downloadURL = await storageRef.getDownloadURL();
            raysPdfUrl.add(downloadURL);
          }
        }
        //_________________

        //add record locally
        recordBox.add(patientRecord);
        patientRecord.raysPDF = raysPdf!;
        patientRecord.rayImages = rayImages!;
        patientRecord.save();
        //_________________

        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('records')
            .doc(patientRecord.id)
            .set({
          'doctorName': getCurrentUser()!.userName,
          'doctorImage':getCurrentUser()!.imageUrl,
          "patientName": patientRecord.patientName,
          "patientNameLowerCase": patientRecord.patientName.toLowerCase(),
          'centerId': centerModel?.centerId ?? '',
          'id': patientRecord.id,
          "date": patientRecord.date is Timestamp
              ? patientRecord.date
              : convertStringToTimestamp(patientRecord.date),
          "diagnosis": patientRecord.diagnosis,
          'mc': patientRecord.mc,
          'program': patientRecord.program,
          'isShared': false,
          'rayImages': raysImagesUrl,
          'raysPDF': raysPdfUrl,
          'age': patientRecord.age,
          'gender': patientRecord.gender,
          'phoneNumber': patientRecord.phoneNumer,
          'medicalHistory': patientRecord.medicalHistory,
          'medication': patientRecord.medication,
          'knownAllergies': patientRecord.knownAllergies,
          'job': patientRecord.job,
          'reasonForVisit': patientRecord.reasonForVisit,
          'conditionAssessment': patientRecord.conditionAssessment
        });

        if (fromCenter) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(centerModel!.adminId)
              .collection('medical_centers')
              .doc(centerModel.centerId)
              .update({"recordCount": FieldValue.increment(1)});

          await FirebaseFirestore.instance
              .collection('users')
              .doc(centerModel!.adminId)
              .collection('medical_centers')
              .doc(centerModel.centerId)
              .collection('records')
              .doc(patientRecord.id)
              .set({
            'doctorName': getCurrentUser()!.userName,
            'doctorImage':getCurrentUser()!.imageUrl,
            "patientName": patientRecord.patientName,
            "patientNameLowerCase": patientRecord.patientName.toLowerCase(),
            'centerId': centerModel.centerId,
            'id': patientRecord.id,
            "date": patientRecord.date is Timestamp
                ? patientRecord.date
                : convertStringToTimestamp(patientRecord.date),
            "diagnosis": patientRecord.diagnosis,
            'mc': patientRecord.mc,
            'program': patientRecord.program,
            'isShared': false,
            'rayImages': raysImagesUrl,
            'raysPDF': raysPdfUrl,
            'age': patientRecord.age,
            'gender': patientRecord.gender,
            'phoneNumber': patientRecord.phoneNumer,
            'medicalHistory': patientRecord.medicalHistory,
            'medication': patientRecord.medication,
            'knownAllergies': patientRecord.knownAllergies,
            'job': patientRecord.job,
            'reasonForVisit': patientRecord.reasonForVisit,
            'conditionAssessment': patientRecord.conditionAssessment
          });
        }
      }

      if (connectivityResult.contains(ConnectivityResult.none) && fromCenter) {
      } else {
        emit(AddRecordSuccess());
      }
    } catch (e) {
      emit(AddRecordError(error: e.toString()));
    }
  }
}
