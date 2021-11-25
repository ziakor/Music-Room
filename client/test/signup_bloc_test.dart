import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';
import 'package:music_room/src/bloc/signup/signup_bloc.dart';
import 'package:music_room/src/data/service/firebase_service.dart';

import 'mocks/mock.dart';
import 'mocks/user_repository_mock.dart';

void main() {
  final MockUserRepository mockRepository = MockUserRepository();
  setupFirebaseAuthMocks();
  setUp(() {});
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('SignupBloc', () {
    test('initial value', () {
      final signupBloc = SignupBloc(repository: mockRepository);
      expect(signupBloc.state, SignupState());
    });
    group('pseudoChanged', () {
      blocTest<SignupBloc, SignupState>(
        'pseudo is not available.',
        build: () {
          when(mockRepository.checkPseudoAvailable("ziakor"))
              .thenAnswer((realInvocation) async => false);
          return SignupBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(PseudoChanged(pseudo: "ziakor")),
        expect: () => [
          SignupState(
              pseudo: "ziakor", buttonStatus: false, pseudoAvailable: false)
        ],
      );
      blocTest<SignupBloc, SignupState>(
        'pseudo is  available.',
        build: () {
          when(mockRepository.checkPseudoAvailable(argThat(isA<String>())))
              .thenAnswer((realInvocation) async => true);
          return SignupBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(PseudoChanged(pseudo: "ziakodr")),
        expect: () => [
          SignupState(
              pseudo: "ziakodr", buttonStatus: false, pseudoAvailable: true)
        ],
      );
      blocTest<SignupBloc, SignupState>(
        'throw an error',
        build: () {
          when(mockRepository.checkPseudoAvailable(argThat(isA<String>())))
              .thenThrow(ServerError());
          return SignupBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(PseudoChanged(pseudo: "ziakodr")),
        expect: () => [
          SignupState(
            buttonStatus: false,
            pseudo: "ziakodr",
            error: "Server error",
          )
        ],
      );
    });
    group('GenderChanged', () {
      blocTest<SignupBloc, SignupState>(
        'should update gender',
        build: () => SignupBloc(repository: mockRepository),
        act: (bloc) => bloc.add(GenderChanged(gender: "Woman")),
        expect: () => [SignupState(gender: "Woman", buttonStatus: false)],
      );
    });
    group('EmailChanged', () {
      blocTest<SignupBloc, SignupState>(
        'should update email',
        build: () => SignupBloc(repository: mockRepository),
        act: (bloc) => bloc.add(EmailChanged(email: "dimitrihauet@gmail.com")),
        expect: () =>
            [SignupState(email: "dimitrihauet@gmail.com", buttonStatus: false)],
      );
    });
    group('PasswordChanged', () {
      blocTest<SignupBloc, SignupState>(
        'should update password',
        build: () => SignupBloc(repository: mockRepository),
        act: (bloc) => bloc.add(PasswordChanged(password: "ZAazerty59")),
        expect: () =>
            [SignupState(password: "ZAazerty59", buttonStatus: false)],
      );
    });
    group('ConfirmPasswordChanged', () {
      blocTest<SignupBloc, SignupState>(
        'should update ConfirmPassword',
        build: () => SignupBloc(repository: mockRepository),
        act: (bloc) =>
            bloc.add(ConfirmPasswordChanged(confirmPassword: "ZAazerty59")),
        expect: () =>
            [SignupState(confirmPassword: "ZAazerty59", buttonStatus: false)],
      );
    });
    group('PasswordMatchChanged', () {
      blocTest<SignupBloc, SignupState>(
        'should update passwordMatch',
        build: () => SignupBloc(repository: mockRepository),
        act: (bloc) => bloc.add(PasswordMatchChanged(passwordMatch: true)),
        expect: () => [SignupState(passwordMatch: true, buttonStatus: false)],
      );
    });
    group('BirthChanged', () {
      blocTest<SignupBloc, SignupState>(
        'should update birth',
        build: () => SignupBloc(repository: mockRepository),
        act: (bloc) => bloc.add(BirthChanged(birth: DateTime(1980, 05, 04))),
        expect: () =>
            [SignupState(birth: DateTime(1980, 05, 04), buttonStatus: false)],
      );
    });
    group('ButtonStatus', () {
      blocTest<SignupBloc, SignupState>(
        'should return buttonstatus: true',
        build: () {
          when(mockRepository.checkPseudoAvailable(argThat(isA<String>())))
              .thenAnswer((realInvocation) async => true);
          return SignupBloc(repository: mockRepository);
        },
        seed: () => SignupState(
            email: "dimitrihauet@gmail.com",
            gender: "Man",
            pseudo: "ziakor",
            password: "ZAazerty59",
            confirmPassword: "ZAazerty59",
            passwordMatch: true,
            birth: DateTime(1980, 05, 04)),
        act: (bloc) => bloc.add(PseudoChanged(pseudo: "jesuisunsalsifi")),
        expect: () => [
          SignupState(
              email: "dimitrihauet@gmail.com",
              gender: "Man",
              pseudo: "jesuisunsalsifi",
              buttonStatus: true,
              pseudoAvailable: true,
              password: "ZAazerty59",
              confirmPassword: "ZAazerty59",
              passwordMatch: true,
              birth: DateTime(1980, 05, 04))
        ],
      );
    });
    group('FormSubmitted', () {
      blocTest<SignupBloc, SignupState>(
        'should create account with success',
        build: () {
          when(mockRepository.signupWithEmailAndPassword(
                  argThat(isA<String>()),
                  argThat(isA<String>()),
                  argThat(isA<String>()),
                  argThat(isA<String>()),
                  argThat(isA<DateTime>())))
              .thenAnswer((realInvocation) async => "uid");
          return SignupBloc(repository: mockRepository);
        },
        seed: () => SignupState(
            email: "dimitrihauet@gmail.com",
            gender: "Woman",
            pseudo: "jesuisunsalsifi",
            buttonStatus: true,
            pseudoAvailable: true,
            password: "ZAazerty59",
            confirmPassword: "ZAazerty59",
            passwordMatch: true,
            birth: DateTime(1980, 05, 04)),
        act: (bloc) => bloc.add(FormSubmitted()),
        expect: () => [
          SignupState(
            email: "",
            gender: "",
            pseudo: "",
            password: "",
            confirmPassword: "",
            passwordMatch: false,
            birth: DateTime(1980, 05, 04),
            buttonStatus: false,
            status: true,
            error: "",
            showPassword: false,
            pseudoAvailable: true,
          )
        ],
      );
      blocTest<SignupBloc, SignupState>(
        'should throw an error',
        build: () {
          when(mockRepository.signupWithEmailAndPassword(
                  argThat(isA<String>()),
                  argThat(isA<String>()),
                  argThat(isA<String>()),
                  argThat(isA<String>()),
                  argThat(isA<DateTime>())))
              .thenThrow(SignupFailure(message: "error"));

          return SignupBloc(repository: mockRepository);
        },
        seed: () => SignupState(
            email: "dimitrihauet@gmail.com",
            gender: "Man",
            pseudo: "jesuisunsalsifi",
            buttonStatus: true,
            pseudoAvailable: true,
            password: "ZAazerty59",
            confirmPassword: "ZAazerty59",
            passwordMatch: true,
            birth: DateTime(1980, 05, 04)),
        act: (bloc) => bloc.add(FormSubmitted()),
        expect: () => [
          SignupState(
              email: "dimitrihauet@gmail.com",
              gender: "Man",
              pseudo: "jesuisunsalsifi",
              buttonStatus: true,
              pseudoAvailable: true,
              password: "ZAazerty59",
              confirmPassword: "ZAazerty59",
              status: false,
              error: "error",
              passwordMatch: true,
              birth: DateTime(1980, 05, 04))
        ],
      );
    });

    group('signupWithFacebook', () {
      blocTest<SignupBloc, SignupState>(
        'should signup with success',
        build: () {
          when(mockRepository.signupWithFacebook())
              .thenAnswer((realInvocation) async => null);
          return SignupBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(signupWithFacebook()),
        expect: () => [SignupState(status: true)],
      );

      blocTest<SignupBloc, SignupState>(
        'should throw a signupfailure error',
        build: () {
          when(mockRepository.signupWithFacebook())
              .thenThrow(SignupFailure(message: "error"));
          return SignupBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(signupWithFacebook()),
        expect: () => [SignupState(status: false, error: "error")],
      );
      blocTest<SignupBloc, SignupState>(
        'should throw server_error',
        build: () {
          when(mockRepository.signupWithFacebook()).thenThrow(ServerError());
          return SignupBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(signupWithFacebook()),
        expect: () => [SignupState(status: false, error: "Server error")],
      );
    });
    group('signupWithGoogle', () {
      blocTest<SignupBloc, SignupState>(
        'should signup with success',
        build: () {
          when(mockRepository.signupWithGoogle())
              .thenAnswer((realInvocation) async => null);
          return SignupBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(signupWithGoogle()),
        expect: () => [SignupState(status: true)],
      );

      blocTest<SignupBloc, SignupState>(
        'should throw a signupfailure error',
        build: () {
          when(mockRepository.signupWithGoogle())
              .thenThrow(SignupFailure(message: "error"));
          return SignupBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(signupWithGoogle()),
        expect: () => [SignupState(status: false, error: "error")],
      );
      blocTest<SignupBloc, SignupState>(
        'should throw server_error',
        build: () {
          when(mockRepository.signupWithGoogle()).thenThrow(ServerError());
          return SignupBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(signupWithGoogle()),
        expect: () => [SignupState(status: false, error: "Server error")],
      );
    });

    group('SignupWithFortyTwo', () {});

    group('ErrorChanged', () {
      blocTest<SignupBloc, SignupState>(
        'emits [MyState] when MyEvent is added.',
        build: () => SignupBloc(repository: mockRepository),
        act: (bloc) =>
            bloc.add(ErrorChanged(error: "ceci est une erreur", status: false)),
        expect: () =>
            [SignupState(error: "ceci est une erreur", status: false)],
      );
    });

    group('showPassworChanged', () {
      blocTest<SignupBloc, SignupState>(
        'emits [MyState] when MyEvent is added.',
        build: () => SignupBloc(repository: mockRepository),
        act: (bloc) => bloc.add(ShowPasswordChanged(showPassword: true)),
        expect: () => [SignupState(showPassword: true)],
      );
    });
  });
}
