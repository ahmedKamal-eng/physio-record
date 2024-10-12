



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physio_record/Cubits/GetUserDataCubit/get_user_data_states.dart';

import '../../models/user_model.dart';

class GetUserDataCubit extends Cubit<GetUserDataState> {
  GetUserDataCubit() : super(GetUserDataInitial());

   UserModel? userModel;

  getUserData() {
    emit(GetUserDataLoading());

    try{

      FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((val) {
        userModel=UserModel.fromJson(val);
      });
      emit(GetUserDataSuccess());
    }catch(e){
      emit(GetUserDataError());
    }

  }


}