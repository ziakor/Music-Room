import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:music_room/src/bloc/auth/auth_bloc.dart';
import 'package:music_room/src/data/model/return_repository.dart';
import 'package:music_room/src/data/model/_user.dart';
import 'package:music_room/src/data/model/user_firestore.dart';
import 'package:music_room/src/page/home/home.dart';
import 'package:music_room/src/page/home/home_page.dart';
import 'package:music_room/src/page/settings.dart';
import 'package:vrouter/vrouter.dart';

import 'mocks/user_repository_mock.dart';

void main() {
  final MockUserRepository mockRepository = MockUserRepository();
  when(mockRepository.currentUser).thenReturn(
      User(id: 'some-uid', email: 'test@gmail.com', pseudo: "ziakor"));
  when(mockRepository.user)
      .thenAnswer((realInvocation) => Stream.value(User(id: 'd')));
  when(mockRepository.getFirestoreUserDataFromId(any)).thenAnswer(
      (realInvocation) async => UserFirestore(
          pseudo: "testPseudo",
          gender: "Man",
          musicalInterests: [],
          bio: "Bio",
          birth: Timestamp.fromDate(DateTime(2002, 12, 05))));

  Future<void> _buildSettings(WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (context) => AuthBloc(userRepository: mockRepository),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return VRouter(
              initialUrl: "/",
              routes: [
                VWidget(path: "/", widget: HomePage(), stackedRoutes: [
                  VWidget(
                    path: "/settings",
                    widget: SettingsPage(
                      userRepository: mockRepository,
                    ),
                  ),
                ]),
              ],
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    final icon = find.byIcon(Icons.more_vert, skipOffstage: true);
    await tester.tap(icon);
    await tester.pumpAndSettle();
    final settingsIcon = find.byIcon(Icons.settings);
    await tester.tap(settingsIcon);

    await tester.pumpAndSettle();
  }

  testWidgets('initial', (WidgetTester tester) async {
    await _buildSettings(tester);
    expect(find.text("Settings"), findsOneWidget);
    expect(find.byType(SettingsPage), findsOneWidget);
  });

  group('pseudo', () {
    testWidgets('update pseudo ', (WidgetTester tester) async {
      await _buildSettings(tester);

      when(mockRepository.checkPseudoAvailable(any))
          .thenAnswer((realInvocation) async => true);
      final pseudoInput = find.byKey(Key("SettingsPseudoInput"));
      await tester.enterText(pseudoInput, "t");
      await tester.pumpAndSettle();

      final iconAvailable = find.byKey(Key("IconAvailablePseudoKey"));
      expect(iconAvailable, findsOneWidget);
    });

    testWidgets('update pseudo ', (WidgetTester tester) async {
      await _buildSettings(tester);

      when(mockRepository.checkPseudoAvailable(any))
          .thenAnswer((realInvocation) async => true);
      final pseudoInput = find.byKey(Key("SettingsPseudoInput"));
      await tester.enterText(pseudoInput, "t");
      await tester.pumpAndSettle();
      when(mockRepository.checkPseudoAvailable(any))
          .thenAnswer((realInvocation) async => false);
      await tester.enterText(pseudoInput, "tuif");
      await tester.pumpAndSettle();

      final iconUnavailable = find.byKey(Key("IconUnavailablePseudoKey"));
      expect(iconUnavailable, findsOneWidget);
    });
  });

  group('gender', () {
    testWidgets('change Gender to Non-binary', (WidgetTester tester) async {
      await _buildSettings(tester);
      expect(find.text("Settings"), findsOneWidget);
      expect(find.byType(SettingsPage), findsOneWidget);

      final genderInput = find.byKey(Key("NonBinaryRadioKey"));
      final genderSemantics = tester.getSemantics(genderInput);
      await tester.tap(genderInput);
      await tester.pumpAndSettle();
      expect(genderSemantics.hasFlag(SemanticsFlag.isChecked), true);
    });

    testWidgets('change Gender to Man', (WidgetTester tester) async {
      await _buildSettings(tester);
      expect(find.text("Settings"), findsOneWidget);
      expect(find.byType(SettingsPage), findsOneWidget);
      final genderWomanInput = find.byKey(Key("WomanRadioKey"));
      await tester.tap(genderWomanInput);
      await tester.pumpAndSettle();
      final genderInput = find.byKey(Key("ManRadioKey"));
      final genderSemantics = tester.getSemantics(genderInput);
      await tester.tap(genderInput);
      await tester.pumpAndSettle();
      expect(genderSemantics.hasFlag(SemanticsFlag.isChecked), true);
    });

    testWidgets('change Gender to Man', (WidgetTester tester) async {
      await _buildSettings(tester);
      expect(find.text("Settings"), findsOneWidget);
      expect(find.byType(SettingsPage), findsOneWidget);

      final genderInput = find.byKey(Key("WomanRadioKey"));
      final genderSemantics = tester.getSemantics(genderInput);
      await tester.tap(genderInput);
      await tester.pumpAndSettle();
      expect(genderSemantics.hasFlag(SemanticsFlag.isChecked), true);
    });
  });

  testWidgets('change Bio', (WidgetTester tester) async {
    await _buildSettings(tester);
    expect(find.text("Settings"), findsOneWidget);
    expect(find.byType(SettingsPage), findsOneWidget);

    final bioInput = find.byKey(Key("SettingsBioInput"));
    await tester.enterText(bioInput, "testBio");
    await tester.pumpAndSettle();
    expect(find.text("testBio"), findsOneWidget);
  });
  testWidgets('change Email', (WidgetTester tester) async {
    await _buildSettings(tester);
    expect(find.text("Settings"), findsOneWidget);
    expect(find.byType(SettingsPage), findsOneWidget);

    final emailInput = find.byKey(Key("SettingsEmailInput"));
    await tester.enterText(emailInput, "test@gmail.com");
    await tester.pumpAndSettle();
    expect(find.text("test@gmail.com"), findsOneWidget);
  });

  testWidgets('change password', (WidgetTester tester) async {
    await _buildSettings(tester);
    expect(find.text("Settings"), findsOneWidget);
    expect(find.byType(SettingsPage), findsOneWidget);

    final passwordInput = find.byKey(Key("SettingsCurrentPasswordInput"));
    await tester.enterText(passwordInput, "Qwerty4242@");
    await tester.pumpAndSettle();
    expect(find.text("Qwerty4242@"), findsOneWidget);
  });

  testWidgets('change new password', (WidgetTester tester) async {
    await _buildSettings(tester);
    expect(find.text("Settings"), findsOneWidget);
    expect(find.byType(SettingsPage), findsOneWidget);

    final passwordInput = find.byKey(Key("SettingsPasswordInput"));
    await tester.enterText(passwordInput, "Qwerty4242@");
    await tester.pumpAndSettle();
    expect(find.text("Qwerty4242@"), findsOneWidget);
  });

  testWidgets('change birth', (WidgetTester tester) async {
    await _buildSettings(tester);
    expect(find.text("Settings"), findsOneWidget);
    expect(find.byType(SettingsPage), findsOneWidget);

    final birthInput = find.byKey(Key("SettingsBirthInputKey"));
    await tester.tap(birthInput);
    await tester.pumpAndSettle();
    expect(find.text("CANCEL"), findsOneWidget);
    expect(find.text("SELECT DATE"), findsOneWidget);
    expect(find.text("OK"), findsOneWidget);
    await tester.tap(find.text("15"));
    await tester.tap(find.text("OK"));

    await tester.pumpAndSettle();

    final text = birthInput.evaluate().single.widget as TextFormField;
    expect(find.text("1980/11/15"), findsOneWidget);
  });

  group('musicalInterests', () {
    testWidgets('change musical Interests', (WidgetTester tester) async {
      await _buildSettings(tester);
      expect(find.text("Settings"), findsOneWidget);
      expect(find.byType(SettingsPage), findsOneWidget);

      final musicalInterestsInput =
          find.byKey(Key("SettingsMusicalInterestsInput"));
      await tester.ensureVisible(musicalInterestsInput);
      await tester.pumpAndSettle();

      await tester.tap(musicalInterestsInput);
      await tester.pumpAndSettle();
      expect(find.text("Apply"), findsOneWidget);

      await tester.tap(find.text("Alternative"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Apply"));
      await tester.pumpAndSettle();
      expect(find.text("Alternative"), findsOneWidget);
    });

    testWidgets('change musical Interests and reset',
        (WidgetTester tester) async {
      await _buildSettings(tester);
      expect(find.text("Settings"), findsOneWidget);
      expect(find.byType(SettingsPage), findsOneWidget);

      final musicalInterestsInput =
          find.byKey(Key("SettingsMusicalInterestsInput"));
      await tester.ensureVisible(musicalInterestsInput);
      await tester.pumpAndSettle();

      await tester.tap(musicalInterestsInput);
      await tester.pumpAndSettle();
      expect(find.text("Apply"), findsOneWidget);

      await tester.tap(find.text("Alternative"));
      await tester.tap(find.text("Reset"));
      await tester.tap(find.text("Britpop"));
      await tester.tap(find.text("Apply"));
      await tester.pumpAndSettle();
      expect(find.text("Britpop"), findsOneWidget);
    });
    testWidgets('select all and apply', (WidgetTester tester) async {
      await _buildSettings(tester);
      expect(find.text("Settings"), findsOneWidget);
      expect(find.byType(SettingsPage), findsOneWidget);

      final musicalInterestsInput =
          find.byKey(Key("SettingsMusicalInterestsInput"));
      await tester.ensureVisible(musicalInterestsInput);
      await tester.pumpAndSettle();

      await tester.tap(musicalInterestsInput);
      await tester.pumpAndSettle();
      expect(find.text("Apply"), findsOneWidget);

      await tester.tap(find.text("All"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Apply"));

      await tester.pumpAndSettle();
    });

    testWidgets('search, select and apply', (WidgetTester tester) async {
      await _buildSettings(tester);
      expect(find.text("Settings"), findsOneWidget);
      expect(find.byType(SettingsPage), findsOneWidget);

      final musicalInterestsInput =
          find.byKey(Key("SettingsMusicalInterestsInput"));
      await tester.pumpAndSettle();

      await tester.ensureVisible(musicalInterestsInput);
      await tester.tap(musicalInterestsInput);
      await tester.pumpAndSettle();
      expect(find.text("Apply"), findsOneWidget);

      final searchInput = find.byType(TextField).at(7);
      await tester.pumpAndSettle();

      await tester.enterText(
        searchInput,
        "College",
      );

      await tester.pumpAndSettle();
      final findCollege = find.text("College").at(1);
      await tester.tap(findCollege);
      await tester.pumpAndSettle();

      await tester.tap(find.text("Apply"));

      await tester.pumpAndSettle();
    });
  });

  group('sendForm', () {
    testWidgets('show error', (WidgetTester tester) async {
      await _buildSettings(tester);
      expect(find.text("Settings"), findsOneWidget);
      expect(find.byType(SettingsPage), findsOneWidget);

      final updateButton = find.byKey(Key("SettingsUpdateButtonKey"));

      final updateButtonSemantics = tester.getSemantics(updateButton);
      expect(updateButtonSemantics.hasFlag(SemanticsFlag.isEnabled), false);

      final musicalInterestsInput =
          find.byKey(Key("SettingsMusicalInterestsInput"));
      await tester.ensureVisible(musicalInterestsInput);
      await tester.pumpAndSettle();

      await tester.tap(musicalInterestsInput);
      await tester.pumpAndSettle();
      expect(find.text("Apply"), findsOneWidget);

      await tester.tap(find.text("Alternative"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Apply"));
      await tester.pumpAndSettle();
      expect(find.text("Alternative"), findsOneWidget);
      expect(updateButtonSemantics.hasFlag(SemanticsFlag.isEnabled), true);
      when(mockRepository.updateUser(
        email: anyNamed('email'),
        bio: anyNamed('bio'),
        birth: anyNamed('birth'),
        gender: anyNamed('gender'),
        musicalInterests: anyNamed('musicalInterests'),
        currentPassword: anyNamed('currentPassword'),
        password: anyNamed('password'),
        pseudo: anyNamed('pseudo'),
      )).thenAnswer((realInvocation) async => ReturnRepository.success());
      await tester.tap(updateButton);
      await tester.pumpAndSettle();
      await tester.pump();
      expect(find.text("Your informations has been updated."), findsOneWidget);
    });

    testWidgets('show success', (WidgetTester tester) async {
      await _buildSettings(tester);
      expect(find.text("Settings"), findsOneWidget);
      expect(find.byType(SettingsPage), findsOneWidget);

      final updateButton = find.byKey(Key("SettingsUpdateButtonKey"));

      final updateButtonSemantics = tester.getSemantics(updateButton);
      expect(updateButtonSemantics.hasFlag(SemanticsFlag.isEnabled), false);

      final musicalInterestsInput =
          find.byKey(Key("SettingsMusicalInterestsInput"));
      await tester.ensureVisible(musicalInterestsInput);
      await tester.pumpAndSettle();

      await tester.tap(musicalInterestsInput);
      await tester.pumpAndSettle();
      expect(find.text("Apply"), findsOneWidget);

      await tester.tap(find.text("Alternative"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Apply"));
      await tester.pumpAndSettle();
      expect(find.text("Alternative"), findsOneWidget);
      expect(updateButtonSemantics.hasFlag(SemanticsFlag.isEnabled), true);
      when(mockRepository.updateUser(
        email: anyNamed('email'),
        bio: anyNamed('bio'),
        birth: anyNamed('birth'),
        gender: anyNamed('gender'),
        musicalInterests: anyNamed('musicalInterests'),
        currentPassword: anyNamed('currentPassword'),
        password: anyNamed('password'),
        pseudo: anyNamed('pseudo'),
      )).thenAnswer((realInvocation) async =>
          ReturnRepository.failed(message: "Test error."));
      await tester.tap(updateButton);
      await tester.pumpAndSettle();
      await tester.pump();
      expect(find.text("Test error."), findsOneWidget);
    });
  });
}
