part of 'signin_bloc.dart';

@immutable
abstract class SigninEvent {
  const SigninEvent();
}

class SigninButtonPressed extends SigninEvent {
  const SigninButtonPressed();
}

class SigninWithGooglePressed extends SigninEvent {
  const SigninWithGooglePressed();
}

class SigninWithFacebookPressed extends SigninEvent {
  const SigninWithFacebookPressed();
}

class EmailFieldUpdate extends SigninEvent {
  const EmailFieldUpdate(this.email);
  final String email;
}

class PasswordFieldUpdate extends SigninEvent {
  const PasswordFieldUpdate(this.password);
  final String password;
}

class StatusReset extends SigninEvent {
  const StatusReset();
}

class ResendEmail extends SigninEvent {
  const ResendEmail();
}
