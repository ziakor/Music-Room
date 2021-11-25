import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_room/src/bloc/playlist/playlist_bloc.dart';
import 'package:music_room/src/data/repository/playlist_repository.dart';
import 'package:music_room/src/data/repository/room_repository.dart';
import 'package:music_room/src/page/home/playlist/create_playlist.dart';
import 'package:music_room/src/page/home/playlist/playlist_container.dart';
import 'package:music_room/src/ui/widgets/right_license/right_license_container.dart';
import 'package:music_room/src/ui/widgets/users_settings_container.dart';

class Playlist extends StatefulWidget {
  final PlaylistRepository playlistRepository;
  const Playlist({
    Key? key,
    required this.playlistRepository,
  }) : super(key: key);

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  @override
  void initState() {
    if (context.read<PlaylistBloc>().state.currentPlaylist.isNotEmpty) {
      //! A REVOIR LUTILITE
      // context.read<PlaylistBloc>().add(UpdateInvitationCode(
      //     context.read<PlaylistBloc>().state.currentPlaylist.id));
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
        child: BlocBuilder<PlaylistBloc, PlaylistState>(
          buildWhen: (previous, current) =>
              previous.currentPlaylist != current.currentPlaylist,
          builder: (context, state) {
            if (context.read<PlaylistBloc>().state.currentPlaylist.isNotEmpty) {
              return PlaylistContainer(
                playlist: context.read<PlaylistBloc>().state.currentPlaylist,
                playlistRepository: widget.playlistRepository,
              );
            } else {
              return CreatePlaylist();
            }
          },
        ),
      ),
    );
  }
}
