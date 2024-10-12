

abstract class ShareRecordState{}

class ShareRecordInitial extends ShareRecordState{}


class ShareRecordLoading extends ShareRecordState{}
class ShareRecordSuccess extends ShareRecordState{}
class ShareRecordError extends ShareRecordState{
  String error;
  ShareRecordError({required this.error});
}