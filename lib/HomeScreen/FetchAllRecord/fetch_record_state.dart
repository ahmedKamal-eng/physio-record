

abstract class FetchRecordState{}

class FetchRecordInitial extends FetchRecordState{}

class FetchRecordLoading extends FetchRecordState{}
class FetchRecordSuccess extends FetchRecordState{}
class FetchRecordError extends FetchRecordState{
  final String error ;
  FetchRecordError({required this.error});
}

class FilterRecordsLoading extends FetchRecordState{}
class FilterRecordsSuccess extends FetchRecordState{}
class FilterRecordsError extends FetchRecordState{
  final String error ;
  FilterRecordsError({required this.error});
}


class ClearFilter extends FetchRecordState{}