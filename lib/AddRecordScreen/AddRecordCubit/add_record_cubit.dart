import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:physio_record/AddRecordScreen/AddRecordCubit/add_record_states.dart';
import 'package:physio_record/models/patient_record.dart';

class AddRecordCubit extends Cubit<AddRecordState>{

  AddRecordCubit() : super(AddRecordInitial());

  addRecord(PatientRecord patientRecord) async{
    emit(AddRecordLoading());
    try{
      var recordBox = Hive.box<PatientRecord>('patient_records');
      recordBox.add(patientRecord);
      emit(AddRecordSuccess());
    }catch(e){
      emit(AddRecordError(error:e.toString()));
    }
  }
}

