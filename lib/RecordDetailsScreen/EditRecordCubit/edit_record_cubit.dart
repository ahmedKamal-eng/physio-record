import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physio_record/models/patient_record.dart';
import '../../global_vals.dart';
import 'edit_record_states.dart';

class EditRecordCubit extends Cubit<EditRecordState> {
  EditRecordCubit() : super(EditRecordInitial());


  void editAge(PatientRecord patient,String age) async {
    emit(EditLoading());
    try {
        patient.age=int.parse(age);
        PatientRecord currentPatient = await getPatientFromLocalById(patient.id);
        currentPatient.age = int.parse(age);
        currentPatient.save();
        emit(EditSuccess());
        print("updated successfully");
    }catch(e)
    {
      print(e.toString()+"))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))");
      emit(EditError(error: e.toString()));
    }
  }

  void editPhoneNumber(PatientRecord patient,String phoneNumber) async {
    emit(EditLoading());
    try {
      patient.phoneNumer=int.parse(phoneNumber);
      PatientRecord currentPatient = await getPatientFromLocalById(patient.id);
      currentPatient.phoneNumer = int.parse(phoneNumber);
      currentPatient.save();
      emit(EditSuccess());
      print("updated successfully");
    }catch(e)
    {
      emit(EditError(error: e.toString()));
    }
  }


  void editName(PatientRecord patientRecord, String name) async {
    emit(EditNameLoading());
    try {

      patientRecord.patientName=name;

      // update in local
      PatientRecord currentPatient = await getPatientFromLocalById(patientRecord.id);
      currentPatient.patientName = name;
      currentPatient.save();

      emit(EditNameSuccess());
    } catch (e) {
      emit(EditNameError(error: e.toString()));
    }
  }

  void editReasonForVisit(PatientRecord patientRecord, String reasonForVisit) async {
    emit(EditLoading());
    try {

      patientRecord.reasonForVisit=reasonForVisit;

      // update in local
      PatientRecord currentPatient = await getPatientFromLocalById(patientRecord.id);
      currentPatient.reasonForVisit = reasonForVisit;
      currentPatient.save();

      emit(EditSuccess());
    } catch (e) {
      emit(EditError(error: e.toString()));
    }
  }
  void editConditionAssessment(PatientRecord patientRecord, String conditionAssessment) async {
    emit(EditLoading());
    try {

      patientRecord.conditionAssessment=conditionAssessment;

      // update in local
      PatientRecord currentPatient = await getPatientFromLocalById(patientRecord.id);
      currentPatient.conditionAssessment = conditionAssessment;
      currentPatient.save();

      emit(EditSuccess());
    } catch (e) {
      emit(EditError(error: e.toString()));
    }
  }

  void editJob(PatientRecord patientRecord, String job) async {
    emit(EditLoading());
    try {

      patientRecord.job=job;

      // update in local
      PatientRecord currentPatient = await getPatientFromLocalById(patientRecord.id);
      currentPatient.job = job;
      currentPatient.save();

      emit(EditSuccess());
    } catch (e) {
      emit(EditError(error: e.toString()));
    }
  }

  void editDiagnosis(PatientRecord patientRecord, String diagnosis) async{
    emit(EditDiagnosisLoading());
    try {
      patientRecord.diagnosis=diagnosis;
      // update in local
      PatientRecord currentPatient = await getPatientFromLocalById(patientRecord.id);
      currentPatient.diagnosis = diagnosis;
      currentPatient.save();
      emit(EditDiagnosisSuccess());
    } catch (e) {
      emit(EditDiagnosisError(error: e.toString()));
    }
  }

  void editMC(PatientRecord patientRecord, String mc)async {
    emit(EditMCLoading());
    try {
      patientRecord.mc = mc.split('\n');

      // update in Local
      PatientRecord currentPatient = await getPatientFromLocalById(patientRecord.id);
      currentPatient.mc=mc.split('\n');
      currentPatient.save();
      emit(EditMCSuccess());
    } catch (e) {
      emit(EditMCError(error: e.toString()));
    }
  }

  void editProgram(PatientRecord patientRecord, String program)async {
    emit(EditProgramLoading());
    try {
      patientRecord.program = program.split('\n');

      // update in local
      PatientRecord currentPatient = await getPatientFromLocalById(patientRecord.id);
      currentPatient.program=program.split('\n');
      currentPatient.save();
      emit(EditProgramSuccess());
    } catch (e) {
      emit(EditProgramError(error: e.toString()));
    }
  }

  void editMedicalHistory(PatientRecord patientRecord, String medicalHistory)async {
    emit(EditProgramLoading());
    try {
      patientRecord.medicalHistory = medicalHistory.split('\n');

      // update in local
      PatientRecord currentPatient = await getPatientFromLocalById(patientRecord.id);
      currentPatient.medicalHistory=medicalHistory.split('\n');
      currentPatient.save();
      emit(EditProgramSuccess());
    } catch (e) {
      emit(EditProgramError(error: e.toString()));
    }
  }

  void editMedication(PatientRecord patientRecord, String medication)async {
    emit(EditProgramLoading());
    try {
      patientRecord.medication = medication.split('\n');

      // update in local
      PatientRecord currentPatient = await getPatientFromLocalById(patientRecord.id);
      currentPatient.medication=medication.split('\n');
      currentPatient.save();
      emit(EditProgramSuccess());
    } catch (e) {
      emit(EditProgramError(error: e.toString()));
    }
  }

  void editKnownAllergies(PatientRecord patientRecord, String knownAllergies)async {
    emit(EditProgramLoading());
    try {
      patientRecord.knownAllergies = knownAllergies.split('\n');

      // update in local
      PatientRecord currentPatient = await getPatientFromLocalById(patientRecord.id);
      currentPatient.knownAllergies=knownAllergies.split('\n');
      currentPatient.save();
      emit(EditProgramSuccess());
    } catch (e) {
      emit(EditProgramError(error: e.toString()));
    }
  }


}
