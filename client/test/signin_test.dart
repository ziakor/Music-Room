import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:music_room/src/bloc/signin/signin_bloc.dart';
import 'package:music_room/src/data/service/firebase_service.dart';
import 'package:music_room/src/page/signin.dart';
import 'package:music_room/src/page/signup.dart';
import 'package:music_room/src/page/unlogged_home.dart';
import 'package:vrouter/vrouter.dart';

import 'mocks/mock.dart';
import 'mocks/user_repository_mock.dart';

void main() {
  final MockUserRepository mockRepository = MockUserRepository();
  final Signin signin = Signin(
    userRepository: mockRepository,
  );
  setupFirebaseAuthMocks();
  setUp(() {});
  setUpAll(() async {
    await Firebase.initializeApp();
  });
  group('Signup widget test', () {
    testWidgets('should update email with a valid email address',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (context) => SigninBloc(userRepository: mockRepository),
            child: signin,
          ),
        ),
      ));
      final emailInput = find.byKey(Key("EmailInputKey"));
      expect(emailInput, findsOneWidget);
      await tester.enterText(emailInput, "dimitrihauet@gmail.com");
      expect(find.text("Invalid email"), findsNothing);
      expect(find.text("dimitrihauet@gmail.com"), findsOneWidget);
    });
    testWidgets('should update email with an invalid email address',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (context) => SigninBloc(userRepository: mockRepository),
            child: signin,
          ),
        ),
      ));
      final emailInput = find.byKey(Key("EmailInputKey"));
      expect(emailInput, findsOneWidget);
      await tester.enterText(emailInput, "dimitrihaue");
      await tester.pumpAndSettle();
      expect(find.text("Invalid email"), findsOneWidget);
      expect(find.text("dimitrihaue"), findsOneWidget);
    });

    testWidgets('should update password', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (context) => SigninBloc(userRepository: mockRepository),
            child: signin,
          ),
        ),
      ));
      final passwordInput = find.byKey(Key("passwordInputKey"));
      expect(passwordInput, findsOneWidget);
      await tester.enterText(passwordInput, "ZAazerty59@");
      await tester.pumpAndSettle();
      expect(find.text("ZAazerty59@"), findsOneWidget);
    });

    testWidgets('should show password', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (context) => SigninBloc(userRepository: mockRepository),
            child: signin,
          ),
        ),
      ));
      final passwordInput = find.byKey(Key("passwordInputKey"));
      expect(passwordInput, findsOneWidget);
      await tester.enterText(passwordInput, "ZAazerty59@");
      await tester.pumpAndSettle();

      expect(find.text("ZAazerty59@"), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle();

      final showPasswordIcon = find.byIcon(Icons.visibility_off);
      expect(showPasswordIcon, findsOneWidget);
    });

    testWidgets('should hide password', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (context) => SigninBloc(userRepository: mockRepository),
            child: signin,
          ),
        ),
      ));
      final passwordInput = find.byKey(Key("passwordInputKey"));
      expect(passwordInput, findsOneWidget);
      await tester.enterText(passwordInput, "ZAazerty59@");
      await tester.pumpAndSettle();

      expect(find.text("ZAazerty59@"), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();

      final showPasswordIcon = find.byIcon(Icons.visibility);
      expect(showPasswordIcon, findsOneWidget);
    });

    testWidgets('form should be submitted', (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          initialUrl: "/signin",
          routes: [
            VWidget(path: "/", widget: UnloggedHome(), stackedRoutes: [
              VWidget(
                path: "/signup",
                widget: Signup(
                  repo: mockRepository,
                ),
              ),
              VWidget(
                path: "/signin",
                widget: Signin(
                  userRepository: mockRepository,
                ),
              ),
            ]),
          ],
          debugShowCheckedModeBanner: false,
        ),
      );
      await tester.pumpAndSettle();
      when(mockRepository.signinWithEmailAndPassword(
              "dimitrihauet@gmail.com", "ZAazerty59@"))
          .thenAnswer((realInvocation) async => null);
      await tester.pumpAndSettle();

      final emailInput = find.byKey(Key("EmailInputKey"));
      final passwordInput = find.byKey(Key("passwordInputKey"));

      final submitButton = find.byKey(Key("SubmitButtonKey"));
      expect(passwordInput, findsOneWidget);
      expect(emailInput, findsOneWidget);
      expect(submitButton, findsOneWidget);

      await tester.enterText(emailInput, "dimitrihauet@gmail.com");
      await tester.enterText(passwordInput, "ZAazerty59@");
      await tester.pumpAndSettle();
      await tester.tap(submitButton);
      await tester.pumpAndSettle();
    });

    testWidgets('FacebookSignin', (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          initialUrl: "/signin",
          routes: [
            VWidget(path: "/", widget: UnloggedHome(), stackedRoutes: [
              VWidget(
                path: "/signup",
                widget: Signup(
                  repo: mockRepository,
                ),
              ),
              VWidget(
                path: "/signin",
                widget: Signin(
                  userRepository: mockRepository,
                ),
              ),
            ]),
          ],
          debugShowCheckedModeBanner: false,
        ),
      );
      await tester.pumpAndSettle();
      when(mockRepository.signupWithFacebook())
          .thenAnswer((realInvocation) async => null);
      await tester.tap(find.byKey(Key("facebookSigninKey")));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
    });

    testWidgets(
        'form should be submitted, show modal email not verified, send email and close the modal',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          initialUrl: "/signin",
          routes: [
            VWidget(path: "/", widget: UnloggedHome(), stackedRoutes: [
              VWidget(
                path: "/signup",
                widget: Signup(
                  repo: mockRepository,
                ),
              ),
              VWidget(
                path: "/signin",
                widget: Signin(
                  userRepository: mockRepository,
                ),
              ),
            ]),
          ],
          debugShowCheckedModeBanner: false,
        ),
      );
      await tester.pumpAndSettle();
      when(mockRepository.signinWithEmailAndPassword(
              "dimitrihauet@gmail.com", "ZAazerty59@"))
          .thenThrow(SigninFailure("mail-not-verified"));
      when(mockRepository.resendEmailVerificationAccount())
          .thenAnswer((realInvocation) async => null);
      await tester.pumpAndSettle();

      final emailInput = find.byKey(Key("EmailInputKey"));
      final passwordInput = find.byKey(Key("passwordInputKey"));

      final submitButton = find.byKey(Key("SubmitButtonKey"));
      expect(passwordInput, findsOneWidget);
      expect(emailInput, findsOneWidget);
      expect(submitButton, findsOneWidget);

      await tester.enterText(emailInput, "dimitrihauet@gmail.com");
      await tester.enterText(passwordInput, "ZAazerty59@");
      await tester.pumpAndSettle();
      await tester.tap(submitButton);
      await tester.pumpAndSettle();
      expect(find.byKey(Key("showDialogKey")), findsOneWidget);
      await tester.tap(find.byKey(Key("VerificationEmailButtonKey")));
    });

    testWidgets('GoogleSignin', (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          initialUrl: "/signin",
          routes: [
            VWidget(path: "/", widget: UnloggedHome(), stackedRoutes: [
              VWidget(
                path: "/signup",
                widget: Signup(
                  repo: mockRepository,
                ),
              ),
              VWidget(
                path: "/signin",
                widget: Signin(
                  userRepository: mockRepository,
                ),
              ),
            ]),
          ],
          debugShowCheckedModeBanner: false,
        ),
      );
      await tester.pumpAndSettle();
      when(mockRepository.signupWithGoogle())
          .thenAnswer((realInvocation) async => null);
      await tester.tap(find.byKey(Key("googleSigninKey")));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
    });

    testWidgets('show error in bottom', (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          initialUrl: "/signin",
          routes: [
            VWidget(path: "/", widget: UnloggedHome(), stackedRoutes: [
              VWidget(
                path: "/signup",
                widget: Signup(
                  repo: mockRepository,
                ),
              ),
              VWidget(
                path: "/signin",
                widget: Signin(
                  userRepository: mockRepository,
                ),
              ),
            ]),
          ],
          debugShowCheckedModeBanner: false,
        ),
      );
      await tester.pumpAndSettle();
      when(mockRepository.signupWithGoogle()).thenThrow(ServerError());
      await tester.tap(find.byKey(Key("googleSigninKey")));
      await tester.pumpAndSettle();
      expect(find.text("Error happened, try again"), findsOneWidget);
    });
  });
}
