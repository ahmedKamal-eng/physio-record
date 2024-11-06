import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physio_record/AddToFriendScreen/AddToFriendCubit/add_to_friend_states.dart';

class AddToFriendCubit extends Cubit<AddToFriendState> {
  AddToFriendCubit() : super(AddToFriendInitial());

  addUserToFriend(
      {required String name,
      required String img,
      required String medicalSpecialization,
      required String id}) async {

    emit(AddToFriendLoading());


    try{
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('friends')
        .doc(id)
        .set({
      'id': id,
      "medicalSpecialization": medicalSpecialization,
      'image': img,
      'name': name,
    });
emit(AddToFriendSuccess());
  }catch(e){
      emit(AddToFriendError());
    }

  }

}
