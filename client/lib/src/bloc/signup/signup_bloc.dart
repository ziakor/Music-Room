import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:music_room/src/data/repository/user_repository.dart';
import 'package:music_room/src/data/service/firebase_service.dart';
import 'package:music_room/src/mixins/validation_mixins.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final UserRepository repository;

  SignupBloc({required this.repository}) : super(SignupState());

  @override
  Stream<SignupState> mapEventToState(
    SignupEvent event,
  ) async* {
    if (event is GenderChanged) {
      yield state.copyWith(
        buttonStatus: _checkButtonStatus(gender: event.gender),
        gender: event.gender,
      );
    } else if (event is PseudoChanged) {
      try {
        final res = await _checkPseudoAvailable(event.pseudo);
        yield state.copyWith(
          pseudoAvailable: res,
          buttonStatus: _checkButtonStatus(pseudo: event.pseudo),
          pseudo: event.pseudo,
        );
      } catch (e) {
        yield state.copyWith(
          buttonStatus: false,
          pseudo: event.pseudo,
          error: "Server error",
        );
      }
    } else if (event is EmailChanged) {
      yield state.copyWith(
        buttonStatus: _checkButtonStatus(email: event.email),
        email: event.email,
      );
    } else if (event is PasswordChanged) {
      yield state.copyWith(
        buttonStatus: _checkButtonStatus(password: event.password),
        password: event.password,
      );
    } else if (event is ConfirmPasswordChanged) {
      yield state.copyWith(
        buttonStatus:
            _checkButtonStatus(confirmPassword: event.confirmPassword),
        confirmPassword: event.confirmPassword,
      );
    } else if (event is PasswordMatchChanged) {
      yield state.copyWith(
        buttonStatus: _checkButtonStatus(passwordMatch: event.passwordMatch),
        passwordMatch: event.passwordMatch,
      );
    } else if (event is BirthChanged) {
      yield state.copyWith(
        buttonStatus: _checkButtonStatus(birth: event.birth),
        birth: event.birth,
      );
    } else if (event is FormSubmitted) {
      try {
        await _signupWithEmailAndPassword();
        yield state.copyWith(
          email: "",
          gender: "",
          pseudo: "",
          password: "",
          confirmPassword: "",
          passwordMatch: false,
          birth: null,
          buttonStatus: false,
          status: true,
          error: "",
          showPassword: false,
          pseudoAvailable: true,
        );
      } on SignupFailure catch (e) {
        yield state.copyWith(status: false, error: e.message);
      }
    } else if (event is ErrorChanged) {
      yield state.copyWith(status: event.status, error: event.error);
    } else if (event is ShowPasswordChanged) {
      yield state.copyWith(showPassword: event.showPassword);
    } else if (event is signupWithGoogle) {
      try {
        await _signupWithGoogle();
        yield state.copyWith(status: true);
      } on SignupFailure catch (e) {
        yield state.copyWith(status: false, error: e.message);
      } catch (e) {
        yield state.copyWith(status: false, error: "Server error");
      }
    } else if (event is signupWithFacebook) {
      try {
        await _signupWithFacebook();
        yield state.copyWith(status: true);
      } on SignupFailure catch (e) {
        yield state.copyWith(status: false, error: e.message);
      } catch (e) {
        yield state.copyWith(status: false, error: "Server error");
      }
    }
  }

  bool _checkButtonStatus({
    String? email,
    String? gender,
    String? pseudo,
    String? password,
    String? confirmPassword,
    bool? passwordMatch,
    DateTime? birth,
  }) {
    if ((pseudo ?? state.pseudo).isNotEmpty &&
        (email ?? state.email).isNotEmpty &&
        (password ?? state.password).isNotEmpty &&
        (confirmPassword ?? state.confirmPassword).isNotEmpty &&
        (passwordMatch ?? state.passwordMatch) == true &&
        (gender ?? state.gender).isNotEmpty &&
        (birth ?? state.birth) != null) {
      return (true);
    }
    return (false);
  }

  Future<void> _signupWithGoogle() async {
    try {
      await repository.signupWithGoogle();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _signupWithFacebook() async {
    try {
      await repository.signupWithFacebook();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _signupWithEmailAndPassword() async {
    try {
      await repository.signupWithEmailAndPassword(state.email, state.password,
          state.pseudo, state.gender, state.birth!);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> _checkPseudoAvailable(String pseudo) async {
    try {
      if (!ValidationMixin().validatePseudo(pseudo)) return false;
      return (await repository.checkPseudoAvailable(pseudo));
    } catch (e) {
      rethrow;
    }
  }
}
