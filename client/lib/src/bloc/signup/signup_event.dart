part of 'signup_bloc.dart';

@immutable
abstract class SignupEvent {
  const SignupEvent();
}

class PseudoChanged extends SignupEvent {
  const PseudoChanged({required this.pseudo});

  final String pseudo;
}

class EmailChanged extends SignupEvent {
  const EmailChanged({required this.email});

  final String email;
}

class GenderChanged extends SignupEvent {
  const GenderChanged({required this.gender});

  final String gender;
}

class PasswordChanged extends SignupEvent {
  const PasswordChanged({required this.password});

  final String password;
}

class ConfirmPasswordChanged extends SignupEvent {
  const ConfirmPasswordChanged({required this.confirmPassword});
  final String confirmPassword;
}

class PasswordMatchChanged extends SignupEvent {
  const PasswordMatchChanged({required this.passwordMatch});
  final bool passwordMatch;
}

class BirthChanged extends SignupEvent {
  const BirthChanged({required this.birth});
  final DateTime birth;
}

class ErrorChanged extends SignupEvent {
  final String error;
  final bool status;

  const ErrorChanged({required this.error, required this.status});
}

class ShowPasswordChanged extends SignupEvent {
  final bool showPassword;

  const ShowPasswordChanged({required this.showPassword});
}

class signupWithGoogle extends SignupEvent {
  const signupWithGoogle();
}

class signupWithFacebook extends SignupEvent {
  const signupWithFacebook();
}

class SignupWithFortyTwo extends SignupEvent {}

class FormSubmitted extends SignupEvent {
  const FormSubmitted();
}
