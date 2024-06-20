import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../../models/patient_record.dart';
import 'fetch_record_state.dart';

class FetchRecordCubit extends Cubit<FetchRecordState>{

  FetchRecordCubit() : super(FetchRecordInitial());

  List<PatientRecord>? patientRecords;

  fetchAllRecord() async{
    emit(FetchRecordLoading());
    try{
      var recordBox = Hive.box<PatientRecord>('patient_records');
      patientRecords=recordBox.values.toList();
       // patientRecords!.sort((a, b) =>  DateFormat('d-M-y').parse( b.date).compareTo(DateFormat('d-M-y').parse(a.date)));
       // print(patientRecords![0].patientName);
      emit(FetchRecordSuccess());
    }catch(e){
      emit(FetchRecordError(error:e.toString()));
    }
  }
}

