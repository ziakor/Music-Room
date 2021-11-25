import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_room/src/bloc/auth/auth_bloc.dart';
import 'package:music_room/src/cubit/user_profile_cubit.dart';
import 'package:music_room/src/data/repository/user_repository.dart';
import 'package:music_room/src/ui/widgets/user_profile.dart';
import 'package:provider/src/provider.dart';
import 'package:vrouter/src/core/extended_context.dart';

class UsersList extends StatefulWidget {
  const UsersList({Key? key, required this.userRepository}) : super(key: key);
  final UserRepository userRepository;
  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  @override
  void initState() {
    // TODO: implement initState
    context.read<AuthBloc>().add(GetUsersList());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) => previous.users != current.users,
      builder: (context, state) {
        return SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black87,
            alignment: Alignment.center,
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Users list",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: Container(
                      height: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? 300
                          : 200,
                      width: 280,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                        // border: Border.all(),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: ListView.separated(
                            itemBuilder: (BuildContext context, int index) {
                              if (context
                                      .read<AuthBloc>()
                                      .state
                                      .users[index]
                                      .id ==
                                  context.read<AuthBloc>().state.user.id) {
                                return Container();
                              }
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                // height: 100,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade900,
                                    borderRadius: BorderRadius.circular(20)),
                                child: ListTile(
                                    onTap: () {
                                      context.vRouter.to(
                                          '/profil/${context.read<AuthBloc>().state.users[index].id}');
                                    },
                                    visualDensity: VisualDensity(
                                        horizontal: 0, vertical: -3),
                                    leading: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 15.0),
                                      child: Text(
                                        (index + 1).toString(),
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 17),
                                      ),
                                    ),
                                    title: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 16.0),
                                      child: Text(
                                        context
                                            .read<AuthBloc>()
                                            .state
                                            .users[index]
                                            .pseudo!,
                                        style: TextStyle(color: Colors.white),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    trailing: IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.badge_outlined,
                                            color: Colors.white70))),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const SizedBox(
                                height: 3,
                              );
                            },
                            itemCount:
                                context.read<AuthBloc>().state.users.length),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
