import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:music_room/src/data/repository/room_repository.dart';
import 'package:music_room/src/data/repository/user_repository.dart';
import 'package:music_room/src/data/service/api_service.dart';
import 'package:music_room/src/page/forgot_password.dart';
import 'package:music_room/src/page/home/home_page.dart';
import 'package:music_room/src/page/settings.dart';
import 'package:music_room/src/page/signin.dart';
import 'package:music_room/src/page/signup.dart';
import 'package:music_room/src/page/unlogged_home.dart';
import 'package:music_room/src/ui/widgets/user_profile.dart';
import 'package:vrouter/vrouter.dart';
import 'bloc/auth/auth_bloc.dart';
import 'data/repository/playlist_repository.dart';
import 'data/service/firebase_service.dart';

class RouterApp extends StatefulWidget {
  const RouterApp({Key? key}) : super(key: key);

  @override
  _RouterAppState createState() => _RouterAppState();
}

class _RouterAppState extends State<RouterApp> {
  final firebaseService = FirebaseService(FirebaseAuth.instance,
      FirebaseFirestore.instance, GoogleSignIn(), FacebookAuth.instance);
  final apiService = ApiService(
    Dio(
      BaseOptions(
        baseUrl: 'http://10.0.2.2:3000',
        connectTimeout: 5000,
        receiveTimeout: 3000,
      ),
    ),
  );
  late UserRepository repository = UserRepository(firebaseService, apiService);
  late RoomRepository roomRepository =
      RoomRepository(firebaseService, apiService);
  late PlaylistRepository playlistRepository =
      PlaylistRepository(firebaseService, apiService);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(userRepository: repository),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return VRouter(
            routes: [
              VGuard(
                beforeEnter: (vRedirector) async {
                  context.read<AuthBloc>().add(AuthDataRequested());
                  if (context.read<AuthBloc>().state.status ==
                      AuthStatus.authenticated) {
                    return (null);
                  }
                  return (vRedirector.to('/home'));
                },
                stackedRoutes: [
                  VWidget(
                      path: "/",
                      widget: HomePage(
                        roomRepository: roomRepository,
                        playlistRepository: playlistRepository,
                        userRepository: repository,
                      ),
                      stackedRoutes: [
                        VWidget(
                          path: "/settings",
                          widget: SettingsPage(
                            userRepository: repository,
                          ),
                        ),
                        VWidget(
                            path: "/profil/:id",
                            widget: UserProfile(
                              userRepository: repository,
                            )),
                      ]),
                ],
              ),
              VGuard(
                  beforeEnter: (vRedirector) async =>
                      context.read<AuthBloc>().state.status ==
                              AuthStatus.not_authenticated
                          ? null
                          : vRedirector.to('/'),
                  stackedRoutes: [
                    VWidget(
                        path: "/home",
                        widget: UnloggedHome(),
                        stackedRoutes: [
                          VWidget(
                            path: "/signup",
                            widget: Signup(
                              repo: repository,
                            ),
                          ),
                          VWidget(
                            path: "/signin",
                            widget: Signin(
                              userRepository: repository,
                            ),
                            stackedRoutes: [
                              VWidget(
                                  path: "/forgot",
                                  widget: ForgotPassword(
                                    repository: repository,
                                  ))
                            ],
                          ),
                        ]),
                  ]),
            ],
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
