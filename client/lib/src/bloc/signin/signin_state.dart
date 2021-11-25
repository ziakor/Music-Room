part of 'signin_bloc.dart';

class SigninState extends Equatable {
  final String email;
  final String password;
  final bool buttonStatus;
  final String error;
  final bool status;
  const SigninState({
    this.email = "",
    this.password = "",
    this.buttonStatus = false,
    this.error = "",
    this.status = false,
  });

  SigninState copyWith({
    String? email,
    String? password,
    bool? buttonStatus,
    String? error,
    bool? status,
  }) {
    return (SigninState(
      email: email ?? this.email,
      password: password ?? this.password,
      buttonStatus: buttonStatus ?? this.buttonStatus,
      error: error ?? this.error,
      status: status ?? this.status,
    ));
  }

  @override
  List<Object> get props => [email, password, buttonStatus, error, status];
}
