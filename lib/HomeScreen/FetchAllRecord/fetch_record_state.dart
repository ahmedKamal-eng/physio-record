

abstract class FetchRecordState{}

class FetchRecordInitial extends FetchRecordState{}

class FetchRecordLoading extends FetchRecordState{}
class FetchRecordSuccess extends FetchRecordState{}
class FetchRecordError extends FetchRecordState{
  final String error ;
  FetchRecordError({required this.error});
}