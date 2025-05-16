

abstract class DeleteRecordState{}

class DeleteRecordInitial extends DeleteRecordState{}

class DeleteRecordLoading extends DeleteRecordState{}
class DeleteRecordSuccess extends DeleteRecordState{}
class DeleteRecordError extends DeleteRecordState{
  final String error ;
  DeleteRecordError({required this.error});
}
