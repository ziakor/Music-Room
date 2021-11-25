part of 'search_song_cubit.dart';

abstract class SearchSongState {
  SearchSongState();
}

class SearchSongInitial extends SearchSongState {
  SearchSongInitial(String name) : super();
}

class SearchSongFind extends SearchSongState {
  final List<Song> list;
  SearchSongFind(
    this.list,
  ) : super();
}

class SearchSongError extends SearchSongState {
  final String error;

  SearchSongError(this.error) : super();
}

class SearchSongLoading extends SearchSongState {}
