import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:music_room/src/data/model/song.dart';
import 'package:music_room/src/data/repository/playlist_repository.dart';
import 'package:music_room/src/data/repository/room_repository.dart';
import 'package:music_room/src/data/repository/user_repository.dart';
import 'package:music_room/src/data/service/api_service.dart';

part 'search_song_state.dart';

class SearchSongCubit extends Cubit<SearchSongState> {
  //! BUG AJOUT EN BACK SONG
  final PlaylistRepository? _playlistRepository;
  final RoomRepository? _roomRepository;
  SearchSongCubit(
      {PlaylistRepository? playlistRepository, RoomRepository? roomRepository})
      : _playlistRepository = playlistRepository,
        _roomRepository = roomRepository,
        super(SearchSongInitial(''));
  void searchSong(String name, int page) async {
    try {
      if (_roomRepository != null) {
        final ReturnTracks res = await _roomRepository!.searchSongs(name);
        emit(SearchSongFind(
          res.tracks,
        ));
      } else {
        final ReturnTracks res = await _playlistRepository!.searchSongs(name);
        emit(SearchSongFind(
          res.tracks,
        ));
      }
    } catch (e) {
      emit(SearchSongError("Server error, try again."));
    }
  }
}
