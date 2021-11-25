import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_room/src/bloc/auth/auth_bloc.dart';
import 'package:music_room/src/bloc/room/room_bloc.dart';
import 'package:music_room/src/cubit/room_socket/room_socket_cubit.dart';
import 'package:music_room/src/data/repository/playlist_repository.dart';
import 'package:music_room/src/data/repository/room_repository.dart';
import 'package:music_room/src/page/home/room/create_room.dart';
import 'package:music_room/src/page/home/room/room_container.dart';

class Room extends StatefulWidget {
  final RoomRepository roomRepository;
  const Room({
    Key? key,
    required this.roomRepository,
  }) : super(key: key);

  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> {
  @override
  void initState() {
    if (context.read<RoomBloc>().state.currentRoom.isNotEmpty) {
      context.read<RoomBloc>().add(
          UpdateInvitationCode(context.read<RoomBloc>().state.currentRoom.id));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black87,
      child: SafeArea(
        child: BlocBuilder<RoomBloc, RoomState>(
          builder: (context, state) {
            if (context.read<RoomBloc>().state.currentRoom.isNotEmpty) {
              return RoomContainer(
                room: context.read<RoomBloc>().state.currentRoom,
                roomRepository: widget.roomRepository,
              );
            } else {
              return CreateRoom();
            }
          },
        ),
      ),
    );
  }
}
