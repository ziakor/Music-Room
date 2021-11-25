part of 'right_license_bloc.dart';

class RightLicenseState extends Equatable {
  final bool? onlyInvitedEnabled;
  final bool? locationEnabled;
  final bool? timeEnabled;
  final TimeOfDay? timeRestrictionStart;
  final TimeOfDay? timeRestrictionEnd;
  final LocationResult? locationRestriction;
  final bool status;
  final String error;
  final bool buttonStatus;

  RightLicenseState({
    this.onlyInvitedEnabled = false,
    this.timeRestrictionStart,
    this.timeRestrictionEnd,
    this.locationRestriction,
    this.status = false,
    this.error = "",
    this.buttonStatus = false,
    this.locationEnabled = false,
    this.timeEnabled = false,
  });

  RightLicenseState copyWith({
    bool? onlyInvitedEnabled,
    bool? locationEnabled,
    bool? timeEnabled,
    TimeOfDay? timeRestrictionStart,
    TimeOfDay? timeRestrictionEnd,
    LocationResult? locationRestriction,
    bool? status,
    String? error,
    bool? buttonStatus,
  }) {
    return RightLicenseState(
      onlyInvitedEnabled: onlyInvitedEnabled ?? this.onlyInvitedEnabled,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      timeEnabled: timeEnabled ?? this.timeEnabled,
      timeRestrictionStart: timeRestrictionStart ?? this.timeRestrictionStart,
      timeRestrictionEnd: timeRestrictionEnd ?? this.timeRestrictionEnd,
      locationRestriction: locationRestriction ?? this.locationRestriction,
      status: status ?? this.status,
      error: error ?? this.error,
      buttonStatus: buttonStatus ?? this.buttonStatus,
    );
  }

  @override
  List<Object?> get props => [
        onlyInvitedEnabled,
        locationEnabled,
        timeEnabled,
        timeRestrictionStart,
        timeRestrictionEnd,
        locationRestriction,
        status,
        error,
        buttonStatus,
      ];
}
