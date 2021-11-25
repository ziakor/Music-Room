import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_room/src/bloc/users_settings/users_settings_bloc.dart';
import 'package:music_room/src/data/model/room_user.dart';
import 'package:music_room/src/data/repository/playlist_repository.dart';
import 'package:music_room/src/data/repository/room_repository.dart';

class UsersSettingsContainer extends StatefulWidget {
  const UsersSettingsContainer({
    Key? key,
    required this.invitationCode,
    required this.playlistRepository,
    required this.roomRepository,
    required this.id,
    required this.users,
    required this.closeFunc,
    required this.updateInvitationCodeFunc,
    required this.updateUserRoleFunc,
    required this.notUser,
  }) : super(key: key);
  final String id;
  final bool notUser;
  final List<RoomUser> users;
  final String invitationCode;
  final PlaylistRepository? playlistRepository;
  final RoomRepository? roomRepository;
  final void Function()? closeFunc;
  final void Function(String code)? updateInvitationCodeFunc;
  final void Function(String role, String userId)? updateUserRoleFunc;
  @override
  _UsersSettingsContainerState createState() => _UsersSettingsContainerState();
}

class _UsersSettingsContainerState extends State<UsersSettingsContainer> {
  final TextEditingController _invitationCodeController =
      TextEditingController();
  late List<RoomUser> usersSorted;
  final FocusNode _invitationCodeNode = FocusNode();

  Future<void> _copyToClipboard(String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  List<DropdownMenuItem<String>> _dropDownItems() {
    return (<String>['Modo', 'User']
        .map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value, style: TextStyle(color: Colors.white)),
      );
    }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocProvider(
        create: (context) => UsersSettingsBloc(
          playlistRepository: widget.playlistRepository,
          roomRepository: widget.roomRepository,
          initialInvitationCode: widget.invitationCode,
          initialUsersList: widget.users,
        ),
        child: BlocBuilder<UsersSettingsBloc, UsersSettingsState>(
          buildWhen: (previous, current) {
            if (previous.invitationCode != current.invitationCode) {
              if (widget.updateInvitationCodeFunc != null) {
                widget.updateInvitationCodeFunc!(current.invitationCode);
              }
            }
            return (previous != current);
          },
          builder: (context, state) {
            return Column(
              children: [
                Container(
                  alignment: Alignment.topRight,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                    child: IconButton(
                        onPressed: widget.closeFunc,
                        icon:
                            Icon(Icons.close, size: 40, color: Colors.black38)),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                if (widget.notUser == true)
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    width: 280,
                    child: TextFormField(
                      controller: _invitationCodeController
                        ..text = context
                            .read<UsersSettingsBloc>()
                            .state
                            .invitationCode,
                      focusNode: _invitationCodeNode,
                      onTap: () => _invitationCodeNode.unfocus(),
                      enableInteractiveSelection: false,
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30.0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(30.0),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(30.0),
                          ),
                          borderSide:
                              BorderSide(color: Colors.white, width: 1.0),
                        ),
                        filled: true,
                        fillColor: Colors.black26,
                        labelText: "Invitation code",
                        contentPadding: EdgeInsets.fromLTRB(25, 0, 5, 0),
                        labelStyle: TextStyle(color: Colors.white60),
                        prefixIcon: IconButton(
                            onPressed: () {
                              context
                                  .read<UsersSettingsBloc>()
                                  .add(UpdateInvitationCode(widget.id));
                            },
                            icon: Icon(
                              Icons.refresh,
                              color: Colors.white60,
                            )),
                        suffixIcon: IconButton(
                          onPressed: () {
                            _copyToClipboard(_invitationCodeController.text,
                                'Copied to clipboard');
                          },
                          icon: Icon(
                            Icons.content_copy,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                      style: TextStyle(color: Colors.white60),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Container(
                    height: 300,
                    width: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      color: Colors.black26,
                      // border: Border.all(),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text(
                              "N°",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17),
                            ),
                          ),
                          horizontalTitleGap: 0,
                          minVerticalPadding: 0,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "Pseudo",
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                "Role",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 7.0),
                          child: Container(
                            width: double.maxFinite,
                            height: 1,
                            color: Colors.black45,
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ListView.separated(
                                itemBuilder: (BuildContext context, int index) {
                                  return Opacity(
                                    opacity: context
                                                .read<UsersSettingsBloc>()
                                                .state
                                                .listUser[index]
                                                .role !=
                                            "Admin"
                                        ? 1
                                        : 0.2,
                                    child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      // height: 100,
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade900,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: ListTile(
                                        visualDensity: VisualDensity(
                                            horizontal: 0, vertical: -3),
                                        leading: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15.0),
                                          child: Text(
                                            (index + 1).toString(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17),
                                          ),
                                        ),
                                        title: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16.0),
                                          child: Text(
                                            context
                                                .read<UsersSettingsBloc>()
                                                .state
                                                .listUser[index]
                                                .pseudo,
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        trailing: context
                                                    .read<UsersSettingsBloc>()
                                                    .state
                                                    .listUser[index]
                                                    .role !=
                                                "Admin"
                                            ? DropdownButton(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20)),
                                                value: context
                                                    .read<UsersSettingsBloc>()
                                                    .state
                                                    .listUser[index]
                                                    .role,
                                                onChanged: widget.notUser
                                                    ? (String? newValue) {
                                                        context
                                                            .read<
                                                                UsersSettingsBloc>()
                                                            .add(UpdateUserRole(
                                                                widget.id,
                                                                index,
                                                                newValue!));
                                                        if (widget
                                                                .updateUserRoleFunc !=
                                                            null) {
                                                          widget
                                                              .updateUserRoleFunc!(
                                                            context
                                                                .read<
                                                                    UsersSettingsBloc>()
                                                                .state
                                                                .listUser[index]
                                                                .id,
                                                            newValue,
                                                          );
                                                        }
                                                      }
                                                    : null,
                                                dropdownColor: Colors.black87,
                                                items: _dropDownItems(),
                                              )
                                            : DropdownButton(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20)),
                                                value: 'Admin',
                                                onChanged: null,
                                                dropdownColor: Colors.black87,
                                                items: [
                                                  DropdownMenuItem<String>(
                                                    value: 'Admin',
                                                    child: Text('Admin',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  )
                                                ],
                                              ),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return const SizedBox(
                                    height: 3,
                                  );
                                },
                                itemCount: context
                                    .read<UsersSettingsBloc>()
                                    .state
                                    .listUser
                                    .length),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
