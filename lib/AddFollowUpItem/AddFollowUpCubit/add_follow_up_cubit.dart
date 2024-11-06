import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:physio_record/AddFollowUpItem/AddFollowUpCubit/add_follow_up_states.dart';
import 'package:physio_record/Cubits/GetUserDataCubit/get_user_data_cubit.dart';
import 'package:physio_record/global_vals.dart';
import 'package:physio_record/models/patient_record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';

class AddFollowUpCubit extends Cubit<AddFollowUpState> {
  AddFollowUpCubit() : super(AddFollowUpInitial());

  Future<void> addFollowUpItem(
      {required PatientRecord patientRecord,
      String? text,
      List<String>? imagePaths,
      List<String>? docPaths}) async {


    emit(AddFollowUpLoading());
    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());



      var uuid = Uuid();
      String followUpId = uuid.v6();
      DateTime currentDate = DateTime.now();
      var formattedCurrentDate = DateFormat('hh:mm d-M-y').format(currentDate);

      if (connectivityResult.contains(ConnectivityResult.none)) {
        patientRecord.followUpList.add(FollowUp(
            date: formattedCurrentDate,
            text: text ?? "",
            image: imagePaths,
            docPath: docPaths,
            id: followUpId,
            onlyInLocal: true));
        patientRecord.followUpIdsOnlyInLocal.add(followUpId);
        patientRecord.save();
      } else {

        List<String> imageURLs=[];
        if(imagePaths?.isNotEmpty ?? false)
        {
          for(var imagePath in imagePaths!)
          {
            File file =File(imagePath);
            final fileName = path.basename(file.path);
            final storageRef = FirebaseStorage.instance.ref().child('images/${patientRecord.id}/$followUpId/$fileName');
            await storageRef.putFile(file);
            final downloadURL = await storageRef.getDownloadURL();
            imageURLs.add(downloadURL);
          }
        }

        List<String> docURLs=[];
        if(docPaths?.isNotEmpty ?? false)
        {
          for(var docPath in docPaths!)
          {
            File file =File(docPath);
            final fileName = path.basename(file.path);
            final storageRef = FirebaseStorage.instance.ref().child('docs/${patientRecord.id}/$followUpId/$fileName');
            await storageRef.putFile(file);
            final downloadURL = await storageRef.getDownloadURL();
            docURLs.add(downloadURL);
          }
        }
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('records')
            .doc(patientRecord.id)
            .collection('followUp')
            .doc(followUpId)
            .set({
          'id': followUpId,
          'RecordId':patientRecord.id,
          'date': convertStringToTimestamp(formattedCurrentDate),
          'text': text ?? "",
          "image": imageURLs,
          "docPaths": docURLs
        });

        patientRecord.followUpList.add(FollowUp(
            date: formattedCurrentDate,
            text: text ?? "",
            image: imagePaths,
            docPath: docPaths,
            id: followUpId));
        patientRecord.save();
      }

      emit(AddFollowUpSuccess());
    } catch (e) {
      emit(AddFollowUpError(error: e.toString()));
    }
  }
}
