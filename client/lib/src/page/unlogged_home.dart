import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_room/src/bloc/auth/auth_bloc.dart';
import 'package:vrouter/vrouter.dart';

class UnloggedHome extends StatelessWidget {
  const UnloggedHome({Key? key}) : super(key: key);

  static const NavigateToSigninButtonKey = Key("navigateToSignin");
  static const NavigateToSignupButtonKey = Key("navigateToSignup");

  void navigateToSignup(BuildContext context) {
    context.vRouter.to("/signup");
  }

  void navigateToSignin(BuildContext context) {
    context.vRouter.to("/signin");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage('assets/images/background_home.png'),
            ),
          ),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state.status == AuthStatus.authenticated) {
                    context.vRouter.to("/");
                  }
                },
                child: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(25, 20, 0, 0),
                            child: Text(
                              "Music Room",
                              style: TextStyle(
                                  fontSize: 35, color: Colors.white70),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                          child: Column(
                        children: [
                          ConstrainedBox(
                            constraints:
                                BoxConstraints.tightFor(width: 200, height: 50),
                            child: ElevatedButton(
                              key: NavigateToSignupButtonKey,
                              onPressed: () => navigateToSignup(context),
                              child: Text(
                                "Signup",
                                style: TextStyle(color: Colors.black),
                              ),
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                  ),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.white)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: ConstrainedBox(
                              constraints: BoxConstraints.tightFor(
                                  width: 200, height: 50),
                              child: ElevatedButton(
                                key: NavigateToSigninButtonKey,
                                onPressed: () => navigateToSignin(context),
                                child: Text(
                                  "Signin",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      ),
                                    ),
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.grey.shade900)),
                              ),
                            ),
                          ),
                        ],
                      )),
                      Text(
                        "by dihauet",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
