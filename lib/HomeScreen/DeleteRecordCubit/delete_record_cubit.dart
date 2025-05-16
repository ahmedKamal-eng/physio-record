import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:physio_record/HomeScreen/DeleteRecordCubit/delete_record_States.dart';
import 'package:physio_record/models/patient_record.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

import '../../global_vals.dart';
import '../FetchAllRecord/fetch_record_cubit.dart';

class DeleteRecordCubit extends Cubit<DeleteRecordState> {
  DeleteRecordCubit() : super(DeleteRecordInitial());

  Future<void> deleteRecord(
      PatientRecord patient, int patientIndex, BuildContext context) async {
    emit(DeleteRecordLoading());

    try {
      // delete record from Local
      var patientBox = await Hive.box<PatientRecord>('patient_records');
      PatientRecord patientToRemove = patientBox.values.firstWhere(
        (p) => p.id == patient.id,
      );
      if (patientToRemove != null) {
        await patientToRemove.delete(); // Delete the object
        print("patient deleted from Local");
      } else {
        print('Patient with this id not found');
      }
      //___________________________

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('records')
          .doc(patient.id);
      final batch = FirebaseFirestore.instance.batch();

      // Delete the document
      batch.delete(docRef);

      // Recursively delete subCollection
      final subcollectionRef = docRef.collection('followUp');
      final docs = await subcollectionRef.get();
      for (final doc in docs.docs) {
        batch.delete(doc.reference);
      }
      batch.commit();

      if (patient.isShared ?? false) {
        if (patient.doctorsId.length == 2) {
          List<String> newDoctorsList = patient.doctorsId;
          newDoctorsList.remove(FirebaseAuth.instance.currentUser!.uid);

          await FirebaseFirestore.instance
              .collection('users')
              .doc(newDoctorsList[0])
              .collection('records')
              .doc(patient.id)
              .update({'isShared': false, 'doctorsIds': newDoctorsList});
        } else {
          List<String> newDoctorsList = patient.doctorsId;
          newDoctorsList.remove(FirebaseAuth.instance.currentUser!.uid);

          for (String doctorId in newDoctorsList) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(doctorId)
                .collection('records')
                .doc(patient.id)
                .update({'doctorsIds': newDoctorsList});
          }
        }
      } else {
        if (patient.followUpList.isNotEmpty) {
          for (var followUp in patient.followUpList) {
            //delete followUp Images
            if (followUp.image!.isNotEmpty) {
              for (var img in followUp.image!) {
                Uri uri = Uri.parse(img);
                String filePath = Uri.decodeComponent(uri.path);
                deleteFile(
                    'images/${patient.id}/${followUp.id}/${path.basename(filePath)}');
              }
            }
            //_______________________________________

            //delete followUp pdf from fireStorage
            if (followUp.docPath!.isNotEmpty) {
              for (var doc in followUp.docPath!) {
                Uri uri = Uri.parse(doc);
                String filePath = Uri.decodeComponent(uri.path);
                deleteFile(
                    'docs/${patient.id}/${followUp.id}/${path.basename(filePath)}');
              }
            }
            //__________________________________________
          }
        }

        //delete rays images
        if (patient.rayImages.isNotEmpty) {
          for (var doc in patient.rayImages) {
            // File file =
            // File(doc);
            // final fileName =
            // path.basename(
            //     file.path);
            Uri uri = Uri.parse(doc);
            String filePath = Uri.decodeComponent(uri.path);

            print(
                'rays Path is: rays/${patient.id}/images/${path.basename(filePath)}');
            deleteFile('rays/${patient.id}/images/${path.basename(filePath)}');
          }
        }

        if (patient.raysPDF.isNotEmpty) {
          for (var doc in patient.raysPDF) {
            Uri uri = Uri.parse(doc);
            String filePath = Uri.decodeComponent(uri.path);
            deleteFile('rays/${patient.id}/pdf/${path.basename(filePath)}');
          }
        }
      }

      BlocProvider.of<FetchRecordCubit>(context).fetchAllRecord();
      emit(DeleteRecordSuccess());
    } catch (e) {
      emit(DeleteRecordError(error: e.toString()));
    }
  }
}
