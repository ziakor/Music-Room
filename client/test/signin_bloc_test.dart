import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:music_room/src/bloc/signin/signin_bloc.dart';
import 'package:music_room/src/data/service/firebase_service.dart';

import 'mocks/mock.dart';
import 'mocks/user_repository_mock.dart';

// @GenerateMocks([Repository])
void main() {
  final MockUserRepository mockRepository = MockUserRepository();

  group('SigninBloc', () {
    test('initial value', () {
      final signinBloc = SigninBloc(userRepository: mockRepository);
      expect(signinBloc.state, SigninState());
    });

    group('EmailFieldUpdate', () {
      blocTest<SigninBloc, SigninState>(
        'should update email field.',
        build: () => SigninBloc(userRepository: mockRepository),
        act: (bloc) => bloc.add(EmailFieldUpdate("dimitrihauet@gmail.com")),
        expect: () =>
            [SigninState(email: "dimitrihauet@gmail.com", buttonStatus: false)],
      );
      blocTest<SigninBloc, SigninState>(
        'should update email field and set buttonStatus to true.',
        build: () => SigninBloc(userRepository: mockRepository),
        seed: () => SigninState(password: "ZAazerty59@"),
        act: (bloc) => bloc.add(EmailFieldUpdate("dimitrihauet@gmail.com")),
        expect: () => [
          SigninState(
              email: "dimitrihauet@gmail.com",
              password: "ZAazerty59@",
              buttonStatus: true)
        ],
      );
    });
    group('PasswordFieldUpdate', () {
      blocTest<SigninBloc, SigninState>(
        'should update email field.',
        build: () => SigninBloc(userRepository: mockRepository),
        act: (bloc) => bloc.add(PasswordFieldUpdate("ZAazerty59@")),
        expect: () =>
            [SigninState(password: "ZAazerty59@", buttonStatus: false)],
      );
      blocTest<SigninBloc, SigninState>(
        'should update password field and set buttonStatus to true.',
        build: () => SigninBloc(userRepository: mockRepository),
        seed: () => SigninState(email: "dimitrihauet@gmail.com"),
        act: (bloc) => bloc.add(PasswordFieldUpdate("ZAazerty59@")),
        expect: () => [
          SigninState(
              email: "dimitrihauet@gmail.com",
              password: "ZAazerty59@",
              buttonStatus: true)
        ],
      );
    });
    group('SigninButtonPressed', () {
      blocTest<SigninBloc, SigninState>(
        'should signin with success',
        build: () {
          when(mockRepository.signinWithEmailAndPassword(
                  "dimitrihauet@gmail.com", "ZAazerty59@"))
              .thenAnswer((realInvocation) async => null);
          return (SigninBloc(userRepository: mockRepository));
        },
        seed: () => SigninState(
            email: "dimitrihauet@gmail.com",
            password: "ZAazerty59@",
            buttonStatus: true),
        act: (bloc) => bloc.add(SigninButtonPressed()),
        expect: () => [
          SigninState(
              email: "",
              password: "",
              buttonStatus: true,
              error: "",
              status: true)
        ],
      );
      blocTest<SigninBloc, SigninState>(
        'should throw a SigninFailure error',
        build: () {
          when(mockRepository.signinWithEmailAndPassword(
                  "dimitrihauet@gmail.com", "ZAazerty59@"))
              .thenThrow(SigninFailure("No user found for that email."));
          return (SigninBloc(userRepository: mockRepository));
        },
        seed: () => SigninState(
            email: "dimitrihauet@gmail.com",
            password: "ZAazerty59@",
            buttonStatus: true),
        act: (bloc) => bloc.add(SigninButtonPressed()),
        expect: () => [
          SigninState(
              email: "dimitrihauet@gmail.com",
              password: "ZAazerty59@",
              buttonStatus: true,
              error: "No user found for that email.",
              status: false)
        ],
      );
      blocTest<SigninBloc, SigninState>(
        'should throw a Server error',
        build: () {
          when(mockRepository.signinWithEmailAndPassword(
                  "dimitrihauet@gmail.com", "ZAazerty59@"))
              .thenThrow(ServerError());
          return (SigninBloc(userRepository: mockRepository));
        },
        seed: () => SigninState(
            email: "dimitrihauet@gmail.com",
            password: "ZAazerty59@",
            buttonStatus: true),
        act: (bloc) => bloc.add(SigninButtonPressed()),
        expect: () => [
          SigninState(
              email: "dimitrihauet@gmail.com",
              password: "ZAazerty59@",
              buttonStatus: true,
              error: "Error happened, try again",
              status: false)
        ],
      );
    });
    group('SigninWithGooglePressed', () {
      blocTest<SigninBloc, SigninState>(
        'should signin with success',
        build: () {
          when(mockRepository.signupWithGoogle())
              .thenAnswer((realInvocation) async => null);
          return (SigninBloc(userRepository: mockRepository));
        },
        act: (bloc) => bloc.add(SigninWithGooglePressed()),
        expect: () => [
          SigninState(
              email: "",
              password: "",
              buttonStatus: false,
              error: "",
              status: true)
        ],
      );
      blocTest<SigninBloc, SigninState>(
        'should throw a Signup error',
        build: () {
          when(mockRepository.signupWithGoogle())
              .thenThrow(SignupFailure(message: 'Error happened, try again'));
          return (SigninBloc(userRepository: mockRepository));
        },
        act: (bloc) => bloc.add(SigninWithGooglePressed()),
        expect: () => [
          SigninState(
              email: "",
              password: "",
              buttonStatus: false,
              error: 'Error happened, try again',
              status: false)
        ],
      );
      blocTest<SigninBloc, SigninState>(
        'should throw a server error',
        build: () {
          when(mockRepository.signupWithGoogle())
              .thenThrow(ServerError(message: 'Error happened, try again'));
          return (SigninBloc(userRepository: mockRepository));
        },
        act: (bloc) => bloc.add(SigninWithGooglePressed()),
        expect: () => [
          SigninState(
              email: "",
              password: "",
              buttonStatus: false,
              error: 'Error happened, try again',
              status: false)
        ],
      );
    });

    group('SigninWithFacebookPressed', () {
      blocTest<SigninBloc, SigninState>(
        'should signin with success',
        build: () {
          when(mockRepository.signupWithFacebook())
              .thenAnswer((realInvocation) async => null);
          return (SigninBloc(userRepository: mockRepository));
        },
        act: (bloc) => bloc.add(SigninWithFacebookPressed()),
        expect: () => [
          SigninState(
              email: "",
              password: "",
              buttonStatus: false,
              error: "",
              status: true)
        ],
      );
      blocTest<SigninBloc, SigninState>(
        'should throw a Signup error',
        build: () {
          when(mockRepository.signupWithFacebook())
              .thenThrow(SignupFailure(message: 'Error happened, try again'));
          return (SigninBloc(userRepository: mockRepository));
        },
        act: (bloc) => bloc.add(SigninWithFacebookPressed()),
        expect: () => [
          SigninState(
              email: "",
              password: "",
              buttonStatus: false,
              error: 'Error happened, try again',
              status: false)
        ],
      );
      blocTest<SigninBloc, SigninState>(
        'should throw a server error',
        build: () {
          when(mockRepository.signupWithFacebook())
              .thenThrow(ServerError(message: 'Error happened, try again'));
          return (SigninBloc(userRepository: mockRepository));
        },
        act: (bloc) => bloc.add(SigninWithFacebookPressed()),
        expect: () => [
          SigninState(
              email: "",
              password: "",
              buttonStatus: false,
              error: 'Error happened, try again',
              status: false)
        ],
      );
    });

    group('StatusReset', () {
      blocTest<SigninBloc, SigninState>(
        'should set status to false and error to empty',
        build: () => SigninBloc(userRepository: mockRepository),
        seed: () => SigninState(status: true, error: "Server error"),
        act: (bloc) => bloc.add(StatusReset()),
        expect: () => [SigninState(status: false, error: "")],
      );
    });

    group('ResendEmail', () {
      blocTest<SigninBloc, SigninState>(
        'should send email with success',
        build: () {
          when(mockRepository.resendEmailVerificationAccount())
              .thenAnswer((realInvocation) async => null);
          return (SigninBloc(userRepository: mockRepository));
        },
        act: (bloc) => bloc.add(ResendEmail()),
        expect: () => [SigninState(status: false, error: "")],
      );

      blocTest<SigninBloc, SigninState>(
        'should throw an error',
        build: () {
          when(mockRepository.resendEmailVerificationAccount())
              .thenThrow(ServerError());
          return (SigninBloc(userRepository: mockRepository));
        },
        act: (bloc) => bloc.add(ResendEmail()),
        expect: () =>
            [SigninState(status: false, error: "Server error, try again")],
      );
    });
  });
}
