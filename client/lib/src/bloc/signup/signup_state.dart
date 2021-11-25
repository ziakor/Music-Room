part of 'signup_bloc.dart';

class SignupState extends Equatable {
  final String email;
  final String pseudo;
  final String password;
  final String confirmPassword;
  final bool passwordMatch;
  final String gender;
  final DateTime? birth;
  final bool buttonStatus;
  final bool status;
  final String error;
  final bool showPassword;
  final bool? pseudoAvailable;

  const SignupState({
    this.gender = "",
    this.email = "",
    this.pseudo = "",
    this.password = "",
    this.confirmPassword = "",
    this.passwordMatch = false,
    this.birth,
    this.buttonStatus = false,
    this.status = false,
    this.error = "",
    this.showPassword = false,
    this.pseudoAvailable,
  });

  SignupState copyWith({
    bool? buttonStatus,
    String? gender,
    String? email,
    String? pseudo,
    String? password,
    bool? passwordMatch,
    String? confirmPassword,
    DateTime? birth,
    bool? status,
    String? error,
    bool? showPassword,
    bool? pseudoAvailable,
  }) {
    return SignupState(
      email: email ?? this.email,
      gender: gender ?? this.gender,
      pseudo: pseudo ?? this.pseudo,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      passwordMatch: passwordMatch ?? this.passwordMatch,
      birth: birth ?? this.birth,
      buttonStatus: buttonStatus ?? this.buttonStatus,
      status: status ?? this.status,
      error: error ?? this.error,
      showPassword: showPassword ?? this.showPassword,
      pseudoAvailable: pseudoAvailable ?? this.pseudoAvailable,
    );
  }

  @override
  List<Object?> get props => [
        email,
        gender,
        pseudo,
        password,
        confirmPassword,
        passwordMatch,
        birth,
        buttonStatus,
        status,
        error,
        showPassword,
        pseudoAvailable,
      ];
}
