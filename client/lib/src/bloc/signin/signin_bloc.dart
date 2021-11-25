import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:music_room/src/data/repository/user_repository.dart';
import 'package:music_room/src/data/service/firebase_service.dart';

part 'signin_event.dart';
part 'signin_state.dart';

class SigninBloc extends Bloc<SigninEvent, SigninState> {
  final UserRepository userRepository;
  SigninBloc({required this.userRepository}) : super(SigninState());
  // @override
  // void onTransition(Transition<SigninEvent, SigninState> transition) {
  //   print(transition);
  //   super.onTransition(transition);
  // }

  @override
  Stream<SigninState> mapEventToState(
    SigninEvent event,
  ) async* {
    if (event is EmailFieldUpdate) {
      yield state.copyWith(
          email: event.email,
          buttonStatus: _checkButtonStatus(event.email, state.password));
    } else if (event is PasswordFieldUpdate) {
      yield state.copyWith(
          password: event.password,
          buttonStatus: _checkButtonStatus(state.email, event.password));
    } else if (event is SigninButtonPressed) {
      try {
        await _signinWithEmailAndPassword(state.email, state.password);
        yield state.copyWith(
          email: "",
          password: "",
          error: "successSigninWithEmail",
          status: true,
        );
      } on SigninFailure catch (e) {
        yield state.copyWith(status: false, error: e.message);
      } catch (e) {
        yield state.copyWith(status: false, error: 'Error happened, try again');
      }
    } else if (event is SigninWithGooglePressed) {
      try {
        await _signinWithGoogle();
        yield state.copyWith(
          status: true,
        );
      } on SignupFailure catch (e) {
        yield state.copyWith(status: false, error: e.message);
      } catch (e) {
        yield state.copyWith(status: false, error: 'Error happened, try again');
      }
    } else if (event is SigninWithFacebookPressed) {
      try {
        await _signinWithFacebook();
        yield state.copyWith(
          status: true,
        );
      } on SignupFailure catch (e) {
        yield state.copyWith(status: false, error: e.message);
      } catch (e) {
        yield state.copyWith(status: false, error: 'Error happened, try again');
      }
    } else if (event is StatusReset) {
      yield state.copyWith(status: false, error: "");
    } else if (event is ResendEmail) {
      try {
        await _resendConfirmationEmail(state.email);
        yield state.copyWith(status: false, error: "");
      } catch (e) {
        yield state.copyWith(status: false, error: "Server error, try again");
      }
    }
  }

  Future<void> _resendConfirmationEmail(String email) async {
    try {
      await userRepository.resendEmailVerificationAccount();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _signinWithEmailAndPassword(
      String email, String password) async {
    try {
      await userRepository.signinWithEmailAndPassword(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _signinWithGoogle() async {
    try {
      await userRepository.signupWithGoogle();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _signinWithFacebook() async {
    try {
      await userRepository.signupWithFacebook();
    } catch (e) {
      rethrow;
    }
  }

  bool _checkButtonStatus(String email, String password) {
    if (email.isNotEmpty && password.isNotEmpty) {
      return (true);
    }
    return (false);
  }
}
