import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physio_record/SharedRecordScreen/DeleteSharedRecordCubit/delete_user_from_shared_record_states.dart';

class DeleteUserFromSharedRecordCubit
    extends Cubit<DeleteUserFromSharedRecordState> {
  DeleteUserFromSharedRecordCubit() : super(DeleteSharedRecordInitial());

  deleteUserFromSharedRecord(String recordId, List<String> doctorIds) async {
    emit(DeleteSharedRecordLoading());

    try {
      doctorIds.remove(FirebaseAuth.instance.currentUser!.uid);
      Set<String> ids=doctorIds.toSet();


      for (int i = 0; i < doctorIds.length; i++) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(doctorIds[i])
            .collection('sharedRecords')
            .doc(recordId)
            .update({'doctorsIds': ids.toList()});
      }

      await deleteSharedRecordDocumentAndItsSubCollection(recordId);
      emit(DeleteSharedRecordSuccess());
    } catch (e) {
      emit(DeleteSharedRecordError(error: e.toString()));
      print(e.toString() +" UUUUUUUUUU");
    }
  }

  Future<void> deleteSharedRecordDocumentAndItsSubCollection(
      String recordId) async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('sharedRecords')
        .doc(recordId);
    final batch = FirebaseFirestore.instance.batch();

    try {
      // Delete the document
      batch.delete(docRef);

      // Recursively delete subcollection
      final subcollectionRef = docRef.collection('followUp');
      final docs = await subcollectionRef.get();
      if (docs != null || docs.docs.isNotEmpty) {
        for (final doc in docs.docs) {
          batch.delete(doc.reference);
        }
      }
    }catch(e){
      print(e.toString()+"^^delete_user_from_shared_record_cubit.dart 55");
    }
    return batch.commit();
  }
}
