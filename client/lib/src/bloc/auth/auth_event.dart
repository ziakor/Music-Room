part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthLogoutRequested extends AuthEvent {}

class AuthUserChanged extends AuthEvent {
  final User user;

  AuthUserChanged({required this.user});
}

class AuthUserDataChanged extends AuthEvent {
  final User user;

  AuthUserDataChanged({required this.user});
}

class AuthDataRequested extends AuthEvent {
  AuthDataRequested();
}

class GetUsersList extends AuthEvent {}

class GetAuthToken extends AuthEvent {}

class AddFriend extends AuthEvent {
  final String friendId;

  AddFriend(this.friendId);
}

class RemoveFriend extends AuthEvent {
  final String friendId;

  RemoveFriend(this.friendId);
}

class GetAuthEmail extends AuthEvent {}
