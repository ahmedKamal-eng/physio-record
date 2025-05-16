import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:physio_record/Cubits/GetUserDataCubit/get_user_data_cubit.dart';
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
    doctorIds=[...requestModel.doctorIds,FirebaseAuth.instance.currentUser!.uid];


  //   if(requestModel.doctorsSharedThisRecord)
  //     {
  //   FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(requestModel.senderId)
  //       .collection('records')
  //       .doc(requestModel.recordId)
  //       .get()
  //       .then((val) {
  //     doctorIds = [...List<String>.from(val.data()!['doctorsIds'])];
  //   });
  // }else
  //   {
  //     doctorIds=[FirebaseAuth.instance.currentUser!.uid,requestModel.senderId];
  //   }
  //   requestModel
    print("doctors IDs"+doctorIds.toString());
  }

  Future<void> getSharedRecord(ShareRequestModel requestModel) async {
    if (requestModel.doctorsSharedThisRecord) {
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

  saveSharedRecordIntoLocal(ShareRequestModel requestModel)async{

    var recordBox = Hive.box<PatientRecord>('patient_records');
    recordBox.add(sharedRecord!);
    Set<String> doctors=requestModel.doctorIds.toSet();
    List<String> doctorsIds=doctors.toList();
    if(sharedRecord!.raysPDF.isNotEmpty)
      {
       sharedRecord!.raysPDF=await fetchAndDownloadXRays(requestModel.recordId, 'pdf');
      }

    if(sharedRecord!.rayImages.isNotEmpty)
    {
      sharedRecord!.rayImages=await  fetchAndDownloadXRays(requestModel.recordId, 'images');
    }


    sharedRecord!.doctorsId=doctorsIds;
    sharedRecord!.isShared=true;
    sharedRecord!.save();
  }
Future<void> addSharedRecord(ShareRequestModel requestModel,context) async {
    emit(AcceptRequestLoading());
    Set<String> doctors=requestModel.doctorIds.toSet();
    List<String> doctorsIds=doctors.toList();

    try {
      await getSharedRecord(requestModel).whenComplete(() async {
        sharedRecord!.followUpList = followUpList;

        if (!requestModel.doctorsSharedThisRecord) {
          // user share this record for first time so you need to add this record in sender user and receiver

          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('records')
              .doc(requestModel.recordId)
              .set({
            "patientName": requestModel.patientName,
            'id': requestModel.recordId,
            "date": convertStringToTimestamp(requestModel.date),
            "diagnosis": requestModel.diagnosis,
            'mc': sharedRecord!.mc,
            'age':sharedRecord!.age,
            'gender':sharedRecord!.gender,
            'job':sharedRecord!.job,
            'phoneNumber':sharedRecord!.phoneNumer,
            'knownAllergies':sharedRecord!.knownAllergies,
            'medicalHistory':sharedRecord!.medicalHistory,
            'medication':sharedRecord!.medication,
            'reasonForVisit':sharedRecord!.reasonForVisit,
            'conditionAssessment':sharedRecord!.conditionAssessment,

            'program': sharedRecord!.program,
            'rayImages':sharedRecord!.rayImages,
            'raysPDF':sharedRecord!.raysPDF,
            'doctorsIds':doctorsIds,
            'isShared':true,
          }).then((_) {
            for (int i = 0; i < followUpList.length; i++) {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('records')
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
              .collection('records')
              .doc(requestModel.recordId)
              .update({
            'isShared':true
          });

          //start add to friend
          String? senderSpecialization;
          await FirebaseFirestore.instance.collection('users').doc(requestModel.senderId).get().then((val){
            senderSpecialization=val.data()!['medicalSpecialization'];
          });


          await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('friends').doc(requestModel.senderId).set(
              {"id": requestModel.senderId,
                'image': requestModel.doctorImage,
                'name': requestModel.doctorName,
                'medicalSpecialization': senderSpecialization  ?? 'physical therapist' });

          await FirebaseFirestore.instance.collection('users').doc(requestModel.senderId).collection('friends').doc(FirebaseAuth.instance.currentUser!.uid).set(
              {"id": FirebaseAuth.instance.currentUser!.uid,
                'image': BlocProvider.of<GetUserDataCubit>(context).userModel!.imagePath,
                'name': BlocProvider.of<GetUserDataCubit>(context).userModel!.userName,
                'medicalSpecialization':BlocProvider.of<GetUserDataCubit>(context).userModel!.medicalSpecialization});
          // end add to friend

          saveSharedRecordIntoLocal(requestModel);

        } else {
          // user  share this record for more than one time

          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('records')
              .doc(requestModel.recordId)
              .set({
            "patientName": requestModel.patientName,
            'id': requestModel.recordId,
            "date": convertStringToTimestamp(requestModel.date),
            "diagnosis": requestModel.diagnosis,
            'mc': sharedRecord!.mc,
            'age':sharedRecord!.age,
            'gender':sharedRecord!.gender,
            'job':sharedRecord!.job,
            'phoneNumber':sharedRecord!.phoneNumer,
            'knownAllergies':sharedRecord!.knownAllergies,
            'medicalHistory':sharedRecord!.medicalHistory,
            'medication':sharedRecord!.medication,
            'reasonForVisit':sharedRecord!.reasonForVisit,
            'conditionAssessment':sharedRecord!.conditionAssessment,
            'program': sharedRecord!.program,
            'rayImages':sharedRecord!.rayImages,
            'raysPDF':sharedRecord!.raysPDF,
            'doctorsIds': [...doctorIds, FirebaseAuth.instance.currentUser!.uid],
            "isShared":true
          }).then((_) async {

            for (int i = 0; i < followUpList.length; i++){
             await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('records')
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

          saveSharedRecordIntoLocal(requestModel);

        }
      });

      await getDoctorsIds(requestModel).whenComplete(() async{
        Set<String> doctorsSet=[...doctorIds, FirebaseAuth.instance.currentUser!.uid].toSet();
        List<String> doctorsIdList =doctorsSet.toList();
        for (var id in doctorsIdList) {
         await FirebaseFirestore.instance
              .collection('users')
              .doc(id)
              .collection('records')
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
