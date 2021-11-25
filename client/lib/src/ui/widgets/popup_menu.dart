import 'package:flutter/material.dart';
import 'package:music_room/src/bloc/auth/auth_bloc.dart';
import 'package:music_room/src/cubit/room_socket/room_socket_cubit.dart';
import 'package:vrouter/vrouter.dart';
import 'package:provider/provider.dart';

class PopupMenu extends StatelessWidget {
  const PopupMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.black87,
        itemBuilder: (context) => [
              PopupMenuItem(
                child: TextButton(
                  onPressed: () => context.vRouter.to('/settings'),
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 3.0),
                          child: Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
                        ),
                        Text("Settings", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
              PopupMenuItem(
                child: TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 3.0),
                          child: Icon(Icons.logout, color: Colors.red),
                        ),
                        Text("Logout", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ),
              )
            ]);
  }
}
