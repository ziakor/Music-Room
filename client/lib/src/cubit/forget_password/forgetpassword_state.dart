part of 'forgetpassword_cubit.dart';

@immutable
abstract class ForgetPasswordState extends Equatable {}

class ForgetPasswordInitial extends ForgetPasswordState {
  @override
  List<Object?> get props => [];
}

class ForgetPasswordSendCodeMail extends ForgetPasswordState {
  final bool status;
  final String error;
  ForgetPasswordSendCodeMail(this.status, this.error);

  @override
  List<Object?> get props => [status, error];
}

class ForgetPasswordUpdateWithCode extends ForgetPasswordState {
  final bool status;
  final String error;

  ForgetPasswordUpdateWithCode(this.status, this.error);
  @override
  List<Object?> get props => [error];
}

class ForgetPasswordError extends ForgetPasswordState {
  final String error;

  ForgetPasswordError(this.error);
  @override
  List<Object?> get props => [error];
}
