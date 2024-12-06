import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:physio_record/AddRecordScreen/AddRecordCubit/add_record_states.dart';
import 'package:physio_record/global_vals.dart';
import 'package:physio_record/models/patient_record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;



class AddRecordCubit extends Cubit<AddRecordState> {
  AddRecordCubit() : super(AddRecordInitial());

  addRecord(PatientRecord patientRecord,List<String>? rayImages,List<String>? raysPdf) async {
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
        List<String> raysImagesUrl=[];
        if(rayImages?.isNotEmpty ?? false)
        {
          for(var imagePath in rayImages!)
          {
            File file =File(imagePath);
            final fileName = path.basename(file.path);
            final storageRef = FirebaseStorage.instance.ref().child('rays/${patientRecord.id}/images/$fileName');
            await storageRef.putFile(file);
            final downloadURL = await storageRef.getDownloadURL();
            raysImagesUrl.add(downloadURL);
          }
        }
        //_______________________


        //add PDF to firestorage
        List<String> raysPdfUrl=[];
        if(raysPdf?.isNotEmpty ?? false)
        {
          for(var docPath in raysPdf!)
          {
            File file =File(docPath);
            final fileName = path.basename(file.path);
            final storageRef = FirebaseStorage.instance.ref().child('rays/${patientRecord.id}/pdf/$fileName');
            await storageRef.putFile(file);
            final downloadURL = await storageRef.getDownloadURL();
            raysPdfUrl.add(downloadURL);
          }
        }
        //_________________


        //add record locally
        recordBox.add(patientRecord);
        patientRecord.raysPDF=raysPdf!;
        patientRecord.rayImages=rayImages!;
        patientRecord.save();
        //_________________

      await  FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('records')
            .doc(patientRecord.id)
            .set({
          "patientName": patientRecord.patientName,
          'id': patientRecord.id,
          "date": convertStringToTimestamp(patientRecord.date),
          "diagnosis": patientRecord.diagnosis,
          'mc': patientRecord.mc,
          'program': patientRecord.program,
          'isShared': false,
          'rayImages': raysImagesUrl,
          'raysPDF':raysPdfUrl
        });
      }

      emit(AddRecordSuccess());
    } catch (e) {
      emit(AddRecordError(error: e.toString()));
    }
  }
}


