import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../models/medical_center_model.dart';
import 'add_doctor_to_center_states.dart';

class AddDoctorToCenterCubit extends Cubit<AddDoctorToCenterStates> {
  AddDoctorToCenterCubit() : super(AddDoctorToCenterInitial());



  // this method send joining request to doctor
  Future<void> sendJoiningRequestToDoctor(
      {required String doctorId,
        required String doctorName,
  required MedicalCenterModel centerModel
      }) async {
    emit(SendToDoctorLoading());
     try{
       var uuid = Uuid();
       String requestId = uuid.v4();

       await FirebaseFirestore.instance.collection('users').doc(centerModel.adminId).collection('medical_centers').doc(centerModel.centerId).update(
           {
             'want_to_join':FieldValue.arrayUnion([doctorId]),
           });

       await FirebaseFirestore.instance.collection('users').doc(centerModel.adminId).collection('submittedRequests').doc(requestId).set(
           {
             'requestType':'joining',
             'adminName':centerModel.adminName,
             'doctorName':doctorName,
             'centerName':centerModel.name,
             'adminId':centerModel.adminId,
             'centerId':centerModel.centerId,
             'date':Timestamp.now(),
             'requestId':requestId,
             'adminImage':centerModel.adminImage,
             'doctorId':doctorId,
             'status': "waiting"
           });


       await FirebaseFirestore.instance.collection('users').doc(doctorId).collection('joining_requests').doc(requestId).set({
         'adminName':centerModel.adminName,
         'centerName':centerModel.name,
         'adminId':centerModel.adminId,
         'centerId':centerModel.centerId,
         'date':Timestamp.now(),
         'requestId':requestId,
         'adminImage':centerModel.adminImage,
       });
       
       
       emit(SendToDoctorSuccess());
     }catch(e){
       emit(SendToDoctorError(error: e.toString()));
     }
  }
}
