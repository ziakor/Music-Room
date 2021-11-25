part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {}

class UpdatePseudo extends SettingsEvent {
  final String pseudo;
  UpdatePseudo({required this.pseudo});
}

class UpdateEmail extends SettingsEvent {
  final String email;
  UpdateEmail({required this.email});
}

class UpdateBio extends SettingsEvent {
  final String bio;
  UpdateBio({required this.bio});
}

class UpdateCurrentPassword extends SettingsEvent {
  final String currentPassword;

  UpdateCurrentPassword({required this.currentPassword});
}

class UpdateNewPassword extends SettingsEvent {
  final String newPassword;
  UpdateNewPassword({required this.newPassword});
}

class UpdateLocation extends SettingsEvent {
  LocationResult location;
  UpdateLocation({required this.location});
}

class UpdateGender extends SettingsEvent {
  final String gender;
  UpdateGender({required this.gender});
}

class UpdateBirth extends SettingsEvent {
  final DateTime birth;
  UpdateBirth({required this.birth});
}

class UpdateMusicalInterests extends SettingsEvent {
  final List<String> musicalInterests;

  UpdateMusicalInterests({required this.musicalInterests});
}

class UpdateSendForm extends SettingsEvent {
  UpdateSendForm();
}

class UpdateError extends SettingsEvent {
  final String error;
  UpdateError({required this.error});
}

class LinkToGoogle extends SettingsEvent {}
