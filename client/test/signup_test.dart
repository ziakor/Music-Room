import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:music_room/src/bloc/signup/signup_bloc.dart';
import 'package:music_room/src/mixins/validation_mixins.dart';
import 'package:music_room/src/page/signin.dart' as signin;
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
  group(
    "Signup widgets test",
    () {
      group('GenderInput', () {
        testWidgets('should select Man Radio Button',
            (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (context) => SignupBloc(repository: mockRepository),
                child: GenderInput(),
              ),
            ),
          ));
          final manRadio = find.byKey(Key("ManRadioKey"));

          var manRadioSemantics = tester.getSemantics(manRadio);
          await tester.tap(manRadio);
          await tester.pumpAndSettle();
          expect(manRadioSemantics.hasFlag(SemanticsFlag.isChecked), true);
        });
        testWidgets('should select Woman Radio Button',
            (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (context) => SignupBloc(repository: mockRepository),
                child: GenderInput(),
              ),
            ),
          ));
          final womanRadio = find.byKey(Key("WomanRadioKey"));

          var manRadioSemantics = tester.getSemantics(womanRadio);
          await tester.tap(womanRadio);
          await tester.pumpAndSettle();
          expect(manRadioSemantics.hasFlag(SemanticsFlag.isChecked), true);
        });
        testWidgets('should select Non-binary Radio Button',
            (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (context) => SignupBloc(repository: mockRepository),
                child: GenderInput(),
              ),
            ),
          ));
          final nonBinaryRadio = find.byKey(Key("NonBinaryRadioKey"));

          var nonBinaryRadioSemantics = tester.getSemantics(nonBinaryRadio);
          await tester.tap(nonBinaryRadio);
          await tester.pumpAndSettle();
          expect(
              nonBinaryRadioSemantics.hasFlag(SemanticsFlag.isChecked), true);
        });
      });
      group('PseudoInput', () {
        testWidgets('should add pseudo and show  available icon',
            (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (context) => SignupBloc(repository: mockRepository),
                child: PseudoInput(),
              ),
            ),
          ));
          when(mockRepository.checkPseudoAvailable(argThat(isA<String>())))
              .thenAnswer((realInvocation) async => true);
          final pseudoInput = find.byKey(Key("pseudoInputKey"));
          expect(pseudoInput, findsOneWidget);
          await tester.enterText(pseudoInput, "ziakor");
          await tester.pumpAndSettle();
          expect(find.text("ziakor"), findsOneWidget);
          final iconPseudo = find.byKey(Key("IconAvailablePseudoKey"));
          expect(iconPseudo, findsOneWidget);
        });
        testWidgets('should add pseudo, show unavailable icon and error text',
            (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (context) => SignupBloc(repository: mockRepository),
                child: PseudoInput(),
              ),
            ),
          ));
          when(mockRepository.checkPseudoAvailable(argThat(isA<String>())))
              .thenAnswer((realInvocation) async => false);
          final pseudoInput = find.byKey(Key("pseudoInputKey"));
          expect(pseudoInput, findsOneWidget);
          await tester.enterText(pseudoInput, "ziakor");
          await tester.pumpAndSettle();
          expect(find.text("ziakor"), findsOneWidget);
          final iconPseudo = find.byKey(Key("IconUnavailablePseudoKey"));
          expect(iconPseudo, findsOneWidget);
          expect(find.text("This pseudo is already taken"), findsOneWidget);
        });
        testWidgets(
            'should add and remove pseudo text, show unavailable icon and error text',
            (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (context) => SignupBloc(repository: mockRepository),
                child: PseudoInput(),
              ),
            ),
          ));
          when(mockRepository.checkPseudoAvailable(argThat(isA<String>())))
              .thenAnswer((realInvocation) async => false);
          final pseudoInput = find.byKey(Key("pseudoInputKey"));
          expect(pseudoInput, findsOneWidget);
          await tester.enterText(pseudoInput, "ziakor");
          await tester.enterText(pseudoInput, "");

          await tester.pumpAndSettle();
          expect(find.text(""), findsOneWidget);
          final iconPseudo = find.byKey(Key("IconUnavailablePseudoKey"));
          expect(iconPseudo, findsOneWidget);
          expect(find.text("Invalid pseudo"), findsOneWidget);
        });
      });
      group('EmailInput', () {
        testWidgets(
          "should add valid email",
          (WidgetTester tester) async {
            await tester.pumpWidget(MaterialApp(
              home: Scaffold(
                body: BlocProvider(
                  create: (context) => SignupBloc(repository: mockRepository),
                  child: EmailInput(),
                ),
              ),
            ));
            final emailInput = find.byKey(Key("EmailInputKey"));
            expect(emailInput, findsOneWidget);
            await tester.enterText(emailInput, "dimitrihauet@gmail.com");
            await tester.pumpAndSettle();
            expect(find.text("dimitrihauet@gmail.com"), findsOneWidget);
          },
        );
        testWidgets(
          "should add invalid email",
          (WidgetTester tester) async {
            await tester.pumpWidget(MaterialApp(
              home: Scaffold(
                body: BlocProvider(
                  create: (context) => SignupBloc(repository: mockRepository),
                  child: EmailInput(),
                ),
              ),
            ));
            final emailInput = find.byKey(Key("EmailInputKey"));
            expect(emailInput, findsOneWidget);
            await tester.enterText(emailInput, "dimitrihauet@gmail");
            await tester.pumpAndSettle();
            expect(find.text("dimitrihauet@gmail"), findsOneWidget);
            expect(find.text("Invalid email"), findsOneWidget);
          },
        );
        testWidgets(
          "should add empty email and display error",
          (WidgetTester tester) async {
            await tester.pumpWidget(MaterialApp(
              home: Scaffold(
                body: BlocProvider(
                  create: (context) => SignupBloc(repository: mockRepository),
                  child: EmailInput(),
                ),
              ),
            ));
            final emailInput = find.byKey(Key("EmailInputKey"));
            expect(emailInput, findsOneWidget);
            await tester.enterText(emailInput, "dimitrihauet@gmail");
            await tester.enterText(emailInput, "");
            await tester.pumpAndSettle();

            expect(find.text(""), findsOneWidget);
            expect(find.text("Please enter your email"), findsOneWidget);
          },
        );
      });
      group('BirthInput', () {
        testWidgets('should show datePicker when tap on birthInput',
            (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (context) => SignupBloc(repository: mockRepository),
                child: BirthInput(),
              ),
            ),
          ));

          final birthInput = find.byKey(Key("BirthInputKey"));
          expect(birthInput, findsOneWidget);
          await tester.tap(birthInput);
          await tester.pumpAndSettle();
          expect(find.text("CANCEL"), findsOneWidget);
          expect(find.text("SELECT DATE"), findsOneWidget);
          expect(find.text("OK"), findsOneWidget);
        });

        testWidgets('should show datePicker and select a date and Ok',
            (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (context) => SignupBloc(repository: mockRepository),
                child: BirthInput(),
              ),
            ),
          ));

          final birthInput = find.byKey(Key("BirthInputKey"));
          expect(birthInput, findsOneWidget);
          await tester.tap(birthInput);
          await tester.pumpAndSettle();
          expect(find.text("CANCEL"), findsOneWidget);
          expect(find.text("SELECT DATE"), findsOneWidget);
          expect(find.text("OK"), findsOneWidget);
          await tester.tap(find.text("15"));
          await tester.tap(find.text("OK"));

          await tester.pumpAndSettle();
          expect(find.text("1980/11/15"), findsOneWidget);
        });
        testWidgets('should show datePicker,select a date and cancel',
            (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (context) => SignupBloc(repository: mockRepository),
                child: BirthInput(),
              ),
            ),
          ));

          final birthInput = find.byKey(Key("BirthInputKey"));
          expect(birthInput, findsOneWidget);
          await tester.tap(birthInput);
          await tester.pumpAndSettle();
          expect(find.text("CANCEL"), findsOneWidget);
          expect(find.text("SELECT DATE"), findsOneWidget);
          expect(find.text("OK"), findsOneWidget);
          await tester.tap(find.text("15"));
          await tester.tap(find.text("OK"));
          await tester.pumpAndSettle();

          await tester.tap(birthInput);
          await tester.pumpAndSettle();
          expect(find.text("CANCEL"), findsOneWidget);
          expect(find.text("SELECT DATE"), findsOneWidget);
          expect(find.text("OK"), findsOneWidget);
          await tester.tap(find.text("18"));
          await tester.tap(find.text("CANCEL"));

          await tester.pumpAndSettle();
          expect(find.text("1980/11/15"), findsOneWidget);
        });
      });

      group('PasswordInput', () {
        String? _validatePassword(String password, String password_2) {
          if (password.isEmpty) return ("Please enter your password!");
          if (!ValidationMixin().validatePassword(password)) {
            return ("Invalid password");
          }
          if (password_2.isNotEmpty && password != password_2) {
            return ("Password don't match");
          }
          return (null);
        }

        testWidgets('should add valid Password', (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (context) => SignupBloc(repository: mockRepository),
                child: PasswordInput(validationFunction: _validatePassword),
              ),
            ),
          ));

          final passwordInput = find.byKey(Key("passwordInputKey"));
          expect(passwordInput, findsOneWidget);

          await tester.enterText(passwordInput, "ZAazerty59@");
          await tester.pumpAndSettle();
          expect(find.text("ZAazerty59@"), findsOneWidget);
        });
        testWidgets('should add invalid Password', (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (context) => SignupBloc(repository: mockRepository),
                child: PasswordInput(validationFunction: _validatePassword),
              ),
            ),
          ));

          final passwordInput = find.byKey(Key("passwordInputKey"));
          await tester.enterText(passwordInput, "ZAazerty5");
          await tester.pumpAndSettle();
          expect(find.text("ZAazerty5"), findsOneWidget);
          expect(find.text("Invalid password"), findsOneWidget);
        });
        testWidgets('should throw not match error',
            (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (context) => SignupBloc(repository: mockRepository),
                child: Column(
                  children: [
                    PasswordInput(validationFunction: _validatePassword),
                    ConfirmPasswordInput(validationFunction: _validatePassword)
                  ],
                ),
              ),
            ),
          ));

          final passwordInput = find.byKey(Key("passwordInputKey"));
          final confirmPassword = find.byKey(Key("ConfirmPasswordInputKey"));
          await tester.enterText(passwordInput, "ZAazerty59@");
          await tester.enterText(confirmPassword, "ZAazerty59@5");

          await tester.pumpAndSettle();
          expect(find.text("Password don't match"), findsWidgets);
        });
        testWidgets('should show password ', (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (context) => SignupBloc(repository: mockRepository),
                child: PasswordInput(validationFunction: _validatePassword),
              ),
            ),
          ));

          final passwordInput = find.byKey(Key("passwordInputKey"));
          await tester.enterText(passwordInput, "ZAazerty59@");
          await tester.tap(find.byIcon(Icons.visibility));
          await tester.pumpAndSettle();

          final showPasswordIcon = find.byIcon(Icons.visibility_off);
          expect(showPasswordIcon, findsOneWidget);
        });
        testWidgets('should hide password ', (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (context) => SignupBloc(repository: mockRepository),
                child: PasswordInput(validationFunction: _validatePassword),
              ),
            ),
          ));

          final passwordInput = find.byKey(Key("passwordInputKey"));
          await tester.enterText(passwordInput, "ZAazerty59@");
          await tester.tap(find.byIcon(Icons.visibility));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(Icons.visibility_off));
          await tester.pumpAndSettle();

          final showPasswordIcon = find.byIcon(Icons.visibility);
          expect(showPasswordIcon, findsOneWidget);
        });
      });

      //asdasd
      group('ConfirmPasswordInput', () {
        String? _validatePassword(String password, String password_2) {
          if (password.isEmpty) return ("Please enter your password!");
          if (!ValidationMixin().validatePassword(password)) {
            return ("Invalid password");
          }
          if (password_2.isNotEmpty && password != password_2) {
            return ("Password don't match");
          }
          return (null);
        }

        testWidgets('should add valid Password', (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (context) => SignupBloc(repository: mockRepository),
                child:
                    ConfirmPasswordInput(validationFunction: _validatePassword),
              ),
            ),
          ));

          final passwordInput = find.byKey(Key("ConfirmPasswordInputKey"));
          expect(passwordInput, findsOneWidget);

          await tester.enterText(passwordInput, "ZAazerty59@");
          await tester.pumpAndSettle();
          expect(find.text("ZAazerty59@"), findsOneWidget);
        });
        testWidgets('should add invalid Password', (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (context) => SignupBloc(repository: mockRepository),
                child:
                    ConfirmPasswordInput(validationFunction: _validatePassword),
              ),
            ),
          ));

          final passwordInput = find.byKey(Key("ConfirmPasswordInputKey"));
          await tester.enterText(passwordInput, "ZAazerty5");
          await tester.pumpAndSettle();
          expect(find.text("ZAazerty5"), findsOneWidget);
          expect(find.text("Invalid password"), findsOneWidget);
        });
        testWidgets('should throw not match error',
            (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (context) => SignupBloc(repository: mockRepository),
                child: Column(
                  children: [
                    PasswordInput(validationFunction: _validatePassword),
                    ConfirmPasswordInput(validationFunction: _validatePassword)
                  ],
                ),
              ),
            ),
          ));

          final confirmPasswordInput = find.byKey(Key("passwordInputKey"));
          final passwordInput = find.byKey(Key("ConfirmPasswordInputKey"));
          await tester.enterText(confirmPasswordInput, "ZAazerty59@");
          await tester.enterText(passwordInput, "ZAazerty59@5");

          await tester.pumpAndSettle();
          expect(find.text("Password don't match"), findsWidgets);
        });
        testWidgets('should show password ', (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (context) => SignupBloc(repository: mockRepository),
                child:
                    ConfirmPasswordInput(validationFunction: _validatePassword),
              ),
            ),
          ));

          final passwordInput = find.byKey(Key("ConfirmPasswordInputKey"));
          await tester.enterText(passwordInput, "ZAazerty59@");
          await tester.tap(find.byIcon(Icons.visibility));
          await tester.pumpAndSettle();

          final showPasswordIcon = find.byIcon(Icons.visibility_off);
          expect(showPasswordIcon, findsOneWidget);
        });
        testWidgets('should hide password ', (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (context) => SignupBloc(repository: mockRepository),
                child:
                    ConfirmPasswordInput(validationFunction: _validatePassword),
              ),
            ),
          ));

          final passwordInput = find.byKey(Key("ConfirmPasswordInputKey"));
          await tester.enterText(passwordInput, "ZAazerty59@");
          await tester.tap(find.byIcon(Icons.visibility));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(Icons.visibility_off));
          await tester.pumpAndSettle();

          final showPasswordIcon = find.byIcon(Icons.visibility);
          expect(showPasswordIcon, findsOneWidget);
        });
      });
      group('Signup', () {
        testWidgets('password and confirm password should match',
            (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                  create: (context) => SignupBloc(repository: mockRepository),
                  child: Signup(
                    repo: mockRepository,
                  )),
            ),
          ));
          final passwordInput = find.byKey(Key("passwordInputKey"));
          final confirmPasswordInput =
              find.byKey(Key("ConfirmPasswordInputKey"));
          expect(passwordInput, findsOneWidget);
          expect(confirmPasswordInput, findsOneWidget);
          await tester.enterText(passwordInput, "ZAazerty59@");
          await tester.enterText(confirmPasswordInput, "ZAazerty59@");
          await tester.pumpAndSettle();
          expect(find.text("ZAazerty59@"), findsWidgets);
        });
        testWidgets(
            'password and confirm password should not match after update password',
            (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                  create: (context) => SignupBloc(repository: mockRepository),
                  child: Signup(
                    repo: mockRepository,
                  )),
            ),
          ));
          final passwordInput = find.byKey(Key("passwordInputKey"));
          final confirmPasswordInput =
              find.byKey(Key("ConfirmPasswordInputKey"));
          expect(passwordInput, findsOneWidget);
          expect(confirmPasswordInput, findsOneWidget);
          await tester.enterText(passwordInput, "ZAazerty59@");
          await tester.enterText(confirmPasswordInput, "ZAazerty59@");
          await tester.pumpAndSettle();
          expect(find.text("ZAazerty59@"), findsWidgets);
          await tester.enterText(passwordInput, "ZAazerty59");
          await tester.pumpAndSettle();
          expect(find.text("ZAazerty59@"), findsOneWidget);
          expect(find.text("ZAazerty59"), findsOneWidget);
        });
        testWidgets(
            'password and confirm password should not match after update confirmPassword',
            (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                  create: (context) => SignupBloc(repository: mockRepository),
                  child: Signup(
                    repo: mockRepository,
                  )),
            ),
          ));
          final passwordInput = find.byKey(Key("passwordInputKey"));
          final confirmPasswordInput =
              find.byKey(Key("ConfirmPasswordInputKey"));
          expect(passwordInput, findsOneWidget);
          expect(confirmPasswordInput, findsOneWidget);
          await tester.enterText(passwordInput, "ZAazerty59@");
          await tester.enterText(confirmPasswordInput, "ZAazerty59@");
          await tester.pumpAndSettle();
          expect(find.text("ZAazerty59@"), findsWidgets);
          await tester.enterText(confirmPasswordInput, "ZAazerty59");
          await tester.pumpAndSettle();
          expect(find.text("ZAazerty59@"), findsOneWidget);
          expect(find.text("ZAazerty59"), findsOneWidget);
        });

        testWidgets(
            'password and confirm password should  match after update password',
            (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                  create: (context) => SignupBloc(repository: mockRepository),
                  child: Signup(
                    repo: mockRepository,
                  )),
            ),
          ));
          final passwordInput = find.byKey(Key("passwordInputKey"));
          final confirmPasswordInput =
              find.byKey(Key("ConfirmPasswordInputKey"));
          expect(passwordInput, findsOneWidget);
          expect(confirmPasswordInput, findsOneWidget);
          await tester.enterText(passwordInput, "ZAazerty59");
          await tester.enterText(confirmPasswordInput, "ZAazerty59@");
          await tester.pumpAndSettle();
          expect(find.text("ZAazerty59@"), findsOneWidget);
          expect(find.text("ZAazerty59"), findsOneWidget);
          await tester.enterText(passwordInput, "ZAazerty59@");
          await tester.pumpAndSettle();
          expect(find.text("ZAazerty59@"), findsWidgets);
        });

        testWidgets(
            'password and confirm password should  match after update password',
            (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (context) => SignupBloc(repository: mockRepository),
                child: Signup(
                  repo: mockRepository,
                ),
              ),
            ),
          ));
          final passwordInput = find.byKey(Key("passwordInputKey"));
          final confirmPasswordInput =
              find.byKey(Key("ConfirmPasswordInputKey"));
          expect(passwordInput, findsOneWidget);
          expect(confirmPasswordInput, findsOneWidget);
          await tester.enterText(passwordInput, "ZAazerty59@");
          await tester.enterText(confirmPasswordInput, "ZAazerty59");
          await tester.pumpAndSettle();
          expect(find.text("ZAazerty59@"), findsOneWidget);
          expect(find.text("ZAazerty59"), findsOneWidget);
          await tester.enterText(confirmPasswordInput, "ZAazerty59@");
          await tester.pumpAndSettle();
          expect(find.text("ZAazerty59@"), findsWidgets);
        });

        testWidgets(
            'Form is submitted with success and show a modal with instructions',
            (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (context) => SignupBloc(repository: mockRepository),
                child: Signup(
                  repo: mockRepository,
                ),
              ),
            ),
          ));
          when(mockRepository.signupWithEmailAndPassword(
                  argThat(isA<String>()),
                  argThat(isA<String>()),
                  argThat(isA<String>()),
                  argThat(isA<String>()),
                  argThat(isA<DateTime>())))
              .thenAnswer((realInvocation) async => null);
          final genderInput = find.byKey(Key("ManRadioKey"));
          final pseudoInput = find.byKey(Key("pseudoInputKey"));
          final emailInput = find.byKey(Key("EmailInputKey"));
          final birthInput = find.byKey(Key("BirthInputKey"));
          final passwordInput = find.byKey(
            Key("passwordInputKey"),
          );
          final confirmPasswordInput =
              find.byKey(Key("ConfirmPasswordInputKey"));
          final submitButton = find.byKey(Key("SubmitButtonKey"));
          await tester.tap(genderInput);
          await tester.enterText(pseudoInput, "ziakor");
          await tester.enterText(emailInput, "dimitrihauet@gmail.com");
          await tester.tap(birthInput);
          await tester.pumpAndSettle();

          await tester.tap(find.text("20"));
          await tester.tap(find.text("OK"));

          await tester.enterText(passwordInput, "ZAazerty59@");
          await tester.enterText(confirmPasswordInput, "ZAazerty59@");
          await tester.pumpAndSettle();
          expect(
              tester.getSemantics(genderInput).hasFlag(SemanticsFlag.isChecked),
              true);
          expect(find.text("ziakor"), findsOneWidget);
          expect(find.text("dimitrihauet@gmail.com"), findsOneWidget);
          expect(find.text("1980/11/20"), findsOneWidget);
          expect(find.text("ZAazerty59@"), findsWidgets);
          await tester.pumpAndSettle();
          await tester.ensureVisible(submitButton);
          expect(tester.widget<ElevatedButton>(submitButton).enabled, isTrue);
          await tester.tap(submitButton);
          await tester.pumpAndSettle();
          expect(find.byType(AlertDialog), findsWidgets);
        });

        testWidgets(
            'Form is submitted with success and show a modal with instructions then redirect to /signin',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            VRouter(
              initialUrl: "/signup",
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
                    widget: signin.Signin(
                      userRepository: mockRepository,
                    ),
                  ),
                ]),
              ],
              debugShowCheckedModeBanner: false,
            ),
          );
          await tester.pumpAndSettle();
          when(mockRepository.signupWithEmailAndPassword(
                  argThat(isA<String>()),
                  argThat(isA<String>()),
                  argThat(isA<String>()),
                  argThat(isA<String>()),
                  argThat(isA<DateTime>())))
              .thenAnswer((realInvocation) async => null);
          final genderInput = find.byKey(Key("ManRadioKey"));
          final pseudoInput = find.byKey(Key("pseudoInputKey"));
          final emailInput = find.byKey(Key("EmailInputKey"));
          final birthInput = find.byKey(Key("BirthInputKey"));
          final passwordInput = find.byKey(
            Key("passwordInputKey"),
          );
          final confirmPasswordInput =
              find.byKey(Key("ConfirmPasswordInputKey"));
          final submitButton = find.byKey(Key("SubmitButtonKey"));
          await tester.tap(genderInput);
          await tester.enterText(pseudoInput, "ziakor");
          await tester.enterText(emailInput, "dimitrihauet@gmail.com");
          await tester.tap(birthInput);
          await tester.pumpAndSettle();

          await tester.tap(find.text("20"));
          await tester.tap(find.text("OK"));

          await tester.enterText(passwordInput, "ZAazerty59@");
          await tester.enterText(confirmPasswordInput, "ZAazerty59@");
          await tester.pumpAndSettle();
          expect(
              tester.getSemantics(genderInput).hasFlag(SemanticsFlag.isChecked),
              true);
          expect(find.text("ziakor"), findsOneWidget);
          expect(find.text("dimitrihauet@gmail.com"), findsOneWidget);
          expect(find.text("1980/11/20"), findsOneWidget);
          expect(find.text("ZAazerty59@"), findsWidgets);
          await tester.pumpAndSettle();
          await tester.ensureVisible(submitButton);
          expect(tester.widget<ElevatedButton>(submitButton).enabled, isTrue);
          await tester.tap(submitButton);
          await tester.pumpAndSettle();
          expect(find.text("Account Successfully"), findsWidgets);
          await tester.tap(find.text("Close"));
          await tester.pumpAndSettle();
          expect(find.byType(signin.Signin), findsOneWidget);
        });
      });
    },
  );
}
