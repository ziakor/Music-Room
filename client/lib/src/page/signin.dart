import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:music_room/src/bloc/auth/auth_bloc.dart';
import 'package:music_room/src/bloc/signin/signin_bloc.dart';
import 'package:vrouter/vrouter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:music_room/src/data/repository/user_repository.dart';
import 'package:music_room/src/mixins/validation_mixins.dart';

class Signin extends StatefulWidget {
  const Signin({Key? key, required this.userRepository}) : super(key: key);
  @override
  _SigninState createState() => _SigninState();

  final UserRepository userRepository;
}

Future<void> _showDialog(BuildContext context, Widget title, Widget body,
    List<Widget> button, bool barrierDismissible) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return AlertDialog(
        key: Key("showDialogKey"),
        backgroundColor: Colors.black54,
        title: title,
        contentPadding: EdgeInsets.fromLTRB(24, 24, 24, 10),
        shape: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(30.0),
          ),
        ),
        content: body,
        actionsPadding: EdgeInsets.only(bottom: 15),
        actions: button,
      );
    },
  );
}

class _SigninState extends State<Signin> {
  void _showModalMail(BuildContext context) {
    _showDialog(
        context,
        Center(
          child: const Text(
            'Email confirmation',
            style: TextStyle(color: Colors.white),
          ),
        ),
        SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text(
                'Your email is not confirmed.',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              Text(
                "You can click on the button below to confirm your account.",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ),
        [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Container(
                width: 160,
                height: 45,
                child: OutlinedButton(
                  key: Key("VerificationEmailButtonKey"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white10),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0))),
                  ),
                  onPressed: () {
                    context.read<SigninBloc>().add(ResendEmail());
                    context.vRouter.pop();
                  },
                  child: const Text("Resend email",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          )
        ],
        true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white70),
          backgroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Welcome",
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w300),
          ),
        ),
        body: BlocProvider(
          create: (context) =>
              SigninBloc(userRepository: widget.userRepository),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black87,
            child: BlocListener<SigninBloc, SigninState>(
              listener: (context, state) {
                if (state.status == false && state.error.isNotEmpty) {
                  if (state.error == 'mail-not-verified') {
                    _showModalMail(context);
                  } else {
                    context.read<SigninBloc>().add(StatusReset());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.error,
                            style: TextStyle(color: Colors.red)),
                      ),
                    );
                  }
                }
                if (state.status == true) {
                  if (state.error == "successSigninWithEmail") {
                    context.read<AuthBloc>().add(GetAuthEmail());
                  } else {}
                  context.vRouter.to('/');
                }
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    BlocBuilder<SigninBloc, SigninState>(
                      builder: (context, state) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              key: Key("facebookSigninKey"),
                              onPressed: () => context
                                  .read<SigninBloc>()
                                  .add(SigninWithFacebookPressed()),
                              child: FaIcon(
                                FontAwesomeIcons.facebookF,
                                color: Colors.blue,
                                size: 40,
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(10),
                                primary: Colors.black54, // <-- Button color
                                onPrimary: Colors.white, // <-- Splash color
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18.0),
                              child: ElevatedButton(
                                key: Key("googleSigninKey"),
                                onPressed: () {
                                  context
                                      .read<SigninBloc>()
                                      .add(SigninWithGooglePressed());
                                },
                                child: SvgPicture.asset(
                                  "assets/images/google_logo.svg",
                                  width: 40,
                                ),
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(12),
                                  primary: Colors.black54,
                                  onPrimary: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: Text(
                        "OR",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                    EmailInput(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: PasswordInput(),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    SigninButton(),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: RichText(
                        text: TextSpan(
                          text: 'Forgot your password?',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.vRouter.to("/forgot");
                            },
                          style: TextStyle(
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EmailInput extends StatefulWidget {
  const EmailInput({Key? key}) : super(key: key);

  @override
  _EmailInputState createState() => _EmailInputState();
}

class _EmailInputState extends State<EmailInput> {
  String? _validateEmail(String? email) {
    if (email != null) {
      if (email.isEmpty) return ("Please enter your email");
      if (!ValidationMixin().validateEmail(email)) return ("Invalid email");
    }
    return (null);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        width: 280,
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextFormField(
            key: Key("EmailInputKey"),
            validator: (value) {
              final String? str = _validateEmail(value);
              if (str != null) {
                context.read<SigninBloc>().add(EmailFieldUpdate(""));
                return (str);
              }
              context.read<SigninBloc>().add(EmailFieldUpdate(value!));
              return (null);
            },
            decoration: InputDecoration(
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(30.0),
                ),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(30.0),
                ),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(30.0),
                ),
                borderSide: BorderSide(color: Colors.grey.shade700, width: 1.0),
              ),
              filled: true,
              contentPadding: EdgeInsets.fromLTRB(25, 0, 5, 0),
              fillColor: Colors.black26,
              labelStyle: TextStyle(color: Colors.white),
              labelText: 'Email',
            ),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class PasswordInput extends StatefulWidget {
  const PasswordInput({
    Key? key,
  }) : super(key: key);

  @override
  _PasswordInputState createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool showPassword = false;
  final GlobalKey<FormState> formPasswordKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        width: 280,
        constraints: BoxConstraints(minHeight: 60),
        child: Form(
          key: formPasswordKey,
          child: Stack(
            children: [
              TextFormField(
                key: Key("passwordInputKey"),
                autocorrect: false,
                obscureText: !showPassword,
                onChanged: (value) =>
                    context.read<SigninBloc>().add(PasswordFieldUpdate(value)),
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () => setState(() {
                      showPassword = !showPassword;
                    }),
                    icon: Icon(
                        showPassword ? Icons.visibility_off : Icons.visibility),
                  ),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                    borderSide:
                        BorderSide(color: Colors.grey.shade700, width: 1.0),
                  ),
                  filled: true,
                  contentPadding: EdgeInsets.fromLTRB(25, 0, 5, 0),
                  fillColor: Colors.black26,
                  labelStyle: TextStyle(color: Colors.white),
                  errorStyle: TextStyle(
                      fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
                  labelText: 'Password',
                ),
                style: TextStyle(color: Colors.white),
              ),
              Positioned(
                top: 49,
                left: 25,
                child: Text(
                  "At least 8 characters, 1 uppercase, 1 number and 1 symboles",
                  style: TextStyle(color: Colors.white, fontSize: 8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SigninButton extends StatelessWidget {
  const SigninButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SigninBloc, SigninState>(
      buildWhen: (previous, current) {
        return (previous.buttonStatus != current.buttonStatus);
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Container(
            width: 280,
            height: 50,
            child: ElevatedButton(
              key: Key("SubmitButtonKey"),
              onPressed: context.read<SigninBloc>().state.buttonStatus != false
                  ? () => context.read<SigninBloc>().add(SigninButtonPressed())
                  : null,
              child: Text(
                "Confirm",
                style: TextStyle(fontSize: 22),
              ),
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all(Colors.black26),
              ),
            ),
          ),
        );
      },
    );
  }
}
