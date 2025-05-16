

abstract class AddDoctorToCenterStates{}

class AddDoctorToCenterInitial extends AddDoctorToCenterStates{}


class AddDoctorToCenterLoading extends AddDoctorToCenterStates{}
class AddDoctorToCenterSuccess extends AddDoctorToCenterStates{}
class AddDoctorToCenterError extends AddDoctorToCenterStates{
  String error;
  AddDoctorToCenterError({required this.error});
}

class SendToDoctorLoading extends AddDoctorToCenterStates{}
class SendToDoctorSuccess extends AddDoctorToCenterStates{}
class SendToDoctorError extends AddDoctorToCenterStates{
  String error;
  SendToDoctorError({required this.error});
}