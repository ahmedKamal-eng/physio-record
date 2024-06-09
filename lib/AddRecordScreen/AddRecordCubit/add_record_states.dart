
abstract class AddRecordState{}

class AddRecordInitial extends AddRecordState{}

class AddRecordLoading extends AddRecordState{}
class AddRecordSuccess extends AddRecordState{}
class AddRecordError extends AddRecordState{
  final String error ;
  AddRecordError({required this.error});
}