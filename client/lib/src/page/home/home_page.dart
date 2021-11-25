import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_room/src/cubit/playlist_socket/playlist_socket_cubit.dart';
import 'package:music_room/src/cubit/room_socket/room_socket_cubit.dart';
import 'package:music_room/src/data/model/_room.dart';
import 'package:music_room/src/data/repository/user_repository.dart';
import 'package:vrouter/vrouter.dart';

import 'package:music_room/src/bloc/auth/auth_bloc.dart';
import 'package:music_room/src/bloc/playlist/playlist_bloc.dart';
import 'package:music_room/src/bloc/room/room_bloc.dart';
import 'package:music_room/src/cubit/home/home_cubit.dart';
import 'package:music_room/src/data/model/playlist.dart';
import 'package:music_room/src/data/repository/playlist_repository.dart';
import 'package:music_room/src/data/repository/room_repository.dart';
import 'package:music_room/src/page/home/home.dart';
import 'package:music_room/src/page/home/users_list.dart';
import 'package:music_room/src/page/home/playlist/playlist.dart' as p;
import 'package:music_room/src/page/home/room/room.dart' as r;
import 'package:music_room/src/ui/widgets/popup_menu.dart';
import 'package:music_room/utils/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.roomRepository,
    required this.playlistRepository,
    required this.userRepository,
  }) : super(key: key);
  final RoomRepository roomRepository;
  final PlaylistRepository playlistRepository;
  final UserRepository userRepository;

  @override
  _HomePageState createState() => _HomePageState();
}

Widget getPageContainer(
    int index,
    RoomRepository roomRepository,
    PlaylistRepository playlistRepository,
    UserRepository userRepository,
    BuildContext context) {
  switch (index) {
    case 0:
      return (Home());
    case 1:
      return (UsersList(
        userRepository: userRepository,
      ));
    case 2:
      return (r.Room(
        roomRepository: roomRepository,
      ));
    case 3:
      return (p.Playlist(
        playlistRepository: playlistRepository,
      ));
    default:
      return (Home());
  }
}

String getPageName(int index) {
  switch (index) {
    case 0:
      return ("Music Room");
    case 1:
      return ("Message");
    case 2:
      return ("Room");
    case 3:
      return ("Playlist");
    default:
      return ("Home");
  }
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.not_authenticated) {
            context.vRouter.to("/home");
          }
        },
        child: MultiBlocProvider(
            providers: [
              BlocProvider(
                lazy: true,
                create: (context) =>
                    RoomSocketCubit(context.read<AuthBloc>().state.authToken),
              ),
              BlocProvider(
                lazy: true,
                create: (context) => PlaylistSocketCubit(
                    context.read<AuthBloc>().state.authToken),
              ),
              BlocProvider(
                lazy: false,
                create: (context) => HomeCubit(),
              ),
              BlocProvider(
                lazy: false,
                create: (context) =>
                    RoomBloc(roomRepository: widget.roomRepository),
              ),
              BlocProvider(
                lazy: false,
                create: (context) =>
                    PlaylistBloc(playlistRepository: widget.playlistRepository),
              ),
            ],
            child: MultiBlocListener(
              listeners: [
                BlocListener<RoomBloc, RoomState>(
                  listener: (context, state) {
                    if (state.currentRoom.isNotEmpty) {
                      context.read<HomeCubit>().changeIndex(2);
                    } else if (state.status == false &&
                        state.error.isNotEmpty) {
                      context.read<RoomBloc>().add(ResetRoomError());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.error,
                              style: TextStyle(color: Colors.red)),
                        ),
                      );
                    }
                  },
                ),
                BlocListener<PlaylistBloc, PlaylistState>(
                  listener: (context, state) {
                    if (state.currentPlaylist.isNotEmpty) {
                      context.read<HomeCubit>().changeIndex(3);
                    } else if (state.status == false &&
                        state.error.isNotEmpty) {
                      context.read<RoomBloc>().add(ResetRoomError());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.error,
                              style: TextStyle(color: Colors.red)),
                        ),
                      );
                    }
                  },
                ),
              ],
              child: BlocBuilder<HomeCubit, HomeState>(
                buildWhen: (previous, current) {
                  return (previous.index != current.index);
                },
                builder: (context, state) {
                  return Scaffold(
                    resizeToAvoidBottomInset: false,
                    appBar: context.read<HomeCubit>().state.index == 0
                        ? AppBar(
                            iconTheme: IconThemeData(color: Colors.white70),
                            backgroundColor: Colors.black87,
                            elevation: 0,
                            centerTitle: true,
                            title: Text(
                              getPageName(
                                  context.read<HomeCubit>().state.index),
                              style: TextStyle(
                                  fontSize: 35, fontWeight: FontWeight.w300),
                            ),
                            actions: [PopupMenu()],
                          )
                        : null,
                    body: getPageContainer(
                        context.read<HomeCubit>().state.index,
                        widget.roomRepository,
                        widget.playlistRepository,
                        widget.userRepository,
                        context),
                    bottomNavigationBar: BottomNavigationBar(
                        selectedItemColor: Colors.blue.shade500,
                        unselectedItemColor: Colors.white,
                        backgroundColor: Color(0xff2b2b2b),
                        type: BottomNavigationBarType.fixed,
                        currentIndex: context.read<HomeCubit>().state.index,
                        onTap: (index) {
                          if (context.read<HomeCubit>().state.index == 2 &&
                              context
                                  .read<RoomBloc>()
                                  .state
                                  .currentRoom
                                  .isNotEmpty) {
                            confirmBeforeLeave(
                              context,
                              'Room',
                              'Are you sure to leave the room ?',
                              () {
                                context.read<RoomSocketCubit>().leaveRoom(
                                    context
                                        .read<RoomBloc>()
                                        .state
                                        .currentRoom
                                        .id);
                                context
                                    .read<RoomBloc>()
                                    .add(UpdateCurrentRoom(Room.empty));
                                context.vRouter.pop();
                                context.read<HomeCubit>().changeIndex(index);
                              },
                              () => context.vRouter.pop(),
                            );
                          } else if (context.read<HomeCubit>().state.index ==
                                  3 &&
                              context
                                      .read<PlaylistBloc>()
                                      .state
                                      .currentPlaylist
                                      .isNotEmpty ==
                                  true) {
                            confirmBeforeLeave(context, 'Playlist',
                                'Are you sure to leave the playlist ?', () {
                              context.read<PlaylistSocketCubit>().leavePlaylist(
                                  context
                                      .read<PlaylistBloc>()
                                      .state
                                      .currentPlaylist
                                      .id);
                              context
                                  .read<PlaylistBloc>()
                                  .add(UpdateCurrentPlaylist(Playlist.empty));
                              context.vRouter.pop();
                              context.read<HomeCubit>().changeIndex(index);
                            }, () => context.vRouter.pop());
                          } else {
                            context.read<HomeCubit>().changeIndex(index);
                          }
                        },
                        items: [
                          BottomNavigationBarItem(
                              icon: Icon(
                                Icons.home,
                              ),
                              label: "Home"),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.account_circle),
                            label: "Users",
                          ),
                          BottomNavigationBarItem(
                              icon: Icon(
                                Icons.headset,
                              ),
                              label: "Room"),
                          BottomNavigationBarItem(
                              icon: Icon(
                                Icons.library_music,
                              ),
                              label: "Playlist"),
                        ]),
                  );
                },
              ),
            )),
      ),
    );
  }
}
