part of 'playlist_socket_cubit.dart';

abstract class PlaylistSocketState {
  const PlaylistSocketState();
}

class PlaylistSocketInitial extends PlaylistSocketState {}

class LeavePlaylist extends PlaylistSocketState {}

class UserAddedSong extends PlaylistSocketState {
  final Song song;

  UserAddedSong(this.song);
}

class UpdateRightLicense extends PlaylistSocketState {
  final RightLicense rightLicense;

  UpdateRightLicense(this.rightLicense);
}

class UserJoined extends PlaylistSocketState {
  final RoomUser user;

  UserJoined(this.user);
}

class UserLeaved extends PlaylistSocketState {
  final String userId;

  UserLeaved(this.userId);
}
