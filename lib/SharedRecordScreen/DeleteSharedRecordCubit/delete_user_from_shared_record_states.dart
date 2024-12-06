

abstract class DeleteUserFromSharedRecordState{}

class DeleteSharedRecordInitial extends DeleteUserFromSharedRecordState{}

class DeleteSharedRecordLoading extends DeleteUserFromSharedRecordState{}
class DeleteSharedRecordSuccess extends DeleteUserFromSharedRecordState{}
class DeleteSharedRecordError extends DeleteUserFromSharedRecordState{
  String error;
  DeleteSharedRecordError({required this.error});
}