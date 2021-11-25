part of 'users_settings_bloc.dart';

@immutable
abstract class UsersSettingsEvent {}

class UpdateInvitationCode extends UsersSettingsEvent {
  final String id;

  UpdateInvitationCode(this.id);
}

class UpdateUserRole extends UsersSettingsEvent {
  final String id;
  final int index;
  final String newRole;

  UpdateUserRole(this.id, this.index, this.newRole);
}
