import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_room/src/bloc/auth/auth_bloc.dart';
import 'package:music_room/src/cubit/user_profile_cubit.dart';
import 'package:music_room/src/data/model/_user.dart';
import 'package:music_room/src/data/repository/user_repository.dart';
import 'package:provider/src/provider.dart';
import 'package:vrouter/src/core/extended_context.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key, required this.userRepository}) : super(key: key);
  final UserRepository userRepository;
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  User user = User.empty;

  bool _privateData(List<String>? friends, String id) {
    if (friends == null) return false;
    if (friends.contains(id)) {
      return true;
    }
    return false;
  }

  String _friendString(List<String> myFriends, List<String> hisFriends,
      String myId, String hisId) {
    if (myFriends.contains(hisId) && hisFriends.contains(myId)) {
      return "${user.pseudo} and you are friends";
    }
    if (!myFriends.contains(hisId) && hisFriends.contains(myId)) {
      return "You are in his friend list, add him!";
    }

    return "${user.pseudo} and you are not friend";
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserProfileCubit(widget.userRepository),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black87,
          elevation: 0,
        ),
        resizeToAvoidBottomInset: false,
        body: BlocListener<UserProfileCubit, UserProfileState>(
          listener: (context, state) {
            // TODO: implement listener
            if (state is GetUserProfile) {
              setState(() {
                user = state.userProfile;
              });
            } else if (state is UserProfileAddFriend) {
              context.read<AuthBloc>().add(AddFriend(state.friendId));
            } else if (state is UserProfileRemoveFriend) {
              context.read<AuthBloc>().add(RemoveFriend(state.friendId));
            }
          },
          child: SingleChildScrollView(
            child: Container(
              color: Colors.black87,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: SafeArea(
                child: BlocBuilder<UserProfileCubit, UserProfileState>(
                  builder: (context, state) {
                    if (user == User.empty) {
                      context.read<UserProfileCubit>().getUserProfile(
                          context.vRouter.pathParameters['id']!);
                    }

                    return Visibility(
                      visible: user != User.empty,
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).orientation ==
                                    Orientation.landscape
                                ? 0
                                : 150,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _friendString(
                                    context
                                            .read<AuthBloc>()
                                            .state
                                            .user
                                            .friends ??
                                        [],
                                    user.friends ?? [],
                                    context.read<AuthBloc>().state.user.id,
                                    user.id),
                                style: TextStyle(color: Colors.grey.shade400),
                              ),
                              !context
                                      .read<AuthBloc>()
                                      .state
                                      .user
                                      .friends!
                                      .contains(user.id)
                                  ? IconButton(
                                      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                      constraints: BoxConstraints(),
                                      onPressed: () {
                                        context
                                            .read<UserProfileCubit>()
                                            .addFriend(user.id);
                                      },
                                      icon: Icon(
                                        Icons.person_add_alt_1_sharp,
                                        color: Colors.grey.shade400,
                                      ),
                                    )
                                  : IconButton(
                                      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                      constraints: BoxConstraints(),
                                      onPressed: () {
                                        context
                                            .read<UserProfileCubit>()
                                            .removeFriend(user.id);
                                      },
                                      icon: Icon(
                                        Icons.person_remove_alt_1_sharp,
                                        color: Colors.grey.shade400,
                                      ),
                                    )
                            ],
                          ),
                          Container(
                            width: 280,
                            height: 100,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      user.pseudo ?? "",
                                      style: TextStyle(
                                          color: Colors.white60, fontSize: 25),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                  child: Container(
                                    height: 50,
                                    width: 220,
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 8, 8, 8),
                                      child: Text(
                                        user.bio ?? "",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Visibility(
                            visible: _privateData(user.friends,
                                context.read<AuthBloc>().state.user.id),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40.0),
                              child: Container(
                                width: 280,
                                height: 80,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Gender: ",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                        Text(
                                          user.gender ?? "",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Birth: ",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
                                          Text(
                                            user.birth == null
                                                ? "...."
                                                : "${user.birth!.month}/${user.birth!.day}/${user.birth!.year}",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
