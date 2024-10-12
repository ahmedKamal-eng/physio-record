import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:physio_record/SearchForDoctorsScreen/ShareRecordCubit/share_record_state.dart';
import 'package:uuid/uuid.dart';

import '../../Cubits/GetUserDataCubit/get_user_data_cubit.dart';

class ShareRecordCubit extends Cubit<ShareRecordState> {
  ShareRecordCubit() : super(ShareRecordInitial());

  Future<void> shareRecord(
      {

      required String recordId,
      required context,
      required String patientName,
      required String receiverDoctorID,
      required String receiverDoctorName,
      required String diagnosis,

      }) async {
    emit(ShareRecordLoading());

    try {
      var uuid = Uuid();
      String requestId = uuid.v8();
      Timestamp currentDate = Timestamp.now();

      FirebaseFirestore.instance
          .collection("users")
          .doc(receiverDoctorID)
          .collection('shareRequests')
          .doc(requestId)
          .set({
        "senderId": FirebaseAuth.instance.currentUser!.uid,
        'doctorIds':[FirebaseAuth.instance.currentUser!.uid],
        "recordId": recordId,
        "doctorsSharedThisRecord": false,
        "date": currentDate,
        "requestId": requestId,
        "patientName": patientName,
        "diagnosis": diagnosis,
        "doctorName":
            BlocProvider.of<GetUserDataCubit>(context).userModel!.userName,
        "doctorImage":
            BlocProvider.of<GetUserDataCubit>(context).userModel!.imageUrl,
      });

      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('submittedRequests')
          .doc(requestId)
          .set({
        "senderId": FirebaseAuth.instance.currentUser!.uid,
        'recieverId':receiverDoctorID,
        "DoctorsSharedThisRecord": false,
        "recordId": recordId,
        "date": currentDate,
        "requestId": requestId,
        "patientName": patientName,
        "diagnosis": diagnosis,
        'status': "waiting",
        "doctorName":
           receiverDoctorName
      });

      emit(ShareRecordSuccess());
    } catch (e) {
      emit(ShareRecordError(error: e.toString()));
      print(e.toString() + "^^^^^^^^^^^^^^^^^^^^^^^");
    }
  }
}
