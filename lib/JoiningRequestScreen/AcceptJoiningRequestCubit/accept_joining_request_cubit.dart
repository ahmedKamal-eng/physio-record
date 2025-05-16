import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physio_record/models/joining_reuest_model.dart';
import 'package:physio_record/models/medical_center_model.dart';
import '../../Cubits/GetUserDataCubit/get_user_data_cubit.dart';
import 'accept_joining_request_states.dart';

class AcceptJoiningRequestCubit extends Cubit<AcceptJoiningRequestState> {
  AcceptJoiningRequestCubit() : super(AcceptJoiningRequestInitial());

  Future<MedicalCenterModel> getCenter(JoiningRequestModel requestModel)async{
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(requestModel.adminId)
        .collection('medical_centers')
        .doc(requestModel.centerId)
        .get();

    MedicalCenterModel medicalCenterModel = MedicalCenterModel.fromJson(docSnapshot);
    return medicalCenterModel;
  }


  acceptJoiningRequest(JoiningRequestModel requestModel,BuildContext context)async{
    emit(AcceptJoiningRequestLoading());
    try{
      //remove doctor Id from want to join and update doctor count
      await FirebaseFirestore.instance.collection('users').doc(requestModel.adminId).collection('medical_centers').doc(requestModel.centerId).update(
          {"want_to_join":FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
            'doctorCount':FieldValue.increment(1),
          });

      //get centerModel
      MedicalCenterModel medicalCenterModel= await getCenter(requestModel);


      //add medical center collection inside user collection
      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('medical_centers').doc(requestModel.centerId).set(medicalCenterModel.toJson());

      //add doctor inside medical center collection inside admin collection

      await FirebaseFirestore.instance.collection('users').doc(requestModel.adminId).collection('medical_centers').doc(requestModel.centerId).collection('doctors').doc(FirebaseAuth.instance.currentUser!.uid).set(
          {'id':FirebaseAuth.instance.currentUser!.uid,
           'image':BlocProvider.of<GetUserDataCubit>(context).userModel!.imageUrl,
           'name':BlocProvider.of<GetUserDataCubit>(context).userModel!.userName,
            'medicalSpecialization':BlocProvider.of<GetUserDataCubit>(context).userModel!.medicalSpecialization,
          });
      emit(AcceptJoiningRequestSuccess());
    }catch(e){
      emit(AcceptJoiningRequestError(e.toString()));
    }
  }

}