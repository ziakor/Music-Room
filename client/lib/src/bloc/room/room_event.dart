part of 'room_bloc.dart';

@immutable
abstract class RoomEvent {}

class UpdateListRooms extends RoomEvent {
  UpdateListRooms();
}

class UpdateCurrentRoom extends RoomEvent {
  final Room room;

  UpdateCurrentRoom(this.room);
}

class UpdateNewRoomName extends RoomEvent {
  final String name;

  UpdateNewRoomName(this.name);
}

class UpdateNewRoomPrivate extends RoomEvent {
  final bool private;

  UpdateNewRoomPrivate(this.private);
}

class CreateNewRoom extends RoomEvent {
  final String creatorId;
  final String creatorPseudo;
  CreateNewRoom(this.creatorId, this.creatorPseudo);
}

class UpdateInvitationCode extends RoomEvent {
  final String roomId;
  final String invitationCode;
  UpdateInvitationCode(this.roomId, {this.invitationCode = ""});
}

class EnterRoomInvitationCode extends RoomEvent {
  final String code;
  final String pseudo;
  EnterRoomInvitationCode(this.code, this.pseudo);
}

class ResetRoomError extends RoomEvent {}

class UpdateOnPlayCurrentSong extends RoomEvent {
  final bool status;
  UpdateOnPlayCurrentSong(this.status);
}

class UpdateTimeCurrentSong extends RoomEvent {
  final Duration time;

  UpdateTimeCurrentSong(this.time);
}

class AddSongToSongs extends RoomEvent {
  final Song song;

  AddSongToSongs(this.song);
}

class UpdateCurrentSong extends RoomEvent {
  final Song song;

  UpdateCurrentSong(this.song);
}

class UpdateVoteSong extends RoomEvent {
  final SongGrade grade;
  final int index;
  final int indexVote;

  UpdateVoteSong(this.grade, this.index, this.indexVote);
}

class UpdateRightLicenseCurrentRoom extends RoomEvent {
  final RightLicense newLicense;

  UpdateRightLicenseCurrentRoom(this.newLicense);
}

class JoinRoom extends RoomEvent {
  final String roomId;
  final String pseudo;
  JoinRoom(this.roomId, this.pseudo);
}

class LeaveRoom extends RoomEvent {}

class AddUserToCurrentRoom extends RoomEvent {
  final RoomUser user;

  AddUserToCurrentRoom(this.user);
}

class RemoveUserToCurrentRoom extends RoomEvent {
  final String userId;

  RemoveUserToCurrentRoom(this.userId);
}

class UpdateUserRole extends RoomEvent {
  final String userId;
  final String role;

  UpdateUserRole(this.userId, this.role);
}
