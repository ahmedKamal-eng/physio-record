

abstract class EditRecordState{}

class EditRecordInitial extends EditRecordState{}

// edit name states
class EditNameLoading extends EditRecordState{}
class EditNameSuccess extends EditRecordState{}
class EditNameError extends EditRecordState{
  final String error ;
  EditNameError({required this.error});
}

// edit diagnosis states
class EditDiagnosisLoading extends EditRecordState{}
class EditDiagnosisSuccess extends EditRecordState{}
class EditDiagnosisError extends EditRecordState{
  final String error ;
  EditDiagnosisError({required this.error});
}

// edit MC states
class EditMCLoading extends EditRecordState{}
class EditMCSuccess extends EditRecordState{}
class EditMCError extends EditRecordState{
  final String error ;
  EditMCError({required this.error});
}

// edit Program states
class EditProgramLoading extends EditRecordState{}
class EditProgramSuccess extends EditRecordState{}
class EditProgramError extends EditRecordState{
  final String error ;
  EditProgramError({required this.error});
}
