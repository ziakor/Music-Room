import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_room/src/bloc/auth/auth_bloc.dart';
import 'package:music_room/src/bloc/room/room_bloc.dart';
import 'package:music_room/src/ui/widgets/button.dart';
import 'package:music_room/src/ui/widgets/switch_input.dart';
import 'package:music_room/src/ui/widgets/text_input.dart';
import 'package:vrouter/src/core/extended_context.dart';

class CreateRoom extends StatefulWidget {
  const CreateRoom({Key? key}) : super(key: key);

  @override
  _CreateRoomState createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoomBloc, RoomState>(
      listener: (context, state) {
        if (context.read<RoomBloc>().state.creationFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error, style: TextStyle(color: Colors.red)),
            ),
          );
        }
      },
      buildWhen: (previous, current) => previous.newRoom != current.newRoom,
      builder: (context, state) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Text(
                  "New room",
                  style: TextStyle(color: Colors.white, fontSize: 27),
                  textAlign: TextAlign.center,
                ),
              ),
              TextInput(
                onChangedFunc: (data) {
                  context.read<RoomBloc>().add(UpdateNewRoomName(data));
                },
                label: "Room name",
                initialValue: "",
                textFormKey: Key("InputNewRoomName"),
              ),
              SwitchInput(
                onChangedFunc: (data) {
                  context.read<RoomBloc>().add(UpdateNewRoomPrivate(data));
                },
                label: "The room will be ",
                trueValue: "private",
                falseValue: "public",
                value: state.newRoom.private,
              ),
              Button(
                  text: "Create",
                  buttonKey: Key("newRoomKey"),
                  onSubmitFunc: () =>
                      context.read<RoomBloc>().add(CreateNewRoom(
                            context.read<AuthBloc>().state.user.id,
                            context.read<AuthBloc>().state.user.pseudo!,
                          )),
                  isEnabled:
                      context.read<RoomBloc>().state.newRoom.name.isNotEmpty)
            ],
          ),
        );
      },
    );
  }
}
