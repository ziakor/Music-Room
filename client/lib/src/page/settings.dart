import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:music_room/src/bloc/auth/auth_bloc.dart';
import 'package:music_room/src/bloc/settings/settings_bloc.dart';
import 'package:music_room/src/cubit/home/home_cubit.dart';
import 'package:music_room/src/data/model/_user.dart';
import 'package:music_room/src/data/repository/user_repository.dart';
import 'package:music_room/src/mixins/validation_mixins.dart';
import 'package:music_room/src/page/home/home.dart';
import 'package:music_room/src/page/home/users_list.dart';
import 'package:music_room/src/page/home/playlist/playlist.dart';
import 'package:music_room/src/page/home/room/room.dart';
import 'package:music_room/src/ui/widgets/bio_input.dart';
import 'package:music_room/src/ui/widgets/birth_input.dart';
import 'package:music_room/src/ui/widgets/email_input.dart';
import 'package:music_room/src/ui/widgets/gender_input.dart';
import 'package:music_room/src/ui/widgets/musical_interests_input.dart';
import 'package:music_room/src/ui/widgets/password_input.dart';
import 'package:music_room/src/ui/widgets/popup_menu.dart';
import 'package:music_room/src/ui/widgets/pseudo_input.dart';
import 'package:music_room/utils/place_picker/lib/widgets/place_picker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    Key? key,
    required this.userRepository,
  }) : super(key: key);
  final UserRepository userRepository;
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isScrollable = true;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc(userRepository: widget.userRepository),
      child: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state.status == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 2),
                content: Text("Your informations has been updated.",
                    style: TextStyle(color: Colors.green)),
              ),
            );
            context.read<AuthBloc>().add(AuthUserDataChanged(
                  user: User(
                    id: context.read<AuthBloc>().state.user.id,
                    pseudo: state.pseudo.isNotEmpty
                        ? state.pseudo
                        : context.read<AuthBloc>().state.user.pseudo,
                    email: state.email.isNotEmpty
                        ? state.email
                        : context.read<AuthBloc>().state.user.email,
                    bio: state.bio.isNotEmpty
                        ? state.bio
                        : context.read<AuthBloc>().state.user.bio,
                    birth: state.birth ??
                        context.read<AuthBloc>().state.user.birth,
                    gender: state.gender.isNotEmpty
                        ? state.gender
                        : context.read<AuthBloc>().state.user.gender,
                    musicalInterests: state.musicalInterests ??
                        context.read<AuthBloc>().state.user.musicalInterests,
                    location: state.location != GeoPoint(0, 0)
                        ? state.location
                        : context.read<AuthBloc>().state.user.location,
                  ),
                ));
          } else if (state.status == false && state.error.isNotEmpty) {
            context.read<SettingsBloc>().add(UpdateError(error: ''));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 5),
                content: Text(state.error, style: TextStyle(color: Colors.red)),
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white70),
            backgroundColor: Colors.black87,
            elevation: 0,
            centerTitle: true,
            title: Text(
              "Settings",
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.w300),
            ),
            actions: [
              BlocBuilder<SettingsBloc, SettingsState>(
                buildWhen: (previous, current) =>
                    previous.buttonStatus != current.buttonStatus,
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.all(7),
                    child: TextButton(
                      key: Key("SettingsUpdateButtonKey"),
                      onPressed: !state.buttonStatus
                          ? null
                          : () {
                              context
                                  .read<SettingsBloc>()
                                  .add(UpdateSendForm());
                            },
                      child: Text("Update",
                          style: state.buttonStatus
                              ? TextStyle(color: Colors.green)
                              : null),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.black38),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Container(
            padding: EdgeInsets.only(top: 20),
            color: Colors.black87,
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              physics:
                  _isScrollable == true ? null : NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 30, 0, 50),
                    width: 270,
                    child: Text(
                      "To update email or password, you must enter your current password.",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  BlocBuilder<SettingsBloc, SettingsState>(
                    buildWhen: (previous, current) =>
                        previous.pseudo != current.pseudo,
                    builder: (context, state) {
                      return PseudoInput(
                        updateFunc: (data) => context
                            .read<SettingsBloc>()
                            .add(UpdatePseudo(pseudo: data)),
                        textFormKey: Key("SettingsPseudoInput"),
                        initialValue:
                            context.read<AuthBloc>().state.user.pseudo ?? "",
                        pseudoAvailable:
                            context.read<SettingsBloc>().state.pseudoAvailable,
                      );
                    },
                  ),
                  BlocBuilder<SettingsBloc, SettingsState>(
                    buildWhen: (previous, current) =>
                        previous.gender != current.gender,
                    builder: (context, state) {
                      return GenderInput(
                          updateFunc: (data) {
                            context
                                .read<SettingsBloc>()
                                .add(UpdateGender(gender: data));
                          },
                          currentValue: state.gender.isNotEmpty
                              ? state.gender
                              : context.read<AuthBloc>().state.user.gender ??
                                  "");
                    },
                  ),
                  BlocBuilder<SettingsBloc, SettingsState>(
                    buildWhen: (previous, current) =>
                        previous.bio != current.bio,
                    builder: (context, state) {
                      return BioInput(
                          onChangedFunc: (data) {
                            context
                                .read<SettingsBloc>()
                                .add(UpdateBio(bio: data));
                          },
                          textFormKey: Key("SettingsBioInput"),
                          initialValue:
                              context.read<AuthBloc>().state.user.bio ?? "");
                    },
                  ),
                  BlocBuilder<SettingsBloc, SettingsState>(
                    buildWhen: (previous, current) =>
                        previous.email != current.email,
                    builder: (context, state) {
                      return EmailInput(
                        updateFunc: (data) => context
                            .read<SettingsBloc>()
                            .add(UpdateEmail(email: data)),
                        formKey: Key("SettingsEmailInput"),
                        initialValue:
                            context.read<AuthBloc>().state.user.email ?? "",
                      );
                    },
                  ),
                  BlocBuilder<SettingsBloc, SettingsState>(
                    buildWhen: (previous, current) =>
                        previous.birth != current.birth,
                    builder: (context, state) {
                      return BirthInput(
                          updateFunc: (data) {
                            context
                                .read<SettingsBloc>()
                                .add(UpdateBirth(birth: data));
                          },
                          formKey: Key("SettingsBirthInputKey"),
                          value: state.birth ??
                              context.read<AuthBloc>().state.user.birth);
                    },
                  ),
                  BlocBuilder<SettingsBloc, SettingsState>(
                    buildWhen: (previous, current) =>
                        previous.currentPassword != current.currentPassword,
                    builder: (context, state) {
                      return PasswordInput(
                        validationFunc: (data) {
                          if (!ValidationMixin().validatePassword(data!)) {
                            context.read<SettingsBloc>().add(
                                UpdateCurrentPassword(currentPassword: ""));
                            return ("Invalid password");
                          }

                          context.read<SettingsBloc>().add(
                              UpdateCurrentPassword(currentPassword: data));
                          return null;
                        },
                        onSavedFunc: null,
                        onChangedFunc: null,
                        textFormKey: Key("SettingsCurrentPasswordInput"),
                        initialValue: null,
                        labelText: "Password",
                      );
                    },
                  ),
                  BlocBuilder<SettingsBloc, SettingsState>(
                    buildWhen: (previous, current) =>
                        previous.newPassword != current.newPassword,
                    builder: (context, state) {
                      return PasswordInput(
                        validationFunc: (data) {
                          if (!ValidationMixin().validatePassword(data!)) {
                            context
                                .read<SettingsBloc>()
                                .add(UpdateNewPassword(newPassword: ""));
                            return ("Invalid password");
                          }

                          context
                              .read<SettingsBloc>()
                              .add(UpdateNewPassword(newPassword: data));
                          return null;
                        },
                        onSavedFunc: null,
                        onChangedFunc: null,
                        textFormKey: Key("SettingsPasswordInput"),
                        initialValue: null,
                        labelText: "New password",
                      );
                    },
                  ),
                  BlocBuilder<SettingsBloc, SettingsState>(
                    buildWhen: (previous, current) =>
                        previous.musicalInterests != current.musicalInterests,
                    builder: (context, state) {
                      return MusicalInterestsInput(
                          updateFunc: (data) {
                            context.read<SettingsBloc>().add(
                                UpdateMusicalInterests(musicalInterests: data));
                          },
                          formKey: Key("SettingsMusicalInterestsInput"),
                          listInterests: state.musicalInterests ??
                              context
                                  .read<AuthBloc>()
                                  .state
                                  .user
                                  .musicalInterests!);
                    },
                  ),
                  BlocBuilder<SettingsBloc, SettingsState>(
                    buildWhen: (previous, current) =>
                        previous.location != current.location,
                    builder: (context, state) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                        child: GestureDetector(
                          onTapDown: (data) {
                            setState(() {
                              _isScrollable = false;
                            });
                          },
                          onTapUp: (data) {
                            setState(() {
                              _isScrollable = true;
                            });
                          },
                          onTapCancel: () {
                            setState(() {
                              _isScrollable = true;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 0),
                            height: 280,
                            width: 280,
                            child: PlacePicker(
                              'AIzaSyAH6wf3RqwdOBaB8zEmw6SdBOinVOMjJEA',
                              displayLocation: LatLng(
                                state.location != GeoPoint(0, 0)
                                    ? state.location.latitude
                                    : context
                                        .read<AuthBloc>()
                                        .state
                                        .user
                                        .location!
                                        .latitude,
                                state.location != GeoPoint(0, 0)
                                    ? state.location.longitude
                                    : context
                                        .read<AuthBloc>()
                                        .state
                                        .user
                                        .location!
                                        .longitude,
                              ),
                              updateLocation: (location) {
                                if (location != null) {
                                  context.read<SettingsBloc>().add(
                                        UpdateLocation(location: location),
                                      );
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  BlocBuilder<SettingsBloc, SettingsState>(
                    builder: (context, state) {
                      return Container(
                          width: 280,
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  "To link your account with google, click below",
                                  style: TextStyle(color: Colors.black87),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<SettingsBloc>()
                                      .add(LinkToGoogle());
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
                            ],
                          ));
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
