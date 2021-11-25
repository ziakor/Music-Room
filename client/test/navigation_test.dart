import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:music_room/src/page/signin.dart';
import 'package:music_room/src/page/signup.dart';
import 'package:music_room/src/page/unlogged_home.dart';
import 'package:music_room/src/router.dart';
import 'mocks/mock.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  setupFirebaseAuthMocks();
  group("UnloggedHome navigation tests", () {
    setUpAll(() async {
      await Firebase.initializeApp();
    });

    testWidgets("initialPage should be Unlogged Homepage",
        (WidgetTester tester) async {
      await tester.pumpWidget(RouterApp());
      await tester.pumpAndSettle();
      expect(find.byType(UnloggedHome), findsOneWidget);
      expect(
          find.byKey(UnloggedHome.NavigateToSigninButtonKey), findsOneWidget);
      expect(
          find.byKey(UnloggedHome.NavigateToSignupButtonKey), findsOneWidget);
    });
    testWidgets("should navigate to signup page", (WidgetTester tester) async {
      await tester.pumpWidget(RouterApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(UnloggedHome.NavigateToSignupButtonKey));
      await tester.pumpAndSettle();
      expect(find.byType(Signup), findsOneWidget);
    });
    testWidgets("should navigate to signup page and back to Unlogged Homepage",
        (WidgetTester tester) async {
      await tester.pumpWidget(RouterApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(UnloggedHome.NavigateToSignupButtonKey));
      await tester.pumpAndSettle();
      expect(find.byType(Signup), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(UnloggedHome), findsOneWidget);
      expect(
          find.byKey(UnloggedHome.NavigateToSigninButtonKey), findsOneWidget);
      expect(
          find.byKey(UnloggedHome.NavigateToSignupButtonKey), findsOneWidget);
    });

    testWidgets("should navigate to signin page", (WidgetTester tester) async {
      await tester.pumpWidget(RouterApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(UnloggedHome.NavigateToSigninButtonKey));
      await tester.pumpAndSettle();
      expect(find.byType(Signin), findsOneWidget);
    });
  });
}
