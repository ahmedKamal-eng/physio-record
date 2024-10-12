



import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:physio_record/widgets/LogoutCubit/logout_states.dart';

import '../../models/patient_record.dart';

class LogoutCubit extends Cubit<LogoutState> {
  LogoutCubit() : super(LogoutInitial());


  Future<void>  logOut()async{

    emit(LogoutLoadingState());

    try {

        FirebaseAuth.instance.signOut().whenComplete(() async {
          var box = Hive.box<PatientRecord>('patient_records');

          // Clear the box
          await box.clear();
        });
        emit(LogoutSuccessState());

    }catch(e){

      emit(LogoutErrorState(e.toString()));

    }
  }

}