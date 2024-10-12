

abstract class AcceptRequestState{}

class AcceptRequestInitial extends AcceptRequestState{}

class AcceptRequestLoading extends AcceptRequestState{}
class AcceptRequestSuccess extends AcceptRequestState{}
class AcceptRequestError extends AcceptRequestState{
 final  String error;

AcceptRequestError(this.error);
}