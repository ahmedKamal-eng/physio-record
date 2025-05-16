



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physio_record/Cubits/GetUserDataCubit/get_user_data_states.dart';
import 'package:physio_record/HiveService/user_functions.dart';

import '../../models/user_model.dart';

class GetUserDataCubit extends Cubit<GetUserDataState> {
  GetUserDataCubit() : super(GetUserDataInitial());

   UserModel? userModel=getCurrentUser();

 Future<void> getUserData()async {

    emit(GetUserDataLoading());

    try{

    await  FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((val) async {
        userModel= UserModel.fromJson(val);

        await saveUserData(userModel!).whenComplete((){
          print("userName is: ${userModel!.userName}");
        });
      });
      emit(GetUserDataSuccess());
    }catch(e){
      print("_______________ _ _ _ _ _______________${e.toString()}");
      emit(GetUserDataError());
    }

  }


}