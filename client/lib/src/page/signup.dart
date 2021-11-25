import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:music_room/src/bloc/signup/signup_bloc.dart';
import 'package:music_room/src/data/repository/user_repository.dart';
import 'package:music_room/src/mixins/validation_mixins.dart';
import 'package:vrouter/vrouter.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key, required this.repo}) : super(key: key);
  @override
  _SignupState createState() => _SignupState();

  final UserRepository repo;
}

class _SignupState extends State<Signup> {
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

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          key: Key("AlertDialogSuccessKey"),
          backgroundColor: Colors.black54,
          title: Column(
            children: [
              Center(
                child: const Text(
                  'Account Successfully',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Center(
                child: const Text(
                  'created',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          contentPadding: EdgeInsets.fromLTRB(24, 24, 24, 10),
          shape: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(30.0),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                  'You will receive an email with a link to activate your account',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                Text(
                  "don't forget to check your spam.",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),
          actionsPadding: EdgeInsets.only(bottom: 15),
          actions: [
            SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Container(
                    width: 160,
                    height: 45,
                    child: OutlinedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white10),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0))),
                      ),
                      onPressed: () => context.vRouter.to("/signin"),
                      child: const Text("Close",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ))
          ],
        );
      },
    );
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
          create: (context) => SignupBloc(repository: widget.repo),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black87,
            child: BlocListener<SignupBloc, SignupState>(
              listener: (context, state) {
                if (state.status == false && state.error.isNotEmpty) {
                  context
                      .read<SignupBloc>()
                      .add(ErrorChanged(error: "", status: false));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error,
                          style: TextStyle(color: Colors.red)),
                    ),
                  );
                }
                if (state.status == true) {
                  _showMyDialog(context);
                  context
                      .read<SignupBloc>()
                      .add(ErrorChanged(error: "", status: false));
                }
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    BlocBuilder<SignupBloc, SignupState>(
                      builder: (context, state) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => context
                                  .read<SignupBloc>()
                                  .add(signupWithFacebook()),
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
                                onPressed: () {
                                  context
                                      .read<SignupBloc>()
                                      .add(signupWithGoogle());
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
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Text(
                        "OR",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                    GenderInput(),
                    PseudoInput(),
                    EmailInput(),
                    BirthInput(),
                    PasswordInput(
                      validationFunction: _validatePassword,
                    ),
                    ConfirmPasswordInput(
                      validationFunction: _validatePassword,
                    ),
                    SignupButton()
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

class GenderInput extends StatefulWidget {
  const GenderInput({Key? key}) : super(key: key);

  @override
  _GenderInputState createState() => _GenderInputState();
}

class _GenderInputState extends State<GenderInput> {
  void handleGenderValue(int value, String gender, BuildContext context) {
    context.read<SignupBloc>().add(GenderChanged(gender: gender));
  }

  int gendervalue(String gender) {
    switch (gender) {
      case "Man":
        return (0);
      case "Woman":
        return (1);
      case "Non-binary":
        return (2);
      default:
        return (-1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        height: 55,
        child: Stack(
          children: [
            BlocBuilder<SignupBloc, SignupState>(
              buildWhen: (previous, current) =>
                  previous.gender != current.gender,
              builder: (context, state) {
                return Container(
                  width: 284,
                  margin: EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Radio(
                          key: Key("ManRadioKey"),
                          value: 0,
                          groupValue: gendervalue(state.gender),
                          activeColor: Colors.grey.shade700,
                          onChanged: (value) =>
                              handleGenderValue(value as int, "Man", context)),
                      Text(
                        "Man",
                        style: TextStyle(color: Colors.white),
                      ),
                      Radio(
                          key: Key("WomanRadioKey"),
                          value: 1,
                          groupValue: gendervalue(state.gender),
                          activeColor: Colors.grey.shade700,
                          onChanged: (value) => handleGenderValue(
                              value as int, "Woman", context)),
                      Text("Woman", style: TextStyle(color: Colors.white)),
                      Radio(
                        value: 2,
                        key: Key("NonBinaryRadioKey"),
                        groupValue: gendervalue(state.gender),
                        activeColor: Colors.grey.shade700,
                        onChanged: (value) => handleGenderValue(
                            value as int, "Non-binary", context),
                      ),
                      Text(
                        "NB",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                );
              },
            ),
            Positioned(
              child: Text(
                "Gender",
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              top: -2.5,
              left: 27,
            )
          ],
        ),
      ),
    );
  }
}

class PseudoInput extends StatefulWidget {
  const PseudoInput({Key? key}) : super(key: key);

  @override
  _PseudoInputState createState() => _PseudoInputState();
}

class _PseudoInputState extends State<PseudoInput> {
  final GlobalKey<FormState> _formPseudoFieldKey = GlobalKey<FormState>();
  String? _validatePseudo(String? pseudo, bool? pseudoAvailable) {
    if (!ValidationMixin().validatePseudo(pseudo!)) {
      return ("Invalid pseudo");
    }
    if (pseudo.length > 1 && pseudoAvailable == false) {
      return ("This pseudo is already taken");
    }
    return (null);
  }

  Widget _IconAvailable(bool pseudoAvailable) {
    if (pseudoAvailable == true) {
      return (Icon(Icons.check,
          key: Key("IconAvailablePseudoKey"), color: Colors.green.shade700));
    }
    return (Icon(Icons.close,
        key: Key("IconUnavailablePseudoKey"), color: Colors.red.shade700));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: 280,
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formPseudoFieldKey,
          child: BlocBuilder<SignupBloc, SignupState>(
            buildWhen: (previous, current) {
              if (previous.pseudo != current.pseudo) {
                _formPseudoFieldKey.currentState!.validate();
              }
              return (previous.pseudo != current.pseudo);
            },
            builder: (context, state) {
              return TextFormField(
                key: Key("pseudoInputKey"),
                validator: (value) {
                  context.read<SignupBloc>().add(PseudoChanged(pseudo: value!));
                  final String? str = _validatePseudo(
                      value, context.read<SignupBloc>().state.pseudoAvailable);

                  return (str);
                },
                decoration: InputDecoration(
                  suffixIcon: BlocBuilder<SignupBloc, SignupState>(
                    buildWhen: (previous, current) {
                      return (previous.pseudoAvailable !=
                          current.pseudoAvailable);
                    },
                    builder: (context, state) {
                      return state.pseudoAvailable == null &&
                              state.pseudo.isEmpty
                          ? Icon(null)
                          : _IconAvailable(state.pseudoAvailable!);
                    },
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
                  labelText: 'Pseudo',
                ),
                style: TextStyle(color: Colors.white),
              );
            },
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
                context.read<SignupBloc>().add(EmailChanged(email: ""));
                return (str);
              }
              context.read<SignupBloc>().add(EmailChanged(email: value!));
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

class BirthInput extends StatefulWidget {
  const BirthInput({Key? key}) : super(key: key);

  @override
  _BirthInputState createState() => _BirthInputState();
}

class _BirthInputState extends State<BirthInput> {
  final TextEditingController _formBirthFieldControllerKey =
      TextEditingController();
  final FocusNode _formBirthFieldNode = FocusNode();

  void _selectDateOfBirth(BuildContext context) async {
    final _initialDate = DateTime(1980, 11, 9);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: context.read<SignupBloc>().state.birth ?? _initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      _formBirthFieldControllerKey.text =
          "${picked.year}/${picked.month}/${picked.day}";
      context.read<SignupBloc>().add(BirthChanged(birth: picked));
    }
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
            readOnly: true,
            key: Key("BirthInputKey"),
            controller: _formBirthFieldControllerKey,
            focusNode: _formBirthFieldNode,
            onTap: () {
              _formBirthFieldNode.unfocus();
              _selectDateOfBirth(context);
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
              errorStyle: TextStyle(
                  fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
              labelText: 'Date of birth',
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
    required this.validationFunction,
  }) : super(key: key);
  final Function(String, String) validationFunction;

  @override
  _PasswordInputState createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  final GlobalKey<FormState> formPasswordKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        width: 280,
        constraints: BoxConstraints(minHeight: 60),
        child: BlocBuilder<SignupBloc, SignupState>(
          buildWhen: (previous, current) =>
              previous.showPassword != current.showPassword,
          builder: (context, state) {
            return Form(
              key: formPasswordKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Stack(
                children: [
                  TextFormField(
                    key: Key("passwordInputKey"),
                    autocorrect: false,
                    obscureText: !context.read<SignupBloc>().state.showPassword,
                    validator: (value) {
                      if (value != null) {
                        final String? str = widget.validationFunction(value,
                            context.read<SignupBloc>().state.confirmPassword);
                        if (str != null) {
                          if (context.read<SignupBloc>().state.passwordMatch ==
                              true) {
                            context.read<SignupBloc>().add(
                                PasswordMatchChanged(passwordMatch: false));
                          }
                          return (str);
                        }
                        formPasswordKey.currentState?.save();
                      }
                    },
                    onSaved: (value) {
                      if (context.read<SignupBloc>().state.password ==
                          context.read<SignupBloc>().state.confirmPassword) {
                        context
                            .read<SignupBloc>()
                            .add(PasswordMatchChanged(passwordMatch: true));
                      }
                    },
                    onChanged: (value) => context
                        .read<SignupBloc>()
                        .add(PasswordChanged(password: value)),
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () => context.read<SignupBloc>().add(
                              ShowPasswordChanged(
                                  showPassword: !context
                                      .read<SignupBloc>()
                                      .state
                                      .showPassword),
                            ),
                        icon: Icon(context.read<SignupBloc>().state.showPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
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
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400),
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
            );
          },
        ),
      ),
    );
  }
}

class ConfirmPasswordInput extends StatefulWidget {
  const ConfirmPasswordInput({
    Key? key,
    required this.validationFunction,
  });
  final Function(String, String) validationFunction;

  @override
  _ConfirmPasswordInputState createState() => _ConfirmPasswordInputState();
}

class _ConfirmPasswordInputState extends State<ConfirmPasswordInput> {
  final GlobalKey<FormState> formPasswordConfirmKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        width: 280,
        constraints: BoxConstraints(minHeight: 60),
        child: BlocBuilder<SignupBloc, SignupState>(
          buildWhen: (previous, current) =>
              previous.showPassword != current.showPassword,
          builder: (context, state) {
            return Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: formPasswordConfirmKey,
              child: Stack(children: [
                TextFormField(
                  key: Key("ConfirmPasswordInputKey"),
                  autocorrect: false,
                  obscureText: !context.read<SignupBloc>().state.showPassword,
                  validator: (value) {
                    if (value != null) {
                      final String? str = widget.validationFunction(
                          value, context.read<SignupBloc>().state.password);
                      if (str != null) {
                        context
                            .read<SignupBloc>()
                            .add(PasswordMatchChanged(passwordMatch: false));
                        return (str);
                      }
                      formPasswordConfirmKey.currentState!.save();
                    }
                  },
                  onSaved: (value) {
                    if (context.read<SignupBloc>().state.password ==
                        context.read<SignupBloc>().state.confirmPassword) {
                      context
                          .read<SignupBloc>()
                          .add(PasswordMatchChanged(passwordMatch: true));
                    }
                  },
                  onChanged: (value) => context
                      .read<SignupBloc>()
                      .add(ConfirmPasswordChanged(confirmPassword: value)),
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () => context.read<SignupBloc>().add(
                            ShowPasswordChanged(
                                showPassword: !context
                                    .read<SignupBloc>()
                                    .state
                                    .showPassword),
                          ),
                      icon: Icon(
                        context.read<SignupBloc>().state.showPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
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
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400),
                    labelText: 'Confirm password',
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
                )
              ]),
            );
          },
        ),
      ),
    );
  }
}

class SignupButton extends StatelessWidget {
  const SignupButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
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
              onPressed: context.read<SignupBloc>().state.buttonStatus != false
                  ? () => context.read<SignupBloc>().add(FormSubmitted())
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
