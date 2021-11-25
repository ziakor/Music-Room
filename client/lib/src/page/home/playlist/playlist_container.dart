import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:music_room/src/bloc/auth/auth_bloc.dart';
import 'package:music_room/src/bloc/playlist/playlist_bloc.dart';
import 'package:music_room/src/cubit/playlist_socket/playlist_socket_cubit.dart';
import 'package:music_room/src/data/model/current_song.dart';
import 'package:music_room/src/data/model/playlist.dart' as pm;
import 'package:music_room/src/data/model/right_license.dart';
import 'package:music_room/src/data/model/room_user.dart';
import 'package:music_room/src/data/repository/playlist_repository.dart';
import 'package:music_room/src/ui/widgets/music_player.dart';
import 'package:music_room/src/ui/widgets/right_license/right_license_container.dart';
import 'package:music_room/src/ui/widgets/search_song.dart';
import 'package:music_room/src/ui/widgets/users_settings_container.dart';
import 'package:music_room/utils/utils.dart';
import 'package:provider/provider.dart';

class PlaylistContainer extends StatefulWidget {
  const PlaylistContainer(
      {Key? key, required this.playlistRepository, required this.playlist})
      : super(key: key);
  final PlaylistRepository playlistRepository;
  final pm.Playlist playlist;
  @override
  _PlaylistContainerState createState() => _PlaylistContainerState();
}

class _PlaylistContainerState extends State<PlaylistContainer> {
  bool _showRightLicense = false;
  bool _showUsersSettings = false;
  late RoomUser myUser;
  CurrentSong currentSong = CurrentSong.empty;

  @override
  void initState() {
    super.initState();
    myUser = getRoomUser(widget.playlist.users,
        context.read<AuthBloc>().state.user.id, widget.playlist.isInvited);

    context.read<PlaylistSocketCubit>().joinPlaylist(
        widget.playlist.id, myUser.pseudo, myUser.role, myUser.isInvited);
  }

  bool _canAddSong(RoomUser user, RightLicense rightLicense) {
    bool res = true;
    if (user.role == 'Admin') {
      return true;
    }
    if (rightLicense.onlyInvitedEnabled) {
      if (user.role == 'User' && user.isInvited == true) {
        res = true;
      } else {
        return false;
      }
    }
    return res;
  }

  bool _isNotUser(String idUser) {
    final RoomUser user =
        widget.playlist.users.firstWhere(((element) => element.id == idUser));
    return (user.role == 'Admin');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlaylistSocketCubit, PlaylistSocketState>(
      listener: (context, state) {
        if (state is UserJoined) {
          if (state.user.id != context.read<AuthBloc>().state.user.id) {
            context
                .read<PlaylistBloc>()
                .add(AddUserToCurrentPlaylist(state.user));
          }
        } else if (state is UserLeaved) {
          context
              .read<PlaylistBloc>()
              .add(RemoveUserToCurrentPlaylist(state.userId));
        } else if (state is UpdateRightLicense) {
          context
              .read<PlaylistBloc>()
              .add(UpdateRightLicenseCurrentPlaylist(state.rightLicense));
        } else if (state is UserAddedSong) {
          context.read<PlaylistBloc>().add(AddSongToSongs(state.song));
        }
      },
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (_showRightLicense == true)
            RightLicenseContainer(
              roomRepository: null,
              playlistRepository: widget.playlistRepository,
              initialRightLicense: widget.playlist.rightLicense,
              uid: context.read<PlaylistBloc>().state.currentPlaylist.id,
              closeFunc: () {
                setState(() {
                  _showRightLicense = false;
                });
              },
              onUpdateRightLicenseFunc: (license) {
                context
                    .read<PlaylistSocketCubit>()
                    .updateRightLicense(widget.playlist.id, license);
              },
              isRoom: false,
            ),
          if (_showUsersSettings)
            UsersSettingsContainer(
              notUser: _isNotUser(context.read<AuthBloc>().state.user.id),
              invitationCode: widget.playlist.invitationCode,
              playlistRepository: widget.playlistRepository,
              roomRepository: null,
              id: context.read<PlaylistBloc>().state.currentPlaylist.id,
              users: widget.playlist.users,
              updateInvitationCodeFunc: (code) => context
                  .read<PlaylistBloc>()
                  .add(UpdateInvitationCode(widget.playlist.id, code)),
              updateUserRoleFunc: null,
              closeFunc: () {
                setState(() {
                  _showUsersSettings = false;
                });
              },
            ),
          Opacity(
            opacity:
                _showRightLicense == true || _showUsersSettings == true ? 0 : 1,
            child: IgnorePointer(
              ignoring: _showRightLicense == true || _showUsersSettings == true
                  ? true
                  : false,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.all(
                            Radius.circular(17),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isNotUser(
                                    context.read<AuthBloc>().state.user.id) ==
                                true)
                              IconButton(
                                splashRadius: 25,
                                tooltip: "Rights settings",
                                onPressed: () {
                                  setState(() {
                                    _showRightLicense = !_showRightLicense;
                                  });
                                },
                                icon: Icon(
                                  Icons.room_preferences,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                            IconButton(
                              splashRadius: 25,
                              tooltip: "Users settings",
                              onPressed: () {
                                setState(() {
                                  _showUsersSettings = !_showUsersSettings;
                                });
                              },
                              icon: Icon(
                                Icons.admin_panel_settings,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SearchSong(
                                list: context
                                    .read<PlaylistBloc>()
                                    .state
                                    .currentPlaylist
                                    .songs,
                                roomRepository: null,
                                playlistRepository: widget.playlistRepository,
                                onAddSong: (song) {
                                  context
                                      .read<PlaylistSocketCubit>()
                                      .addSong(widget.playlist.id, song);
                                },
                                canAddSong: _canAddSong(
                                  myUser.copyWith(
                                      isInvited: widget.playlist.isInvited),
                                  widget.playlist.rightLicense,
                                ))
                          ],
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: _showRightLicense == true ||
                              _showUsersSettings == true
                          ? 0
                          : 1,
                      child: MusicPlayer(
                        isRoom: false,
                        id: widget.playlist.id,
                        list: context
                            .read<PlaylistBloc>()
                            .state
                            .currentPlaylist
                            .songs,
                        song: currentSong,
                        listenFunc: (data) {
                          setState(() {
                            currentSong =
                                currentSong.copyWith(time: data.toDouble());
                          });
                        },
                        onPlayFunc: (status) {
                          setState(() {
                            currentSong = currentSong.copyWith(onPlay: status);
                          });
                        },
                        onVote: (note, name, author) {},
                        onDoubleTapSong: (song) {
                          setState(() {
                            currentSong =
                                currentSong.copyWith(time: 0, song: song);
                          });
                        },
                        hasMusicControl: true,
                        canVote: false,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
