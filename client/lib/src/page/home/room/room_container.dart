import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:music_room/src/bloc/auth/auth_bloc.dart';
import 'package:music_room/src/bloc/room/room_bloc.dart';
import 'package:music_room/src/cubit/room_socket/room_socket_cubit.dart';
import 'package:music_room/src/data/model/_room.dart';
import 'package:music_room/src/data/model/current_song.dart';
import 'package:music_room/src/data/model/playlist.dart';
import 'package:music_room/src/data/model/right_license.dart';
import 'package:music_room/src/data/model/room_user.dart';
import 'package:music_room/src/data/model/song.dart';
import 'package:music_room/src/data/repository/playlist_repository.dart';
import 'package:music_room/src/data/repository/room_repository.dart';
import 'package:music_room/src/ui/widgets/search_song.dart';
import 'package:music_room/src/ui/widgets/modal_dialog.dart';
import 'package:music_room/src/ui/widgets/music_player.dart';
import 'package:music_room/src/ui/widgets/right_license/right_license_container.dart';
import 'package:music_room/src/ui/widgets/users_settings_container.dart';
import 'package:music_room/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RoomContainer extends StatefulWidget {
  const RoomContainer({
    Key? key,
    required this.roomRepository,
    required this.room,
  }) : super(key: key);
  final RoomRepository roomRepository;
  final Room room;
  @override
  _RoomContainerState createState() => _RoomContainerState();
}

class _RoomContainerState extends State<RoomContainer> {
  bool _showRightLicense = false;
  bool _showUsersSettings = false;
  late RoomUser myUser;

  @override
  void initState() {
    super.initState();
    print(widget.room.isInvited);
    setState(() {
      myUser = myUser = getRoomUser(widget.room.users,
          context.read<AuthBloc>().state.user.id, widget.room.isInvited);
    });
    myUser = getRoomUser(widget.room.users,
        context.read<AuthBloc>().state.user.id, widget.room.isInvited);

    context.read<RoomSocketCubit>().joinRoom(
        widget.room.id, myUser.pseudo, myUser.role, widget.room.isInvited);
  }

  bool _canControlMusicPlayer(RoomUser user) {
    return user.role == 'Admin' || user.role == 'Modo' ? true : false;
  }

  bool _canVote(RoomUser user, RightLicense rightLicense, LatLng loc) {
    bool res = true;
    if (user.role == 'Admin' || user.role == 'Modo') {
      return true;
    }
    if (rightLicense.onlyInvitedEnabled) {
      if (user.role == 'User' && user.isInvited == true) {
        res = true;
      } else {
        return false;
      }
    }
    if (rightLicense.timeEnabled) {
      DateTime currentDateTime = DateTime.now();
      TimeOfDay startTimeOfDay = TimeOfDay(
        hour: (rightLicense.time.start / 60).floor(),
        minute: (rightLicense.time.start % 60),
      );
      DateTime start = DateTime(
        currentDateTime.year,
        currentDateTime.month,
        currentDateTime.day,
        startTimeOfDay.hour,
        startTimeOfDay.minute,
      );
      TimeOfDay endTimeOfDay = TimeOfDay(
        hour: (rightLicense.time.end / 60).floor(),
        minute: (rightLicense.time.end % 60),
      );
      DateTime end = DateTime(
        currentDateTime.year,
        currentDateTime.month,
        rightLicense.time.start > rightLicense.time.end
            ? currentDateTime.day + 1
            : currentDateTime.day,
        endTimeOfDay.hour,
        endTimeOfDay.minute,
      );

      if (currentDateTime.isAfter(start) && currentDateTime.isBefore(end)) {
        res = true;
      } else {
        return false;
      }
    }
    if (rightLicense.locationEnabled) {
      final Distance distance = Distance();
      final km = distance.as(
          LengthUnit.Kilometer,
          LatLng(
              rightLicense.location.latitude, rightLicense.location.longitude),
          loc);
      if (km < 2) {
        res = true;
      } else {
        return false;
      }
    }
    return res;
  }

  bool _isNotUser(String idUser) {
    final RoomUser user =
        widget.room.users.firstWhere(((element) => element.id == idUser));
    return (user.role == 'Admin');
  }

