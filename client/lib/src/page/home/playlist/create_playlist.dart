import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_room/src/bloc/auth/auth_bloc.dart';
import 'package:music_room/src/bloc/playlist/playlist_bloc.dart';
import 'package:music_room/src/bloc/room/room_bloc.dart';
import 'package:music_room/src/ui/widgets/button.dart';
import 'package:music_room/src/ui/widgets/switch_input.dart';
import 'package:music_room/src/ui/widgets/text_input.dart';

class CreatePlaylist extends StatefulWidget {
  const CreatePlaylist({Key? key}) : super(key: key);

  @override
  _CreatePlaylistState createState() => _CreatePlaylistState();
}

class _CreatePlaylistState extends State<CreatePlaylist> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlaylistBloc, PlaylistState>(
      listener: (context, state) {
        if (context.read<PlaylistBloc>().state.creationFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error, style: TextStyle(color: Colors.red)),
            ),
          );
        }
      },
      buildWhen: (previous, current) =>
          previous.newPlaylist != current.newPlaylist,
      builder: (context, state) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Text(
                  "New playlist",
                  style: TextStyle(color: Colors.white, fontSize: 27),
                  textAlign: TextAlign.center,
                ),
              ),
              TextInput(
                onChangedFunc: (data) {
                  context.read<PlaylistBloc>().add(UpdateNewPlaylistName(data));
                },
                label: "Playlist name",
                initialValue: "",
                textFormKey: Key("InputNewRoomName"),
              ),
              SwitchInput(
                onChangedFunc: (data) {
                  context
                      .read<PlaylistBloc>()
                      .add(UpdateNewPlaylistPrivate(data));
                },
                label: "The playlist will be ",
                trueValue: "private",
                falseValue: "public",
                value: state.newPlaylist.private,
                width: 294,
                switchPadding: EdgeInsets.fromLTRB(12, 0, 0, 0),
              ),
              Button(
                  text: "Create",
                  buttonKey: Key("newRoomKey"),
                  onSubmitFunc: () =>
                      context.read<PlaylistBloc>().add(CreateNewPlaylist(
                            context.read<AuthBloc>().state.user.pseudo!,
                            context.read<AuthBloc>().state.user.id,
                          )),
                  isEnabled: context
                      .read<PlaylistBloc>()
                      .state
                      .newPlaylist
                      .name
                      .isNotEmpty)
            ],
          ),
        );
      },
    );
  }
}
