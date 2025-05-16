import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:physio_record/AddFollowUpItem/AddFollowUpCubit/add_follow_up_states.dart';
import 'package:physio_record/Cubits/GetUserDataCubit/get_user_data_cubit.dart';
import 'package:physio_record/HomeScreen/FetchAllRecord/fetch_record_cubit.dart';
import 'package:physio_record/global_vals.dart';
import 'package:physio_record/models/patient_record.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';



class AddFollowUpCubit extends Cubit<AddFollowUpState> {
  AddFollowUpCubit() : super(AddFollowUpInitial());


  Future<void> addFollowUpItem({
    required PatientRecord patientRecord,
    String? text,
    List<String>? imagePaths,
    List<String>? docPaths,
    required BuildContext context,
  }) async {
    emit(AddFollowUpLoading());

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final userDataCubit = BlocProvider.of<GetUserDataCubit>(context);
      final userModel = userDataCubit.userModel;

      if (userModel == null) {
        await userDataCubit.getUserData();
      }

      final uuid = Uuid();
      final followUpId = uuid.v6();
      final currentDate = DateTime.now();
      final formattedCurrentDate = DateFormat('hh:mm d-M-y').format(currentDate);

      List<String> imageURLs = [];
      List<String> docURLs = [];

      if (connectivityResult.contains(ConnectivityResult.none)) {
        // Handle offline case
        patientRecord.followUpList.add(FollowUp(
          date: formattedCurrentDate,
          text: text ?? "",
          image: imagePaths,
          docPath: docPaths,
          id: followUpId,
          doctorName: userModel?.userName ?? "",
          onlyInLocal: true,
        ));
        patientRecord.followUpOnlyInLocal.add(FollowUp(
          date: formattedCurrentDate,
          text: text ?? "",
          image: imagePaths,
          docPath: docPaths,
          id: followUpId,
          doctorName: userModel?.userName ?? "",
          onlyInLocal: true,
        ));
        await patientRecord.save();
      } else {
        // Handle online case
        if (imagePaths?.isNotEmpty ?? false) {
          imageURLs = await Future.wait(imagePaths!.map((imagePath) async {
            final file = File(imagePath);
            final fileName = path.basename(file.path);
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('images/${patientRecord.id}/$followUpId/$fileName');
            await storageRef.putFile(file);
            return await storageRef.getDownloadURL();
          }));
        }

        if (docPaths?.isNotEmpty ?? false) {
          docURLs = await Future.wait(docPaths!.map((docPath) async {
            final file = File(docPath);
            final fileName = path.basename(file.path);
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('docs/${patientRecord.id}/$followUpId/$fileName');
            await storageRef.putFile(file);
            return await storageRef.getDownloadURL();
          }));
        }

        final firestore = FirebaseFirestore.instance;
        final batch = firestore.batch();

        if (patientRecord.isShared ?? false) {
          for (String doctorId in patientRecord.doctorsId) {
            final docRef = firestore
                .collection('users')
                .doc(doctorId)
                .collection('records')
                .doc(patientRecord.id)
                .collection('followUp')
                .doc(followUpId);

            batch.set(docRef, {
              'id': followUpId,
              'RecordId': patientRecord.id,
              'date': convertStringToTimestamp(formattedCurrentDate),
              'text': text ?? "",
              "image": imageURLs,
              "docPaths": docURLs,
              'doctorName': userModel?.userName ?? "",
              'doctorId': userModel?.id ?? "",
            });
          }

          await batch.commit();

          // Update local Hive database
          final patientBox = await Hive.openBox<PatientRecord>('patient_records');
          final currentPatient = patientBox.values.firstWhere((p) => p.id == patientRecord.id);

          currentPatient.followUpList.add(FollowUp(
            date: formattedCurrentDate,
            text: text ?? "",
            image: imagePaths,
            docPath: docPaths,
            id: followUpId,
            doctorName: userModel?.userName ?? "",
          ));

          await currentPatient.save();
          await BlocProvider.of<FetchRecordCubit>(context).fetchAllRecord();
        } else {
          await firestore
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('records')
              .doc(patientRecord.id)
              .collection('followUp')
              .doc(followUpId)
              .set({
            'id': followUpId,
            'RecordId': patientRecord.id,
            'date': convertStringToTimestamp(formattedCurrentDate),
            'text': text ?? "",
            "image": imageURLs,
            "docPaths": docURLs,
            'doctorName': userModel?.userName ?? "",
            'doctorId': userModel?.id ?? "",
          });

          // Update local Hive database
          final patientBox = await Hive.openBox<PatientRecord>('patient_records');
          final currentPatient = patientBox.values.firstWhere((p) => p.id == patientRecord.id);

          currentPatient.followUpList.add(FollowUp(
            date: formattedCurrentDate,
            text: text ?? "",
            image: imagePaths,
            docPath: docPaths,
            id: followUpId,
            doctorName: userModel?.userName ?? "",
          ));

          await currentPatient.save();
          await BlocProvider.of<FetchRecordCubit>(context).fetchAllRecord();
        }
      }

      emit(AddFollowUpSuccess());
    } catch (e) {
      print("%% add followUp error: ${e.toString()}");
      emit(AddFollowUpError(error: e.toString()));
    }
  }


}
