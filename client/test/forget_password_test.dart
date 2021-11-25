import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:music_room/src/data/service/api_service.dart';
import 'package:music_room/src/data/service/firebase_service.dart';
import 'package:music_room/src/page/forgot_password.dart';
import 'package:music_room/src/page/signin.dart';
import 'package:music_room/src/page/signup.dart';
import 'package:music_room/src/page/unlogged_home.dart';
import 'package:vrouter/vrouter.dart';

import 'mocks/mock.dart';
import 'mocks/user_repository_mock.dart';

void main() {
  final MockUserRepository mockRepository = MockUserRepository();
  setupFirebaseAuthMocks();
  setUp(() {});
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('ForgetPasswordPage', () {
    testWidgets('initial', (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          initialUrl: "/forgot",
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
                stackedRoutes: [
                  VWidget(
                      path: "/forgot",
                      widget: ForgotPassword(
                        repository: mockRepository,
                      ))
                ],
              ),
            ]),
          ],
          debugShowCheckedModeBanner: false,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPassword), findsOneWidget);
    });

    testWidgets('enter email should activate button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          initialUrl: "/forgot",
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
                stackedRoutes: [
                  VWidget(
                      path: "/forgot",
                      widget: ForgotPassword(
                        repository: mockRepository,
                      ))
                ],
              ),
            ]),
          ],
          debugShowCheckedModeBanner: false,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPassword), findsOneWidget);
      final emailInput = find.byKey(Key("forgotEmailInputKey"));
      expect(emailInput, findsOneWidget);
      await tester.enterText(emailInput, "dimitrihauet@gmail.com");
      await tester.pumpAndSettle();
      final submitButton = find.byKey(Key("SubmitButtonKey"));
      expect(submitButton, findsOneWidget);
      expect(tester.widget<ElevatedButton>(submitButton).enabled, isTrue);
    });

    testWidgets('tap on button should show modal and send code by email',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          initialUrl: "/forgot",
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
                stackedRoutes: [
                  VWidget(
                      path: "/forgot",
                      widget: ForgotPassword(
                        repository: mockRepository,
                      ))
                ],
              ),
            ]),
          ],
          debugShowCheckedModeBanner: false,
        ),
      );
      when(mockRepository.resetPasswordCode("dimitrihauet@gmail.com"))
          .thenAnswer((realInvocation) async => null);
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPassword), findsOneWidget);
      final emailInput = find.byKey(Key("forgotEmailInputKey"));
      expect(emailInput, findsOneWidget);
      await tester.enterText(emailInput, "dimitrihauet@gmail.com");
      await tester.pumpAndSettle();
      final submitButton = find.byKey(Key("SubmitButtonKey"));
      expect(submitButton, findsOneWidget);
      expect(tester.widget<ElevatedButton>(submitButton).enabled, isTrue);

      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(
          find.text(
              "Enter your new password and the code that you have receive by email."),
          findsOneWidget);
    });

    testWidgets('tap on button and show an error', (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          initialUrl: "/forgot",
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
                stackedRoutes: [
                  VWidget(
                      path: "/forgot",
                      widget: ForgotPassword(
                        repository: mockRepository,
                      ))
                ],
              ),
            ]),
          ],
          debugShowCheckedModeBanner: false,
        ),
      );
      when(mockRepository.resetPasswordCode("dimitrihauet@gmail.com"))
          .thenThrow(ApiServerError("Test error message"));
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPassword), findsOneWidget);
      final emailInput = find.byKey(Key("forgotEmailInputKey"));
      expect(emailInput, findsOneWidget);
      await tester.enterText(emailInput, "dimitrihauet@gmail.com");

      await tester.pumpAndSettle();
      final submitButton = find.byKey(Key("SubmitButtonKey"));
      expect(submitButton, findsOneWidget);
      expect(tester.widget<ElevatedButton>(submitButton).enabled, isTrue);

      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text("Test error message"), findsOneWidget);
    });

    testWidgets('tap on button and show another error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          initialUrl: "/forgot",
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
                stackedRoutes: [
                  VWidget(
                      path: "/forgot",
                      widget: ForgotPassword(
                        repository: mockRepository,
                      ))
                ],
              ),
            ]),
          ],
          debugShowCheckedModeBanner: false,
        ),
      );
      when(mockRepository.resetPasswordCode("dimitrihauet@gmail.com"))
          .thenThrow(ServerError());
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPassword), findsOneWidget);
      final emailInput = find.byKey(Key("forgotEmailInputKey"));
      expect(emailInput, findsOneWidget);
      await tester.enterText(emailInput, "dimitrihauet@gmail.com");

      await tester.pumpAndSettle();
      final submitButton = find.byKey(Key("SubmitButtonKey"));
      expect(submitButton, findsOneWidget);
      expect(tester.widget<ElevatedButton>(submitButton).enabled, isTrue);

      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text("Internal server error"), findsOneWidget);
    });

    testWidgets(' should throw an error', (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          initialUrl: "/forgot",
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
                stackedRoutes: [
                  VWidget(
                      path: "/forgot",
                      widget: ForgotPassword(
                        repository: mockRepository,
                      ))
                ],
              ),
            ]),
          ],
          debugShowCheckedModeBanner: false,
        ),
      );
      when(mockRepository.resetPasswordCode("dimitrihauet@gmail.com"))
          .thenAnswer((realInvocation) async => null);
      when(mockRepository.resetPassword(
              "dimitrihauet@gmail.com", "ZAazerty59@", "asd145asd"))
          .thenAnswer((realInvocation) async => null);
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPassword), findsOneWidget);
      final emailInput = find.byKey(Key("forgotEmailInputKey"));
      expect(emailInput, findsOneWidget);
      await tester.enterText(emailInput, "dimitrihauet@gmail.com");
      await tester.pumpAndSettle();
      final submitButton = find.byKey(Key("SubmitButtonKey"));
      expect(submitButton, findsOneWidget);
      expect(tester.widget<ElevatedButton>(submitButton).enabled, isTrue);

      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      final codeInput = find.byKey(Key("CodeInputKey"));
      final password = find.byKey(Key("passwordInputKey"));
      final submitUpdateInput =
          find.byKey(Key("SubmitUpdatePasswordButtonKey"));
      await tester.enterText(codeInput, "asd145asd");
      await tester.enterText(password, "ZAazerty59@");
      await tester.tap(submitUpdateInput);
      await tester.pumpAndSettle();
      expect(find.text("You have changed your password with success."),
          findsOneWidget);
    });

    testWidgets('should not update password and show error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          initialUrl: "/forgot",
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
                stackedRoutes: [
                  VWidget(
                      path: "/forgot",
                      widget: ForgotPassword(
                        repository: mockRepository,
                      ))
                ],
              ),
            ]),
          ],
          debugShowCheckedModeBanner: false,
        ),
      );
      when(mockRepository.resetPasswordCode("dimitrihauet@gmail.com"))
          .thenAnswer((realInvocation) async => null);
      when(mockRepository.resetPassword(
              "dimitrihauet@gmail.com", "ZAazerty59@", "asd145asd"))
          .thenThrow(ServerError());

      await tester.pumpAndSettle();
      expect(find.byType(ForgotPassword), findsOneWidget);
      final emailInput = find.byKey(Key("forgotEmailInputKey"));
      expect(emailInput, findsOneWidget);
      await tester.enterText(emailInput, "dimitrihauet@gmail.com");
      await tester.pumpAndSettle();
      final submitButton = find.byKey(Key("SubmitButtonKey"));
      expect(submitButton, findsOneWidget);
      expect(tester.widget<ElevatedButton>(submitButton).enabled, isTrue);

      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(
          find.text(
              "Enter your new password and the code that you have receive by email."),
          findsOneWidget);
      final codeInput = find.byKey(Key("CodeInputKey"));
      final password = find.byKey(Key("passwordInputKey"));
      final submitUpdateInput =
          find.byKey(Key("SubmitUpdatePasswordButtonKey"));
      await tester.enterText(codeInput, "asd145asd");
      await tester.enterText(password, "ZAazerty59@");
      await tester.tap(submitUpdateInput);
      await tester.pumpAndSettle();
      expect(find.text("Internal server error"), findsOneWidget);
    });
  });
}
