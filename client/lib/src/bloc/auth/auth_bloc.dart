import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:music_room/src/data/model/_user.dart';
import 'package:music_room/src/data/model/user_firestore.dart';
import 'package:music_room/src/data/repository/user_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(userRepository.currentUser.isNotEmpty
            ? AuthState.authenticated(userRepository.currentUser, "", [])
            : const AuthState.unauthenticated()) {
    _userSubscription = _userRepository.user.listen(_onUserChanged);
  }

  final UserRepository _userRepository;
  late final StreamSubscription _userSubscription;

  // @override
  // void onTransition(Transition<AuthEvent, AuthState> transition) {
  //   print(transition);
  //   super.onTransition(transition);
  // }

  void _onUserChanged(User user) => add(AuthUserChanged(user: user));
  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is AuthUserChanged) {
      yield await _mapUserChangedToState(event, state);
    } else if (event is AuthLogoutRequested) {
      yield await _mapUserLogoutRequested(state);
    } else if (event is AuthDataRequested) {
      yield await _mapUserDataRequested(state);
    } else if (event is AuthUserDataChanged) {
      yield AuthState.authenticated(event.user, state.authToken, state.users);
    } else if (event is GetAuthToken) {
    } else if (event is GetUsersList) {
      yield await _getUsersList();
    } else if (event is AddFriend) {
      List<String> t = List.from(state.user.friends ?? []);
      t.add(event.friendId);
      yield AuthState.authenticated(
          state.user.copyWith(friends: t), state.authToken, state.users);
    } else if (event is RemoveFriend) {
      List<String> t = List.from(state.user.friends ?? []);
      t.remove(event.friendId);
      yield AuthState.authenticated(
          state.user.copyWith(friends: t), state.authToken, state.users);
    } else if (event is GetAuthEmail) {
      final user = _userRepository.currentUser;
      final UserFirestore? firestoreData =
          await _userRepository.getFirestoreUserDataFromId(user.id);
      (AuthState.authenticated(
          user.copyWith(
            pseudo: firestoreData!.pseudo,
            birth: firestoreData.birth.toDate(),
            gender: firestoreData.gender,
            musicalInterests: firestoreData.musicalInterests,
            bio: firestoreData.bio,
            location: firestoreData.location,
            friends: firestoreData.friends,
          ),
          await _userRepository.getAuthToken(),
          []));
    }
  }

  Future<AuthState> _mapUserChangedToState(
      AuthUserChanged event, AuthState state) async {
    if (event.user.isNotEmpty) {
      final String authToken = await _userRepository.getAuthToken();
      return (AuthState.authenticated(
          event.user.copyWith(
            pseudo: "",
            birth: null,
            gender: "",
            musicalInterests: [],
            bio: "",
          ),
          authToken,
          []));
    }
    return (const AuthState.unauthenticated());
  }

  Future<AuthState> _getUsersList() async {
    final res = await _userRepository.getUsersList();
    if (res.status == false) {
      AuthState.authenticated(state.user, state.authToken, []);
    }
    return AuthState.authenticated(
        state.user, state.authToken, res.data['users']);
  }

  Future<AuthState> _mapUserLogoutRequested(AuthState state) async {
    await _userRepository.logoutUser();
    return const AuthState.unauthenticated();
  }

  Future<AuthState> _mapUserDataRequested(AuthState state) async {
    final user = _userRepository.currentUser;
    if (user.id.isEmpty) {
      return (state);
    }
    final UserFirestore? firestoreData =
        await _userRepository.getFirestoreUserDataFromId(user.id);
    if (firestoreData == null) return (state);
    return (AuthState.authenticated(
        user.copyWith(
          pseudo: firestoreData.pseudo,
          birth: firestoreData.birth.toDate(),
          gender: firestoreData.gender,
          musicalInterests: firestoreData.musicalInterests,
          bio: firestoreData.bio,
          location: firestoreData.location,
          friends: firestoreData.friends,
        ),
        await _userRepository.getAuthToken(),
        []));
  }

  @override
  Future<void> close() async {
    _userSubscription.cancel();
    return (super.close());
  }
}
