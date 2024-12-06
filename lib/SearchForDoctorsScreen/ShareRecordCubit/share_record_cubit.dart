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
      required List<String> doctorIds,
      required String receiverDoctorName,
      required String diagnosis,
      required bool isSharedBefore,
      required Timestamp recordDate

      }) async {

    emit(ShareRecordLoading());

   late String doctorName;
   late String doctorImage;
    try {
      final userDataCubit = BlocProvider.of<GetUserDataCubit>(context);
       doctorName = userDataCubit.userModel?.userName ?? 'Unknown Doctor';
       doctorImage = userDataCubit.userModel?.imageUrl ?? '';
    }catch(e)
    {
      print(e.toString()+"######## look at share_record_cubit");
    }

      try {
        var uuid = Uuid();
        String requestId = uuid.v8();


      await  FirebaseFirestore.instance
            .collection("users")
            .doc(receiverDoctorID)
            .collection('shareRequests')
            .doc(requestId)
            .set({
          "senderId": FirebaseAuth.instance.currentUser!.uid,
          'doctorIds':doctorIds,
          "recordId": recordId,
          "doctorsSharedThisRecord": isSharedBefore,
          "date": recordDate,
          "requestId": requestId,
          "patientName": patientName,
          "diagnosis": diagnosis,
          "doctorName":doctorName,
          "doctorImage":doctorImage,
        });

       await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('submittedRequests')
            .doc(requestId)
            .set({
          "senderId": FirebaseAuth.instance.currentUser!.uid,
          'recieverId':receiverDoctorID,
          "DoctorsSharedThisRecord": isSharedBefore,
          "recordId": recordId,
          "date": recordDate,
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
