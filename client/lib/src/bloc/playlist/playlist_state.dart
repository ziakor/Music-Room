part of 'playlist_bloc.dart';

class PlaylistState extends Equatable {
  final List<Playlist> listPlaylists;
  final Playlist currentPlaylist;
  final Playlist newPlaylist;
  final bool status;
  final String error;

  PlaylistState({
    this.listPlaylists = const [],
    this.currentPlaylist = const Playlist(),
    this.newPlaylist = const Playlist(),
    this.error = "",
    this.status = false,
  });

  bool get creationSuccess =>
      newPlaylist.isNotEmpty == true && status == true && error.isEmpty;
  bool get creationFailed =>
      newPlaylist.isNotEmpty == true && status == false && error.isNotEmpty;

  PlaylistState copyWith({
    List<Playlist>? listPlaylists,
    Playlist? currentPlaylist,
    Playlist? newPlaylist,
    bool? status,
    String? error,
  }) {
    return PlaylistState(
      listPlaylists: listPlaylists ?? this.listPlaylists,
      currentPlaylist: currentPlaylist ?? this.currentPlaylist,
      newPlaylist: newPlaylist ?? this.newPlaylist,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [
        listPlaylists,
        currentPlaylist,
        newPlaylist,
        status,
        error,
      ];
}
