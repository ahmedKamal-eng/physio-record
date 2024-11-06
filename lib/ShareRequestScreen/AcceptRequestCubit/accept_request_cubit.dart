import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physio_record/ShareRequestScreen/AcceptRequestCubit/accept_request_states.dart';
import 'package:physio_record/models/patient_record.dart';
import 'package:physio_record/models/share_request_model.dart';

import '../../global_vals.dart';

class AcceptRequestCubit extends Cubit<AcceptRequestState> {
  AcceptRequestCubit() : super(AcceptRequestInitial());

  PatientRecord? sharedRecord;
  List<FollowUp> followUpList = [];
  List<String> doctorIds = [];

  Future<void> getDoctorsIds(ShareRequestModel requestModel) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(requestModel.senderId)
        .collection('sharedRecords')
        .doc(requestModel.recordId)
        .get()
        .then((val) {
      doctorIds = List<String>.from(val.data()!['doctorsIds']);
    });
  }

  Future<void> getSharedRecord(ShareRequestModel requestModel) async {
    if (requestModel.doctorsSharedThisRecord) {
      followUpList = [];
      await FirebaseFirestore.instance
          .collection("users")
          .doc(requestModel.senderId)
          .collection("sharedRecords")
          .doc(requestModel.recordId)
          .get()
          .then((val) {
        sharedRecord = PatientRecord.fromFirestore(val);
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(requestModel.senderId)
          .collection('sharedRecords')
          .doc(requestModel.recordId)
          .collection('followUp')
          .get()
          .then((val) {
        if (val.docs.isNotEmpty) {
          for (int i = 0; i < val.docs.length; i++) {
            followUpList.add(FollowUp.fromFirestore(val.docs[i]));
          }
        }
      });
    } else {
      followUpList = [];
      await FirebaseFirestore.instance
          .collection("users")
          .doc(requestModel.senderId)
          .collection("records")
          .doc(requestModel.recordId)
          .get()
          .then((val) {
        sharedRecord = PatientRecord.fromFirestore(val);
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(requestModel.senderId)
          .collection('records')
          .doc(requestModel.recordId)
          .collection('followUp')
          .get()
          .then((val) {
        if (val.docs.isNotEmpty) {
          for (int i = 0; i < val.docs.length; i++) {
            followUpList.add(FollowUp.fromFirestore(val.docs[i]));
          }
        }
      });
    }
  }

  Future<void> addSharedRecord(ShareRequestModel requestModel) async {
    emit(AcceptRequestLoading());

    try {
      await getSharedRecord(requestModel).whenComplete(() async {
        sharedRecord!.followUpList = followUpList;

        if (!requestModel.doctorsSharedThisRecord) {
          // user share this record for first time so you need to add this record in sender user and receiver

          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('sharedRecords')
              .doc(requestModel.recordId)
              .set({
            "patientName": requestModel.patientName,
            'id': requestModel.recordId,
            "date": convertStringToTimestamp(requestModel.date),
            "diagnosis": requestModel.diagnosis,
            'mc': sharedRecord!.mc,
            'program': sharedRecord!.program,
            'doctorsIds': [
              FirebaseAuth.instance.currentUser!.uid,
              requestModel.senderId
            ]
          }).then((_) {
            for (int i = 0; i < followUpList.length; i++) {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('sharedRecords')
                  .doc(requestModel.recordId)
                  .collection('followUp')
                  .doc(followUpList[i].id)
                  .set({
                'id': followUpList[i].id,
                'RecordId': sharedRecord!.id,
                'date': convertStringToTimestamp(followUpList[i].date),
                'text': followUpList[i].text ?? "",
                "image": followUpList[i].image,
                "docPaths": followUpList[i].docPath,
                "doctorName": requestModel.doctorName,
                "doctorId": requestModel.senderId
              });
            }
          });

          await FirebaseFirestore.instance
              .collection('users')
              .doc(requestModel.senderId)
              .collection('sharedRecords')
              .doc(requestModel.recordId)
              .set({
            "patientName": requestModel.patientName,
            'id': requestModel.recordId,
            "date": convertStringToTimestamp(requestModel.date),
            "diagnosis": requestModel.diagnosis,
            'mc': sharedRecord!.mc,
            'program': sharedRecord!.program,
            'doctorsIds': [
              FirebaseAuth.instance.currentUser!.uid,
              requestModel.senderId
            ]
          }).then((_) {
            for (int i = 0; i < followUpList.length; i++) {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(requestModel.senderId)
                  .collection('sharedRecords')
                  .doc(requestModel.recordId)
                  .collection('followUp')
                  .doc(followUpList[i].id)
                  .set({
                'id': followUpList[i].id,
                'RecordId': sharedRecord!.id,
                'date': convertStringToTimestamp(followUpList[i].date),
                'text': followUpList[i].text ?? "",
                "image": followUpList[i].image,
                "docPaths": followUpList[i].docPath,
                "doctorName": requestModel.doctorName,
                "doctorId": requestModel.senderId
              });
            }
          });
        } else {
          // user  share this record for more than one time

          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('sharedRecords')
              .doc(requestModel.recordId)
              .set({
            "patientName": requestModel.patientName,
            'id': requestModel.recordId,
            "date": convertStringToTimestamp(requestModel.date),
            "diagnosis": requestModel.diagnosis,
            'mc': sharedRecord!.mc,
            'program': sharedRecord!.program,
            'doctorsIds': [...doctorIds, FirebaseAuth.instance.currentUser!.uid]
          }).then((_) {

            for (int i = 0; i < followUpList.length; i++) {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('sharedRecords')
                  .doc(requestModel.recordId)
                  .collection('followUp')
                  .doc(followUpList[i].id)
                  .set({
                'id': followUpList[i].id,
                'RecordId': sharedRecord!.id,
                'date': convertStringToTimestamp(followUpList[i].date),
                'text': followUpList[i].text ?? "",
                "image": followUpList[i].image,
                "docPaths": followUpList[i].docPath,
                "doctorName": followUpList[i].doctorName,
                "doctorId": requestModel.senderId
              });
            }
          });
        }
      });

      await getDoctorsIds(requestModel).whenComplete(() {
        Set<String> doctorsSet=[...doctorIds, FirebaseAuth.instance.currentUser!.uid].toSet();
        List<String> doctorsIdList =doctorsSet.toList();
        for (var id in doctorsIdList) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(id)
              .collection('sharedRecords')
              .doc(requestModel.recordId)
              .update({
            'doctorsIds': doctorsIdList
          });
        }
      });

      // add doctors to your friend collection
      for (String doctorId in [
        ...doctorIds,
        FirebaseAuth.instance.currentUser!.uid
      ]) {
        DocumentReference docRef =
            await FirebaseFirestore.instance.collection('users').doc(doctorId);

        for (String id in [
          ...doctorIds,
          FirebaseAuth.instance.currentUser!.uid
        ]) {
          if (id != doctorId) {
            String? image;
            String? name;
            String? medicalSpecialization;

            await FirebaseFirestore.instance
                .collection('users')
                .doc(id)
                .get()
                .then((val) {
              image = val.data()!['imageUrl'];
              name = val.data()!['userName'];
              medicalSpecialization = val.data()!['medicalSpecialization'];
            });

            await docRef.collection('friends').doc(id).set({
              "id": id,
              'image': image,
              'name': name,
              'medicalSpecialization': medicalSpecialization
            });
          }
        }
      }
      emit(AcceptRequestSuccess());
    } catch (e) {
      emit(AcceptRequestError(e.toString()));
    }
  }
}
