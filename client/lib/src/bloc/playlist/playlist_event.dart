part of 'playlist_bloc.dart';

@immutable
abstract class PlaylistEvent {}

class UpdateListPlaylist extends PlaylistEvent {}

class UpdateCurrentPlaylist extends PlaylistEvent {
  final Playlist? playlist;
  UpdateCurrentPlaylist(this.playlist);
}

class UpdateNewPlaylistName extends PlaylistEvent {
  final String name;
  UpdateNewPlaylistName(this.name);
}

class UpdateNewPlaylistPrivate extends PlaylistEvent {
  final bool private;

  UpdateNewPlaylistPrivate(this.private);
}

class CreateNewPlaylist extends PlaylistEvent {
  final String pseudo;
  final String idCreator;

  CreateNewPlaylist(this.pseudo, this.idCreator);
}

class ResetNewPlaylsit extends PlaylistEvent {}

class UpdateInvitationCode extends PlaylistEvent {
  final String playlistId;
  final String code;

  UpdateInvitationCode(this.playlistId, this.code);
}

class EnterPlaylistInvitationCode extends PlaylistEvent {
  final String code;
  final String pseudo;
  EnterPlaylistInvitationCode(this.code, this.pseudo);
}

class ResetPlaylistError extends PlaylistEvent {}

class UpdateRightLicenseCurrentPlaylist extends PlaylistEvent {
  final RightLicense newLicense;

  UpdateRightLicenseCurrentPlaylist(this.newLicense);
}

class JoinPlaylist extends PlaylistEvent {
  final String playlistId;
  final String pseudo;
  JoinPlaylist(this.playlistId, this.pseudo);
}

class LeavePlaylist extends PlaylistEvent {}

class AddUserToCurrentPlaylist extends PlaylistEvent {
  final RoomUser user;

  AddUserToCurrentPlaylist(this.user);
}

class RemoveUserToCurrentPlaylist extends PlaylistEvent {
  final String userId;

  RemoveUserToCurrentPlaylist(this.userId);
}

class AddSongToSongs extends PlaylistEvent {
  final Song song;

  AddSongToSongs(this.song);
}
