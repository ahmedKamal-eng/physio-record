import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:physio_record/AddRecordScreen/AddRecordCubit/add_record_states.dart';
import 'package:physio_record/models/patient_record.dart';
import 'package:uuid/uuid.dart';

class AddRecordCubit extends Cubit<AddRecordState> {
  AddRecordCubit() : super(AddRecordInitial());

  addRecord(PatientRecord patientRecord) async {
    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
    var recordBox = Hive.box<PatientRecord>('patient_records');

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
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('records')
            .doc(patientRecord.id)
            .set({
        "patientName": patientRecord.patientName,
        'id':patientRecord.id,
        "date": patientRecord.date,
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
