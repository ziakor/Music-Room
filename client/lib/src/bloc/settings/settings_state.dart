part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final String email;
  final String pseudo;
  final String currentPassword;
  final String newPassword;
  final bool? pseudoAvailable;
  final String bio;
  final String gender;
  final DateTime? birth;
  final List<String>? musicalInterests;
  final bool status;
  final bool buttonStatus;
  final String error;
  final GeoPoint location;

  SettingsState({
    this.email = "",
    this.pseudo = "",
    this.pseudoAvailable,
    this.newPassword = "",
    this.currentPassword = "",
    this.bio = "",
    this.gender = "",
    this.birth,
    this.musicalInterests,
    this.status = false,
    this.buttonStatus = false,
    this.error = "",
    this.location = const GeoPoint(0, 0),
  });

  @override
  List<Object?> get props {
    return [
      email,
      pseudo,
      bio,
      currentPassword,
      newPassword,
      gender,
      birth,
      musicalInterests,
      status,
      pseudoAvailable,
      buttonStatus,
      error,
    ];
  }

  SettingsState copyWith({
    String? email,
    String? pseudo,
    bool? pseudoAvailable,
    String? bio,
    String? currentPassword,
    String? newPassword,
    String? gender,
    DateTime? birth,
    List<String>? musicalInterests,
    bool? status,
    bool? buttonStatus,
    String? error,
    GeoPoint? location,
  }) {
    return SettingsState(
      email: email ?? this.email,
      pseudo: pseudo ?? this.pseudo,
      pseudoAvailable: pseudoAvailable ?? this.pseudoAvailable,
      bio: bio ?? this.bio,
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      gender: gender ?? this.gender,
      birth: birth ?? this.birth,
      musicalInterests: musicalInterests ?? this.musicalInterests,
      status: status ?? this.status,
      buttonStatus: buttonStatus ?? this.buttonStatus,
      error: error ?? this.error,
      location: location ?? this.location,
    );
  }
}
