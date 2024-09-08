import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:physio_record/AddRecordScreen/AddRecordCubit/add_record_states.dart';
import 'package:physio_record/global_vals.dart';
import 'package:physio_record/models/patient_record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AddRecordCubit extends Cubit<AddRecordState> {
  AddRecordCubit() : super(AddRecordInitial());

  addRecord(PatientRecord patientRecord) async {
    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
    var recordBox = Hive.box<PatientRecord>('patient_records');
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    emit(AddRecordLoading());
    try {

      if(connectivityResult.contains(ConnectivityResult.none))
      {
        recordBox.add(patientRecord);
        patientRecord.onlyInLocal=true;
        patientRecord.save();
      }
      else
        {
        recordBox.add(patientRecord);
        patientRecord.save();
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('records')
            .doc(patientRecord.id)
            .set({
        "patientName": patientRecord.patientName,
        'id':patientRecord.id,
        "date": convertStringToTimestamp(patientRecord.date),
        "diagnosis": patientRecord.diagnosis,
        'mc': patientRecord.mc,
        'program': patientRecord.program,
        });
        emit(AddRecordSuccess());

        }

    } catch (e) {
      emit(AddRecordError(error: e.toString()));
    }
  }
}
