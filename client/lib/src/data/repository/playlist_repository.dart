import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:music_room/src/data/model/playlist.dart';
import 'package:music_room/src/data/model/return_repository.dart';
import 'package:music_room/src/data/service/api_service.dart';
import 'package:music_room/src/data/service/firebase_service.dart';
import 'package:music_room/utils/utils.dart';

class PlaylistRepository {
  final FirebaseService _firebaseService;
  final ApiService _apiService;

  PlaylistRepository(this._firebaseService, this._apiService);

  Future<List<Playlist>> getPlaylist(bool private) async {
    _apiService.sendLog("getPlaylist");
    final List playlist = await _firebaseService.getAllPlaylist(private);
    if (playlist.isNotEmpty) {
      return (List.from(playlist.map((e) => Playlist.fromMap(e))));
    }
    return ([]);
  }

  Future<ReturnRepository> createPlaylist(Playlist playlist) async {
    final User? currentUser = _firebaseService.currentUser();
    _apiService.sendLog("createPlaylist");
    if (currentUser == null) return (ReturnRepository.failed(message: 'Unlog'));
    ;
    Map<String, dynamic> playlistMap = playlist.toMap();
    playlistMap['creatorId'] = currentUser.uid;
    try {
      final id = await _firebaseService.createPlaylist(playlistMap);
      return (ReturnRepository.success(message: id));
    } catch (e) {
      return (ReturnRepository.failed(message: 'Server error, try again.'));
    }
  }

  Future<ReturnRepository> updatePlaylist(
      String idPlaylist, Map<String, dynamic> data, bool merge) async {
    try {
      _apiService.sendLog("updatePlaylist");
      await _firebaseService.updatePlaylist(idPlaylist, data, merge);
      return (ReturnRepository.success());
    } catch (e) {
      return (ReturnRepository.failed(message: e.toString()));
    }
  }

  Future<ReturnRepository> getInvitationCode(String id) async {
    try {
      _apiService.sendLog("getInvitationCode");
      final data = await _firebaseService.getPlaylistData(id);

      if (data == null) {
        return (ReturnRepository.failed(message: 'Server error, try again.'));
      }
      return (ReturnRepository.success(
          data: {'invitationCode': data.invitationCode}));
    } catch (e) {
      return (ReturnRepository.failed(message: e.toString()));
    }
  }

  Future<ReturnRepository> enterInvitationCode(
      String code, String pseudo) async {
    try {
      _apiService.sendLog("enterInvitationCode");
      final String authToken = await _firebaseService.getAuthToken();
      final Playlist? data =
          await _apiService.joinInvitedPlaylist(code, authToken, pseudo);
      if (data == null) {
        return (ReturnRepository.failed(message: 'Invalid invitation code.'));
      }
      return (ReturnRepository.success(data: {'playlist': data}));
    } catch (e) {
      return (ReturnRepository.failed(message: "Server error, try again."));
    }
  }

  Future<ReturnRepository> joinPlaylist(
      String playlistId, String pseudo) async {
    try {
      _apiService.sendLog("joinPlaylist");
      final String authToken = await _firebaseService.getAuthToken();
      final Playlist? data =
          await _apiService.joinPlaylist(playlistId, authToken, pseudo);
      if (data == null) {
        return (ReturnRepository.failed(message: 'Invalid invitation code.'));
      }
      return (ReturnRepository.success(data: {'playlist': data}));
    } catch (e) {
      return (ReturnRepository.failed(message: "Server error, try again."));
    }
  }

  Future<ReturnTracks> searchSongs(String trackName) async {
    _apiService.sendLog("searchSongs");
    return await _apiService.searchSong(
      trackName,
    );
  }
}
