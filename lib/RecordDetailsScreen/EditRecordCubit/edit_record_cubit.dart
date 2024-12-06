import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physio_record/models/patient_record.dart';

import 'edit_record_states.dart';

class EditRecordCubit extends Cubit<EditRecordState> {
  EditRecordCubit() : super(EditRecordInitial());

  void editName(PatientRecord patientRecord, String name) {
    emit(EditNameLoading());
    try {
      patientRecord.patientName = name;
      patientRecord.save();

      emit(EditNameSuccess());
    } catch (e) {
      emit(EditNameError(error: e.toString()));
    }
  }

  void editDiagnosis(PatientRecord patientRecord, String diagnosis) {
    emit(EditDiagnosisLoading());
    try {
      patientRecord.diagnosis = diagnosis;
      patientRecord.save();
      emit(EditDiagnosisSuccess());
    } catch (e) {
      emit(EditDiagnosisError(error: e.toString()));
    }
  }

  void editMC(PatientRecord patientRecord, String mc) {
    emit(EditMCLoading());
    try {
      patientRecord.mc = mc.split('\n');
      patientRecord.save();
      emit(EditMCSuccess());
    } catch (e) {
      emit(EditMCError(error: e.toString()));
    }
  }

  void editProgram(PatientRecord patientRecord, String program) {
    emit(EditProgramLoading());
    try {
      patientRecord.program = program;
      patientRecord.save();
      emit(EditProgramSuccess());
    } catch (e) {
      emit(EditProgramError(error: e.toString()));
    }
  }
}