  @override
  Widget build(BuildContext context) {
    print(myUser);
    return BlocListener<RoomSocketCubit, RoomSocketState>(
      listener: (context, state) {
        if (state is CurrentSongStatusChanged) {
          context.read<RoomBloc>().add(UpdateOnPlayCurrentSong(state.status));
        } else if (state is CurrentSongTimeChanged) {
          context
              .read<RoomBloc>()
              .add(UpdateTimeCurrentSong(Duration(seconds: state.time)));
        } else if (state is UserAddedSong) {
          context.read<RoomBloc>().add(AddSongToSongs(state.song));
        } else if (state is UserVoteSong) {
          context
              .read<RoomBloc>()
              .add(UpdateVoteSong(state.grade, state.index, state.voteIndex));
        } else if (state is CurrentSongChanged) {
          context.read<RoomBloc>().add(UpdateCurrentSong(state.newSong));
        } else if (state is UpdateRightLicense) {
          context
              .read<RoomBloc>()
              .add(UpdateRightLicenseCurrentRoom(state.rightLicense));
        } else if (state is InvitationCodeUpdated) {
          context.read<RoomBloc>().add(UpdateInvitationCode(widget.room.id,
              invitationCode: state.invitationCode));
        } else if (state is RoleUserUpdated) {
          context
              .read<RoomBloc>()
              .add(UpdateUserRole(state.userId, state.role));
        } else if (state is UserJoined) {
          if (state.user.id != context.read<AuthBloc>().state.user.id) {
            context.read<RoomBloc>().add(AddUserToCurrentRoom(state.user));
          }
        } else if (state is UserLeaved) {
          context.read<RoomBloc>().add(RemoveUserToCurrentRoom(state.userId));
        }
      },
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (_showRightLicense == true)
            RightLicenseContainer(
              roomRepository: widget.roomRepository,
              playlistRepository: null,
              initialRightLicense: widget.room.rightLicense,
              uid: context.read<RoomBloc>().state.currentRoom.id,
              closeFunc: () {
                setState(() {
                  _showRightLicense = false;
                });
              },
              onUpdateRightLicenseFunc: (license) {
                context
                    .read<RoomSocketCubit>()
                    .updateRightLicense(widget.room.id, license);
              },
            ),
          if (_showUsersSettings == true)
            UsersSettingsContainer(
              notUser: _isNotUser(context.read<AuthBloc>().state.user.id),
              invitationCode: widget.room.invitationCode,
              playlistRepository: null,
              roomRepository: widget.roomRepository,
              id: context.read<RoomBloc>().state.currentRoom.id,
              users: widget.room.users,
              closeFunc: () {
                setState(() {
                  _showUsersSettings = false;
                });
              },
              updateInvitationCodeFunc: (code) {
                context
                    .read<RoomSocketCubit>()
                    .updateInvitationCode(widget.room.id, code);
              },
              updateUserRoleFunc: (String userId, String role) {
                context
                    .read<RoomSocketCubit>()
                    .updateUserRole(widget.room.id, userId, role);
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
                      child: Container(
                        alignment: Alignment.center,
                        height: double.maxFinite,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SearchSong(
                                list: context
                                    .read<RoomBloc>()
                                    .state
                                    .currentRoom
                                    .songs,
                                roomRepository: widget.roomRepository,
                                playlistRepository: null,
                                onAddSong: (song) {
                                  context
                                      .read<RoomSocketCubit>()
                                      .addSong(widget.room.id, song);
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: _showRightLicense == true ||
                              _showUsersSettings == true
                          ? 0
                          : 1,
                      child: BlocBuilder<RoomBloc, RoomState>(
                        builder: (context, state) {
                          return MusicPlayer(
                            isRoom: true,
                            id: widget.room.id,
                            list: context
                                .read<RoomBloc>()
                                .state
                                .currentRoom
                                .songs,
                            song: CurrentSong(
                              time: context
                                  .read<RoomBloc>()
                                  .state
                                  .currentRoom
                                  .currentSong
                                  .time,
                              onPlay: context
                                  .read<RoomBloc>()
                                  .state
                                  .currentRoom
                                  .currentSong
                                  .onPlay,
                              song: context
                                  .read<RoomBloc>()
                                  .state
                                  .currentRoom
                                  .currentSong
                                  .song,
                            ),
                            listenFunc: (data) => context
                                .read<RoomSocketCubit>()
                                .updateTimeSong(widget.room.id, data),
                            onPlayFunc: (status) {
                              context
                                  .read<RoomSocketCubit>()
                                  .playSong(widget.room.id, status);
                            },
                            onVote: (note, name, author) {
                              context
                                  .read<RoomSocketCubit>()
                                  .voteSong(widget.room.id, note, name, author);
                            },
                            onDoubleTapSong: (song) => context
                                .read<RoomSocketCubit>()
                                .updateCurrentSong(widget.room.id, song),
                            hasMusicControl: _canControlMusicPlayer(getRoomUser(
                                widget.room.users,
                                context.read<AuthBloc>().state.user.id,
                                widget.room.isInvited)),
                            canVote: _canVote(
                              myUser.copyWith(isInvited: widget.room.isInvited),
                              widget.room.rightLicense,
                              LatLng(
                                  context
                                      .read<AuthBloc>()
                                      .state
                                      .user
                                      .location!
                                      .latitude,
                                  context
                                      .read<AuthBloc>()
                                      .state
                                      .user
                                      .location!
                                      .longitude),
                            ),
                          );
                        },
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
