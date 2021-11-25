part of 'users_settings_bloc.dart';

class UsersSettingsState {
  final String invitationCode;
  final List<RoomUser> listUser;
  final bool status;
  final String error;
  UsersSettingsState({
    this.invitationCode = "",
    this.listUser = const [],
    this.status = false,
    this.error = "",
  });

  UsersSettingsState copyWith({
    String? invitationCode,
    List<RoomUser>? listUser,
    bool? status,
    String? error,
  }) {
    return UsersSettingsState(
      invitationCode: invitationCode ?? this.invitationCode,
      listUser: listUser ?? this.listUser,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}
