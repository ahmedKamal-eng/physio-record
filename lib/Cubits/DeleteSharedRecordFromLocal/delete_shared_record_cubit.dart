import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:physio_record/Cubits/DeleteSharedRecordFromLocal/delete_shared_record_states.dart';

import '../../models/patient_record.dart';

class DeleteSharedRecordCubit extends Cubit<DeleteSharedRecordState> {
  DeleteSharedRecordCubit() : super(DeleteSharedRecordInitialState());

  List<String> sharedRecordIds = [];
  List<String> acceptedRequestIds = [];

  Future<void> getSharedRecordAndAcceptedRequestsIds() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('submittedRequests')
        .get()
        .then((val) {
      if (val.docs.isNotEmpty) {
        for (int i = 0; i < val.docs!.length; i++) {
          if (val.docs[i]['status'] == 'accept') {
            print(val.docs[i]['recordId'] + "@@@@@@@@@@");

            sharedRecordIds.add(val.docs[i]["recordId"]);
            acceptedRequestIds.add(val.docs[i]['requestId']);
          }
        }
      }
    });

    Set<String> idsSet = sharedRecordIds.toSet();
    sharedRecordIds = idsSet.toList();
    Set<String> requestsSet = acceptedRequestIds.toSet();
    acceptedRequestIds = requestsSet.toList();
  }




  Future<void> deleteRecordCollectionFromFireStore()async {
    for (int i = 0; i < sharedRecordIds.length; i++) {

      final docRef = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('records').doc(sharedRecordIds[i]);
      final batch = FirebaseFirestore.instance.batch();

      // Delete the document
      batch.delete(docRef);

      // Recursively delete subcollection
      final subcollectionRef = docRef.collection('followUp');
      final docs = await subcollectionRef.get();
      for (final doc in docs.docs) {
        batch.delete(doc.reference);
      }

      return batch.commit();

    }

  }

  deleteAcceptedRequests() async {
    for (int i = 0; i < acceptedRequestIds.length; i++) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('submittedRequests')
          .doc(acceptedRequestIds[i])
          .delete();
    }
  }

  deleteSharedRecordsFromLocal()async {

         var box = Hive.box<PatientRecord>('patient_records');
         final objects = box.values.toList();

         final objectsToRemove = objects.where((object) => sharedRecordIds.contains(object.id)).toList();


         // Delete the filtered objects
         for (final object in objectsToRemove) {
           await object.delete();
         }

    // try {
    //   for (int i = 0; i < sharedRecordIds.length; i++) {
    //     // delete record
    //     var box = Hive.box<PatientRecord>('patient_records');
    //     // Find the object using its ID
    //     PatientRecord? recordToDelete = box.values.firstWhere(
    //       (record) => record.id == sharedRecordIds[i],
    //       // orElse: () => null,
    //     );
    //     if (recordToDelete != null) {
    //       recordToDelete.delete();
    //     }
    //   }
    // } catch (e) {
    //   print(e.toString() + "____________________#4");
    // }
  }

  deleteSharedRecordFromUserRecordsInLocalAndFirestore() async {
    emit(DeleteSharedRecordLoadingState());
    try {
      print(sharedRecordIds.toString() + " #########");
      if (sharedRecordIds.isNotEmpty) {
        await deleteRecordCollectionFromFireStore();

         await deleteSharedRecordsFromLocal();

         await deleteAcceptedRequests();
      }

      emit(DeleteSharedRecordSuccessState());
    } catch (e) {
      emit(DeleteSharedRecordErrorState());
    }
    // deleteAcceptedRequests();
    sharedRecordIds = [];
    acceptedRequestIds = [];
  }
}
