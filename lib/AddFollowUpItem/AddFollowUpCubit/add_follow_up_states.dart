
abstract class AddFollowUpState{}

class AddFollowUpInitial extends AddFollowUpState{}

class AddFollowUpLoading extends AddFollowUpState{}
class AddFollowUpSuccess extends AddFollowUpState{}
class AddFollowUpError extends AddFollowUpState{
  final String error ;
  AddFollowUpError({required this.error});
}