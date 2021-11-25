part of 'right_license_bloc.dart';

@immutable
abstract class RightLicenseEvent {}

class RightLicenseUpdateVoteOnlyInvited extends RightLicenseEvent {
  final bool voteOnlyInvitedStatus;

  RightLicenseUpdateVoteOnlyInvited(this.voteOnlyInvitedStatus);
}

class RightLicenseUpdateVoteStartRestriction extends RightLicenseEvent {
  final TimeOfDay startTime;

  RightLicenseUpdateVoteStartRestriction(this.startTime);
}

class RightLicenseUpdateVoteEndRestriction extends RightLicenseEvent {
  final TimeOfDay endTime;

  RightLicenseUpdateVoteEndRestriction(this.endTime);
}

class RightLicenseUpdateLocalisationRestriction extends RightLicenseEvent {
  final LocationResult location;

  RightLicenseUpdateLocalisationRestriction(this.location);
}

class RightLicenseSendUpdate extends RightLicenseEvent {
  final String id;

  RightLicenseSendUpdate(this.id);
}

class RightLicenseResetError extends RightLicenseEvent {}

class RightLicenseUpdateRestrictionVoteLocation extends RightLicenseEvent {
  final bool status;

  RightLicenseUpdateRestrictionVoteLocation(this.status);
}

class RightLicenseUpdateRestrictionVoteTime extends RightLicenseEvent {
  final bool status;

  RightLicenseUpdateRestrictionVoteTime(this.status);
}
