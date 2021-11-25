import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_room/src/bloc/auth/auth_bloc.dart';
import 'package:music_room/src/bloc/room/room_bloc.dart';
import 'package:music_room/src/cubit/home/home_cubit.dart';
import 'package:music_room/src/cubit/room_socket/room_socket_cubit.dart';
import 'package:music_room/src/ui/widgets/modal_dialog.dart';
import 'package:vrouter/src/core/extended_context.dart';

class ListRoom extends StatefulWidget {
  const ListRoom({Key? key}) : super(key: key);

  @override
  State<ListRoom> createState() => _ListRoomState();
}

class _ListRoomState extends State<ListRoom> {
  final TextEditingController _invitationcodeInputController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<RoomBloc>().add(UpdateListRooms());
  }

  void _onClickRoom(int index) {
    context.read<RoomBloc>().add(JoinRoom(
        context.read<RoomBloc>().state.listRooms[index].id,
        context.read<AuthBloc>().state.user.pseudo!));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 300,
      ),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      margin: EdgeInsets.fromLTRB(30, 10, 30, 15),
      child: BlocBuilder<RoomBloc, RoomState>(
        buildWhen: (previous, current) =>
            previous.listRooms != current.listRooms,
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: ListTile(
                  contentPadding: EdgeInsets.only(left: 30),
                  visualDensity: VisualDensity(horizontal: 0, vertical: -3),
                  title: Text(
                    "Room",
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: "Invitation code",
                        padding: EdgeInsets.zero,
                        iconSize: 35,
                        onPressed: () => {
                          modalDialog(
                              context,
                              Center(
                                child: const Text(
                                  'Invitation code',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Text(
                                      'Enter the invitation code to join a room.',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 15, 0, 0),
                                      width: 280,
                                      child: TextField(
                                        key: Key("CodeInputKey"),
                                        controller:
                                            _invitationcodeInputController,
                                        decoration: InputDecoration(
                                          alignLabelWithHint: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(30.0),
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(30.0),
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(30.0),
                                            ),
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade700,
                                                width: 1.0),
                                          ),
                                          filled: true,
                                          contentPadding:
                                              EdgeInsets.fromLTRB(25, 0, 5, 0),
                                          fillColor: Colors.grey.shade900,
                                          labelStyle:
                                              TextStyle(color: Colors.white),
                                          errorStyle: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.w400),
                                          labelText: 'Code',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(
                                    child: Container(
                                      width: 160,
                                      height: 45,
                                      child: OutlinedButton(
                                        key: Key("Close"),
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.white10),
                                          shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0))),
                                        ),
                                        onPressed: () {
                                          context.read<RoomBloc>().add(
                                              EnterRoomInvitationCode(
                                                  _invitationcodeInputController
                                                      .text,
                                                  context
                                                      .read<AuthBloc>()
                                                      .state
                                                      .user
                                                      .pseudo!));
                                          context.vRouter.pop();
                                        },
                                        child: const Text("Enter",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              true,
                              backgroundColors: Colors.black87)
                        },
                        icon: Icon(Icons.add_link),
                      ),
                      IconButton(
                        tooltip: "Refresh",
                        iconSize: 30,
                        onPressed: () =>
                            context.read<RoomBloc>().add(UpdateListRooms()),
                        icon: Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 9,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    height: 227,
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount:
                          context.read<RoomBloc>().state.listRooms.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(
                          height: 3,
                        );
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(20)),
                          child: ListTile(
                            visualDensity:
                                VisualDensity(horizontal: 0, vertical: -3),
                            minVerticalPadding: 0,
                            title: Text(
                              state.listRooms[index].name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.people,
                                  color: Colors.white,
                                ),
                                Text(
                                  (state.listRooms[index].users.length)
                                      .toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                )
                              ],
                            ),
                            onTap: () => _onClickRoom(index),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
