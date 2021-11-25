import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_room/src/cubit/forget_password/forgetpassword_cubit.dart';
import 'package:music_room/src/data/repository/user_repository.dart';
import 'package:music_room/src/ui/widgets/modal_dialog.dart';
import 'package:vrouter/vrouter.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key, required this.repository}) : super(key: key);
  final UserRepository repository;
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool _buttonStatus = false;

  final TextEditingController emailInputController = TextEditingController();
  final TextEditingController codeInputController = TextEditingController();
  final TextEditingController passwordInputController = TextEditingController();

  bool _handleButtonStatus(String code, String password) {
    return (code.isNotEmpty && password.isNotEmpty);
  }

  _sendCodeMail(BuildContext context) {
    modalDialog(
        context,
        Center(
          child: const Text(
            'Reset your password',
            style: TextStyle(color: Colors.white),
          ),
        ),
        SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                'Enter your new password and the code that you have receive by email.',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              Text(
                "PS: Don't forget your spam!",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                width: 280,
                child: TextField(
                  key: Key("CodeInputKey"),
                  controller: codeInputController,
                  onChanged: (value) {
                    setState(() {
                      _buttonStatus = _handleButtonStatus(
                          value, passwordInputController.text);
                    });
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
                      borderSide:
                          BorderSide(color: Colors.grey.shade700, width: 1.0),
                    ),
                    filled: true,
                    contentPadding: EdgeInsets.fromLTRB(25, 0, 5, 0),
                    fillColor: Colors.grey.shade900,
                    labelStyle: TextStyle(color: Colors.white),
                    errorStyle: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400),
                    labelText: 'Code',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                width: 280,
                child: TextField(
                  key: Key("passwordInputKey"),
                  controller: passwordInputController,
                  onChanged: (value) {
                    setState(() {
                      _buttonStatus =
                          _handleButtonStatus(codeInputController.text, value);
                    });
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
                      borderSide:
                          BorderSide(color: Colors.grey.shade700, width: 1.0),
                    ),
                    filled: true,
                    contentPadding: EdgeInsets.fromLTRB(25, 0, 5, 0),
                    fillColor: Colors.grey.shade900,
                    labelStyle: TextStyle(color: Colors.white),
                    errorStyle: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400),
                    labelText: 'Password',
                  ),
                ),
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
                  key: Key("SubmitUpdatePasswordButtonKey"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white10),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0))),
                  ),
                  onPressed: () {
                    //! Add  disable button
                    context.read<ForgetPasswordCubit>().updatePasswordWithCode(
                        codeInputController.text,
                        passwordInputController.text,
                        emailInputController.text);
                  },
                  child: const Text("Change password",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          )
        ],
        true);
  }

  _sendNewPasswordMail(BuildContext context) {
    modalDialog(
        context,
        Center(
          child: const Text(
            'Reset your password',
            style: TextStyle(color: Colors.white),
          ),
        ),
        SingleChildScrollView(
          child: Text(
            'You have changed your password with success.',
            style: TextStyle(color: Colors.white, fontSize: 15),
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
                  key: Key("Close"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white10),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0))),
                  ),
                  onPressed: () {
                    context.vRouter.to("/");
                  },
                  child: const Text("Close",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ),
        ],
        true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white70),
          backgroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),
        body: BlocProvider(
          create: (context) => ForgetPasswordCubit(widget.repository),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black87,
            child: BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
              listener: (context, state) {
                if (state is ForgetPasswordSendCodeMail) {
                  if (state.status) _sendCodeMail(context);
                } else if (state is ForgetPasswordUpdateWithCode) {
                  if (state.status) {
                    context.vRouter.pop();
                    _sendNewPasswordMail(context);
                  }
                } else if (state is ForgetPasswordError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error,
                          style: TextStyle(color: Colors.red)),
                    ),
                  );
                }
              },
              builder: (context, state) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 50, 0, 160),
                      child: Text(
                        "Reset your password",
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w400,
                            color: Colors.white),
                      ),
                    ),
                    Padding(
                      //!Center
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: Container(
                        width: 280,
                        child: Text(
                          "Please enter your email to receive a mail with a code to reset your password",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 25),
                      width: 280,
                      child: TextField(
                        key: Key("forgotEmailInputKey"),
                        controller: emailInputController,
                        onChanged: (value) {
                          setState(() {
                            _buttonStatus = value.isNotEmpty;
                          });
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
                            borderSide: BorderSide(
                                color: Colors.grey.shade700, width: 1.0),
                          ),
                          filled: true,
                          contentPadding: EdgeInsets.fromLTRB(25, 0, 5, 0),
                          fillColor: Colors.black26,
                          labelStyle: TextStyle(color: Colors.white),
                          errorStyle: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w400),
                          labelText: 'Email',
                        ),
                      ),
                    ),
                    Container(
                      width: 280,
                      height: 50,
                      child: ElevatedButton(
                        key: Key("SubmitButtonKey"),
                        onPressed: _buttonStatus
                            ? () {
                                context
                                    .read<ForgetPasswordCubit>()
                                    .sendEmailCode(emailInputController.text);
                              }
                            : null,
                        child: Text(
                          "Confirm",
                          style: TextStyle(fontSize: 22),
                        ),
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black26),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
