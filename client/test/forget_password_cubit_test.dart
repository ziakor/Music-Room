import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:music_room/src/cubit/forget_password/forgetpassword_cubit.dart';
import 'package:music_room/src/data/repository/user_repository.dart';
import 'package:music_room/src/data/service/api_service.dart';
import 'package:music_room/src/data/service/firebase_service.dart';

import 'mocks/user_repository_mock.dart';

// @GenerateMocks([UserRepository])
void main() {
  final MockUserRepository mockRepository = MockUserRepository();

  group('ForgetPasswordCubit', () {
    test('initialState', () {
      final forgetPasswordCubit = ForgetPasswordCubit(mockRepository);
      expect(forgetPasswordCubit.state, ForgetPasswordInitial());
    });
    blocTest<ForgetPasswordCubit, ForgetPasswordState>(
      'initialState should return nothing',
      build: () => ForgetPasswordCubit(mockRepository),
      // act: (bloc) => bloc.add(MyEvent),
      expect: () => [],
    );
    group('sendEmailCode', () {
      blocTest<ForgetPasswordCubit, ForgetPasswordState>(
        'should return normally',
        build: () {
          when(mockRepository.resetPasswordCode("dimitrihauet@gmail.com"))
              .thenAnswer((realInvocation) async => null);
          return (ForgetPasswordCubit(mockRepository));
        },
        act: (cubit) => cubit.sendEmailCode("dimitrihauet@gmail.com"),
        expect: () => [ForgetPasswordSendCodeMail(true, "")],
      );
      blocTest<ForgetPasswordCubit, ForgetPasswordState>(
        'should  catch an ApiServerError and throw ForgetPasswordError',
        build: () {
          when(mockRepository.resetPasswordCode("dimitrihauet@gmail.com"))
              .thenThrow(ApiServerError("Server error"));
          return (ForgetPasswordCubit(mockRepository));
        },
        act: (cubit) => cubit.sendEmailCode("dimitrihauet@gmail.com"),
        expect: () => [ForgetPasswordError("Server error")],
      );

      blocTest<ForgetPasswordCubit, ForgetPasswordState>(
        'should  catch and throw ForgetPasswordError',
        build: () {
          when(mockRepository.resetPasswordCode("dimitrihauet@gmail.com"))
              .thenThrow(ServerError());

          return (ForgetPasswordCubit(mockRepository));
        },
        act: (cubit) => cubit.sendEmailCode("dimitrihauet@gmail.com"),
        expect: () => [ForgetPasswordError("Internal server error")],
      );
    });
    group('updatePasswordWithCode', () {
      final email = "dimitrihauet@gmail.com";
      final code = "d4fg56sdf";
      final password = "ZAazerty59@";
      blocTest<ForgetPasswordCubit, ForgetPasswordState>(
        'should return normally',
        build: () {
          when(mockRepository.resetPassword(email, password, code))
              .thenAnswer((realInvocation) async => null);
          return (ForgetPasswordCubit(mockRepository));
        },
        act: (cubit) => cubit.updatePasswordWithCode(code, password, email),
        expect: () => [ForgetPasswordUpdateWithCode(true, "")],
      );
      blocTest<ForgetPasswordCubit, ForgetPasswordState>(
        'should  catch an ApiServerError and throw ForgetPasswordError',
        build: () {
          when(mockRepository.resetPassword(email, password, code))
              .thenThrow(ApiServerError("Server error"));
          return (ForgetPasswordCubit(mockRepository));
        },
        act: (cubit) => cubit.updatePasswordWithCode(code, password, email),
        expect: () => [ForgetPasswordError("Server error")],
      );

      blocTest<ForgetPasswordCubit, ForgetPasswordState>(
        'should  catch and throw ForgetPasswordError',
        build: () {
          when(mockRepository.resetPassword(email, password, code))
              .thenThrow(ServerError());

          return (ForgetPasswordCubit(mockRepository));
        },
        act: (cubit) => cubit.updatePasswordWithCode(code, password, email),
        expect: () => [ForgetPasswordError("Internal server error")],
      );
    });
  });
}
