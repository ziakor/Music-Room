part of 'room_socket_cubit.dart';

abstract class RoomSocketState {
  const RoomSocketState();
}

class RoomSocketInitial extends RoomSocketState {}

class LeaveRoom extends RoomSocketState {}

class CurrentSongChanged extends RoomSocketState {
  final Song newSong;

  CurrentSongChanged(this.newSong);
}

class CurrentSongStatusChanged extends RoomSocketState {
  final bool status;

  CurrentSongStatusChanged(this.status);
}

class CurrentSongTimeChanged extends RoomSocketState {
  final int time;

  CurrentSongTimeChanged(this.time);
}

class UserAddedSong extends RoomSocketState {
  final Song song;

  UserAddedSong(this.song);
}

class UserVoteSong extends RoomSocketState {
  final int index;
  final int voteIndex;
  final SongGrade grade;

  UserVoteSong(this.index, this.grade, this.voteIndex);
}

class UpdateRightLicense extends RoomSocketState {
  final RightLicense rightLicense;

  UpdateRightLicense(this.rightLicense);
}

class InvitationCodeUpdated extends RoomSocketState {
  final String invitationCode;

  InvitationCodeUpdated(this.invitationCode);
}

class RoleUserUpdated extends RoomSocketState {
  final String role;
  final String userId;

  RoleUserUpdated(this.role, this.userId);
}

class UserJoined extends RoomSocketState {
  final RoomUser user;

  UserJoined(this.user);
}

class UserLeaved extends RoomSocketState {
  final String userId;

  UserLeaved(this.userId);
}
