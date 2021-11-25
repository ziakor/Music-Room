import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:music_room/src/data/model/playlist.dart';
import 'package:music_room/src/data/model/return_repository.dart';
import 'package:music_room/src/data/model/right_license.dart';
import 'package:music_room/src/data/model/room_user.dart';
import 'package:music_room/src/data/model/song.dart';
import 'package:music_room/src/data/repository/playlist_repository.dart';
import 'package:music_room/utils/utils.dart';

part 'playlist_event.dart';
part 'playlist_state.dart';

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final PlaylistRepository _playlistRepository;

  PlaylistBloc({required PlaylistRepository playlistRepository})
      : _playlistRepository = playlistRepository,
        super(PlaylistState());

  @override
  Stream<PlaylistState> mapEventToState(
    PlaylistEvent event,
  ) async* {
    if (event is UpdateListPlaylist) {
      yield (state.copyWith(listPlaylists: await _getPlaylist()));
    } else if (event is UpdateCurrentPlaylist) {
      yield state.copyWith(currentPlaylist: event.playlist);
    } else if (event is UpdateNewPlaylistName) {
      yield state.copyWith(
          newPlaylist: state.newPlaylist.copyWith(name: event.name));
    } else if (event is UpdateNewPlaylistPrivate) {
      yield state.copyWith(
          newPlaylist: state.newPlaylist.copyWith(private: event.private));
    } else if (event is CreateNewPlaylist) {
      yield await _createPlaylist(
          state.newPlaylist, event.idCreator, event.pseudo);
    } else if (event is UpdateInvitationCode) {
      yield await _updateInvitationCode(event.playlistId, event.code);
    } else if (event is EnterPlaylistInvitationCode) {
      yield await _enterInvitation(event.code, event.pseudo);
    } else if (event is ResetPlaylistError) {
      yield state.copyWith(error: "");
    } else if (event is UpdateRightLicenseCurrentPlaylist) {
      yield state.copyWith(
          currentPlaylist:
              state.currentPlaylist.copyWith(rightLicense: event.newLicense));
    } else if (event is JoinPlaylist) {
      yield await _joinPlaylist(event.playlistId, event.pseudo);
    } else if (event is AddUserToCurrentPlaylist) {
      List<RoomUser> t = List.from(state.currentPlaylist.users);
      t.add(event.user);
      yield state.copyWith(
          currentPlaylist: state.currentPlaylist.copyWith(users: t));
    } else if (event is RemoveUserToCurrentPlaylist) {
      List<RoomUser> t = List.from(state.currentPlaylist.users);
      t.removeWhere((element) => element.id == event.userId);
      yield state.copyWith(
          currentPlaylist: state.currentPlaylist.copyWith(users: t));
    } else if (event is AddSongToSongs) {
      List<Song> newList = List.from(state.currentPlaylist.songs);
      newList.add(event.song);
      yield state.copyWith(
          currentPlaylist: state.currentPlaylist.copyWith(
        songs: newList,
      ));
    }
  }

  Future<PlaylistState> _createPlaylist(
      Playlist newPlaylist, String creatorId, String creatorPseudo) async {
    final Playlist createRoomTmp = newPlaylist.copyWith(
      rightLicense: newPlaylist.private
          ? newPlaylist.rightLicense.copyWith(onlyInvitedEnabled: true)
          : newPlaylist.rightLicense,
      invitationCode:
          "${getRandomString(6)}-${getRandomString(4)}-${getRandomString(2)}",
      users: [
        RoomUser(
          id: creatorId,
          pseudo: creatorPseudo,
          role: 'Admin',
          isInvited: false,
        )
      ],
    );

    final res = await _playlistRepository.createPlaylist(createRoomTmp);
    if (res.status == true) {
      return (state.copyWith(
          status: true,
          error: "",
          currentPlaylist: state.newPlaylist.copyWith(id: res.message, users: [
            RoomUser(
              id: creatorId,
              pseudo: creatorPseudo,
              role: 'Admin',
              isInvited: false,
            )
          ]),
          newPlaylist: Playlist.empty));
    }
    return (state.copyWith(
      status: false,
      error: "Server error, try again",
    ));
  }

  Future<List<Playlist>> _getPlaylist() async {
    return (await _playlistRepository.getPlaylist(false));
  }

  Future<PlaylistState> _updateInvitationCode(
      String playlistId, String code) async {
    if (code.isNotEmpty) {
      return (state.copyWith(
          currentPlaylist:
              state.currentPlaylist.copyWith(invitationCode: code)));
    }
    final ReturnRepository res =
        await _playlistRepository.getInvitationCode(playlistId);
    if (res.status == false) {
      return (state.copyWith(error: 'Server error.', status: false));
    }
    return (state.copyWith(
        currentPlaylist: state.currentPlaylist
            .copyWith(invitationCode: res.data['invitationCode'])));
  }

  Future<PlaylistState> _enterInvitation(String code, String pseudo) async {
    if (code.isEmpty) {
      return (state.copyWith(error: "Invalid code.", status: false));
    }
    final ReturnRepository res =
        await _playlistRepository.enterInvitationCode(code, pseudo);
    if (res.status == false) {
      return (state.copyWith(error: res.message, status: false));
    }
    return (state.copyWith(
        status: true,
        currentPlaylist: res.data['playlist'].copyWith(isInvited: true)));
  }

  Future<PlaylistState> _joinPlaylist(String playlistId, String pseudo) async {
    final ReturnRepository res =
        await _playlistRepository.joinPlaylist(playlistId, pseudo);
    if (res.status == false) {
      return (state.copyWith(error: res.message, status: false));
    }
    return (state.copyWith(
        status: true, currentPlaylist: res.data['playlist']));
  }
}
