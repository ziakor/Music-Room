part of 'auth_bloc.dart';

enum AuthStatus {
  authenticated,
  not_authenticated,
}

@immutable
class AuthState extends Equatable {
  final AuthStatus status;
  final User user;
  final String authToken;
  final List<User> users;
  const AuthState._(
      {required this.status,
      this.user = User.empty,
      this.authToken = "",
      this.users = const []});

  const AuthState.authenticated(User user, String authToken, List<User> users)
      : this._(
            status: AuthStatus.authenticated,
            user: user,
            authToken: authToken,
            users: users);

  const AuthState.unauthenticated()
      : this._(status: AuthStatus.not_authenticated);
  @override
  List<Object?> get props => [status, user, users, authToken];
}
