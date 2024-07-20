import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:physio_record/AddFollowUpItem/AddFollowUpCubit/add_follow_up_states.dart';
import 'package:physio_record/models/patient_record.dart';


class AddFollowUpCubit extends Cubit<AddFollowUpState>{

  AddFollowUpCubit() : super(AddFollowUpInitial());

  Future<void> addFollowUpItem({required PatientRecord patientRecord, String? text,List<String>? imagePaths,List<String>? docPaths}) async {

    emit(AddFollowUpLoading());
    try {
      DateTime currentDate = DateTime.now();
      var formattedCurrentDate = DateFormat('hh:mm d-M-y').format(currentDate);


      patientRecord.followUpList.add(
          FollowUp(date: formattedCurrentDate,
              text: text ?? "",
              image: imagePaths,
              docPath: docPaths));
      patientRecord.save();
      emit(AddFollowUpSuccess());

    }catch(e){
      emit(AddFollowUpError(error: e.toString()));
    }
  }







}

