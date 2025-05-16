
abstract class AcceptJoiningRequestState{}

class AcceptJoiningRequestInitial extends AcceptJoiningRequestState{}

class AcceptJoiningRequestLoading extends AcceptJoiningRequestState{}
class AcceptJoiningRequestSuccess extends AcceptJoiningRequestState{}
class AcceptJoiningRequestError extends AcceptJoiningRequestState{
  final  String error;
  AcceptJoiningRequestError(this.error);
}