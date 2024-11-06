import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:physio_record/AddFollowAppToSharedRecord/AddFollowUpToSharedRecordCubit/add_follow_up_to_shared_record_states.dart';
import 'package:physio_record/Cubits/GetUserDataCubit/get_user_data_cubit.dart';
import 'package:physio_record/models/shared_record_model.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../../global_vals.dart';

class AddFollowUpToSharedRecordCubit
    extends Cubit<AddFollowUpToSharedRecordState> {
  AddFollowUpToSharedRecordCubit()
      : super(AddFollowUpToSharedRecordInitialState());

  Future<void> addFollowUpItem(
      {required SharedRecordModel patientRecord,
      context,
      String? text,
      List<String>? imagePaths,
      List<String>? docPaths}) async {
    emit(AddFollowUpToSharedRecordLoadingState());
    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());

      var uuid = Uuid();
      String followUpId = uuid.v6();
      DateTime currentDate = DateTime.now();
      var formattedCurrentDate = DateFormat('hh:mm d-M-y').format(currentDate);

      if (connectivityResult.contains(ConnectivityResult.none)) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('There is no internet connection please try again'),
              );
            });
      } else {
        List<String> imageURLs = [];
        if (imagePaths?.isNotEmpty ?? false) {
          for (var imagePath in imagePaths!) {
            File file = File(imagePath);
            final fileName = path.basename(file.path);
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('images/${patientRecord.id}/$followUpId/$fileName');
            await storageRef.putFile(file);
            final downloadURL = await storageRef.getDownloadURL();
            imageURLs.add(downloadURL);
          }
        }

        List<String> docURLs = [];
        if (docPaths?.isNotEmpty ?? false) {
          for (var docPath in docPaths!) {
            File file = File(docPath);
            final fileName = path.basename(file.path);
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('docs/${patientRecord.id}/$followUpId/$fileName');
            await storageRef.putFile(file);
            final downloadURL = await storageRef.getDownloadURL();
            docURLs.add(downloadURL);
          }
        }

        for (var doctorId in patientRecord.doctorsIds) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(doctorId)
              .collection('sharedRecords')
              .doc(patientRecord.id)
              .collection('followUp')
              .doc(followUpId)
              .set({
            'id': followUpId,
            'RecordId': patientRecord.id,
            'date': convertStringToTimestamp(formattedCurrentDate),
            'text': text ?? "",
            'doctorName':
                BlocProvider.of<GetUserDataCubit>(context).userModel!.userName,
            'doctorId':
                BlocProvider.of<GetUserDataCubit>(context).userModel!.id,
            "image": imageURLs,
            "docPaths": docURLs
          });
          
        }

      }

      emit(AddFollowUpToSharedRecordSuccessState());
    } catch (e) {
      print(e.toString() + "_________5");
      emit(AddFollowUpToSharedRecordErrorState());
    }
  }
}
