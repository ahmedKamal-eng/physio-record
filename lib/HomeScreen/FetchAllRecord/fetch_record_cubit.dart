import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../../models/patient_record.dart';
import 'fetch_record_state.dart';

class FetchRecordCubit extends Cubit<FetchRecordState> {
  FetchRecordCubit() : super(FetchRecordInitial());

  List<PatientRecord>? patientRecords;
  List<PatientRecord>? filteredPatientRecords=[];
  bool isFiltered=false;

  fetchAllRecord() async {
    emit(FetchRecordLoading());
    try {
      var recordBox = Hive.box<PatientRecord>('patient_records');
      patientRecords = recordBox.values.toList();
      // patientRecords!.sort((a, b) =>  DateFormat('d-M-y').parse( b.date).compareTo(DateFormat('d-M-y').parse(a.date)));
      // print(patientRecords![0].patientName);
      emit(FetchRecordSuccess());
    } catch (e) {
      emit(FetchRecordError(error: e.toString()));
    }
  }

  clearFilter(){
    isFiltered= false;
    emit(ClearFilter());
  }

  void filterPatientsByDate(DateTime filterDate) {
    emit(FilterRecordsLoading());
    try {
      DateFormat formatter;
      formatter = DateFormat("HH:mm d-M-y");
      // final DateTime parsedDate = formatter.parse(filterDate);
      var recordBox = Hive.box<PatientRecord>('patient_records');

      filteredPatientRecords = recordBox.values.where((patient) {
        DateTime parsedDate = formatter.parse(patient.date);

        // DateTime patientDate = dateFormat.parse(patient.date);
        return parsedDate.year == filterDate.year &&
            parsedDate.month == filterDate.month &&
            parsedDate.day == filterDate.day;
      }).toList();
      isFiltered=true;
      emit(FilterRecordsSuccess());
    } catch (e) {
      emit(FilterRecordsError(error: e.toString()));
    }
  }
}
