import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:music_room/src/bloc/settings/settings_bloc.dart';
import 'package:music_room/src/data/model/return_repository.dart';
import 'package:music_room/src/data/service/firebase_service.dart';

import 'mocks/user_repository_mock.dart';

void main() {
  group('SettingsBloc', () {
    final MockUserRepository mockRepository = MockUserRepository();
    SettingsBloc settingsBloc = SettingsBloc(userRepository: mockRepository);

    setUp(() => {settingsBloc = SettingsBloc(userRepository: mockRepository)});
    test('initialValue', () {
      expect(settingsBloc.state, SettingsState());
    });

    group('UpdatePseudo', () {
      blocTest<SettingsBloc, SettingsState>(
        'should update pseudo and pseudo is available',
        build: () {
          when(mockRepository.checkPseudoAvailable(any))
              .thenAnswer((realInvocation) async => true);
          return (settingsBloc);
        },
        act: (bloc) => bloc.add(UpdatePseudo(pseudo: "testPseudo")),
        expect: () => [
          SettingsState(
              pseudo: "testPseudo", pseudoAvailable: true, buttonStatus: true)
        ],
      );

      blocTest<SettingsBloc, SettingsState>(
        'should set pseudo to empty because pseudo is not available',
        build: () {
          when(mockRepository.checkPseudoAvailable(any))
              .thenAnswer((realInvocation) async => false);
          return (settingsBloc);
        },
        act: (bloc) => bloc.add(UpdatePseudo(pseudo: "testPseudo")),
        expect: () => [
          SettingsState(pseudo: "", pseudoAvailable: false, buttonStatus: false)
        ],
      );

      blocTest<SettingsBloc, SettingsState>(
        'should throw an error',
        build: () {
          when(mockRepository.checkPseudoAvailable(any))
              .thenThrow(ServerError());
          return (settingsBloc);
        },
        act: (bloc) => bloc.add(UpdatePseudo(pseudo: "testPseudo")),
        expect: () => [
          SettingsState(
              pseudo: "",
              pseudoAvailable: false,
              buttonStatus: false,
              error: "Server error, try again.")
        ],
      );
    });

    blocTest<SettingsBloc, SettingsState>(
      'should update mail',
      build: () => settingsBloc,
      act: (bloc) => bloc.add(UpdateEmail(email: "test@gmail.com")),
      expect: () =>
          [SettingsState(email: "test@gmail.com", buttonStatus: true)],
    );

    blocTest<SettingsBloc, SettingsState>(
      'should update current password',
      build: () => settingsBloc,
      act: (bloc) =>
          bloc.add(UpdateCurrentPassword(currentPassword: "Qwerty4242@")),
      expect: () => [
        SettingsState(
          currentPassword: "Qwerty4242@",
        )
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'should update current password',
      build: () => settingsBloc,
      act: (bloc) =>
          bloc.add(UpdateMusicalInterests(musicalInterests: ['Rap', 'Pop'])),
      expect: () => [
        SettingsState(
          musicalInterests: ['Rap', 'Pop'],
          buttonStatus: true,
        )
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'should update new password',
      build: () => settingsBloc,
      act: (bloc) => bloc.add(UpdateNewPassword(newPassword: "Qwerty4242@")),
      expect: () =>
          [SettingsState(newPassword: "Qwerty4242@", buttonStatus: true)],
    );

    blocTest<SettingsBloc, SettingsState>(
      'should update bio',
      build: () => settingsBloc,
      act: (bloc) => bloc.add(UpdateBio(bio: "This is a bio test")),
      expect: () =>
          [SettingsState(bio: "This is a bio test", buttonStatus: true)],
    );

    blocTest<SettingsBloc, SettingsState>(
      'should update gender',
      build: () => settingsBloc,
      act: (bloc) => bloc.add(UpdateGender(gender: "Man")),
      expect: () => [SettingsState(gender: "Man", buttonStatus: true)],
    );

    blocTest<SettingsBloc, SettingsState>(
      'should update Birth',
      build: () => settingsBloc,
      act: (bloc) => bloc.add(UpdateBirth(birth: DateTime(1980, 05, 04))),
      expect: () =>
          [SettingsState(birth: DateTime(1980, 05, 04), buttonStatus: true)],
    );

    blocTest<SettingsBloc, SettingsState>(
      'should update Error',
      build: () => settingsBloc,
      seed: () => SettingsState(error: "this is an error"),
      act: (bloc) => bloc.add(UpdateError(error: "")),
      expect: () => [
        SettingsState(
          error: "",
        )
      ],
    );

    group('UpdateSendForm', () {
      blocTest<SettingsBloc, SettingsState>(
        'should send error, need to enter current password',
        seed: () => SettingsState(email: "test@gmail.com"),
        build: () => settingsBloc,
        act: (bloc) => bloc.add(UpdateSendForm()),
        expect: () => [
          SettingsState(
              status: false,
              email: "test@gmail.com",
              error:
                  "To update your email or password, you must enter your current password.")
        ],
      );

      blocTest<SettingsBloc, SettingsState>(
        'should update with success',
        seed: () => SettingsState(
            email: "test@gmail.com",
            bio: "test bio",
            birth: DateTime(1980, 05, 04),
            gender: "Man",
            musicalInterests: ["Rap, Pop"],
            currentPassword: "Qwerty42@",
            newPassword: "Azerty472@",
            pseudo: "pseudoTest",
            buttonStatus: true),
        build: () {
          when(mockRepository.updateUser(
            email: "test@gmail.com",
            bio: "test bio",
            birth: DateTime(1980, 05, 04),
            gender: "Man",
            musicalInterests: ["Rap, Pop"],
            currentPassword: "Qwerty42@",
            password: "Azerty472@",
            pseudo: "pseudoTest",
          )).thenAnswer((realInvocation) async => ReturnRepository.success());
          return (settingsBloc);
        },
        act: (bloc) => bloc.add(UpdateSendForm()),
        expect: () => [
          SettingsState(
            email: "test@gmail.com",
            bio: "test bio",
            birth: DateTime(1980, 05, 04),
            gender: "Man",
            musicalInterests: ["Rap, Pop"],
            currentPassword: "Qwerty42@",
            newPassword: "Azerty472@",
            pseudo: "pseudoTest",
            buttonStatus: true,
            status: true,
          )
        ],
      );

      blocTest<SettingsBloc, SettingsState>(
        'should send error, need to enter current password',
        seed: () => SettingsState(
            email: "test@gmail.com",
            bio: "test bio",
            birth: DateTime(1980, 05, 04),
            gender: "Man",
            musicalInterests: ["Rap, Pop"],
            currentPassword: "Qwerty42@",
            newPassword: "Azerty472@",
            pseudo: "pseudoTest",
            buttonStatus: true),
        build: () {
          when(mockRepository.updateUser(
            email: "test@gmail.com",
            bio: "test bio",
            birth: DateTime(1980, 05, 04),
            gender: "Man",
            musicalInterests: ["Rap, Pop"],
            currentPassword: "Qwerty42@",
            password: "Azerty472@",
            pseudo: "pseudoTest",
          )).thenAnswer((realInvocation) async =>
              ReturnRepository.failed(message: 'error'));
          return (SettingsBloc(userRepository: mockRepository));
        },
        act: (bloc) => bloc.add(UpdateSendForm()),
        expect: () => [
          SettingsState(
              email: "test@gmail.com",
              bio: "test bio",
              birth: DateTime(1980, 05, 04),
              gender: "Man",
              musicalInterests: ["Rap, Pop"],
              currentPassword: "Qwerty42@",
              newPassword: "Azerty472@",
              pseudo: "pseudoTest",
              buttonStatus: true,
              status: false,
              error: "error")
        ],
      );
    });
  });
}
